import { defineMiddleware } from 'astro:middleware';
import { initScheduler } from './lib/scheduler';

// Global flag to ensure we only init once per server instance lifecycle
let schedulerInitialized = false;

export const onRequest = defineMiddleware(async (context, next) => {
    const { url, cookies, redirect } = context;

    if (!schedulerInitialized) {
        // We only want this to run on the server side
        // In Astro SSR, this middleware runs on server.
        initScheduler();
        schedulerInitialized = true;
    }

    const isLoginPage = url.pathname === '/login';
    const isAuthApi = url.pathname.startsWith('/api/auth');
    const isAsset = url.pathname.startsWith('/_astro') || /\.(ico|png|jpg|jpeg|svg|css|js|woff2?)$/.test(url.pathname);
    const isPublicPath = isLoginPage || isAuthApi || isAsset;

    const isAuthenticated = cookies.get('auth_session')?.value === 'authenticated';

    if (isAuthenticated && isLoginPage) {
        return redirect('/');
    }

    if (!isAuthenticated && !isPublicPath) {
        if (url.pathname.startsWith('/api/')) {
            return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
        }
        return redirect('/login');
    }

    const response = await next();
    response.headers.set('X-Frame-Options', 'DENY');
    response.headers.set('X-Content-Type-Options', 'nosniff');
    response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
    response.headers.set('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
    response.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    response.headers.set('Content-Security-Policy', "default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; script-src 'self' 'unsafe-inline';");

    return response;
});
