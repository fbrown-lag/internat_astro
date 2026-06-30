import { pool } from './src/lib/db.js';
import fs from 'fs';
import path from 'path';

async function resetDB() {
    const scripts = [
        '../BD/01_Schema.sql',
        '../BD/02_Insert_Data.sql',
        '../BD/03_Views_DB.sql',
        '../BD/04_Function.sql'
    ];

    try {
        console.log("Cleaning public schema...");
        //await pool.query("DROP SCHEMA public CASCADE; CREATE SCHEMA public;");
        //await pool.query("GRANT ALL ON SCHEMA public TO public;");
        await pool.query("CREATE SCHEMA IF NOT EXISTS public;");

        for (const scriptPath of scripts) {
            const absolutePath = path.resolve(process.cwd(), scriptPath);
            if (fs.existsSync(absolutePath)) {
                console.log(`Executing: ${scriptPath}`);
                const sql = fs.readFileSync(absolutePath, 'utf8');
                await pool.query(sql);
            } else {
                console.warn(`File not found: ${absolutePath}`);
            }
        }
        console.log("Database reset finished.");
        process.exit(0);
    } catch (err) {
        console.error("Error during reset:", err);
        process.exit(1);
    }
}

resetDB();
