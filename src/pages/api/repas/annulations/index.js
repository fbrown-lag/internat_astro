import { withTransaction, pool } from '../../../../lib/db';

// GET : Liste toutes les annulations (pour annulations.astro)
export const GET = async () => {
    try {
        const query = `
            SELECT 
                a.id, 
                a.eleve_id, 
                a.mode, 
                a.jour_cible as jour, 
                a.date_debut, 
                a.date_fin, 
                a.repas_force,
                e.nom, 
                e.prenom, 
                c.nom as classe -- On récupère le nom depuis la table classes
            FROM repas_annulations a
            JOIN eleves e ON a.eleve_id = e.id
            LEFT JOIN classes c ON e.classe_id = c.id -- Jointure nécessaire ici
            ORDER BY a.date_debut DESC;`;
        const result = await pool.query(query);
        return new Response(JSON.stringify(result.rows), { status: 200 });
    } catch (err) {
        console.error("Erreur SQL détaillée:", err.message); // Pour voir l'erreur dans ton terminal
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}

// POST : Crée une annulation ou un repas forcé (pour repas.astro)
export const POST = async ({ request }) => {
    try {
        const body = await request.json();
        let { eleve_id, mode, jour_cible, date_debut, date_fin, repas_force } = body;

        // Logique de calcul de date si mode 'jour'
        if (mode === 'jour' && jour_cible) {
            const joursMap = { 'dimanche': 0, 'lundi': 1, 'mardi': 2, 'mercredi': 3, 'jeudi': 4, 'vendredi': 5, 'samedi': 6 };
            const cible = joursMap[jour_cible.toLowerCase()];
            const d = new Date();
            let diff = (cible - d.getDay() + 7) % 7;
            if (diff === 0) diff = 7;
            d.setDate(d.getDate() + diff);
            date_debut = d.toISOString().split('T')[0];
            date_fin = date_debut;
        }

        const result = await withTransaction(async (client) => {
            return (await client.query(
                `INSERT INTO repas_annulations (eleve_id, mode, jour_cible, date_debut, date_fin, repas_force)
                 VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
                [eleve_id, mode, jour_cible, date_debut, date_fin, repas_force || 'None']
            )).rows[0];
        });
        return new Response(JSON.stringify(result), { status: 201 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}