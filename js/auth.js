// ONE TEAM - Authentication Logic
// Supabase integration will be added here

document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');
    
    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const userId = document.getElementById('userId').value;
            const password = document.getElementById('password').value;
            
            // TODO: Supabase authentication
            console.log('Login attempt:', { userId, password });
            
            // Temporary: Redirect to report page
            alert('ログイン機能は準備中です\nSupabase設定後に有効化されます');
            // window.location.href = 'report.html';
        });
    }
});
