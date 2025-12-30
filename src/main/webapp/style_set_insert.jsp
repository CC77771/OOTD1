<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@page import="java.util.regex.*"%>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<jsp:useBean id="objFolderConfig" scope="session" class="CZ.group.tool.upload.FolderConfig2" />
<%
try {
    request.setCharacterEncoding("UTF-8");

    String savePath = application.getRealPath("/") + "images\\style_sets";
    File saveDir = new File(savePath);
    if (!saveDir.exists()) {
        saveDir.mkdirs();
    }

    int maxSize = 5 * 1024 * 1024;
    MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

    String styleTitle = multi.getParameter("styleTitle");
    String tagsData = multi.getParameter("tagsData");
    String memberId = (String) session.getAttribute("accessId");

    String fileName = multi.getFilesystemName("styleImage");
    String picPath = "images/style_sets/" + fileName;

    out.println("<!--");
    out.println("styleTitle: " + styleTitle);
    out.println("tagsData: " + tagsData);
    out.println("memberId: " + memberId);
    out.println("-->");

    String dbPath = objDBConfig.FilePath();
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);

    // ✅ 修改正則表達式,擷取 x, y 座標
    Pattern pattern = Pattern.compile("\\{\"name\":\"([^\"]*)\",\"price\":\"([^\"]*)\",\"url\":\"([^\"]*)\",\"x\":([\\d.]+),\"y\":([\\d.]+)");
    Matcher matcher = pattern.matcher(tagsData);

    String getMaxCodeSql = "SELECT MAX(VAL(commodity_code)) as maxCode FROM commodity_information";
    Statement stmt = con.createStatement();
    ResultSet rs = stmt.executeQuery(getMaxCodeSql);
    int maxCode = 0;
    if(rs.next()) {
        maxCode = rs.getInt("maxCode");
    }
    rs.close();
    stmt.close();

    // ✅ 修改 SQL,加入 tag_x 和 tag_y
    PreparedStatement pstmt = null;
    String insertSql = "INSERT INTO commodity_information (commodity_code, memberId, commodity_title, pic, commodity_name, price, website, authorization, tag_x, tag_y) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    int count = 0;
    while(matcher.find()) {
        maxCode++;
        String commodityCode = String.valueOf(maxCode);
        
        String commodityName = matcher.group(1);
        String price = matcher.group(2);
        String url = matcher.group(3);
        double tagX = Double.parseDouble(matcher.group(4));  // ✅ 取得 X 座標
        double tagY = Double.parseDouble(matcher.group(5));  // ✅ 取得 Y 座標
        
        out.println("<!-- 標籤 " + count + ": " + commodityName + ", X=" + tagX + ", Y=" + tagY + " -->");
        
        pstmt = con.prepareStatement(insertSql);
        pstmt.setString(1, commodityCode);
        pstmt.setString(2, memberId);
        pstmt.setString(3, styleTitle);
        pstmt.setString(4, picPath);
        pstmt.setString(5, commodityName);
        pstmt.setString(6, price);
        pstmt.setString(7, url);
        pstmt.setBoolean(8, true);
        pstmt.setDouble(9, tagX);   // ✅ 儲存 X 座標
        pstmt.setDouble(10, tagY);  // ✅ 儲存 Y 座標
        
        pstmt.executeUpdate();
        pstmt.close();
        count++;
    }

    con.close();
    out.println("<!-- 成功新增 " + count + " 個商品標籤! -->");
    response.setStatus(200);
    out.println("SUCCESS: 已成功新增 " + count + " 筆資料至資料庫");

} catch(Exception e) {
    out.println("<!-- 錯誤: " + e.getMessage() + " -->");
    e.printStackTrace(new PrintWriter(out));
    response.setStatus(500);
    out.println("ERROR: " + e.getMessage());
}
%>