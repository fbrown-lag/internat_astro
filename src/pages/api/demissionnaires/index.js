import { pool } from '../../../lib/db';

export const GET = async () => {
    try {
        const query = 'SELECT * FROM démissionnaires ORDER BY nom ASC, prenom ASC';
        const result = await pool.query(query);
        return new Response(JSON.stringify(result.rows), { status: 200 });
    } catch (err) {
        console.error("Erreur API démissionnaires (GET):", err.message);
        return new Response(JSON.stringify({ error: "Erreur lors du chargement des démissionnaires" }), { status: 500 });
    }
}
