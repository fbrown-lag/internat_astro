import { defineMiddleware } from 'astro:middleware';
import { initScheduler } from './lib/scheduler';

// Global flag to ensure we only init once per server instance lifecycle
let schedulerInitialized = false;

export const onRequest = defineMiddleware((context, next) => {
    if (!schedulerInitialized) {
        // We only want this to run on the server side
        // In Astro SSR, this middleware runs on server.
        initScheduler();
        schedulerInitialized = true;
    }
    return next();
});
