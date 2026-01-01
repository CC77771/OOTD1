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

    // ✅ 修正 1：使用 File.separator 取代 \\
    String savePath = application.getRealPath("/") + File.separator + "images";
    
    // ✅ 修正 2：詳細的資料夾建立檢查
    File saveDir = new File(savePath);
    
    out.println("<!-- ===== 除錯資訊 ===== -->");
    out.println("<!-- 完整儲存路徑: " + savePath + " -->");
    out.println("<!-- 資料夾是否存在: " + saveDir.exists() + " -->");
    out.println("<!-- 資料夾是否可寫: " + saveDir.canWrite() + " -->");
    
    if (!saveDir.exists()) {
        boolean created = saveDir.mkdirs();
        out.println("<!-- 嘗試建立資料夾: " + created + " -->");
        
        if (!created) {
            throw new Exception("無法建立資料夾: " + savePath);
        }
    }
    
    // ✅ 修正 3：確認資料夾權限
    if (!saveDir.canWrite()) {
        throw new Exception("資料夾無寫入權限: " + savePath);
    }

    int maxSize = 5 * 1024 * 1024;
    MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

    String styleTitle = multi.getParameter("styleTitle");
    String tagsData = multi.getParameter("tagsData");
    String memberId = (String) session.getAttribute("accessId");

    String fileName = multi.getFilesystemName("styleImage");
    
    // ✅ 修正 4：檢查檔案是否成功上傳
    out.println("<!-- 上傳的檔案名稱: " + fileName + " -->");
    
    if (fileName == null || fileName.trim().isEmpty()) {
        throw new Exception("檔案上傳失敗，沒有收到圖片");
    }
    
    // ✅ 修正 5：檢查檔案是否真的存在
    File uploadedFile = new File(savePath + File.separator + fileName);
    out.println("<!-- 檔案完整路徑: " + uploadedFile.getAbsolutePath() + " -->");
    out.println("<!-- 檔案是否存在: " + uploadedFile.exists() + " -->");
    out.println("<!-- 檔案大小: " + uploadedFile.length() + " bytes -->");
    
    // ✅ 修正 6：使用正斜線儲存到資料庫（網頁路徑）
    String picPath = "images/" + fileName;
    out.println("<!-- 資料庫儲存路徑: " + picPath + " -->");

    out.println("<!-- styleTitle: " + styleTitle + " -->");
    out.println("<!-- tagsData: " + tagsData + " -->");
    out.println("<!-- memberId: " + memberId + " -->");

    String dbPath = objDBConfig.FilePath();
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);

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

    PreparedStatement pstmt = null;
    String insertSql = "INSERT INTO commodity_information (commodity_code, memberId, commodity_title, pic, commodity_name, price, website, authorization, tag_x, tag_y) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    int count = 0;
    while(matcher.find()) {
        maxCode++;
        String commodityCode = String.valueOf(maxCode);

        String commodityName = matcher.group(1);
        String price = matcher.group(2);
        String url = matcher.group(3);
        double tagX = Double.parseDouble(matcher.group(4));
        double tagY = Double.parseDouble(matcher.group(5));

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
        pstmt.setDouble(9, tagX);
        pstmt.setDouble(10, tagY);

        pstmt.executeUpdate();
        pstmt.close();
        count++;
    }

    con.close();
    out.println("<!-- 成功新增 " + count + " 個商品標籤! -->");
    out.println("<!-- ===== 除錯資訊結束 ===== -->");
    response.setStatus(200);
    out.println("SUCCESS: 已成功新增 " + count + " 筆資料至資料庫");

} catch(Exception e) {
    out.println("<!-- ===== 發生錯誤 ===== -->");
    out.println("<!-- 錯誤訊息: " + e.getMessage() + " -->");
    out.println("<!-- 詳細堆疊: -->");
    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    e.printStackTrace(pw);
    out.println("<!-- " + sw.toString() + " -->");
    out.println("<!-- ===== 錯誤資訊結束 ===== -->");
    response.setStatus(500);
    out.println("ERROR: " + e.getMessage());
}
%>