export const ALL = async ({ cookies, redirect }) => {
    // Thoroughly clear any variations of the auth cookie
    const cookieOptions = { path: '/', httpOnly: true, secure: false, sameSite: 'lax' };
    cookies.delete('auth_session', cookieOptions);
    cookies.delete('auth_session', { ...cookieOptions, sameSite: 'strict' });

    return redirect('/login');
}
