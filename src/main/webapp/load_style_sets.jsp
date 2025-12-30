<%@ page language="java" contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<%
response.setContentType("application/json");
String memberId = request.getParameter("memberId");

StringBuilder json = new StringBuilder();
json.append("{\"success\":true,\"styleSets\":[");

try {
    String dbPath = objDBConfig.FilePath();
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);
    
    // 查詢該會員的所有穿搭組合
    String sql = "SELECT commodity_title, pic, MIN(commodity_code) as min_code " +
             "FROM commodity_information " +
             "WHERE memberId = ? AND authorization = true " +
             "GROUP BY commodity_title, pic " +
             "ORDER BY MIN(commodity_code) DESC";
    
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setString(1, memberId);
    ResultSet rs = pstmt.executeQuery();
    
    boolean firstSet = true;
    while(rs.next()) {
        String title = rs.getString("commodity_title");
        String pic = rs.getString("pic");
        
        if(!firstSet) json.append(",");
        firstSet = false;
        
        json.append("{\"title\":\"").append(title.replace("\"", "\\\"")).append("\",");
        json.append("\"image\":\"").append(pic.replace("\\", "/")).append("\",");
        json.append("\"isActive\":true,");
        json.append("\"createdAt\":\"").append(new java.util.Date().toString()).append("\",");
        json.append("\"tags\":[");
        
        // ✅ 查詢該穿搭組合的所有商品標籤 (包含座標)
        String tagSql = "SELECT commodity_name, price, website, tag_x, tag_y " +
                       "FROM commodity_information " +
                       "WHERE memberId = ? AND commodity_title = ?";
        PreparedStatement tagPstmt = con.prepareStatement(tagSql);
        tagPstmt.setString(1, memberId);
        tagPstmt.setString(2, title);
        ResultSet tagRs = tagPstmt.executeQuery();
        
        boolean firstTag = true;
        while(tagRs.next()) {
            if(!firstTag) json.append(",");
            firstTag = false;
            
            json.append("{\"name\":\"").append(tagRs.getString("commodity_name").replace("\"", "\\\"")).append("\",");
            json.append("\"price\":\"").append(tagRs.getString("price")).append("\",");
            json.append("\"url\":\"").append(tagRs.getString("website").replace("\"", "\\\"")).append("\",");
            json.append("\"x\":").append(tagRs.getDouble("tag_x")).append(",");  // ✅ 讀取座標
            json.append("\"y\":").append(tagRs.getDouble("tag_y")).append("}");  // ✅ 讀取座標
        }
        
        json.append("]}");
        
        tagRs.close();
        tagPstmt.close();
    }
    
    rs.close();
    pstmt.close();
    con.close();
    
    json.append("]}");
    out.print(json.toString());
    
} catch(Exception e) {
    json = new StringBuilder();
    json.append("{\"success\":false,\"message\":\"").append(e.getMessage().replace("\"", "\\\"")).append("\"}");
    out.print(json.toString());
}
%>