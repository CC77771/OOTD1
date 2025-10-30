<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<jsp:useBean id="objFolderConfig" scope="session" class="CZ.group.tool.upload.FolderConfig2" />

<%
// 設定圖片上傳路徑
String savePath = application.getRealPath("/") + "images\\my_wardrobe";
File saveDir = new File(savePath);
if (!saveDir.exists()) {
    saveDir.mkdirs();
}

// 設定上傳檔案大小限制 (5MB)
int maxSize = 5 * 1024 * 1024;

// 處理檔案上傳
MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

// 取得表單資料
String memberId = multi.getParameter("memberId");
String clothing_code = multi.getParameter("clothing_code");
String text_description = multi.getParameter("text_description");
String brand = multi.getParameter("brand");
String color_code = multi.getParameter("color_code");

System.out.println("memberId: " + memberId);
System.out.println("clothing_code: " + clothing_code);
System.out.println("brand: " + brand);
// 取得上傳的檔案名稱
String fileName = multi.getFilesystemName("clothingImage");
String pic = "images/my_wardrobe/" + fileName;

// 連接資料庫
String dbPath = objDBConfig.FilePath();
Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);

// 使用 PreparedStatement 防止 SQL Injection
String sql = "INSERT INTO my_wardrobe (memberId, clothing_code, text_description, brand, pic, color_code) VALUES(?, ?, ?, ?, ?, ?)";
PreparedStatement pstmt = con.prepareStatement(sql);
pstmt.setString(1, memberId);
pstmt.setString(2, clothing_code);
pstmt.setString(3, text_description);
pstmt.setString(4, brand);
pstmt.setString(5, pic);
pstmt.setString(6, color_code);

// 執行 SQL
pstmt.executeUpdate();

// 除錯用：印出 SQL
out.println("資料已成功新增");

// 關閉連接
pstmt.close();
con.close();

// 導向回衣櫥頁面
response.sendRedirect("my_wardrobe3.jsp");
%>