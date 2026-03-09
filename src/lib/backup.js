import { exec } from 'child_process';
import path from 'path';
import fs from 'fs';
import 'dotenv/config';

// Ensure backup directory exists
const BACKUP_DIR = path.resolve(process.cwd(), 'backups');
if (!fs.existsSync(BACKUP_DIR)) {
    fs.mkdirSync(BACKUP_DIR, { recursive: true });
}

export async function performBackup() {
    const date = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = `backup_${date}.sql`;
    const filepath = path.join(BACKUP_DIR, filename);

    console.log(`[Backup] Starting backup to ${filepath}...`);

    // Using DATABASE_URL from env
    const dbUrl = process.env.DATABASE_URL;
    if (!dbUrl) {
        console.error('[Backup] Error: DATABASE_URL not set.');
        return;
    }

    // Command to dump database
    // Note: pg_dump must be installed and in PATH
    const command = `pg_dump "${dbUrl}" -f "${filepath}"`;

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`[Backup] Error: ${error.message}`);
            return;
        }
        if (stderr) {
            // pg_dump writes info messages to stderr sometimes, but we log it just in case
            console.log(`[Backup] Info/Stderr: ${stderr}`);
        }
        console.log(`[Backup] Success! Backup created at ${filepath}`);

        // Cleanup old backups (optional: keep last 7 days)
        cleanupOldBackups();
    });
}

function cleanupOldBackups() {
    try {
        const files = fs.readdirSync(BACKUP_DIR);
        const now = Date.now();
        const MAX_AGE = 7 * 24 * 60 * 60 * 1000; // 7 days

        files.forEach(file => {
            const fp = path.join(BACKUP_DIR, file);
            const stats = fs.statSync(fp);
            if (now - stats.mtimeMs > MAX_AGE) {
                fs.unlinkSync(fp);
                console.log(`[Backup] Deleted old backup: ${file}`);
            }
        });
    } catch (err) {
        console.error('[Backup] Cleanup error:', err);
    }
}
