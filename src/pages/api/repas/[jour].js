import { pool } from '../../../lib/db.js';

export const GET = async ({ params }) => {
    const { jour } = params;
    const joursValides = ['lundi', 'mardi', 'mercredi', 'jeudi'];

    if (!jour || !joursValides.includes(jour.toLowerCase())) {
        return new Response(JSON.stringify({ error: "Jour invalide" }), { status: 400 });
    }

    try {
        // 1. Get Regular Meals (from View)
        const queryRegular = `SELECT * FROM v_repas_${jour.toLowerCase()} ORDER BY nom, prenom`;
        const resultRegular = await pool.query(queryRegular);
        let repas = resultRegular.rows;

        // 2. Calculate Target Date for this [jour]
        // Logic must match PostgreSQL view: Next occurrence of [jour] (or today)
        const daysMap = { 'dimanche': 0, 'lundi': 1, 'mardi': 2, 'mercredi': 3, 'jeudi': 4, 'vendredi': 5, 'samedi': 6 };
        const targetDayIndex = daysMap[jour.toLowerCase()];

        const today = new Date();
        const currentDayIndex = today.getDay();

        let diff = (targetDayIndex - currentDayIndex + 7) % 7;
        // Strict match with View logic: if today is the day, diff is 0.

        const targetDate = new Date(today);
        targetDate.setDate(today.getDate() + diff);
        const targetDateStr = targetDate.toISOString().split('T')[0];

        // 3. Get ALL Exceptions/Modifications for this day (Regulars AND Additions)
        // We do typically filter exclusions if needed, but here we want positive actions or cancellations.
        const queryExceptions = `
            SELECT 
                e.id AS eleve_id, e.nom, e.prenom, c.nom AS classe, ch.numero AS numero_chambre, 
                '18:00' AS heure_retour,
                ra.repas_force AS repas_final,
                TRUE AS a_modification,
                ra.id AS annulation_id,
                ra.repas_force
            FROM repas_annulations ra
            JOIN eleves e ON ra.eleve_id = e.id
            LEFT JOIN classes c ON e.classe_id = c.id
            LEFT JOIN chambres ch ON e.chambre_id = ch.id
            WHERE ra.est_traite = FALSE
            AND (
                (ra.mode = 'jour' AND ra.jour_cible = $1) OR 
                (ra.mode = 'periode' AND $2::date BETWEEN ra.date_debut AND ra.date_fin) OR 
                (ra.mode = 'hybride' AND ra.jour_cible = $1 AND $2::date BETWEEN ra.date_debut AND ra.date_fin)
            )
        `;

        const resultExceptions = await pool.query(queryExceptions, [jour.toLowerCase(), targetDateStr]);
        const exceptions = resultExceptions.rows;

        // 4. Merge Logic
        // Map regulars by ID for easy lookup
        const repasMap = new Map();
        repas.forEach(r => repasMap.set(r.id, r));

        // Process exceptions
        exceptions.forEach(ex => {
            if (repasMap.has(ex.eleve_id)) {
                // Update existing regular student
                const existing = repasMap.get(ex.eleve_id);
                existing.a_modification = true;
                existing.annulation_id = ex.annulation_id;
                existing.repas_force = ex.repas_force;

                // If specific meal forced, override repas_final
                // If repas_force is 'None', repas_final becomes 'None' (Cancellation)
                existing.repas_final = ex.repas_force;
            } else {
                // Add new student (Addition) ONLY if they have a forced meal (not None)
                if (ex.repas_force && ex.repas_force !== 'None') {
                    // Match the structure of regular items
                    const newItem = {
                        id: ex.eleve_id, // Important: use eleve_id as id for frontend keys if needed, or maintain consistency
                        ...ex,
                        // Ensure ID field consistency: view uses 'id' for eleve_id? 
                        // View definition: "SELECT e.id ..." -> So yes, 'id' is eleve_id.
                        id: ex.eleve_id
                    };
                    repas.push(newItem);
                }
            }
        });

        // Sort again by name
        repas.sort((a, b) => a.nom.localeCompare(b.nom));

        return new Response(JSON.stringify(repas), {
            status: 200,
            headers: { "Content-Type": "application/json" }
        });
    } catch (err) {
        console.error(err);
        return new Response(JSON.stringify({ error: "Erreur lors de la récupération des repas" }), {
            status: 500
        });
    }
}

export function getStaticPaths() {
    return [
        { params: { jour: 'lundi' } },
        { params: { jour: 'mardi' } },
        { params: { jour: 'mercredi' } },
        { params: { jour: 'jeudi' } },
    ];
}
