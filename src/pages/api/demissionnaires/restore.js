import { pool, withTransaction } from '../../../lib/db';

export const POST = async ({ request }) => {
    try {
        const body = await request.json();
        const { id } = body;

        if (!id) {
            return new Response(JSON.stringify({ error: "ID manquant" }), { status: 400 });
        }

        const message = await withTransaction(async (client) => {
            // 1. On récupère les données du démissionnaire
            const findEleve = await client.query(
                'SELECT * FROM démissionnaires WHERE id = $1',
                [id]
            );

            if (findEleve.rows.length === 0) {
                const err = new Error("Démissionnaire non trouvé");
                err.status = 404;
                throw err;
            }

            const e = findEleve.rows[0];

            // 2. On le restaure dans la table eleves avec TOUTES ses infos
            await client.query(
                `INSERT INTO eleves (
                    id, nom, prenom, adresse, genre, dimanche, 
                    dossier_complet, urgence_sociale, dossier_cartone_transmis,
                    classe_id, chambre_id, referent_grenoble_id
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
                [
                    e.id, e.nom, e.prenom, e.adresse, e.genre, e.dimanche,
                    e.dossier_complet, e.urgence_sociale, e.dossier_cartone_transmis,
                    e.classe_id, e.chambre_id, e.referent_grenoble_id
                ]
            );

            // 3. Restauration des retours tardifs
            if (e.retours_tardifs_backup) {
                const rt = e.retours_tardifs_backup;
                await client.query(
                    `INSERT INTO retours_tardifs (
                        eleve_id, lundi_actif, mardi_actif, mercredi_actif, jeudi_actif,
                        heure_lundi, heure_mardi, heure_mercredi, heure_jeudi
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
                    [
                        id, rt.lundi_actif, rt.mardi_actif, rt.mercredi_actif, rt.jeudi_actif,
                        rt.heure_lundi, rt.heure_mardi, rt.heure_mercredi, rt.heure_jeudi
                    ]
                );
            }

            // 4. Restauration des repas prévus
            if (e.repas_prevus_backup && Array.isArray(e.repas_prevus_backup)) {
                for (const r of e.repas_prevus_backup) {
                    await client.query(
                        `INSERT INTO repas_prevus (eleve_id, jour_nom, type_repas_prevu) VALUES ($1, $2, $3)`,
                        [id, r.jour_nom, r.type_repas_prevu]
                    );
                }
            }

            // 3. On le supprime de la table démissionnaires
            await client.query('DELETE FROM démissionnaires WHERE id = $1', [id]);

            return "Élève restauré avec succès";
        });

        return new Response(JSON.stringify({ message }), { status: 200 });

    } catch (err) {
        console.error("Erreur API restore:", err.message);
        return new Response(JSON.stringify({ error: err.message }), { status: err.status || 500 });
    }
}
