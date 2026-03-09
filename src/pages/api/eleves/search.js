import { pool } from '../../../lib/db';

export const GET = async ({ request }) => {
    const url = new URL(request.url);
    const term = url.searchParams.get('term');

    if (!term) return new Response(JSON.stringify([]), { status: 200 });

    try {
        const query = `
            SELECT 
                e.id, e.nom, e.prenom, e.genre, c.nom AS classe, 
                ch.numero || ' (' || ch.bat || ')' AS chambre,
                e.referent_grenoble_id,
                r.nom || ' ' || r.prenom AS referent_grenoble,
                e.dimanche, e.dossier_complet
            FROM eleves e 
            LEFT JOIN classes c ON e.classe_id = c.id 
            LEFT JOIN chambres ch ON e.chambre_id = ch.id
            LEFT JOIN responsables r ON e.referent_grenoble_id = r.id
            WHERE e.nom ILIKE $1 OR e.prenom ILIKE $1
            ORDER BY e.nom ASC`;

        const result = await pool.query(query, [`%${term}%`]);
        return new Response(JSON.stringify(result.rows), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}
