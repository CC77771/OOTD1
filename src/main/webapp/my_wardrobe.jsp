<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>

<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />
<jsp:useBean id="objFolderConfig" scope="session" class="CZ.group.tool.upload.FolderConfig2" />

<%
    // 取得當前登入的帳號
    String accountNumber = (String) session.getAttribute("account_number");
    if (accountNumber == null) {
        accountNumber = "guest";
    }
    
    // 處理操作請求
    String action = request.getParameter("action");
    String message = "";
    String messageType = "success";
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        // 使用 UcanAccess 連接 MS Access 數據庫
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        conn = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 處理刪除
        if ("delete".equals(action)) {
            String clothingCode = request.getParameter("clothing_code");
            String sql = "DELETE FROM my_wardrobe WHERE account_number = ? AND clothing_code = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, accountNumber);
            pstmt.setString(2, clothingCode);
            pstmt.executeUpdate();
            message = "衣物已刪除";
        }
        
        // 處理新增/編輯
        if ("save".equals(action)) {
            String clothingCode = request.getParameter("clothing_code");
            String typesOfClothes = request.getParameter("types_of_clothes");
            String textDescription = request.getParameter("text_description");
            String colorCode = request.getParameter("color_code");
            String brand = request.getParameter("brand");
            String wearingDisplay = request.getParameter("wearing_display");
            
            try {
                if (clothingCode != null && !clothingCode.isEmpty()) {
                    // 編輯
                    String sql = "UPDATE my_wardrobe SET text_description = ?, color_code = ?, brand = ?, wearing_display = ? WHERE account_number = ? AND clothing_code = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, textDescription);
                    pstmt.setString(2, colorCode);
                    pstmt.setString(3, brand);
                    pstmt.setString(4, wearingDisplay);
                    pstmt.setString(5, accountNumber);
                    pstmt.setString(6, clothingCode);
                    pstmt.executeUpdate();
                    message = "衣物已更新";
                } else {
                    // 新增
                    String sql = "INSERT INTO my_wardrobe (account_number, clothing_code, text_description, types_of_clothes, color_code, brand, wearing_display) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    String newCode = accountNumber + "_" + System.currentTimeMillis();
                    
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, accountNumber);
                    pstmt.setString(2, newCode);
                    pstmt.setString(3, textDescription);
                    pstmt.setString(4, typesOfClothes);
                    pstmt.setString(5, colorCode);
                    pstmt.setString(6, brand);
                    pstmt.setString(7, wearingDisplay);
                    pstmt.executeUpdate();
                    message = "衣物已新增";
                }
            } catch (Exception e) {
                message = "保存失敗: " + e.getMessage();
                messageType = "error";
            }
        }
    } catch (Exception e) {
        message = "操作失敗: " + e.getMessage();
        messageType = "error";
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
    
    // 查詢當前分類的資料
    String currentCategory = request.getParameter("category");
    if (currentCategory == null || currentCategory.isEmpty()) {
        currentCategory = "衣服";
    }
    
    // 分類對應
    Map<String, String> categoryMap = new HashMap<>();
    categoryMap.put("衣服", "TOP");
    categoryMap.put("褲子", "BOTTOM");
    categoryMap.put("裙子", "SKIRT");
    categoryMap.put("連身裙/褲", "DRESS");
    categoryMap.put("配件", "ACCESSORY");
    categoryMap.put("鞋子", "SHOES");
    
    String dbCategory = categoryMap.get(currentCategory);
    
    // 查詢資料
    List<Map<String, String>> itemsList = new ArrayList<>();
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        conn = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        String sql = "SELECT * FROM my_wardrobe WHERE account_number = ? AND types_of_clothes = ? ORDER BY clothing_code DESC";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, accountNumber);
        pstmt.setString(2, dbCategory);
        
        ResultSet rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String, String> item = new HashMap<>();
            item.put("clothing_code", rs.getString("clothing_code"));
            item.put("text_description", rs.getString("text_description"));
            item.put("color_code", rs.getString("color_code"));
            item.put("brand", rs.getString("brand"));
            item.put("wearing_display", rs.getString("wearing_display"));
            itemsList.add(item);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的衣櫥管理</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft JhengHei', 'Arial', sans-serif; background: #fafbfc; min-height: 100vh; }
        .top-header { background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 50%, #9a8e7e 100%); padding: 28px 50px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12); position: sticky; top: 0; z-index: 100; }
        .header-content { max-width: 1800px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 28px; font-weight: 700; color: white; letter-spacing: 1.5px; }
        .current-category { background: rgba(255, 255, 255, 0.25); padding: 10px 24px; border-radius: 30px; color: white; font-size: 15px; font-weight: 600; backdrop-filter: blur(10px); letter-spacing: 0.5px; }
        .main-container { max-width: 1800px; margin: 0 auto; padding: 40px 50px 60px; display: flex; gap: 35px; }
        .categories-section { background: white; border-radius: 20px; padding: 32px 28px; box-shadow: 0 2px 16px rgba(0, 0, 0, 0.06); width: 280px; flex-shrink: 0; height: fit-content; position: sticky; top: 120px; }
        .section-title { font-size: 14px; color: #999; margin-bottom: 24px; font-weight: 600; text-transform: uppercase; letter-spacing: 1.5px; }
        .categories-grid { display: flex; flex-direction: column; gap: 12px; }
        .category-card { padding: 18px 24px; background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%); border: 2px solid #e8e8e8; border-radius: 14px; cursor: pointer; transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1); text-align: left; position: relative; overflow: hidden; text-decoration: none; display: block; }
        .category-card::before { content: ''; position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%); opacity: 0; transition: opacity 0.35s ease; z-index: 0; }
        .category-card:hover::before { opacity: 0.08; }
        .category-card:hover { border-color: #c4b5a0; transform: translateX(4px); box-shadow: 0 4px 16px rgba(168, 159, 145, 0.2); }
        .category-card.active { background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%); border-color: #a89f91; box-shadow: 0 4px 16px rgba(168, 159, 145, 0.35); transform: translateX(2px); }
        .category-card.active::before { opacity: 0; }
        .category-name { font-size: 15px; font-weight: 600; color: #333; position: relative; z-index: 1; letter-spacing: 0.5px; }
        .category-card.active .category-name { color: white; }
        .content-section { background: white; border-radius: 20px; padding: 32px 40px 40px; box-shadow: 0 2px 16px rgba(0, 0, 0, 0.06); flex: 1; }
        .content-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; padding-bottom: 24px; border-bottom: 2px solid #f0f0f0; }
        .content-title { display: flex; align-items: center; gap: 16px; }
        .title-text { font-size: 24px; font-weight: 700; color: #2c3e50; letter-spacing: 0.5px; }
        .count-badge { background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%); color: white; padding: 8px 20px; border-radius: 25px; font-size: 14px; font-weight: 700; box-shadow: 0 4px 12px rgba(168, 159, 145, 0.3); }
        .btn-add { padding: 14px 28px; background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%); color: white; border: none; border-radius: 30px; cursor: pointer; font-size: 15px; font-weight: 700; transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1); box-shadow: 0 4px 16px rgba(168, 159, 145, 0.35); letter-spacing: 0.8px; }
        .btn-add:hover { background: linear-gradient(135deg, #a89f91 0%, #9a8e7e 100%); transform: translateY(-3px); box-shadow: 0 8px 24px rgba(168, 159, 145, 0.45); }
        .items-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 28px; min-height: 400px; }
        .item-card { background: white; border-radius: 18px; overflow: hidden; box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08); transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); border: 1px solid #f0f0f0; }
        .item-card:hover { transform: translateY(-8px) scale(1.02); box-shadow: 0 12px 32px rgba(0, 0, 0, 0.16); border-color: #e0e0e0; }
        .item-image-container { position: relative; overflow: hidden; background: linear-gradient(135deg, #fafafa 0%, #f5f5f5 100%); height: 300px; }
        .item-image { width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
        .item-card:hover .item-image { transform: scale(1.08); }
        .item-info { padding: 20px 22px; }
        .item-name { font-weight: 700; font-size: 17px; margin-bottom: 12px; color: #2c3e50; letter-spacing: 0.3px; line-height: 1.4; }
        .item-details { font-size: 14px; color: #7f8c8d; margin-bottom: 6px; line-height: 1.6; }
        .item-actions { display: flex; gap: 10px; padding: 0 22px 22px; }
        .btn-edit, .btn-delete { flex: 1; padding: 11px; border: none; border-radius: 12px; cursor: pointer; font-size: 14px; font-weight: 700; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); letter-spacing: 0.3px; }
        .btn-edit { background: linear-gradient(135deg, #48c774 0%, #3ec46d 100%); color: white; box-shadow: 0 4px 12px rgba(72, 199, 116, 0.3); }
        .btn-edit:hover { background: linear-gradient(135deg, #3ec46d 0%, #34b65e 100%); transform: translateY(-2px); box-shadow: 0 6px 16px rgba(72, 199, 116, 0.4); }
        .btn-delete { background: linear-gradient(135deg, #ff6b81 0%, #ee5a6f 100%); color: white; box-shadow: 0 4px 12px rgba(255, 107, 129, 0.3); }
        .btn-delete:hover { background: linear-gradient(135deg, #ee5a6f 0%, #e14b5d 100%); transform: translateY(-2px); box-shadow: 0 6px 16px rgba(255, 107, 129, 0.4); }
        .empty-state { grid-column: 1 / -1; text-align: center; padding: 100px 20px; color: #999; }
        .empty-title { font-size: 20px; margin-bottom: 12px; color: #666; font-weight: 600; }
        .empty-text { font-size: 15px; color: #999; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.65); align-items: center; justify-content: center; backdrop-filter: blur(4px); }
        .modal.show { display: flex; }
        .modal-content { background: white; padding: 40px; border-radius: 24px; width: 90%; max-width: 540px; max-height: 90vh; overflow-y: auto; box-shadow: 0 24px 64px rgba(0, 0, 0, 0.3); }
        .modal-header { font-size: 26px; font-weight: 700; margin-bottom: 28px; display: flex; justify-content: space-between; align-items: center; color: #2c3e50; letter-spacing: 0.5px; }
        .close { font-size: 32px; cursor: pointer; color: #bbb; transition: all 0.3s ease; line-height: 1; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 50%; }
        .close:hover { color: #666; background: #f0f0f0; transform: rotate(90deg); }
        .form-group { margin-bottom: 24px; }
        .form-label { display: block; margin-bottom: 10px; font-weight: 700; color: #555; font-size: 14px; letter-spacing: 0.5px; }
        .form-input { width: 100%; padding: 14px 16px; border: 2px solid #e8e8e8; border-radius: 12px; font-size: 15px; transition: all 0.3s ease; font-family: 'Microsoft JhengHei', 'Arial', sans-serif; }
        .form-input:focus { outline: none; border-color: #c4b5a0; box-shadow: 0 0 0 4px rgba(196, 181, 160, 0.1); }
        .form-actions { display: flex; gap: 12px; margin-top: 32px; }
        .btn-primary { flex: 1; padding: 16px; background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%); color: white; border: none; border-radius: 14px; cursor: pointer; font-size: 16px; font-weight: 700; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); letter-spacing: 0.5px; box-shadow: 0 4px 16px rgba(168, 159, 145, 0.35); }
        .btn-primary:hover { background: linear-gradient(135deg, #a89f91 0%, #9a8e7e 100%); transform: translateY(-2px); box-shadow: 0 6px 20px rgba(168, 159, 145, 0.45); }
        .btn-secondary { flex: 1; padding: 16px; background: linear-gradient(135deg, #e8e8e8 0%, #d8d8d8 100%); color: #555; border: none; border-radius: 14px; cursor: pointer; font-size: 16px; font-weight: 600; transition: all 0.3s ease; letter-spacing: 0.5px; }
        .btn-secondary:hover { background: linear-gradient(135deg, #d8d8d8 0%, #c8c8c8 100%); transform: translateY(-2px); }
        .notification { position: fixed; top: 24px; right: 24px; padding: 18px 32px; background: linear-gradient(135deg, #48c774 0%, #3ec46d 100%); color: white; border-radius: 14px; box-shadow: 0 8px 24px rgba(72, 199, 116, 0.4); z-index: 1001; font-weight: 600; letter-spacing: 0.5px; font-size: 15px; animation: slideIn 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .notification.error { background: linear-gradient(135deg, #ff6b81 0%, #ee5a6f 100%); box-shadow: 0 8px 24px rgba(255, 107, 129, 0.4); }
        @keyframes slideIn { from { transform: translateX(400px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
    </style>
</head>
<body>
    <div class="top-header">
        <div class="header-content">
            <div class="logo">我的衣櫥</div>
            <div class="current-category"><%= currentCategory %></div>
        </div>
    </div>
    
    <div class="main-container">
        <div class="categories-section">
            <div class="section-title">分類</div>
            <div class="categories-grid">
                <a href="?category=衣服" class="category-card <%= "衣服".equals(currentCategory) ? "active" : "" %>">
                    <div class="category-name">衣服</div>
                </a>
                <a href="?category=褲子" class="category-card <%= "褲子".equals(currentCategory) ? "active" : "" %>">
                    <div class="category-name">褲子</div>
                </a>
                <a href="?category=裙子" class="category-card <%= "裙子".equals(currentCategory) ? "active" : "" %>">
                    <div class="category-name">裙子</div>
                </a>
                <a href="?category=連身裙/褲" class="category-card <%= "連身裙/褲".equals(currentCategory) ? "active" : "" %>">
                    <div class="category-name">連身裙/褲</div>
                </a>
                <a href="?category=配件" class="category-card <%= "配件".equals(currentCategory) ? "active" : "" %>">
                    <div class="category-name">配件</div>
                </a>
                <a href="?category=鞋子" class="category-card <%= "鞋子".equals(currentCategory) ? "active" : "" %>">
                    <div class="category-name">鞋子</div>
                </a>
            </div>
        </div>
        
        <div class="content-section">
            <div class="content-header">
                <div class="content-title">
                    <span class="title-text"><%= currentCategory %></span>
                    <span class="count-badge"><%= itemsList.size() %> 件</span>
                </div>
                <button class="btn-add" onclick="openAddModal()">新增衣物</button>
            </div>
            
            <div class="items-grid">
                <% if (itemsList.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-title">此分類尚無衣物</div>
                        <div class="empty-text">點擊上方「新增衣物」開始添加</div>
                    </div>
                <% } else {
                    for (Map<String, String> item : itemsList) {
                        String imagePath = item.get("wearing_display");
                        if (imagePath == null || imagePath.isEmpty()) {
                            imagePath = "images/no-image.jpg";
                        }
                        String desc = item.get("text_description");
                        if (desc == null) desc = "未命名";
                        String color = item.get("color_code");
                        if (color == null) color = "";
                %>
                    <div class="item-card">
                        <div class="item-image-container">
                            <img src="<%= imagePath %>" alt="<%= desc %>" class="item-image">
                        </div>
                        <div class="item-info">
                            <div class="item-name"><%= desc %></div>
                            <% if (!color.isEmpty()) { %>
                                <div class="item-details">顏色：<%= color %></div>
                            <% } %>
                            <% String brand = item.get("brand");
                               if (brand != null && !brand.isEmpty()) { %>
                                <div class="item-details">品牌：<%= brand %></div>
                            <% } %>
                        </div>
                        <div class="item-actions">
                            <button class="btn-edit" onclick="openEditModal('<%= item.get("clothing_code") %>', '<%= desc.replace("'", "\\'") %>', '<%= color.replace("'", "\\'") %>')">編輯</button>
                            <form method="post" style="flex:1; margin:0;" onsubmit="return confirm('確定要刪除這件衣物嗎？');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="clothing_code" value="<%= item.get("clothing_code") %>">
                                <input type="hidden" name="category" value="<%= currentCategory %>">
                                <button type="submit" class="btn-delete">刪除</button>
                            </form>
                        </div>
                    </div>
                <% }} %>
            </div>
        </div>
    </div>
    
    <div class="modal" id="edit-modal">
        <div class="modal-content">
            <div class="modal-header">
                <span id="modal-title">編輯衣物</span>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            <form method="post" id="edit-form">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="category" value="<%= currentCategory %>">
                <input type="hidden" name="clothing_code" id="clothing_code">
                <input type="hidden" name="types_of_clothes" value="<%= dbCategory %>">
                <input type="hidden" name="wearing_display" id="wearing_display">
                <div class="form-group">
                    <label class="form-label">衣物圖片</label>
                    <div id="image-preview" style="width: 100%; height: 250px; background: #f0f0f0; border-radius: 12px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px; overflow: hidden;">
                        <span style="color: #999;">點擊下方選擇圖片預覽</span>
                    </div>
                    <input type="file" name="wearing_display_file" id="wearing_display_file" class="form-input" accept="image/*" required>
                </div>
                <div class="form-group">
                    <label class="form-label">衣物名稱</label>
                    <input type="text" name="text_description" id="text_description" class="form-input" placeholder="例如：白色T恤">
                </div>
                <div class="form-group">
                    <label class="form-label">品牌</label>
                    <input type="text" name="brand" id="brand" class="form-input" placeholder="例如：UNIQLO">
                </div>
                <div class="form-group">
                    <label class="form-label">顏色</label>
                    <input type="text" name="color_code" id="color_code" class="form-input" placeholder="例如：白色">
                </div>
                <div class="form-actions">
                    <button type="button" class="btn-secondary" onclick="closeModal()">取消</button>
                    <button type="submit" class="btn-primary">儲存</button>
                </div>
            </form>
        </div>
    </div>
    
    <% if (!message.isEmpty()) { %>
    <div class="notification <%= messageType %>"><%= message %></div>
    <script>setTimeout(function(){ var n = document.querySelector('.notification'); if(n) n.style.display='none'; }, 3000);</script>
    <% } %>
    
    <script>
        // 圖片預覽功能
        document.getElementById('wearing_display_file').addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(event) {
                    const preview = document.getElementById('image-preview');
                    preview.innerHTML = '<img src="' + event.target.result + '" style="width: 100%; height: 100%; object-fit: cover;">';
                    document.getElementById('wearing_display').value = event.target.result;
                };
                reader.readAsDataURL(file);
            }
        });
        
        function openAddModal() {
            document.getElementById('modal-title').textContent = '新增衣物';
            document.getElementById('clothing_code').value = '';
            document.getElementById('text_description').value = '';
            document.getElementById('color_code').value = '';
            document.getElementById('brand').value = '';
            document.getElementById('wearing_display_file').value = '';
            document.getElementById('wearing_display').value = '';
            document.getElementById('image-preview').innerHTML = '<span style="color: #999;">點擊下方選擇圖片預覽</span>';
            document.getElementById('edit-modal').classList.add('show');
        }
        
        function openEditModal(code, desc, color, brand) {
            document.getElementById('modal-title').textContent = '編輯衣物';
            document.getElementById('clothing_code').value = code;
            document.getElementById('text_description').value = desc;
            document.getElementById('color_code').value = color;
            document.getElementById('brand').value = brand;
            document.getElementById('wearing_display_file').value = '';
            document.getElementById('image-preview').innerHTML = '<span style="color: #999;">點擊下方選擇圖片預覽</span>';
            document.getElementById('edit-modal').classList.add('show');
        }
        
        function closeModal() {
            document.getElementById('edit-modal').classList.remove('show');
        }
        
        document.getElementById('edit-modal').addEventListener('click', function(e) {
            if (e.target === this) closeModal();
        });
    </script>
</body>
</html>