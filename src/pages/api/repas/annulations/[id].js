import { pool } from '../../../../lib/db';

export const DELETE = async ({ params }) => {
    try {
        const { id } = params;

        if (!id) {
            return new Response(JSON.stringify({ error: "ID manquant" }), { status: 400 });
        }

        const result = await pool.query('DELETE FROM repas_annulations WHERE id = $1', [id]);

        if (result.rowCount === 0) {
            return new Response(JSON.stringify({ error: "Annulation introuvable" }), { status: 404 });
        }

        return new Response(JSON.stringify({ message: "Supprimé avec succès" }), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}