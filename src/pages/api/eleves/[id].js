import { pool, withTransaction } from '../../../lib/db';

export const GET = async ({ params }) => {
    const { id } = params;
    try {
        const query = `
            SELECT 
                e.*, 
                c.nom AS classe, 
                ch.numero || ' (' || ch.bat || ')' AS chambre,
                r.nom || ' ' || r.prenom AS referent_nom_complet,
                r.telephone AS referent_tel,
                rt.lundi_actif, rt.heure_lundi,
                rt.mardi_actif, rt.heure_mardi,
                rt.mercredi_actif, rt.heure_mercredi,
                rt.jeudi_actif, rt.heure_jeudi
            FROM eleves e
            LEFT JOIN classes c ON e.classe_id = c.id
            LEFT JOIN chambres ch ON e.chambre_id = ch.id
            LEFT JOIN responsables r ON e.referent_grenoble_id = r.id
            LEFT JOIN retours_tardifs rt ON e.id = rt.eleve_id
            WHERE e.id = $1`;

        const result = await pool.query(query, [id]);
        if (result.rows.length === 0) return new Response(JSON.stringify({ error: "Élève non trouvé" }), { status: 404 });

        const eleve = result.rows[0];

        // Récupération des repas détaillés
        const repas = await pool.query(
            'SELECT jour_nom, type_repas_prevu FROM repas_prevus WHERE eleve_id = $1', [id]
        );
        eleve.repas_details = repas.rows;

        return new Response(JSON.stringify(eleve), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}

export const DELETE = async ({ params }) => {
    const { id } = params;

    try {
        const message = await withTransaction(async (client) => {
            // 1. On récupère les données de l'élève avant suppression
            const findEleve = await client.query(
                'SELECT * FROM eleves WHERE id = $1',
                [id]
            );

            if (findEleve.rows.length === 0) {
                const err = new Error("Élève non trouvé");
                err.status = 404;
                throw err;
            }

            const e = findEleve.rows[0];

            // 1b. Récupération des données liées pour le backup
            const retoursTardifs = await client.query(
                'SELECT * FROM retours_tardifs WHERE eleve_id = $1',
                [id]
            );
            const repasPrevus = await client.query(
                'SELECT * FROM repas_prevus WHERE eleve_id = $1',
                [id]
            );

            // 2. On l'insère dans la table démissionnaires avec TOUTES ses infos ET le backup
            await client.query(
                `INSERT INTO démissionnaires (
                    id, nom, prenom, adresse, genre, dimanche, 
                    dossier_complet, urgence_sociale, dossier_cartone_transmis,
                    classe_id, chambre_id, referent_grenoble_id,
                    retours_tardifs_backup, repas_prevus_backup
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)`,
                [
                    e.id, e.nom, e.prenom, e.adresse, e.genre, e.dimanche,
                    e.dossier_complet, e.urgence_sociale, e.dossier_cartone_transmis,
                    e.classe_id, e.chambre_id, e.referent_grenoble_id,
                    JSON.stringify(retoursTardifs.rows[0] || null),
                    JSON.stringify(repasPrevus.rows)
                ]
            );

            // 3. On le supprime de la table eleves
            await client.query('DELETE FROM eleves WHERE id = $1', [id]);

            return "Élève déplacé vers les démissionnaires avec succès";
        });

        return new Response(JSON.stringify({ message }), { status: 200 });

    } catch (err) {
        console.error("Erreur lors de la suppression/démission:", err.message);
        return new Response(JSON.stringify({ error: err.message }), { status: err.status || 500 });
    }
}

export const PUT = async ({ params, request }) => {
    const { id } = params;
    const body = await request.json();

    try {
        await withTransaction(async (client) => {
            await client.query(`
                UPDATE eleves SET 
                nom=$1, prenom=$2, genre=$3, adresse=$4, dimanche=$5, 
                dossier_complet=$6, urgence_sociale=$7, dossier_cartone_transmis=$8,
                classe_id=$9, chambre_id=$10, referent_grenoble_id=$11
                WHERE id=$12`,
                [body.nom, body.prenom, body.genre, body.adresse,
                body.dimanche, body.dossier_complet, body.urgence_sociale,
                body.dossier_cartone_transmis, body.classe_id, body.chambre_id,
                body.referent_grenoble_id, id]
            );

            const rt = body.retours_tardifs;
            if (rt) {
                await client.query(`
                    UPDATE retours_tardifs SET
                    lundi_actif=$1, heure_lundi=$2, mardi_actif=$3, heure_mardi=$4,
                    mercredi_actif=$5, heure_mercredi=$6, jeudi_actif=$7, heure_jeudi=$8
                    WHERE eleve_id=$9`,
                    [rt.lundi_actif, rt.heure_lundi, rt.mardi_actif, rt.heure_mardi,
                    rt.mercredi_actif, rt.heure_mercredi, rt.jeudi_actif, rt.heure_jeudi, id]
                );
            }

            await client.query('DELETE FROM repas_prevus WHERE eleve_id = $1', [id]);
            if (body.repas && body.repas.length > 0) {
                for (const r of body.repas) {
                    await client.query(
                        'INSERT INTO repas_prevus (eleve_id, jour_nom, type_repas_prevu) VALUES ($1, $2, $3)',
                        [id, r.jour, r.type]
                    );
                }
            }
        });

        return new Response(JSON.stringify({ message: "Mise à jour réussie" }), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}
