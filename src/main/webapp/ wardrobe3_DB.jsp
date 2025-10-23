<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@page import="CZ.group.tool.database.DBConfig"%>

<%
// 設定圖片上傳路徑
String savePath = application.getRealPath("/") + "images\\wardrobe";
File saveDir = new File(savePath);
if (!saveDir.exists()) {
    saveDir.mkdirs();
}

// 設定上傳檔案大小限制 (5MB)
int maxSize = 5 * 1024 * 1024;

// 處理檔案上傳
MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "UTF-8", new DefaultFileRenamePolicy());

// 取得表單資料
String memberId = new String(multi.getParameter("memberId"));
String clothing_code = new String(multi.getParameter("clothing_code"));
String text_description = new String(multi.getParameter("text_description"));
String types_of_clothes = new String(multi.getParameter("types_of_clothes"));
String color_code = new String(multi.getParameter("color_code"));

// 取得上傳的檔案名稱
String fileName = multi.getFilesystemName("clothingImage");
String pic = "images/wardrobe/" + fileName;

// 連接資料庫
DBConfig dbConfig = new DBConfig();
String dbPath = dbConfig.FilePath();
Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);
Statement smt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

// 執行 SQL
smt.executeUpdate("INSERT INTO my_wardrobe VALUES('" + memberId + "','" + clothing_code + "','" + text_description + "','" + types_of_clothes + "','" + pic + "','" + color_code + "')");

// 除錯用：印出 SQL
out.println("INSERT INTO my_wardrobe VALUES('" + memberId + "','" + clothing_code + "','" + text_description + "','" + types_of_clothes + "','" + pic + "','" + color_code + "')");

// 關閉連接
con.close();

// 導向回衣櫥頁面
response.sendRedirect("my_wardrobe3.jsp");
%>