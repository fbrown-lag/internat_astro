import { withTransaction } from '../../../lib/db';

export const PUT = async ({ params, request }) => {
    const { id } = params;
    try {
        const { nom, description } = await request.json();
        if (!nom) return new Response(JSON.stringify({ error: "Nom obligatoire" }), { status: 400 });

        await withTransaction(async (client) => {
            await client.query(
                'UPDATE activites SET nom = $1, description = $2 WHERE id = $3',
                [nom, description || '', id]
            );
        });
        return new Response(JSON.stringify({ id, nom }), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
};

export const DELETE = async ({ params }) => {
    const { id } = params;
    try {
        await withTransaction(async (client) => {
            await client.query('DELETE FROM activites WHERE id = $1', [id]);
        });
        return new Response(null, { status: 204 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
};
