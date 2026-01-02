<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@include file="menu.jsp" %>
<jsp:useBean id='objDBConfig' scope='session' class='CZ.group.tool.database.DBConfig' />

<%
try {
    // 取得要查看的用戶 ID
    String targetMemberId = request.getParameter("memberId");
    
    if(targetMemberId == null || targetMemberId.trim().isEmpty()) {
        response.sendRedirect("index1.jsp");
        return;
    }

    // 連接資料庫
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://"+objDBConfig.FilePath()+";");
    
    // 查詢用戶基本資料 - 使用 personal_information
    String userInfoSql = "SELECT * FROM personal_information WHERE account = ?";
    PreparedStatement pstmtUser = con.prepareStatement(userInfoSql);
    pstmtUser.setString(1, targetMemberId);
    ResultSet rsUser = pstmtUser.executeQuery();
    
    String userName = targetMemberId;
    String userGender = "未設定";
    String userBio = "";
    boolean userFound = false;
    
    if(rsUser.next()) {
        userFound = true;
        // 根據實際欄位名稱調整
        userName = rsUser.getString("name") != null ? rsUser.getString("name") : targetMemberId;
        userGender = rsUser.getString("sex") != null ? rsUser.getString("sex") : "未設定";
    }
    
    // 統計資料 - 從 personal_wear 查詢
    String statsSql = "SELECT COUNT(*) as postCount, " +
                      "SUM([like]) as totalLikes, " +
                      "SUM(collect) as totalCollects " +
                      "FROM personal_wear " +
                      "WHERE memberId = ? AND post_state = True " +
                      "GROUP BY memberId";
    PreparedStatement pstmtStats = con.prepareStatement(statsSql);
    pstmtStats.setString(1, targetMemberId);
    ResultSet rsStats = pstmtStats.executeQuery();
    
    int postCount = 0;
    int totalLikes = 0;
    int totalCollects = 0;
    if(rsStats.next()) {
        postCount = rsStats.getInt("postCount");
        totalLikes = rsStats.getInt("totalLikes");
        totalCollects = rsStats.getInt("totalCollects");
    }
    
    // 查詢該用戶的衣櫃資料 - 使用 my_wardrobe
    String wardrobeSql = "SELECT * FROM my_wardrobe WHERE account = ? ORDER BY ID DESC";
    PreparedStatement pstmtWardrobe = con.prepareStatement(wardrobeSql);
    pstmtWardrobe.setString(1, targetMemberId);
    ResultSet rsWardrobe = pstmtWardrobe.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%=userName%> 的個人頁面</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="css/vendor.css">
    <link rel="stylesheet" type="text/css" href="style.css">
    
    <style>
        body {
            background-color: #f8f5f0;
            font-family: 'Jost', sans-serif;
            padding-top: 80px;
        }
        
        .profile-header {
            background: linear-gradient(165deg, #a89f91 0%, #8f8c7f 100%);
            color: white;
            padding: 60px 0;
            margin-bottom: 40px;
        }
        
        .profile-avatar {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 60px;
            color: #a89f91;
            margin: 0 auto 20px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.2);
            font-weight: bold;
        }
        
        .profile-info h2 {
            font-size: 32px;
            margin-bottom: 10px;
            font-weight: 500;
        }
        
        .profile-username {
            font-size: 16px;
            opacity: 0.9;
            margin-bottom: 5px;
        }
        
        .profile-gender {
            font-size: 14px;
            opacity: 0.8;
            display: inline-block;
            padding: 4px 12px;
            background: rgba(255,255,255,0.2);
            border-radius: 15px;
            margin-top: 10px;
        }
        
        .profile-stats {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-number {
            font-size: 28px;
            font-weight: bold;
            display: block;
        }
        
        .stat-label {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .wardrobe-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 40px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }
        
        .wardrobe-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .wardrobe-item {
            border: 2px solid #f0ebe5;
            border-radius: 10px;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        
        .wardrobe-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(168, 159, 145, 0.3);
            border-color: #a89f91;
        }
        
        .wardrobe-item img {
            width: 100%;
            height: 250px;
            object-fit: cover;
        }
        
        .wardrobe-item-info {
            padding: 12px;
            background: #f8f5f0;
        }
        
        .wardrobe-item-name {
            font-weight: 500;
            color: #4a4239;
            margin-bottom: 5px;
            font-size: 14px;
        }
        
        .wardrobe-item-type {
            font-size: 13px;
            color: #6a6158;
        }
        
        .back-btn {
            background: white;
            color: #a89f91;
            border: 2px solid #a89f91;
            padding: 10px 30px;
            border-radius: 25px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            margin-bottom: 20px;
        }
        
        .back-btn:hover {
            background: #a89f91;
            color: white;
            text-decoration: none;
        }
        
        .empty-message {
            text-align: center;
            padding: 60px 20px;
            color: #999;
            font-size: 18px;
        }
        
        .section-title {
            font-size: 24px;
            color: #4a4239;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #a89f91;
        }
        
        .user-not-found {
            text-align: center;
            padding: 100px 20px;
        }
        
        .user-not-found-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<%
if(!userFound) {
%>
    <div class="container">
        <div class="user-not-found">
            <div class="user-not-found-icon">😔</div>
            <h2>找不到此用戶</h2>
            <p class="text-muted">用戶 @<%=targetMemberId%> 不存在或尚未建立個人資料</p>
            <a href="index1.jsp" class="back-btn mt-3">← 返回首頁</a>
        </div>
    </div>
<%
} else {
%>

<!-- 個人資料頁首 -->
<div class="profile-header">
    <div class="container">
        <a href="index1.jsp" class="back-btn">← 返回首頁</a>
        
        <div class="profile-info text-center">
            <div class="profile-avatar">
                <%= userName.substring(0, Math.min(2, userName.length())).toUpperCase() %>
            </div>
            
            <h2><%=userName%></h2>
            <p class="profile-username">@<%=targetMemberId%></p>
            <span class="profile-gender"><%=userGender%></span>
            
            <!-- 統計資料 -->
            <div class="profile-stats">
                <div class="stat-item">
                    <span class="stat-number"><%=postCount%></span>
                    <span class="stat-label">發文數</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number"><%=totalLikes%></span>
                    <span class="stat-label">獲得讚數</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number"><%=totalCollects%></span>
                    <span class="stat-label">獲得收藏</span>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 衣櫃區域 -->
<div class="container mb-5">
    <div class="wardrobe-section">
        <h3 class="section-title">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="vertical-align: middle; margin-right: 8px;">
                <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                <line x1="9" y1="3" x2="9" y2="21"></line>
            </svg>
            <%=userName%> 的衣櫃
        </h3>
        
        <%
        boolean hasItems = false;
        java.util.ArrayList<java.util.HashMap<String, String>> wardrobeList = new java.util.ArrayList<>();
        
        // 先把所有資料讀取到 ArrayList 中
        while(rsWardrobe.next()) { 
            hasItems = true;
            java.util.HashMap<String, String> item = new java.util.HashMap<>();
            
            // 根據 my_wardrobe 的實際欄位名稱調整
            item.put("pic", rsWardrobe.getString("pic"));
            item.put("name", rsWardrobe.getString("name") != null ? rsWardrobe.getString("name") : "未命名");
            item.put("type", rsWardrobe.getString("type") != null ? rsWardrobe.getString("type") : "未分類");
            
            wardrobeList.add(item);
        }
        %>
        
        <div class="wardrobe-grid">
            <% 
            for(java.util.HashMap<String, String> item : wardrobeList) { 
            %>
            <div class="wardrobe-item">
                <img src="<%=item.get("pic")%>" 
                     alt="<%=item.get("name")%>"
                     onerror="this.style.display='none'; this.parentElement.innerHTML='<div style=\'padding:50px;text-align:center;color:#999;background:#f8f5f0;height:250px;display:flex;align-items:center;justify-content:center;\'>📷<br>圖片載入失敗</div>'">
                <div class="wardrobe-item-info">
                    <div class="wardrobe-item-name"><%=item.get("name")%></div>
                    <div class="wardrobe-item-type"><%=item.get("type")%></div>
                </div>
            </div>
            <% } %>
        </div>
        
        <% if(!hasItems) { %>
        <div class="empty-message">
            <p>😊 此用戶的衣櫃還是空的</p>
            <p style="font-size: 14px; color: #bbb;">尚未新增任何衣物</p>
        </div>
        <% } %>
    </div>
</div>

<%
}
%>

<%
    // 關閉資源
    if(rsWardrobe != null) rsWardrobe.close();
    if(pstmtWardrobe != null) pstmtWardrobe.close();
    if(rsStats != null) rsStats.close();
    if(pstmtStats != null) pstmtStats.close();
    if(rsUser != null) rsUser.close();
    if(pstmtUser != null) pstmtUser.close();
    if(con != null) con.close();
    
} catch(Exception e) {
    out.println("<div class='container mt-5' style='padding-top:100px;'>");
    out.println("<div class='alert alert-danger'>");
    out.println("<h2>❌ 發生錯誤</h2>");
    out.println("<p><strong>錯誤訊息：</strong>" + e.getMessage() + "</p>");
    out.println("<hr>");
    out.println("<details>");
    out.println("<summary>詳細錯誤資訊（點擊展開）</summary>");
    out.println("<pre style='text-align:left; font-size:12px; margin-top:10px;'>");
    e.printStackTrace(new PrintWriter(out));
    out.println("</pre>");
    out.println("</details>");
    out.println("<a href='index1.jsp' class='btn btn-primary mt-3'>返回首頁</a>");
    out.println("</div>");
    out.println("</div>");
}
%>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>