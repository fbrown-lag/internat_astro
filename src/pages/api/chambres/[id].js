import { withTransaction } from '../../../lib/db';

export const PUT = async ({ params, request }) => {
    const { id } = params;
    try {
        const { numero, capacite, etage, bat } = await request.json();
        if (!numero || !bat) return new Response(JSON.stringify({ error: "Numéro et Bâtiment obligatoires" }), { status: 400 });

        await withTransaction(async (client) => {
            await client.query(
                `UPDATE chambres SET numero = $1, capacite = $2, etage = $3, bat = $4 
                 WHERE id = $5`,
                [numero, capacite || 0, etage || 0, bat, id]
            );
        });
        return new Response(JSON.stringify({ message: "Chambre mise à jour" }), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
};

export const DELETE = async ({ params }) => {
    const { id } = params;
    try {
        await withTransaction(async (client) => {
            // Check if eleves are in this room
            const check = await client.query('SELECT id FROM eleves WHERE chambre_id = $1 LIMIT 1', [id]);
            if (check.rows.length > 0) {
                const error = new Error("Impossible de supprimer : des élèves sont rattachés à cette chambre.");
                error.status = 400;
                throw error;
            }
            await client.query('DELETE FROM chambres WHERE id = $1', [id]);
        });
        return new Response(null, { status: 204 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: err.status || 500 });
    }
};
