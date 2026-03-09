import { defineMiddleware } from "astro/middleware";

export const onRequest = defineMiddleware(async (context, next) => {
    const { url, cookies, redirect } = context;

    // 1. Security Headers
    const setSecurityHeaders = (response) => {
        response.headers.set("X-Frame-Options", "DENY");
        response.headers.set("X-Content-Type-Options", "nosniff");
        response.headers.set("Referrer-Policy", "strict-origin-when-cross-origin");
        response.headers.set("Permissions-Policy", "geolocation=(), microphone=(), camera=()");
        response.headers.set("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate");
        // Basic CSP - adjust if you use external assets
        response.headers.set("Content-Security-Policy", "default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; script-src 'self' 'unsafe-inline';");
        return response;
    };

    // 2. Auth Protection Logic
    const isLoginPage = url.pathname === "/login";
    const isAuthApi = url.pathname.startsWith("/api/auth");
    const isAsset = url.pathname.startsWith("/_astro") || /\.(ico|png|jpg|jpeg|svg|css|js|woff2?)$/.test(url.pathname);
    const isPublicPath = isLoginPage || isAuthApi || isAsset;

    const isAuthenticated = cookies.get("auth_session")?.value === "authenticated";

    // If not authenticated and trying to access a protected path
    if (!isAuthenticated && !isPublicPath) {
        // If it's an API request, return 401 instead of redirecting
        if (url.pathname.startsWith("/api/")) {
            return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
        }
        return redirect("/login");
    }

    // Continue to the next middleware or the page
    const response = await next();

    // Add security headers to the response
    return setSecurityHeaders(response);
});
