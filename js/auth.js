// ONE TEAM - Authentication Logic

document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('loginForm');
    
    if (loginForm) {
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const userId = document.getElementById('userId').value.trim();
            const password = document.getElementById('password').value;
            const submitBtn = loginForm.querySelector('button[type="submit"]');
            
            // ボタンを無効化
            submitBtn.disabled = true;
            submitBtn.textContent = 'ログイン中...';
            
            try {
                const user = await SessionManager.login(userId, password);
                
                // ロール判定してリダイレクト
                if (user.role === 'admin') {
                    window.location.href = 'admin.html';
                } else {
                    window.location.href = 'report.html';
                }
            } catch (error) {
                alert(error.message || 'ログインに失敗しました');
                submitBtn.disabled = false;
                submitBtn.textContent = 'LOGIN';
            }
        });
    }
});
