<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.security.MessageDigest"%>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>更新個人資料</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f1f1f0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .message-box {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 500px;
        }
        .success {
            color: #28a745;
        }
        .error {
            color: #dc3545;
        }
        .loading {
            color: #17a2b8;
        }
    </style>
</head>
<body>
    <div class="message-box">
<%
    request.setCharacterEncoding("UTF-8");
    
    String memberId = request.getParameter("memberId");
    String nickName = request.getParameter("nickName");
    String gendercode = request.getParameter("gendercode");
    String born = request.getParameter("born");
    String email = request.getParameter("Email");
    String currentPassword = request.getParameter("currentPassword");
    String newPassword = request.getParameter("newPassword");
    
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 檢查必填欄位
        if (nickName == null || nickName.trim().isEmpty()) {
            out.println("<h2 class='error'>❌ 錯誤</h2>");
            out.println("<p>暱稱不能為空！</p>");
            out.println("<p><a href='javascript:history.back()'>返回修改</a></p>");
            return;
        }
        
        if (gendercode == null || gendercode.trim().isEmpty()) {
            out.println("<h2 class='error'>❌ 錯誤</h2>");
            out.println("<p>請選擇性別！</p>");
            out.println("<p><a href='javascript:history.back()'>返回修改</a></p>");
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            out.println("<h2 class='error'>❌ 錯誤</h2>");
            out.println("<p>電子信箱不能為空！</p>");
            out.println("<p><a href='javascript:history.back()'>返回修改</a></p>");
            return;
        }
        
        // 如果要修改密碼
        boolean updatePassword = false;
        if (currentPassword != null && !currentPassword.trim().isEmpty() && 
            newPassword != null && !newPassword.trim().isEmpty()) {
            
            // 驗證目前密碼
            String checkPwdSql = "SELECT memberPwd FROM personal_information WHERE memberId = ?";
            pstmt = con.prepareStatement(checkPwdSql);
            pstmt.setString(1, memberId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String dbPassword = rs.getString("memberPwd");
                
                // 這裡假設密碼是明文存儲，如果是加密的需要對應處理
                if (!currentPassword.equals(dbPassword)) {
                    out.println("<h2 class='error'>❌ 錯誤</h2>");
                    out.println("<p>目前密碼不正確！</p>");
                    out.println("<p><a href='javascript:history.back()'>返回修改</a></p>");
                    return;
                }
                updatePassword = true;
            }
            
            if (pstmt != null) pstmt.close();
            if (rs != null) rs.close();
        }
        
        // 更新基本資料
        String updateSql;
        if (updatePassword) {
            updateSql = "UPDATE personal_information SET nickName = ?, gendercode = ?, born = ?, Email = ?, memberPwd = ? WHERE memberId = ?";
        } else {
            updateSql = "UPDATE personal_information SET nickName = ?, gendercode = ?, born = ?, Email = ? WHERE memberId = ?";
        }
        
        pstmt = con.prepareStatement(updateSql);
        pstmt.setString(1, nickName);
        pstmt.setString(2, gendercode);
        
        // 處理生日（可為空）
        if (born != null && !born.trim().isEmpty()) {
            pstmt.setString(3, born);
        } else {
            pstmt.setNull(3, java.sql.Types.VARCHAR);
        }
        
        pstmt.setString(4, email);
        
        if (updatePassword) {
            pstmt.setString(5, newPassword);
            pstmt.setString(6, memberId);
        } else {
            pstmt.setString(5, memberId);
        }
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            // ✅ 更新成功，立即跳轉到 member.jsp
            response.sendRedirect("member.jsp?memberId=" + memberId);
        } else {
            // ❌ 更新失敗
            response.sendRedirect("memberEdit1.jsp?memberId=" + memberId + "&error=update_failed");
        }
        
    } catch (Exception e) {
        out.println("<h2 class='error'>❌ 系統錯誤</h2>");
        out.println("<p>發生錯誤：" + e.getMessage() + "</p>");
        out.println("<p><a href='javascript:history.back()'>返回修改</a></p>");
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
    </div>
</body>
</html>