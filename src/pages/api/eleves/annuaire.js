import { pool } from '../../../lib/db';

export const GET = async () => {
    try {
        const query = `
            SELECT 
                e.id, 
                e.nom, 
                e.prenom, 
                e.genre, 
                c.nom AS classe, 
                ch.numero || ' (' || ch.bat || ')' AS chambre,
                e.referent_grenoble_id,
                r.nom || ' ' || r.prenom AS referent_grenoble,
                e.dimanche, 
                e.dossier_complet,
                e.urgence_sociale
            FROM eleves e
            LEFT JOIN classes c ON e.classe_id = c.id
            LEFT JOIN chambres ch ON e.chambre_id = ch.id
            LEFT JOIN responsables r ON e.referent_grenoble_id = r.id
            ORDER BY e.nom ASC, e.prenom ASC`;

        const result = await pool.query(query);
        return new Response(JSON.stringify(result.rows), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: "Erreur lors du chargement de l'annuaire" }), { status: 500 });
    }
}
