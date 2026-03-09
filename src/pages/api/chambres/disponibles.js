import { pool } from '../../../lib/db';

export const GET = async ({ request }) => {
    const url = new URL(request.url);
    const genre = url.searchParams.get('genre');

    try {
        let conditionBat = "";
        if (genre === 'M') {
            conditionBat = " AND c.bat = 'A' ";
        } else if (genre === 'F') {
            conditionBat = " AND c.bat = 'B' ";
        }

        const query = `
            SELECT 
                c.id, 
                c.numero, 
                c.bat, 
                c.capacite,
                (c.capacite - COUNT(e.id)) AS places_libres
            FROM chambres c
            LEFT JOIN eleves e ON c.id = e.chambre_id
            WHERE 1=1 ${conditionBat}
            GROUP BY c.id
            HAVING (c.capacite - COUNT(e.id)) > 0
            ORDER BY c.bat, c.numero`;

        const result = await pool.query(query);
        return new Response(JSON.stringify(result.rows), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}
