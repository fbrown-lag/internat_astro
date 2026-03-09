import { pool } from '../../../lib/db';

export const GET = async () => {
    try {
        const query = `
            SELECT 
                c.id AS chambre_id, 
                c.numero, 
                c.bat, 
                c.etage, 
                c.capacite,
                e.id AS eleve_id,
                e.nom,
                e.prenom,
                e.dimanche,
                e.activite_id,
                cl.nom AS classe_nom
            FROM chambres c
            LEFT JOIN eleves e ON c.id = e.chambre_id
            LEFT JOIN classes cl ON e.classe_id = cl.id
            ORDER BY c.bat, c.etage, c.numero, e.nom;
        `;
        const result = await pool.query(query);
        return new Response(JSON.stringify(result.rows), {
            status: 200,
            headers: {
                "Content-Type": "application/json"
            }
        });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500,
            headers: {
                "Content-Type": "application/json"
            }
        });
    }
}
