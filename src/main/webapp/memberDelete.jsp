<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>刪除帳號</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f1f1f0;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .message-box {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 500px;
            width: 100%;
        }
        .message-box h2 {
            margin-bottom: 20px;
        }
        .message-box p {
            margin: 15px 0;
            line-height: 1.6;
        }
        .success {
            color: #28a745;
        }
        .error {
            color: #dc3545;
        }
        .warning {
            color: #ffc107;
        }
        .loading {
            color: #17a2b8;
        }
        .icon-large {
            font-size: 64px;
            margin-bottom: 20px;
        }
        .btn {
            display: inline-block;
            padding: 12px 30px;
            margin: 10px 5px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
        }
        .btn-danger {
            background-color: #dc3545;
            color: white;
        }
        .btn-danger:hover {
            background-color: #c82333;
        }
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        .warning-box {
            background-color: #fff3cd;
            border: 2px solid #ffc107;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .warning-box ul {
            text-align: left;
            margin: 10px 0;
            padding-left: 20px;
        }
        .warning-box li {
            margin: 8px 0;
            color: #856404;
        }
    </style>
</head>
<body>
    <div class="message-box">
<%
    request.setCharacterEncoding("UTF-8");
    
    String memberId = request.getParameter("memberId");
    String confirm = request.getParameter("confirm");
    
    // 驗證 memberId
    if (memberId == null || memberId.trim().isEmpty()) {
        memberId = (String) session.getAttribute("accessId");
    }
    
    // 如果還沒確認，顯示確認頁面
    if (confirm == null || !confirm.equals("yes")) {
%>
        <i class="fas fa-exclamation-triangle icon-large warning"></i>
        <h2 class="warning">⚠️ 刪除帳號確認</h2>
        
        <div class="warning-box">
            <p><strong>刪除帳號後，以下資料將永久清除：</strong></p>
            <ul>
                <li>個人基本資料（暱稱、信箱、生日等）</li>
                <li>所有發布的貼文</li>
                <li>所有留言與互動記錄</li>
                <li>我的衣櫃資料</li>
                <li>收藏與按讚記錄</li>
                <li>大頭照與相關圖片</li>
            </ul>
            <p style="color: #dc3545; font-weight: bold; margin-top: 15px;">
                ❗ 此操作無法復原，請謹慎考慮！
            </p>
        </div>
        
        <p style="margin: 20px 0;">確定要刪除您的帳號嗎？</p>
        
        <div style="margin-top: 30px;">
            <a href="member.jsp" class="btn btn-secondary">
                <i class="fas fa-times"></i> 取消，返回會員頁面
            </a>
            <a href="memberDelete.jsp?memberId=<%= memberId %>&confirm=yes" class="btn btn-danger">
                <i class="fas fa-trash-alt"></i> 確定刪除帳號
            </a>
        </div>
<%
    } else {
        // 執行刪除操作
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
            con.setAutoCommit(false); // 開始交易
            
            // 1. 刪除個人貼文相關資料
            String deletePostsSql = "DELETE FROM personal_wear WHERE memberId = ?";
            pstmt = con.prepareStatement(deletePostsSql);
            pstmt.setString(1, memberId);
            int postsDeleted = pstmt.executeUpdate();
            pstmt.close();
            
            // 2. 刪除衣櫃資料（如果有相關表）
            // String deleteWardrobeSql = "DELETE FROM wardrobe WHERE memberId = ?";
            // pstmt = con.prepareStatement(deleteWardrobeSql);
            // pstmt.setString(1, memberId);
            // pstmt.executeUpdate();
            // pstmt.close();
            
            // 3. 刪除收藏與按讚記錄（根據你的資料庫結構調整）
            // String deleteFavoritesSql = "DELETE FROM favorites WHERE memberId = ?";
            // pstmt = con.prepareStatement(deleteFavoritesSql);
            // pstmt.setString(1, memberId);
            // pstmt.executeUpdate();
            // pstmt.close();
            
            // 4. 最後刪除會員主資料
            String deleteMemberSql = "DELETE FROM personal_information WHERE memberId = ?";
            pstmt = con.prepareStatement(deleteMemberSql);
            pstmt.setString(1, memberId);
            int memberDeleted = pstmt.executeUpdate();
            
            if (memberDeleted > 0) {
                con.commit(); // 提交交易
                
                // 清除 session
                session.invalidate();
                
                out.println("<i class='fas fa-check-circle icon-large success'></i>");
                out.println("<h2 class='success'>✅ 帳號已刪除</h2>");
                out.println("<p>您的帳號及相關資料已成功刪除。</p>");
                out.println("<p>刪除統計：</p>");
                out.println("<ul style='text-align: left; display: inline-block;'>");
                out.println("<li>貼文資料：" + postsDeleted + " 筆</li>");
                out.println("<li>會員資料：1 筆</li>");
                out.println("</ul>");
                out.println("<p class='loading'>3秒後自動跳轉到首頁...</p>");
                out.println("<script>");
                out.println("setTimeout(function() {");
                out.println("    location.href = 'index.jsp';"); // 修改為你的首頁
                out.println("}, 3000);");
                out.println("</script>");
            } else {
                con.rollback(); // 回滾交易
                out.println("<i class='fas fa-times-circle icon-large error'></i>");
                out.println("<h2 class='error'>❌ 刪除失敗</h2>");
                out.println("<p>無法找到該會員資料。</p>");
                out.println("<p><a href='member.jsp' class='btn btn-secondary'>返回會員頁面</a></p>");
            }
            
        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback(); // 發生錯誤時回滾
                } catch (SQLException se) {
                    se.printStackTrace();
                }
            }
            
            out.println("<i class='fas fa-exclamation-circle icon-large error'></i>");
            out.println("<h2 class='error'>❌ 系統錯誤</h2>");
            out.println("<p>刪除過程中發生錯誤：" + e.getMessage() + "</p>");
            out.println("<p><a href='member.jsp' class='btn btn-secondary'>返回會員頁面</a></p>");
            e.printStackTrace();
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>
    </div>
</body>
</html>