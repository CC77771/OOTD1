<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@include file = "menu.jsp" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<%
    String memberId = (String)session.getAttribute("accessId");
    String clothing_number = request.getParameter("clothing_number");
    
    // 從資料庫讀取該衣物的資料
    String clothing_code = "";
    String text_description = "";
    String brand = "";
    String color_code = "";
    String pic = "";
    
    if(clothing_number != null) {
        try {
            String dbPath = objDBConfig.FilePath();
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);
            
            String sql = "SELECT * FROM my_wardrobe WHERE memberId = ? AND clothing_number = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, memberId);
            pstmt.setString(2, clothing_number);
            ResultSet rs = pstmt.executeQuery();
            
            if(rs.next()) {
                clothing_code = rs.getString("clothing_code");
                text_description = rs.getString("text_description");
                brand = rs.getString("brand");
                color_code = rs.getString("color_code");
                pic = rs.getString("pic");
            }
            
            rs.close();
            pstmt.close();
            con.close();
        } catch(Exception e) {
            out.println("資料庫錯誤: " + e.getMessage());
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>編輯衣物</title>
    <style>
        body { 
            font-family: 'Microsoft JhengHei', 'Arial', sans-serif; 
            background: #fafbfc; 
            min-height: 100vh; 
            padding: 0;
        }
        
        .container { 
            max-width: 600px; 
            margin: 100px auto 0;
            background: white; 
            border-radius: 24px; 
            padding: 40px; 
            box-shadow: 0 4px 24px rgba(0, 0, 0, 0.1); 
        }
        .page-title { font-size: 28px; font-weight: 700; color: #2c3e50; margin-bottom: 32px; text-align: center; }
        
        .form-group { margin-bottom: 24px; }
        .form-label { display: block; margin-bottom: 10px; font-weight: 700; color: #555; font-size: 14px; letter-spacing: 0.5px; }
        .form-label .required { color: #ff6b81; margin-left: 4px; }
        .form-input, .form-select { width: 100%; padding: 14px 16px; border: 2px solid #e8e8e8; border-radius: 12px; font-size: 15px; transition: all 0.3s ease; font-family: 'Microsoft JhengHei', 'Arial', sans-serif; }
        .form-input:focus, .form-select:focus { outline: none; border-color: #c4b5a0; box-shadow: 0 0 0 4px rgba(196, 181, 160, 0.1); }
        
        .preview-image { width: 100%; max-height: 320px; object-fit: contain; border-radius: 16px; margin-bottom: 20px; border: 2px solid #f0f0f0; box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08); }
        .change-image-btn { width: 100%; padding: 16px; background: linear-gradient(135deg, #fafafa 0%, #f5f5f5 100%); border: 3px dashed #d8d8d8; border-radius: 14px; cursor: pointer; text-align: center; color: #777; transition: all 0.3s ease; font-weight: 600; letter-spacing: 0.5px; font-size: 15px; display: block; }
        .change-image-btn:hover { background: linear-gradient(135deg, #f0ebe6 0%, #e8e3dd 100%); border-color: #c4b5a0; color: #555; }
        
        .form-actions { display: flex; gap: 12px; margin-top: 32px; }
        .btn-primary { flex: 1; padding: 16px; background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%); color: white; border: none; border-radius: 14px; cursor: pointer; font-size: 16px; font-weight: 700; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); letter-spacing: 0.5px; box-shadow: 0 4px 16px rgba(168, 159, 145, 0.35); }
        .btn-primary:hover { background: linear-gradient(135deg, #a89f91 0%, #9a8e7e 100%); transform: translateY(-2px); box-shadow: 0 6px 20px rgba(168, 159, 145, 0.45); }
        .btn-secondary { flex: 1; padding: 16px; background: linear-gradient(135deg, #e8e8e8 0%, #d8d8d8 100%); color: #555; border: none; border-radius: 14px; cursor: pointer; font-size: 16px; font-weight: 600; transition: all 0.3s ease; letter-spacing: 0.5px; }
        .btn-secondary:hover { background: linear-gradient(135deg, #d8d8d8 0%, #c8c8c8 100%); transform: translateY(-2px); }
        
        #file-input { display: none; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="page-title">編輯衣物</h1>         
        <form action="wardrobe3_Update.jsp" method="post" enctype="multipart/form-data">
            <input type="hidden" name="memberId" value="<%= memberId %>">
            <input type="hidden" name="oldClothingCode" value="<%= clothing_code %>">
            <input type="hidden" name="clothing_number" value="<%= clothing_number %>">
            <div class="form-group">
                <label class="form-label">衣物圖片</label>                
                <% if(pic != null && !pic.isEmpty()) { %>
                    <img src="<%= pic %>" class="preview-image" id="preview-image">
                <% } %>
                <label for="file-input" class="change-image-btn">📷 點擊更換圖片（選填）</label>
                <input type="file" id="file-input" name="clothingImage" accept="image/*">
                <input type="hidden" name="oldPic" value="<%= pic %>">
            </div>
            
            <div class="form-group">
                <label class="form-label">衣物名稱</label>
                <input type="text" name="brand" class="form-input" placeholder="例如:品牌名稱" value="<%= brand %>">
            </div>
            
            <div class="form-group">
                <label class="form-label">衣物描述</label>
                <input type="text" name="text_description" class="form-input" placeholder="例如:簡約舒適的基本款" value="<%= text_description != null ? text_description : "" %>">
            </div>
            
            <div class="form-group">
                <label class="form-label">衣物類型<span class="required">*</span></label>
                <select name="clothing_code" class="form-select" required>
                    <option value="">請選擇類型</option>
                    <option value="1" <%= clothing_code.equals("1") ? "selected" : "" %>>上衣</option>
                    <option value="2" <%= clothing_code.equals("2") ? "selected" : "" %>>褲子</option>
                    <option value="3" <%= clothing_code.equals("3") ? "selected" : "" %>>裙子</option>
                    <option value="4" <%= clothing_code.equals("4") ? "selected" : "" %>>連身裙/褲</option>
                    <option value="5" <%= clothing_code.equals("5") ? "selected" : "" %>>配件</option>
                    <option value="6" <%= clothing_code.equals("6") ? "selected" : "" %>>鞋子</option>
                </select>
            </div>
            
            <div class="form-group">
                <label class="form-label">顏色</label>
                <select name="color_code" class="form-select">
                    <option value="">請選擇顏色</option>
                    <option value="BK" <%= "BK".equals(color_code) ? "selected" : "" %>>黑</option>
                    <option value="BL" <%= "BL".equals(color_code) ? "selected" : "" %>>藍</option>
                    <option value="BR" <%= "BR".equals(color_code) ? "selected" : "" %>>棕</option>
                    <option value="G" <%= "G".equals(color_code) ? "selected" : "" %>>綠</option>
                    <option value="GR" <%= "GR".equals(color_code) ? "selected" : "" %>>灰</option>
                    <option value="OR" <%= "OR".equals(color_code) ? "selected" : "" %>>橙</option>
                    <option value="P" <%= "P".equals(color_code) ? "selected" : "" %>>紫</option>
                    <option value="R" <%= "R".equals(color_code) ? "selected" : "" %>>紅</option>
                    <option value="W" <%= "W".equals(color_code) ? "selected" : "" %>>白</option>
                    <option value="Y" <%= "Y".equals(color_code) ? "selected" : "" %>>黃</option>
                    <option value="O" <%= "O".equals(color_code) ? "selected" : "" %>>其他</option>
                </select>
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn-secondary" onclick="window.location.href='my_wardrobe3.jsp'">取消</button>
                <button type="submit" class="btn-primary" >更新</button>
            </div>
        </form>
    </div>
    
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
    </script>
</body>
</html>