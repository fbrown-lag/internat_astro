import { pool, withTransaction } from '../../../lib/db';

export const GET = async () => {
    try {
        const result = await pool.query('SELECT * FROM chambres ORDER BY bat, etage, numero');
        return new Response(JSON.stringify(result.rows), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}

export const POST = async ({ request }) => {
    try {
        const { numero, capacite, etage, bat } = await request.json();
        if (!numero || !bat) return new Response(JSON.stringify({ error: "Numéro et Bâtiment obligatoires" }), { status: 400 });

        const result = await withTransaction(async (client) => {
            const res = await client.query(
                `INSERT INTO chambres (numero, capacite, etage, bat, dispo) 
                 VALUES ($1, $2, $3, $4, $2) RETURNING *`,
                [numero, capacite || 0, etage || 0, bat]
            );
            return res.rows[0];
        });

        return new Response(JSON.stringify(result), { status: 201 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}
