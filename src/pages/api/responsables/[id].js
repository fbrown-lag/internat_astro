import { pool, withTransaction } from '../../../lib/db';

export const GET = async ({ params }) => {
    const { id } = params;
    try {
        const respResult = await pool.query('SELECT * FROM responsables WHERE id = $1', [id]);
        if (respResult.rows.length === 0) return new Response(JSON.stringify({ error: "Responsable non trouvé" }), { status: 404 });

        const responsable = respResult.rows[0];
        const elevesResult = await pool.query('SELECT nom, prenom, classe_id FROM eleves WHERE referent_grenoble_id = $1', [id]);
        responsable.eleves = elevesResult.rows;

        return new Response(JSON.stringify(responsable), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}

export const PUT = async ({ params, request }) => {
    const { id } = params;
    const body = await request.json();
    const { nom, prenom, telephone, adresse } = body;

    try {
        await withTransaction(async (client) => {
            await client.query(
                'UPDATE responsables SET nom=$1, prenom=$2, telephone=$3, adresse=$4 WHERE id=$5',
                [nom, prenom, telephone, adresse, id]
            );
        });
        return new Response(JSON.stringify({ message: "Mise à jour réussie" }), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}

export const DELETE = async ({ params }) => {
    const { id } = params;
    try {
        const message = await withTransaction(async (client) => {
            const checkEleves = await client.query('SELECT id FROM eleves WHERE referent_grenoble_id = $1', [id]);
            if (checkEleves.rows.length > 0) {
                const error = new Error("Impossible de supprimer : des élèves sont rattachés à ce responsable.");
                error.status = 400;
                throw error;
            }

            await client.query('DELETE FROM responsables WHERE id = $1', [id]);
            return "Responsable supprimé avec succès";
        });
        return new Response(JSON.stringify({ message }), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: err.status || 500 });
    }
}
