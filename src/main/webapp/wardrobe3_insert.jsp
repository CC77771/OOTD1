<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    // 取得當前登入的會員ID (請根據你的登入系統調整)
    String memberId = (String)session.getAttribute("memberId");
    if(memberId == null) {
        memberId = "1"; // 預設值
    }
%>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>新增衣物</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft JhengHei', 'Arial', sans-serif; background: #fafbfc; min-height: 100vh; padding: 40px 20px; }
        
        .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 24px; padding: 40px; box-shadow: 0 4px 24px rgba(0, 0, 0, 0.1); }
        .page-title { font-size: 28px; font-weight: 700; color: #2c3e50; margin-bottom: 32px; text-align: center; }
        
        .modal-content { background: white; }
        .modal-header { font-size: 26px; font-weight: 700; margin-bottom: 28px; display: flex; justify-content: space-between; align-items: center; color: #2c3e50; letter-spacing: 0.5px; }
        
        .form-group { margin-bottom: 24px; }
        .form-label { display: block; margin-bottom: 10px; font-weight: 700; color: #555; font-size: 14px; letter-spacing: 0.5px; }
        .form-input, .form-select { width: 100%; padding: 14px 16px; border: 2px solid #e8e8e8; border-radius: 12px; font-size: 15px; transition: all 0.3s ease; font-family: 'Microsoft JhengHei', 'Arial', sans-serif; }
        .form-input:focus, .form-select:focus { outline: none; border-color: #c4b5a0; box-shadow: 0 0 0 4px rgba(196, 181, 160, 0.1); }
        
        .preview-image { width: 100%; max-height: 320px; object-fit: contain; border-radius: 16px; margin-bottom: 20px; border: 2px solid #f0f0f0; box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08); display: none; }
        .change-image-btn { width: 100%; padding: 16px; background: linear-gradient(135deg, #fafafa 0%, #f5f5f5 100%); border: 3px dashed #d8d8d8; border-radius: 14px; cursor: pointer; text-align: center; color: #777; transition: all 0.3s ease; font-weight: 600; letter-spacing: 0.5px; font-size: 15px; display: block; }
        .change-image-btn:hover { background: linear-gradient(135deg, #f0ebe6 0%, #e8e3dd 100%); border-color: #c4b5a0; color: #555; }
        
        .form-actions { display: flex; gap: 12px; margin-top: 32px; }
        .btn-primary { flex: 1; padding: 16px; background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%); color: white; border: none; border-radius: 14px; cursor: pointer; font-size: 16px; font-weight: 700; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); letter-spacing: 0.5px; box-shadow: 0 4px 16px rgba(168, 159, 145, 0.35); }
        .btn-primary:hover { background: linear-gradient(135deg, #a89f91 0%, #9a8e7e 100%); transform: translateY(-2px); box-shadow: 0 6px 20px rgba(168, 159, 145, 0.45); }
        .btn-secondary { flex: 1; padding: 16px; background: linear-gradient(135deg, #e8e8e8 0%, #d8d8d8 100%); color: #555; border: none; border-radius: 14px; cursor: pointer; font-size: 16px; font-weight: 600; transition: all 0.3s ease; letter-spacing: 0.5px; }
        .btn-secondary:hover { background: linear-gradient(135deg, #d8d8d8 0%, #c8c8c8 100%); transform: translateY(-2px); }
        
        .notification { position: fixed; top: 24px; right: 24px; padding: 18px 32px; background: linear-gradient(135deg, #48c774 0%, #3ec46d 100%); color: white; border-radius: 14px; box-shadow: 0 8px 24px rgba(72, 199, 116, 0.4); display: none; z-index: 1001; font-weight: 600; letter-spacing: 0.5px; font-size: 15px; }
        .notification.show { display: block; animation: slideIn 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .notification.error { background: linear-gradient(135deg, #ff6b81 0%, #ee5a6f 100%); box-shadow: 0 8px 24px rgba(255, 107, 129, 0.4); }
        @keyframes slideIn { from { transform: translateX(400px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        
        #file-input { display: none; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="page-title">新增衣物</h1>
        
        <form id="clothingForm" action="insert_DB.jsp" method="post" enctype="multipart/form-data">
            <input type="hidden" name="memberId" value="<%= memberId %>">
            
            <div class="form-group">
                <img id="preview-image" class="preview-image">
                <label for="file-input" class="change-image-btn">📷 點擊選擇圖片</label>
                <input type="file" id="file-input" name="clothingImage" accept="image/*" required>
            </div>
            
            <div class="form-group">
                <label class="form-label">衣物名稱</label>
                <input type="text" name="clothing_code" class="form-input" placeholder="例如：白色T恤" required>
            </div>
            
            <div class="form-group">
                <label class="form-label">衣物描述</label>
                <input type="text" name="text_description" class="form-input" placeholder="例如：簡約舒適的基本款">
            </div>
            
            <div class="form-group">
                <label class="form-label">衣物類型</label>
                <select name="types_of_clothes" class="form-select" required>
                    <option value="">請選擇類型</option>
                    <option value="上衣">上衣</option>
                    <option value="褲子">褲子</option>
                    <option value="裙子">裙子</option>
                    <option value="洋裝">洋裝</option>
                    <option value="外套">外套</option>
                    <option value="其他">其他</option>
                </select>
            </div>
            
            <div class="form-group">
                <label class="form-label">顏色</label>
                <input type="text" name="color_code" class="form-input" placeholder="例如：白色">
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="window.location.href='my_wardrobe3.jsp'">取消</button>
                <button type="submit" class="btn-primary">儲存</button>
            </div>
        </form>
    </div>
    
    <div class="notification" id="notification"></div>
    
    <script>
        // 圖片預覽
        document.getElementById('file-input').addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(event) {
                    const preview = document.getElementById('preview-image');
                    preview.src = event.target.result;
                    preview.style.display = 'block';
                };
                reader.readAsDataURL(file);
            }
        });
        
        // 表單提交
        document.getElementById('clothingForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            
            try {
                const response = await fetch('insert_DB.jsp', {
                    method: 'POST',
                    body: formData
                });
                
                const result = await response.json();
                
                if (result.success) {
                    showNotification('衣物新增成功！');
                    setTimeout(() => {
                        window.location.href = 'my_wardrobe3.jsp';
                    }, 1500);
                } else {
                    showNotification(result.message || '新增失敗', 'error');
                }
            } catch (error) {
                console.error('錯誤:', error);
                showNotification('新增失敗，請稍後再試', 'error');
            }
        });
        
        function showNotification(message, type = 'success') {
            const notification = document.getElementById('notification');
            notification.textContent = message;
            notification.className = 'notification show ' + (type === 'error' ? 'error' : '');
            setTimeout(() => {
                notification.classList.remove('show');
            }, 3000);
        }
    </script>
</body>
</html>