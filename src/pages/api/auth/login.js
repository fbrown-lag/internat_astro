import dotenv from 'dotenv';
import { resolve } from 'node:path';

const rootDir = process.cwd();
const envExamplePath = resolve(rootDir, '.env.example');
const envPath = resolve(rootDir, '.env');
const envLocalPath = resolve(rootDir, '.env.local');

// Load defaults from .env.example first, then allow overrides from .env and .env.local.
dotenv.config({ path: envExamplePath });
dotenv.config({ path: envPath });
dotenv.config({ path: envLocalPath });

const adminPasswordFallback = 'change_this_to_a_strong_password';
const adminPassword = process.env.ADMIN_PASSWORD //|| adminPasswordFallback;

export const POST = async ({ request, cookies }) => {
    try {
        const { password } = await request.json();

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
