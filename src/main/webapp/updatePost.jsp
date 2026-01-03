<%@page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<jsp:useBean id='objDBConfig' scope='application' class='CZ.group.tool.database.DBConfig' />
<%
    request.setCharacterEncoding("utf-8");
    response.setContentType("text/plain; charset=utf-8");

    String postid = request.getParameter("postid");
    String wearId = request.getParameter("wearId");
    String tags = request.getParameter("tags");

    // 除錯訊息
    System.out.println("========== updatePost.jsp 接收資料 ==========");
    System.out.println("postid: [" + postid + "]");
    System.out.println("wearId: [" + wearId + "]");
    System.out.println("tags: [" + tags + "]");
    System.out.println("==========================================");

    if (postid == null || postid.trim().isEmpty()) {
        System.out.println("錯誤: postid 為空");
        out.print("error: postid is null");
        return;
    }

    Connection con = null;
    PreparedStatement checkStmt = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
        con = DriverManager.getConnection("jdbc:ucanaccess://" + objDBConfig.FilePath() + ";memory=false;");
        con.setAutoCommit(false);
        System.out.println("資料庫連線成功");

        // 先查詢該 postid 的第一筆記錄的 recordid
        String querySql = "SELECT MIN([recordid]) as minRecordId FROM [personal_wear] WHERE [postid] = ?";
        checkStmt = con.prepareStatement(querySql);
        checkStmt.setString(1, postid);
        rs = checkStmt.executeQuery();

        Integer targetRecordId = null;
        if (rs.next()) {
            targetRecordId = rs.getInt("minRecordId");
            if (rs.wasNull()) {
                System.out.println("錯誤: 找不到該 postid 的記錄");
                out.print("error: postid not found");
                con.rollback();
                return;
            }
            System.out.println("目標 recordid: " + targetRecordId);
        } else {
            out.print("error: postid not found");
            con.rollback();
            return;
        }

        rs.close();
        checkStmt.close();

        // 使用 Access 語法更新：方括號包欄位名，用 & 串接 tags
        // 如果 tags 是要「追加」內容，使用: [tags] & ',' & ?
        // 如果 tags 是要「完全取代」，使用: ?
        String sql = "UPDATE [personal_wear] SET [wearId] = ?, [tags] = ? WHERE [recordid] = ?";

pstmt = con.prepareStatement(sql);
pstmt.setString(1, wearId != null ? wearId : "");
pstmt.setString(2, tags != null ? tags : ""); // 不加逗號，直接取代
pstmt.setInt(3, targetRecordId);

        System.out.println("執行 SQL: " + sql);
        System.out.println("參數1 wearId: [" + wearId + "]");
        System.out.println("參數2 tags (追加): [" + tags + "]");
        System.out.println("參數3 recordid: " + targetRecordId);

        int rowsAffected = pstmt.executeUpdate();
        System.out.println("影響的行數: " + rowsAffected);

        con.commit();
        System.out.println("交易已提交");

        pstmt.close();

        // 驗證更新結果
        String verifySql = "SELECT [wearId], [tags] FROM [personal_wear] WHERE [recordid] = ?";
        PreparedStatement verifyStmt = con.prepareStatement(verifySql);
        verifyStmt.setInt(1, targetRecordId);
        ResultSet verifyRs = verifyStmt.executeQuery();
        
        if (verifyRs.next()) {
            String updatedWearId = verifyRs.getString("wearId");
            String updatedTags = verifyRs.getString("tags");
            System.out.println("===== 更新後的值 =====");
            System.out.println("wearId: [" + updatedWearId + "]");
            System.out.println("tags: [" + updatedTags + "]");
            System.out.println("=====================");
        }
        verifyRs.close();
        verifyStmt.close();

        if (rowsAffected > 0) {
            out.print("success");
        } else {
            out.print("error: no rows updated");
        }

    } catch (Exception e) {
        System.out.println("例外錯誤: " + e.getMessage());
        e.printStackTrace();
        if (con != null) {
            try {
                con.rollback();
                System.out.println("交易已回滾");
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        out.print("error: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (checkStmt != null) checkStmt.close();
            if (pstmt != null) pstmt.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
                System.out.println("資料庫連線已關閉");
            }
        } catch (SQLException e) {
            System.out.println("關閉資源時發生錯誤: " + e.getMessage());
        }
    }
%>