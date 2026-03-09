import cron from 'node-cron';
import { performBackup } from './backup.js';

let isScheduled = false;

export function initScheduler() {
    if (isScheduled) {
        console.log('[Scheduler] Already initialized.');
        return;
    }

    console.log('[Scheduler] Initializing daily backup task...');

    // Schedule task to run at 03:00 AM every day
    // Cron format: Minute Hour DayOfMonth Month DayOfWeek
    // '0 3 * * *' = 03:00 daily
    cron.schedule('0 3 * * *', () => {
        console.log('[Scheduler] Triggering scheduled backup...');
        performBackup();
    });

    // Also run one immediately on start? checking env? 
    // No, user just asked for every 24h.
    // However, for verification, I might expose a function to verify it works.

    isScheduled = true;
    console.log('[Scheduler] Daily backup scheduled for 03:00 AM.');
}
