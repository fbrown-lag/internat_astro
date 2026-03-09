import { pool, withTransaction } from '../../../lib/db';

export const GET = async () => {
    try {
        const result = await pool.query('SELECT * FROM classes ORDER BY nom');
        return new Response(JSON.stringify(result.rows), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}

export const POST = async ({ request }) => {
    try {
        const { nom, niveau, prof_principal, cpe_referent } = await request.json();
        if (!nom || !niveau) return new Response(JSON.stringify({ error: "Nom et Niveau obligatoires" }), { status: 400 });

        const result = await withTransaction(async (client) => {
            const res = await client.query(
                `INSERT INTO classes (nom, niveau, prof_principal, cpe_referent) 
                 VALUES ($1, $2, $3, $4) RETURNING *`,
                [nom, niveau, prof_principal || '', cpe_referent || '']
            );
            return res.rows[0];
        });

        return new Response(JSON.stringify(result), { status: 201 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}
