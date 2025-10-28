<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />

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
String oldClothingCode = multi.getParameter("oldClothingCode");
String clothing_code = multi.getParameter("clothing_code");
String text_description = multi.getParameter("text_description");
String brand = multi.getParameter("brand");
String color_code = multi.getParameter("color_code");

// 取得圖片路徑
String pic = multi.getParameter("oldPic"); // 預設使用舊圖片
String fileName = multi.getFilesystemName("clothingImage");
if(fileName != null && !fileName.isEmpty()) {
    // 如果有上傳新圖片，使用新圖片
    pic = "images/my_wardrobe/" + fileName;
}

// 連接資料庫
String dbPath = objDBConfig.FilePath();
Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);

// 更新資料
String sql = "UPDATE my_wardrobe SET clothing_code = ?, text_description = ?, brand = ?, pic = ?, color_code = ? WHERE memberId = ? AND clothing_code = ?";
PreparedStatement pstmt = con.prepareStatement(sql);
pstmt.setString(1, clothing_code);
pstmt.setString(2, text_description);
pstmt.setString(3, brand);
pstmt.setString(4, pic);
pstmt.setString(5, color_code);
pstmt.setString(6, memberId);
pstmt.setString(7, oldClothingCode);

// 執行 SQL
int result = pstmt.executeUpdate();

// 關閉連接
pstmt.close();
con.close();





//... 你的更新邏輯

if(result > 0) {
 // 根據 clothing_code 決定跳轉的分類
 String category = "";
 switch(clothing_code) {
     case "1": category = "衣服"; break;
     case "2": category = "褲子"; break;
     case "3": category = "裙子"; break;
     case "4": category = "連身裙/褲"; break;
     case "5": category = "配件"; break;
     case "6": category = "鞋子"; break;
     default: category = "衣服";
 }
 
 out.println("<script>alert('更新成功!'); window.location.href='my_wardrobe3.jsp?category=" + category + "';</script>");
} else {
 out.println("<script>alert('更新失敗!'); window.history.back();</script>");
}
%>