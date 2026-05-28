import pg from 'pg';
import 'dotenv/config';

const { Pool } = pg;

export function getDatabaseUrl() {
    return process.env.POSTGRES_URL || process.env.DATABASE_URL;
}

// Use connectionString from environment variables for better security and flexibility
export const pool = new Pool({
    connectionString: getDatabaseUrl(),
});

/**
 * Helper to run database operations within a transaction.
 * @param {Function} callback - Function receiving the client: (client) => Promise<any>
 */
export async function withTransaction(callback) {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const result = await callback(client);
        await client.query('COMMIT');
        return result;
    } catch (err) {
        await client.query('ROLLBACK');
        throw err;
    } finally {
        client.release();
    }
}
