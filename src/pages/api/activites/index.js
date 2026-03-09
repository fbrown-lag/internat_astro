import { withTransaction, pool } from '../../../lib/db';

// Simple Levenshtein distance for similarity check
function levenshtein(a, b) {
    const matrix = [];
    for (let i = 0; i <= b.length; i++) matrix[i] = [i];
    for (let j = 0; j <= a.length; j++) matrix[0][j] = j;

    for (let i = 1; i <= b.length; i++) {
        for (let j = 1; j <= a.length; j++) {
            if (b.charAt(i - 1) === a.charAt(j - 1)) {
                matrix[i][j] = matrix[i - 1][j - 1];
            } else {
                matrix[i][j] = Math.min(
                    matrix[i - 1][j - 1] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j] + 1
                );
            }
        }
    }
    return matrix[b.length][a.length];
}

function calculateSimilarity(s1, s2) {
    const longer = s1.length > s2.length ? s1 : s2;
    const shorter = s1.length > s2.length ? s2 : s1;
    if (longer.length === 0) return 1.0;
    return (longer.length - levenshtein(longer.toLowerCase(), shorter.toLowerCase())) / longer.length;
}

export const GET = async () => {
    try {
        const result = await pool.query('SELECT * FROM activites ORDER BY nom');
        return new Response(JSON.stringify(result.rows), { status: 200 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
};

export const POST = async ({ request }) => {
    try {
        const { nom, description } = await request.json();
        if (!nom) return new Response(JSON.stringify({ error: "Nom obligatoire" }), { status: 400 });

        const result = await withTransaction(async (client) => {
            // Check for duplicates with fuzzy matching
            const existing = await client.query('SELECT nom FROM activites');
            for (const row of existing.rows) {
                const similarity = calculateSimilarity(nom, row.nom);
                if (similarity >= 0.9) {
                    const error = new Error(`Activité trop similaire existante : "${row.nom}" (${(similarity * 100).toFixed(1)}%)`);
                    error.status = 409;
                    throw error;
                }
            }

            // Generate ID from name (slug-like)
            const id = nom.toLowerCase()
                .normalize("NFD").replace(/[\u0300-\u036f]/g, "") // remove accents
                .replace(/[^a-z0-9]/g, '-')
                .replace(/-+/g, '-')
                .replace(/^-|-$/g, '');

            await client.query(
                'INSERT INTO activites (id, nom, description) VALUES ($1, $2, $3)',
                [id, nom, description || '']
            );

            return { id, nom };
        });

        return new Response(JSON.stringify(result), { status: 201 });
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: err.status || 500 });
    }
};
