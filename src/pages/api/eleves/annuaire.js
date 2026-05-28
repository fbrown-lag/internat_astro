import { getDatabaseUrl, pool } from '../../../lib/db';

export const GET = async () => {
    const databaseUrl = getDatabaseUrl();
    if (!databaseUrl) {
        console.error('[api/eleves/annuaire] No database URL configured');
        return new Response(JSON.stringify({ error: "Base de données non configurée" }), {
            status: 503,
            headers: { 'Content-Type': 'application/json' }
        });
    }

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
        return new Response(JSON.stringify(result.rows), {
            status: 200,
            headers: { 'Content-Type': 'application/json' }
        });
    } catch (err) {
        console.error('[api/eleves/annuaire] Failed to load élèves', err);
        return new Response(JSON.stringify({ error: "Erreur lors du chargement de l'annuaire" }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' }
        });
    }
}
