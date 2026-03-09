import { withTransaction, pool } from '../../../lib/db';

export const GET = async () => {
    try {
        const result = await pool.query('SELECT * FROM responsables ORDER BY nom ASC');
        return new Response(JSON.stringify(result.rows), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}

export const POST = async ({ request }) => {
    try {
        const body = await request.json();
        const { nom, prenom, telephone, adresse } = body;

        if (!nom) return new Response(JSON.stringify({ error: "Le nom est obligatoire" }), { status: 400 });

        const result = await withTransaction(async (client) => {
            const res = await client.query(
                'INSERT INTO responsables (nom, prenom, telephone, adresse) VALUES ($1, $2, $3, $4) RETURNING *',
                [nom, prenom, telephone, adresse]
            );
            return res.rows[0];
        });

        return new Response(JSON.stringify(result), { status: 201 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}
