<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@include file = "menu.jsp" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<%
    // 取得當前登入的會員ID
    String memberId = (String)session.getAttribute("accessId");
//String clothing_number = request.getParameter("clothing_number");

        // 取得當前選擇的分類，預設為「衣服」
    
    // 取得當前選擇的分類，預設為「衣服」
    String currentCategory = request.getParameter("category");
    if(currentCategory == null || currentCategory.isEmpty()) {
        currentCategory = "衣服";  // 👈 只有沒傳 category 時才預設為「衣服」
    }

    
    // 從資料庫讀取衣物資料
    Map<String, List<Map<String, String>>> wardrobeData = new HashMap<>();
    wardrobeData.put("衣服", new ArrayList<>());
    wardrobeData.put("褲子", new ArrayList<>());
    wardrobeData.put("裙子", new ArrayList<>());
    wardrobeData.put("連身裙/褲", new ArrayList<>());
    wardrobeData.put("配件", new ArrayList<>());
    wardrobeData.put("鞋子", new ArrayList<>());
    
    // 顏色代碼對應表
    Map<String, String> colorMap = new HashMap<>();
    colorMap.put("BK", "黑色");
    colorMap.put("BL", "藍色");
    colorMap.put("BR", "棕色");
    colorMap.put("G", "綠色");
    colorMap.put("GR", "灰色");
    colorMap.put("OR", "橙色");
    colorMap.put("P", "紫色");
    colorMap.put("R", "紅色");
    colorMap.put("W", "白色");
    colorMap.put("Y", "黃色");
    colorMap.put("O", "其他");
    
    if(memberId != null) {
        try {
            String dbPath = objDBConfig.FilePath();
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);
            
            String sql = "SELECT * FROM my_wardrobe WHERE memberId = ? ";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, memberId);
                 
            ResultSet rs = pstmt.executeQuery();
            
            while(rs.next()) {
                Map<String, String> item = new HashMap<>();
                item.put("clothing_number", rs.getString("clothing_number"));               
                item.put("clothing_code", rs.getString("clothing_code"));
                item.put("text_description", rs.getString("text_description"));
                item.put("brand", rs.getString("brand"));
                item.put("pic", rs.getString("pic"));
                item.put("color_code", rs.getString("color_code"));
                
                // 根據 clothing_code 分類
                String type = rs.getString("clothing_code");
                String category = "";
                switch(type) {
                    case "1": category = "衣服"; break;
                    case "2": category = "褲子"; break;
                    case "3": category = "裙子"; break;
                    case "4": category = "連身裙/褲"; break;
                    case "5": category = "配件"; break;
                    case "6": category = "鞋子"; break;
                    default: category = "衣服";
                }
                
                if(wardrobeData.containsKey(category)) {
                    wardrobeData.get(category).add(item);
                }
            }
            
            rs.close();
            pstmt.close();
            con.close();
        } catch(Exception e) {
            out.println("資料庫錯誤: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // 取得當前分類的衣物列表
    List<Map<String, String>> currentItems = wardrobeData.get(currentCategory);
%>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的衣櫥管理</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Microsoft JhengHei', 'Arial', sans-serif; background: #fafbfc; min-height: 100vh; }
        
        /* 頂部導航 */
        .top-header { background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 50%, #9a8e7e 100%); padding: 28px 50px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.12); position: sticky; top: 0; z-index: 100; }
        .header-content { max-width: 1800px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 28px; font-weight: 700; color: white; letter-spacing: 1.5px; }
        .current-category { background: rgba(255, 255, 255, 0.25); padding: 10px 24px; border-radius: 30px; color: white; font-size: 15px; font-weight: 600; backdrop-filter: blur(10px); letter-spacing: 0.5px; }
        
        /* 主容器 */
        .main-container { max-width: 1800px; margin: 0 auto; padding: 40px 50px 60px; display: flex; gap: 35px; }
        
        /* 分類區塊 */
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
        
        /* 內容區塊 */
        .content-section { background: white; border-radius: 20px; padding: 32px 40px 40px; box-shadow: 0 2px 16px rgba(0, 0, 0, 0.06); flex: 1; }
        .content-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; padding-bottom: 24px; border-bottom: 2px solid #f0f0f0; }
        .content-title { display: flex; align-items: center; gap: 16px; }
        .title-text { font-size: 24px; font-weight: 700; color: #2c3e50; letter-spacing: 0.5px; }
        .count-badge { background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%); color: white; padding: 8px 20px; border-radius: 25px; font-size: 14px; font-weight: 700; box-shadow: 0 4px 12px rgba(168, 159, 145, 0.3); }
        .btn-add { padding: 14px 28px; background: linear-gradient(135deg, #c4b5a0 0%, #a89f91 100%); color: white; border: none; border-radius: 30px; cursor: pointer; font-size: 15px; font-weight: 700; transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1); box-shadow: 0 4px 16px rgba(168, 159, 145, 0.35); letter-spacing: 0.8px; text-decoration: none; display: inline-block; }
        .btn-add:hover { background: linear-gradient(135deg, #a89f91 0%, #9a8e7e 100%); transform: translateY(-3px); box-shadow: 0 8px 24px rgba(168, 159, 145, 0.45); }
        
        /* 衣物網格 */
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
        .btn-edit, .btn-delete { flex: 1; padding: 11px; border: none; border-radius: 12px; cursor: pointer; font-size: 14px; font-weight: 700; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); letter-spacing: 0.3px; text-decoration: none; display: inline-block; text-align: center; }
        .btn-edit { background: linear-gradient(135deg, #48c774 0%, #3ec46d 100%); color: white; box-shadow: 0 4px 12px rgba(72, 199, 116, 0.3); }
        .btn-edit:hover { background: linear-gradient(135deg, #3ec46d 0%, #34b65e 100%); transform: translateY(-2px); box-shadow: 0 6px 16px rgba(72, 199, 116, 0.4); }
        .btn-delete { background: linear-gradient(135deg, #ff6b81 0%, #ee5a6f 100%); color: white; box-shadow: 0 4px 12px rgba(255, 107, 129, 0.3); }
        .btn-delete:hover { background: linear-gradient(135deg, #ee5a6f 0%, #e14b5d 100%); transform: translateY(-2px); box-shadow: 0 6px 16px rgba(255, 107, 129, 0.4); }
        
        .empty-state { grid-column: 1 / -1; text-align: center; padding: 100px 20px; color: #999; }
        .empty-title { font-size: 20px; margin-bottom: 12px; color: #666; font-weight: 600; }
        .empty-text { font-size: 15px; color: #999; }
    </style>
</head>
<body>
    <!-- 頂部導航 -->
    <div class="top-header">
        <div class="header-content">
            <div class="logo">我的衣櫥</div>
            <div class="current-category"><%= currentCategory %></div>
        </div>
    </div>
    
    <!-- 主容器 -->
    <div class="main-container">
        <!-- 分類區塊 -->
        <div class="categories-section">
            <div class="section-title">分類</div>
            <div class="categories-grid">
                <a href="my_wardrobe3.jsp?category=衣服" class="category-card <%= currentCategory.equals("衣服") ? "active" : "" %>">
                    <div class="category-name">衣服</div>
                </a>
                <a href="my_wardrobe3.jsp?category=褲子" class="category-card <%= currentCategory.equals("褲子") ? "active" : "" %>">
                    <div class="category-name">褲子</div>
                </a>
                <a href="my_wardrobe3.jsp?category=裙子" class="category-card <%= currentCategory.equals("裙子") ? "active" : "" %>">
                    <div class="category-name">裙子</div>
                </a>
                <a href="my_wardrobe3.jsp?category=連身裙/褲" class="category-card <%= currentCategory.equals("連身裙/褲") ? "active" : "" %>">
                    <div class="category-name">連身裙/褲</div>
                </a>
                <a href="my_wardrobe3.jsp?category=配件" class="category-card <%= currentCategory.equals("配件") ? "active" : "" %>">
                    <div class="category-name">配件</div>
                </a>
                <a href="my_wardrobe3.jsp?category=鞋子" class="category-card <%= currentCategory.equals("鞋子") ? "active" : "" %>">
                    <div class="category-name">鞋子</div>
                </a>
            </div>
        </div>
        
        <!-- 內容區塊 -->
        <div class="content-section">
            <div class="content-header">
                <div class="content-title">
                    <span class="title-text"><%= currentCategory %></span>
                    <span class="count-badge"><%= currentItems.size() %> 件</span>
                </div>
                <a href="wardrobe3_insert.jsp" class="btn-add">新增衣物</a>
            </div>
            
            <div class="items-grid">
                <% 
                if(currentItems.isEmpty()) { 
                %>
                    <div class="empty-state">
                        <div class="empty-title">此分類尚無衣物</div>
                        <div class="empty-text">點擊上方「新增衣物」開始添加</div>
                    </div>
                <% 
                } else {
                    for(Map<String, String> item : currentItems) {
                    	String clothing_number = item.get("clothing_number");  
                        String clothing_code = item.get("clothing_code");
                        String brand = item.get("brand");
                        String textDescription = item.get("text_description");
                        String pic = item.get("pic");
                        String colorCode = item.get("color_code");
                        String colorName = colorMap.get(colorCode);
                        if(colorName == null) colorName = colorCode;
                %>
                    <div class="item-card">
                        <div class="item-image-container">
                            <img src="<%= pic %>" class="item-image" alt="<%= brand != null ? brand : "衣物" %>">
                        </div>
                        <div class="item-info">
                            <div class="item-name"><%= brand != null && !brand.isEmpty() ? brand : "未命名" %></div>
                            <% if(textDescription != null && !textDescription.isEmpty()) { %>
                                <div class="item-details">描述: <%= textDescription %></div>
                            <% } %>
                            <% if(colorCode != null && !colorCode.isEmpty()) { %>
                                <div class="item-details">顏色: <%= colorName %></div>
                            <% } %>
                        </div>
                        <div class="item-actions">
                            <a href="wardrobe3_Edit.jsp?memberId=<%= memberId %>&clothing_number=<%= clothing_number %>&category=<%= currentCategory %>" class="btn-edit">編輯</a>
                            <a href="wardrobe3_delete.jsp?memberId=<%= memberId %>&clothing_number=<%= clothing_number %>&category=<%= currentCategory %>" class="btn-delete" onclick="return confirm('確定要刪除這件衣物嗎?')">刪除</a>
                        </div>
                    </div>
                <% 
                    }
                }
                %>
            </div>
        </div>
    </div>
</body>
</html>