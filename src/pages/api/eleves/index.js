import { withTransaction } from '../../../lib/db';

export const POST = async ({ request }) => {
    try {
        const body = await request.json();
        const {
            nom, prenom, genre, classe_id, chambre_id,
            referent_grenoble_id, activite_id, adresse,
            temps_transport, dimanche, dossier_cartone_transmis,
            dossier_complet, urgence_sociale,
            retours_tardifs, repas
        } = body;

        const newEleveId = await withTransaction(async (client) => {
            const queryEleve = `
                INSERT INTO eleves (
                    nom, prenom, genre, classe_id, chambre_id, 
                    referent_grenoble_id, activite_id, adresse, 
                    temps_transport, dimanche, dossier_cartone_transmis, 
                    dossier_complet, urgence_sociale
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
                RETURNING id`;

            const valuesEleve = [
                nom, prenom, genre, classe_id || null, chambre_id || null,
                referent_grenoble_id || null, activite_id || null, adresse,
                temps_transport || null, dimanche || false, dossier_cartone_transmis || false,
                dossier_complet || false, urgence_sociale || false
            ];

            const resEleve = await client.query(queryEleve, valuesEleve);
            const eleveId = resEleve.rows[0].id;

            if (retours_tardifs) {
                await client.query(`
                    INSERT INTO retours_tardifs (
                        eleve_id, lundi_actif, mardi_actif, mercredi_actif, jeudi_actif,
                        heure_lundi, heure_mardi, heure_mercredi, heure_jeudi
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`, [
                    eleveId,
                    retours_tardifs.lundi_actif, retours_tardifs.mardi_actif,
                    retours_tardifs.mercredi_actif, retours_tardifs.jeudi_actif,
                    retours_tardifs.heure_lundi, retours_tardifs.heure_mardi,
                    retours_tardifs.heure_mercredi, retours_tardifs.heure_jeudi
                ]);
            }

            if (repas && repas.length > 0) {
                for (const r of repas) {
                    await client.query(
                        `INSERT INTO repas_prevus (eleve_id, jour_nom, type_repas_prevu) VALUES ($1, $2, $3)`,
                        [eleveId, r.jour, r.type]
                    );
                }
            }

            return eleveId;
        });

        return new Response(JSON.stringify({ message: "Élève créé avec succès", id: newEleveId }), { status: 201 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}
