<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>

<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的衣櫥管理</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Microsoft JhengHei', 'Arial', sans-serif;
            background: #fafbfc;
            min-height: 100vh;
        }
        
        /* 頂部導航 */
        .top-header {
            background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 50%, #9a8e7e 100%);
            padding: 0;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12);
            position: sticky;
            top: 0;
            z-index: 100;
        }
        
        .header-content {
            max-width: 1600px;
            margin: 0 auto;
            padding: 28px 50px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            font-size: 28px;
            font-weight: 700;
            color: white;
            display: flex;
            align-items: center;
            gap: 12px;
            letter-spacing: 1px;
        }
        
        .logo-icon {
            font-size: 32px;
        }
        
        .current-category {
            background: rgba(255, 255, 255, 0.25);
            padding: 10px 24px;
            border-radius: 30px;
            color: white;
            font-size: 15px;
            font-weight: 600;
            backdrop-filter: blur(10px);
            letter-spacing: 0.5px;
        }
        
        /* 主容器 */
        .main-container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 40px 50px 60px;
        }
        
        /* 分類區塊 */
        .categories-section {
            background: white;
            border-radius: 20px;
            padding: 32px 40px;
            margin-bottom: 35px;
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.06);
        }
        
        .section-title {
            font-size: 16px;
            color: #666;
            margin-bottom: 20px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .categories-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
        }
        
        .category-card {
            padding: 20px 24px;
            background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
            border: 2px solid #e8e8e8;
            border-radius: 16px;
            cursor: pointer;
            transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .category-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%);
            opacity: 0;
            transition: opacity 0.35s ease;
            z-index: 0;
        }
        
        .category-card:hover::before {
            opacity: 0.08;
        }
        
        .category-card:hover {
            border-color: #c4b5a0;
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(168, 159, 145, 0.25);
        }
        
        .category-card.active {
            background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%);
            border-color: #a89f91;
            box-shadow: 0 8px 24px rgba(168, 159, 145, 0.35);
            transform: translateY(-2px);
        }
        
        .category-card.active::before {
            opacity: 0;
        }
        
        .category-icon {
            font-size: 32px;
            display: block;
            margin-bottom: 8px;
            position: relative;
            z-index: 1;
        }
        
        .category-name {
            font-size: 15px;
            font-weight: 600;
            color: #333;
            position: relative;
            z-index: 1;
        }
        
        .category-card.active .category-name {
            color: white;
        }
        
        /* 內容區塊 */
        .content-section {
            background: white;
            border-radius: 20px;
            padding: 32px 40px 40px;
            box-shadow: 0 2px 16px rgba(0, 0, 0, 0.06);
        }
        
        .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
            padding-bottom: 24px;
            border-bottom: 2px solid #f0f0f0;
        }
        
        .content-title {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        
        .title-text {
            font-size: 24px;
            font-weight: 700;
            color: #2c3e50;
            letter-spacing: 0.5px;
        }
        
        .count-badge {
            background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%);
            color: white;
            padding: 8px 20px;
            border-radius: 25px;
            font-size: 14px;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(168, 159, 145, 0.3);
        }
        
        .btn-add {
            padding: 14px 32px;
            background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%);
            color: white;
            border: none;
            border-radius: 30px;
            cursor: pointer;
            font-size: 15px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 16px rgba(168, 159, 145, 0.35);
            letter-spacing: 0.5px;
        }
        
        .btn-add:hover {
            background: linear-gradient(135deg, #a89f91 0%, #9a8e7e 100%);
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(168, 159, 145, 0.45);
        }
        
        /* 衣物網格 */
        .items-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 28px;
            min-height: 400px;
        }
        
        .item-card {
            background: white;
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid #f0f0f0;
        }
        
        .item-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.16);
            border-color: #e0e0e0;
        }
        
        .item-image-container {
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #fafafa 0%, #f5f5f5 100%);
            height: 300px;
        }
        
        .item-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            cursor: pointer;
            transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .item-card:hover .item-image {
            transform: scale(1.08);
        }
        
        .item-info {
            padding: 20px 22px;
        }
        
        .item-name {
            font-weight: 700;
            font-size: 17px;
            margin-bottom: 12px;
            color: #2c3e50;
            letter-spacing: 0.3px;
            line-height: 1.4;
        }
        
        .item-details {
            font-size: 14px;
            color: #7f8c8d;
            margin-bottom: 6px;
            line-height: 1.6;
        }
        
        .item-actions {
            display: flex;
            gap: 10px;
            padding: 0 22px 22px;
        }
        
        .btn-edit, .btn-delete {
            flex: 1;
            padding: 11px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 700;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            letter-spacing: 0.3px;
        }
        
        .btn-edit {
            background: linear-gradient(135deg, #48c774 0%, #3ec46d 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(72, 199, 116, 0.3);
        }
        
        .btn-edit:hover {
            background: linear-gradient(135deg, #3ec46d 0%, #34b65e 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(72, 199, 116, 0.4);
        }
        
        .btn-delete {
            background: linear-gradient(135deg, #ff6b81 0%, #ee5a6f 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(255, 107, 129, 0.3);
        }
        
        .btn-delete:hover {
            background: linear-gradient(135deg, #ee5a6f 0%, #e14b5d 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(255, 107, 129, 0.4);
        }
        
        .empty-state {
            grid-column: 1 / -1;
            text-align: center;
            padding: 100px 20px;
            color: #999;
        }
        
        .empty-icon {
            font-size: 80px;
            margin-bottom: 24px;
            opacity: 0.6;
        }
        
        .empty-title {
            font-size: 20px;
            margin-bottom: 12px;
            color: #666;
            font-weight: 600;
        }
        
        .empty-text {
            font-size: 15px;
            color: #999;
        }
        
        /* 彈窗 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.65);
            align-items: center;
            justify-content: center;
            backdrop-filter: blur(4px);
        }
        
        .modal.show {
            display: flex;
        }
        
        .modal-content {
            background: white;
            padding: 40px;
            border-radius: 24px;
            width: 90%;
            max-width: 540px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 24px 64px rgba(0, 0, 0, 0.3);
        }
        
        .modal-header {
            font-size: 26px;
            font-weight: 700;
            margin-bottom: 28px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #2c3e50;
            letter-spacing: 0.5px;
        }
        
        .close {
            font-size: 32px;
            cursor: pointer;
            color: #bbb;
            transition: all 0.3s ease;
            line-height: 1;
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }
        
        .close:hover {
            color: #666;
            background: #f0f0f0;
            transform: rotate(90deg);
        }
        
        .form-group {
            margin-bottom: 24px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 10px;
            font-weight: 700;
            color: #555;
            font-size: 14px;
            letter-spacing: 0.5px;
        }
        
        .form-input {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid #e8e8e8;
            border-radius: 12px;
            font-size: 15px;
            transition: all 0.3s ease;
            font-family: 'Microsoft JhengHei', 'Arial', sans-serif;
        }
        
        .form-input:focus {
            outline: none;
            border-color: #c4b5a0;
            box-shadow: 0 0 0 4px rgba(196, 181, 160, 0.1);
        }
        
        .preview-image {
            width: 100%;
            max-height: 320px;
            object-fit: contain;
            border-radius: 16px;
            margin-bottom: 20px;
            border: 2px solid #f0f0f0;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
        }
        
        .change-image-btn {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #fafafa 0%, #f5f5f5 100%);
            border: 3px dashed #d8d8d8;
            border-radius: 14px;
            cursor: pointer;
            text-align: center;
            color: #777;
            transition: all 0.3s ease;
            font-weight: 600;
            letter-spacing: 0.5px;
            font-size: 15px;
        }
        
        .change-image-btn:hover {
            background: linear-gradient(135deg, #f0ebe6 0%, #e8e3dd 100%);
            border-color: #c4b5a0;
            color: #555;
        }
        
        .form-actions {
            display: flex;
            gap: 12px;
            margin-top: 32px;
        }
        
        .btn-primary {
            flex: 1;
            padding: 16px;
            background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%);
            color: white;
            border: none;
            border-radius: 14px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 700;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            letter-spacing: 0.5px;
            box-shadow: 0 4px 16px rgba(168, 159, 145, 0.35);
        }
        
        .btn-primary:hover {
            background: linear-gradient(135deg, #a89f91 0%, #9a8e7e 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(168, 159, 145, 0.45);
        }
        
        .btn-secondary {
            flex: 1;
            padding: 16px;
            background: linear-gradient(135deg, #e8e8e8 0%, #d8d8d8 100%);
            color: #555;
            border: none;
            border-radius: 14px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s ease;
            letter-spacing: 0.5px;
        }
        
        .btn-secondary:hover {
            background: linear-gradient(135deg, #d8d8d8 0%, #c8c8c8 100%);
            transform: translateY(-2px);
        }
        
        .notification {
            position: fixed;
            top: 24px;
            right: 24px;
            padding: 18px 32px;
            background: linear-gradient(135deg, #48c774 0%, #3ec46d 100%);
            color: white;
            border-radius: 14px;
            box-shadow: 0 8px 24px rgba(72, 199, 116, 0.4);
            display: none;
            z-index: 1001;
            font-weight: 600;
            letter-spacing: 0.5px;
            font-size: 15px;
        }
        
        .notification.show {
            display: block;
            animation: slideIn 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .notification.error {
            background: linear-gradient(135deg, #ff6b81 0%, #ee5a6f 100%);
            box-shadow: 0 8px 24px rgba(255, 107, 129, 0.4);
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        #file-input, #change-image-input {
            display: none;
        }
    </style>
</head>
<body>
    <!-- 頂部導航 -->
    <div class="top-header">
        <div class="header-content">
            <div class="logo">
                <span class="logo-icon">👔</span>
                <span>我的衣櫥</span>
            </div>
            <div class="current-category" id="header-category">衣服</div>
        </div>
    </div>
    
    <!-- 主容器 -->
    <div class="main-container">
        <!-- 分類區塊 -->
        <div class="categories-section">
            <div class="section-title">選擇分類</div>
            <div class="categories-grid">
                <div class="category-card active" data-category="衣服">
                    <span class="category-icon">👕</span>
                    <div class="category-name">衣服</div>
                </div>
                <div class="category-card" data-category="褲子">
                    <span class="category-icon">👖</span>
                    <div class="category-name">褲子</div>
                </div>
                <div class="category-card" data-category="裙子">
                    <span class="category-icon">👗</span>
                    <div class="category-name">裙子</div>
                </div>
                <div class="category-card" data-category="連身裙/褲">
                    <span class="category-icon">🩱</span>
                    <div class="category-name">連身裙/褲</div>
                </div>
                <div class="category-card" data-category="配件">
                    <span class="category-icon">👜</span>
                    <div class="category-name">配件</div>
                </div>
                <div class="category-card" data-category="鞋子">
                    <span class="category-icon">👟</span>
                    <div class="category-name">鞋子</div>
                </div>
            </div>
        </div>
        
        <!-- 內容區塊 -->
        <div class="content-section">
            <div class="content-header">
                <div class="content-title">
                    <span class="title-text" id="category-title">衣服</span>
                    <span class="count-badge" id="item-count">0 件</span>
                </div>
                <label for="file-input" class="btn-add">
                    <span>➕</span>
                    <span>新增衣物</span>
                </label>
                <input type="file" id="file-input" accept="image/*" multiple>
            </div>
            
            <div class="items-grid" id="items-container">
                <div class="empty-state">
                    <div class="empty-icon">📭</div>
                    <div class="empty-title">此分類尚無衣物</div>
                    <div class="empty-text">點擊上方「新增衣物」開始添加</div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- 編輯彈窗 -->
    <div class="modal" id="edit-modal">
        <div class="modal-content">
            <div class="modal-header">
                <span id="modal-title">編輯衣物</span>
                <span class="close">&times;</span>
            </div>
            
            <img id="preview-image" class="preview-image" style="display: none;">
            <label for="change-image-input" class="change-image-btn">📷 點擊更換圖片</label>
            <input type="file" id="change-image-input" accept="image/*">
            
            <div class="form-group">
                <label class="form-label">衣物名稱</label>
                <input type="text" id="item-name" class="form-input" placeholder="例如：白色T恤">
            </div>
            
            <div class="form-group">
                <label class="form-label">品牌</label>
                <input type="text" id="item-brand" class="form-input" placeholder="例如：UNIQLO">
            </div>
            
            <div class="form-group">
                <label class="form-label">顏色</label>
                <input type="text" id="item-color" class="form-input" placeholder="例如：白色">
            </div>
            
            <div class="form-actions">
                <button class="btn-secondary" id="cancel-btn">取消</button>
                <button class="btn-primary" id="save-btn">儲存</button>
            </div>
        </div>
    </div>
    
    <div class="notification" id="notification"></div>
    
    <script>
        // 資料結構
        const wardrobeData = {
            '衣服': [],
            '褲子': [],
            '裙子': [],
            '連身裙/褲': [],
            '配件': [],
            '鞋子': []
        };
        
        let currentCategory = '衣服';
        let editingIndex = -1;
        let tempImageData = null;
        let itemIdCounter = 0;
        
        // 從 localStorage 載入
        function loadData() {
            const saved = localStorage.getItem('wardrobeData');
            if (saved) {
                try {
                    const parsed = JSON.parse(saved);
                    Object.assign(wardrobeData, parsed.data || {});
                    itemIdCounter = parsed.counter || 0;
                } catch (e) {
                    console.error('載入失敗:', e);
                }
            }
        }
        
        // 儲存到 localStorage
        function saveData() {
            try {
                localStorage.setItem('wardrobeData', JSON.stringify({
                    data: wardrobeData,
                    counter: itemIdCounter
                }));
            } catch (e) {
                console.error('儲存失敗:', e);
                showNotification('儲存失敗', 'error');
            }
        }
        
        // 顯示通知
        function showNotification(message, type = 'success') {
            const notification = document.getElementById('notification');
            notification.textContent = message;
            notification.className = 'notification show ' + (type === 'error' ? 'error' : '');
            setTimeout(() => {
                notification.classList.remove('show');
            }, 3000);
        }
        
        // 渲染項目
        function renderItems() {
            const container = document.getElementById('items-container');
            const items = wardrobeData[currentCategory] || [];
            
            document.getElementById('category-title').textContent = currentCategory;
            document.getElementById('header-category').textContent = currentCategory;
            document.getElementById('item-count').textContent = items.length + ' 件';
            
            if (items.length === 0) {
                container.innerHTML = `
                    <div class="empty-state">
                        <div class="empty-icon">📭</div>
                        <div class="empty-title">此分類尚無衣物</div>
                        <div class="empty-text">點擊上方「新增衣物」開始添加</div>
                    </div>
                `;
                return;
            }
            
            container.innerHTML = '';
            items.forEach((item, index) => {
                const card = document.createElement('div');
                card.className = 'item-card';
                
                let detailsHtml = '';
                if (item.brand) detailsHtml += `<div class="item-details">品牌：${item.brand}</div>`;
                if (item.color) detailsHtml += `<div class="item-details">顏色：${item.color}</div>`;
                
                card.innerHTML = `
                    <div class="item-image-container">
                        <img src="${item.image}" alt="${item.name}" class="item-image" data-index="${index}">
                    </div>
                    <div class="item-info">
                        <div class="item-name">${item.name}</div>
                        ${detailsHtml}
                    </div>
                    <div class="item-actions">
                        <button class="btn-edit" data-index="${index}">✏️ 編輯</button>
                        <button class="btn-delete" data-index="${index}">🗑️ 刪除</button>
                    </div>
                `;
                
                container.appendChild(card);
            });
        }
        
        // 開啟編輯彈窗
        function openEditModal(index = -1) {
            editingIndex = index;
            const modal = document.getElementById('edit-modal');
            const preview = document.getElementById('preview-image');
            
            if (index >= 0) {
                // 編輯模式
                const item = wardrobeData[currentCategory][index];
                document.getElementById('modal-title').textContent = '編輯衣物';
                document.getElementById('item-name').value = item.name || '';
                document.getElementById('item-brand').value = item.brand || '';
                document.getElementById('item-color').value = item.color || '';
                
                tempImageData = item.image;
                preview.src = item.image;
                preview.style.display = 'block';
            } else {
                // 新增模式
                document.getElementById('modal-title').textContent = '新增衣物';
                document.getElementById('item-name').value = '';
                document.getElementById('item-brand').value = '';
                document.getElementById('item-color').value = '';
                
                if (tempImageData) {
                    preview.src = tempImageData;
                    preview.style.display = 'block';
                } else {
                    preview.style.display = 'none';
                }
            }
            
            modal.classList.add('show');
        }
        
        // 關閉彈窗
        function closeModal() {
            document.getElementById('edit-modal').classList.remove('show');
            if (editingIndex < 0) {
                tempImageData = null;
            }
        }
        
        // 儲存項目
        function saveItem() {
            const name = document.getElementById('item-name').value.trim();
            
            if (!tempImageData) {
                showNotification('請選擇圖片', 'error');
                return;
            }
            
            const itemData = {
                id: editingIndex >= 0 ? wardrobeData[currentCategory][editingIndex].id : ++itemIdCounter,
                name: name || '未命名',
                brand: document.getElementById('item-brand').value.trim(),
                color: document.getElementById('item-color').value.trim(),
                image: tempImageData,
                date: new Date().toLocaleDateString('zh-TW')
            };
            
            if (editingIndex >= 0) {
                wardrobeData[currentCategory][editingIndex] = itemData;
                showNotification('衣物已更新');
            } else {
                wardrobeData[currentCategory].push(itemData);
                showNotification('衣物已新增');
            }
            
            saveData();
            renderItems();
            closeModal();
            tempImageData = null;
        }
        
        // 刪除項目
        function deleteItem(index) {
            if (confirm('確定要刪除這件衣物嗎？')) {
                wardrobeData[currentCategory].splice(index, 1);
                saveData();
                renderItems();
                showNotification('衣物已刪除');
            }
        }
        
        // 事件監聽
        document.querySelectorAll('.category-card').forEach(cat => {
            cat.addEventListener('click', function() {
                document.querySelectorAll('.category-card').forEach(c => c.classList.remove('active'));
                this.classList.add('active');
                currentCategory = this.dataset.category;
                renderItems();
            });
        });
        
        document.getElementById('file-input').addEventListener('change', function(e) {
            const files = e.target.files;
            if (files.length === 0) return;
            
            const file = files[0];
            const reader = new FileReader();
            reader.onload = function(event) {
                tempImageData = event.target.result;
                openEditModal(-1);
            };
            reader.readAsDataURL(file);
            
            e.target.value = '';
        });
        
        document.getElementById('change-image-input').addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (!file) return;
            
            const reader = new FileReader();
            reader.onload = function(event) {
                tempImageData = event.target.result;
                const preview = document.getElementById('preview-image');
                preview.src = tempImageData;
                preview.style.display = 'block';
            };
            reader.readAsDataURL(file);
            
            e.target.value = '';
        });
        
        document.getElementById('items-container').addEventListener('click', function(e) {
            const target = e.target;
            
            if (target.classList.contains('item-image')) {
                const index = parseInt(target.dataset.index);
                openEditModal(index);
            } else if (target.classList.contains('btn-edit')) {
                const index = parseInt(target.dataset.index);
                openEditModal(index);
            } else if (target.classList.contains('btn-delete')) {
                const index = parseInt(target.dataset.index);
                deleteItem(index);
            }
        });
        
        document.querySelector('.close').addEventListener('click', closeModal);
        document.getElementById('cancel-btn').addEventListener('click', closeModal);
        document.getElementById('save-btn').addEventListener('click', saveItem);
        
        document.getElementById('edit-modal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
        
        // 初始化
        loadData();
        renderItems();
    </script>
</body>
</html>