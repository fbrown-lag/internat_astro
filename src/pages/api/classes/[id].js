import { withTransaction } from '../../../lib/db';

export const PUT = async ({ params, request }) => {
    const { id } = params;
    try {
        const { nom, niveau, prof_principal, cpe_referent } = await request.json();
        if (!nom || !niveau) return new Response(JSON.stringify({ error: "Nom et Niveau obligatoires" }), { status: 400 });

        await withTransaction(async (client) => {
            await client.query(
                `UPDATE classes SET nom = $1, niveau = $2, prof_principal = $3, cpe_referent = $4 
                 WHERE id = $5`,
                [nom, niveau, prof_principal || '', cpe_referent || '', id]
            );
        });
        return new Response(JSON.stringify({ message: "Classe mise à jour" }), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
};

export const DELETE = async ({ params }) => {
    const { id } = params;
    try {
        await withTransaction(async (client) => {
            // Check if eleves are in this class
            const check = await client.query('SELECT id FROM eleves WHERE classe_id = $1 LIMIT 1', [id]);
            if (check.rows.length > 0) {
                const error = new Error("Impossible de supprimer : des élèves sont rattachés à cette classe.");
                error.status = 400;
                throw error;
            }
            await client.query('DELETE FROM classes WHERE id = $1', [id]);
        });
        return new Response(null, { status: 204 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: err.status || 500 });
    }
};
