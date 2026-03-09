import { withTransaction } from '../../../lib/db';



export const POST = async ({ request }) => {
    try {
        const text = await request.text();
        const lines = text.split(/\r?\n/).filter(l => l.trim() !== '');

        // Basic CSV Parser
        const separator = ';';
        const headers = lines[0].split(separator).map(h => h.trim().toUpperCase());

        // Validate Headers
        const required = ['NOM', 'PRENOM', 'GENRE', 'CLASSE', 'CHAMBRE'];
        const missing = required.filter(r => !headers.includes(r));
        if (missing.length > 0) {
            return new Response(JSON.stringify({ error: `Colonnes manquantes: ${missing.join(', ')}` }), { status: 400 });
        }

        const dataRows = lines.slice(1);
        let createdCount = 0;
        let errors = [];

        for (let i = 0; i < dataRows.length; i++) {
            const rowRaw = dataRows[i].split(separator);
            if (rowRaw.length < required.length) continue;

            const row = {};
            headers.forEach((h, index) => {
                row[h] = rowRaw[index]?.trim() || '';
            });

            if (!row['NOM'] || !row['PRENOM']) continue;

            try {
                await withTransaction(async (client) => {
                    // 0. Check for Duplicates
                    const resExist = await client.query("SELECT id FROM eleves WHERE nom = $1 AND prenom = $2", [row['NOM'], row['PRENOM']]);
                    if (resExist.rows.length > 0) {
                        throw new Error("Doublon - Élève déjà existant");
                    }

                    // 1. Resolve Class
                    let classeId = null;
                    if (row['CLASSE']) {
                        const resClasse = await client.query("SELECT id FROM classes WHERE nom = $1", [row['CLASSE']]);
                        if (resClasse.rows.length > 0) {
                            classeId = resClasse.rows[0].id;
                        } else {
                            // Create Class if not exists
                            // Infer simple level from name
                            let niveau = 'Autre';
                            const upperNom = row['CLASSE'].toUpperCase();
                            if (upperNom.startsWith('2ND')) niveau = 'Seconde';
                            else if (upperNom.startsWith('1ER')) niveau = 'Premiere';
                            else if (upperNom.startsWith('TER')) niveau = 'Terminale';
                            else if (upperNom.startsWith('CPGE')) niveau = 'CPGE';
                            else if (upperNom.startsWith('BTS')) niveau = 'BTS1'; // Defaulting to BTS1 for generic BTS

                            const newClasse = await client.query("INSERT INTO classes (nom, niveau) VALUES ($1, $2) RETURNING id", [row['CLASSE'], niveau]);
                            classeId = newClasse.rows[0].id;
                        }
                    }

                    // 2. Resolve Room
                    let chambreId = null;
                    if (row['CHAMBRE']) {
                        const resChambre = await client.query("SELECT id FROM chambres WHERE numero = $1 LIMIT 1", [row['CHAMBRE']]);
                        if (resChambre.rows.length > 0) {
                            chambreId = resChambre.rows[0].id;
                        }
                    }

                    // 3. Resolve Responsable
                    let respId = null;
                    if (row['RESPONSABLE']) {
                        const parts = row['RESPONSABLE'].split(' ');
                        const rNom = parts[0];
                        const rPrenom = parts.slice(1).join(' ') || '';

                        const resResp = await client.query("SELECT id FROM responsables WHERE nom = $1 AND prenom = $2", [rNom, rPrenom]);
                        if (resResp.rows.length > 0) {
                            respId = resResp.rows[0].id;
                        } else {
                            const newResp = await client.query("INSERT INTO responsables (nom, prenom) VALUES ($1, $2) RETURNING id", [rNom, rPrenom]);
                            respId = newResp.rows[0].id;
                        }
                    }

                    // 4. Resolve Activite
                    let actId = null;
                    if (row['ACTIVITE']) {
                        const actName = row['ACTIVITE'].trim();
                        // Check if exists by name
                        const resAct = await client.query("SELECT id FROM activites WHERE nom = $1", [actName]);
                        if (resAct.rows.length > 0) {
                            actId = resAct.rows[0].id;
                        } else {
                            // Generate ID: First 4 chars + Random suffix to ensure uniqueness or just slug
                            // Existing seed data uses simple 4-char codes like 'FOOT'.
                            // Let's create a code based on name.
                            let newId = actName.substring(0, 4).toUpperCase().replace(/[^A-Z0-9]/g, '');
                            if (newId.length < 2) newId = 'ACT' + Math.floor(Math.random() * 1000);

                            // Ensure uniqueness (simple retry or check)
                            // Ideally check if this ID exists
                            const existingId = await client.query("SELECT id FROM activites WHERE id = $1", [newId]);
                            if (existingId.rows.length > 0) {
                                newId = newId + '_' + Math.floor(Math.random() * 1000);
                            }

                            const newAct = await client.query("INSERT INTO activites (id, nom) VALUES ($1, $2) RETURNING id", [newId, actName]);
                            actId = newAct.rows[0].id;
                        }
                    }

                    // 5. Booleans
                    const isTrue = (val) => ['OUI', 'TRUE', '1', 'YES', 'VRAI'].includes(val?.toUpperCase());

                    // 6. Insert Student
                    await client.query(`
                        INSERT INTO eleves (
                            nom, prenom, genre, classe_id, chambre_id, 
                            referent_grenoble_id, activite_id, adresse,
                            temps_transport, dimanche, dossier_cartone_transmis,
                            dossier_complet, urgence_sociale
                        )
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
                    `, [
                        row['NOM'], row['PRENOM'], row['GENRE'], classeId, chambreId,
                        respId, actId, row['ADRESSE'] || null,
                        row['TEMPS_TRANSPORT'] || null, isTrue(row['DIMANCHE']), isTrue(row['DOSSIER_CARTONE']),
                        isTrue(row['DOSSIER_COMPLET']), isTrue(row['URGENCE_SOCIALE'])
                    ]);
                });

                createdCount++;

            } catch (rowErr) {
                console.error(`Error row ${i + 2}:`, rowErr);
                errors.push(`Ligne ${i + 2} (${row['NOM']}): ${rowErr.message}`);
            }
        }

        return new Response(JSON.stringify({
            message: `${createdCount} élèves importés.`,
            errors: errors.length > 0 ? errors : undefined
        }), { status: 201 });

    } catch (err) {
        console.error(err);
        return new Response(JSON.stringify({ error: "Erreur serveur lors de l'import" }), { status: 500 });
    }
}
