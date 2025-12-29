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

    // 設定圖片上傳路徑
    String savePath = application.getRealPath("/") + "images\\style_sets";
    File saveDir = new File(savePath);
    if (!saveDir.exists()) {
        saveDir.mkdirs();
    }

    // 設定上傳檔案大小限制 (5MB)
    int maxSize = 5 * 1024 * 1024;

    // 處理檔案上傳
    MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

    // 取得表單資料
    String styleTitle = multi.getParameter("styleTitle");
    String tagsData = multi.getParameter("tagsData"); // JSON 格式的標籤資料
    String memberId = multi.getParameter("memberId"); // 從表單取得 memberId

    // 取得上傳的檔案名稱
    String fileName = multi.getFilesystemName("styleImage");
    String picPath = "images/style_sets/" + fileName;

    // 除錯輸出
    out.println("<!--");
    out.println("styleTitle: " + styleTitle);
    out.println("tagsData: " + tagsData);
    out.println("memberId: " + memberId);
    out.println("fileName: " + fileName);
    out.println("picPath: " + picPath);
    out.println("-->");

    // 連接資料庫
    String dbPath = objDBConfig.FilePath();
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);

    // 手動解析 JSON 字串
    // 格式: [{"name":"咖啡外套","price":"750","url":"https://...","x":20,"y":30},...]
    Pattern pattern = Pattern.compile("\\{\"name\":\"([^\"]*)\",\"price\":\"([^\"]*)\",\"url\":\"([^\"]*)\"");
    Matcher matcher = pattern.matcher(tagsData);

    // 取得目前最大的 commodity_code 以產生新的代碼
    String getMaxCodeSql = "SELECT MAX(VAL(commodity_code)) as maxCode FROM commodity_information";
    Statement stmt = con.createStatement();
    ResultSet rs = stmt.executeQuery(getMaxCodeSql);
    int maxCode = 0;
    if(rs.next()) {
        maxCode = rs.getInt("maxCode");
    }
    rs.close();
    stmt.close();

    // 為每個標籤建立一筆資料
    // 更新 SQL 以符合資料表結構：commodity_code, memberId, commodity_title, pic, commodity_name, price, website, authorization
    PreparedStatement pstmt = null;
    String insertSql = "INSERT INTO commodity_information (commodity_code, memberId, commodity_title, pic, commodity_name, price, website, authorization) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";

    int count = 0;
    while(matcher.find()) {
        // 產生新的 commodity_code
        maxCode++;
        String commodityCode = String.valueOf(maxCode);
        
        // 取得標籤資料
        String commodityName = matcher.group(1);  // 商品名稱
        String price = matcher.group(2);          // 價格
        String url = matcher.group(3);            // 蝦皮連結
        
        // 除錯輸出
        out.println("<!-- 第 " + count + " 個標籤: " + commodityName + ", $" + price + ", " + url + " -->");
        
        // 執行插入
        pstmt = con.prepareStatement(insertSql);
        pstmt.setString(1, commodityCode);        // commodity_code
        pstmt.setString(2, memberId);             // memberId (從表單取得)
        pstmt.setString(3, styleTitle);           // commodity_title (穿搭組合標題)
        pstmt.setString(4, picPath);              // pic (穿搭組合圖片)
        pstmt.setString(5, commodityName);        // commodity_name (商品名稱)
        pstmt.setString(6, price);                // price (價格)
        pstmt.setString(7, url);                  // website (蝦皮連結)
        pstmt.setBoolean(8, true);                // authorization (預設為已授權)
        
        pstmt.executeUpdate();
        pstmt.close();
        count++;
    }

    // 關閉連接
    con.close();

    out.println("<!-- 成功新增 " + count + " 個商品標籤! -->");
    
    // 回傳成功訊息
    response.setStatus(200);
    out.println("SUCCESS: 已成功新增 " + count + " 筆資料至資料庫");

} catch(Exception e) {
    out.println("<!-- 錯誤: " + e.getMessage() + " -->");
    e.printStackTrace(new PrintWriter(out));
    response.setStatus(500);
    out.println("ERROR: " + e.getMessage());
}
%>