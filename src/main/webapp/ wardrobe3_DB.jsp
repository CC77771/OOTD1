<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>

<%
// 設定圖片上傳路徑
String savePath = "C:\\Users\\My\\eclipse-workspace\\CZ\\OOTD1\\OOTD1\\src\\main\\webapp\\images";
// 或使用相對路徑
// String savePath = application.getRealPath("/") + "images\\wardrobe";

File saveDir = new File(savePath);
if (!saveDir.exists()) {
    saveDir.mkdirs();
}

// 設定上傳檔案大小限制 (50MB)
int maxSize = 50 * 1024 * 1024;

Connection con = null;
Statement smt = null;

try {
    // 處理檔案上傳
    MultipartRequest multi = new MultipartRequest(
        request,
        savePath,
        maxSize,
        "UTF-8",
        new DefaultFileRenamePolicy()
    );

    // 取得表單資料
    String memberId = multi.getParameter("memberId");
    String clothing_code = multi.getParameter("clothing_code");
    String text_description = multi.getParameter("text_description");
    String types_of_clothes = multi.getParameter("types_of_clothes");
    String color_code = multi.getParameter("color_code");

    // 取得上傳的檔案名稱
    String fileName = multi.getFilesystemName("clothingImage");
    String wearing_display = "images/wardrobe/" + fileName;

    // 連接 Access 資料庫
    String dbPath = "C:\\Users\\My\\eclipse-workspace\\CZ\\OOTD1\\OOTD1\\src\\main\\webapp\\OOTD1.accdb";
    String dbURL = "jdbc:ucanaccess://" + dbPath;
    
    // 載入 UCanAccess 驅動程式
    Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
    con = DriverManager.getConnection(dbURL);
    
    smt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

    // 建立 SQL 語句
    String sql = "INSERT INTO my_wardrobe (memberId, clothing_code, text_description, types_of_clothes, wearing_display, color_code) " +
                 "VALUES('" + memberId + "','" + clothing_code + "','" + text_description + "','" +
                 types_of_clothes + "','" + wearing_display + "','" + color_code + "')";

    // 執行新增
    smt.executeUpdate(sql);

    out.println("<script>");
    out.println("alert('衣物新增成功！');");
    out.println("window.location.href='my_wardrobe3.jsp';");
    out.println("</script>");

} catch(Exception e) {
    out.println("<script>");
    out.println("alert('新增失敗：" + e.getMessage().replace("'", "\\'") + "');");
    out.println("history.back();");
    out.println("</script>");
    e.printStackTrace();
} finally {
    if (smt != null) try { smt.close(); } catch(Exception e) {}
    if (con != null) try { con.close(); } catch(Exception e) {}
}
%>