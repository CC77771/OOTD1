<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<%
    response.setContentType("text/plain");
    response.setCharacterEncoding("utf-8");
    
    String postid = request.getParameter("postid");
    String memberId = (String) session.getAttribute("accessId");
    
    // 驗證參數
    if (postid == null || postid.trim().isEmpty() || memberId == null) {
        out.print("error");
        return;
    }
    
    Connection con = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";");
        
        // 更新 post_state 為 false (軟刪除)
        String sql = "UPDATE personal_wear SET post_state = False WHERE postid = ? AND memberId = ?";
        pstmt = con.prepareStatement(sql);
        pstmt.setString(1, postid);
        pstmt.setString(2, memberId);
        
        int rowsAffected = pstmt.executeUpdate();
        
        if (rowsAffected > 0) {
            out.print("success");
        } else {
            out.print("error");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("error");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (con != null) try { con.close(); } catch(Exception e) {}
    }
%>