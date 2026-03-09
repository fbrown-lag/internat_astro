import 'dotenv/config';

export const POST = async ({ request, cookies }) => {
    try {
        const { password } = await request.json();
        const adminPassword = process.env.ADMIN_PASSWORD;

        if (password && password === adminPassword) {
            // Set an auth cookie
            cookies.set('auth_session', 'authenticated', {
                path: '/',
                httpOnly: true,
                secure: false, // Local dev
                sameSite: 'lax',
                maxAge: 60 * 60 * 24
            });
            return new Response(JSON.stringify({ message: "Login success" }), { status: 200 });
        } else {
            return new Response(JSON.stringify({ error: "Invalid password" }), { status: 401 });
        }
    } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
}
