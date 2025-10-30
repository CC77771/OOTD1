<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<jsp:useBean id="objDBConfig" scope="session" class="CZ.group.tool.database.DBConfig" />
<jsp:useBean id="objFolderConfig" scope="session" class="CZ.group.tool.upload.FolderConfig2" />

<%
// 設定圖片上傳路徑
String savePath = application.getRealPath("/") + "images/my_wardrobe";
File saveDir = new File(savePath);
if (!saveDir.exists()) {
    saveDir.mkdirs();
}

// 設定上傳檔案大小限制 (5MB)
int maxSize = 5 * 1024 * 1024;

// 處理檔案上傳
MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, "utf-8", new DefaultFileRenamePolicy());

// 取得表單資料
String memberId = multi.getParameter("memberId");
String clothing_number = multi.getParameter("clothing_number");
String clothing_code = multi.getParameter("clothing_code");
String text_description = multi.getParameter("text_description");
String brand = multi.getParameter("brand");
String color_code = multi.getParameter("color_code");

// 連接資料庫
String dbPath = objDBConfig.FilePath();
Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
Connection con = DriverManager.getConnection("jdbc:ucanaccess://" + dbPath);

// ✅ 先從資料庫取得舊的圖片路徑
long clothingNumberLong = Long.parseLong(clothing_number);
String oldPicFromDB = null;

String querySql = "SELECT pic FROM my_wardrobe WHERE clothing_number = ? AND memberId = ? AND clothing_code = ?";
PreparedStatement queryStmt = con.prepareStatement(querySql);
queryStmt.setLong(1, clothingNumberLong);
queryStmt.setString(2, memberId);
queryStmt.setString(3, clothing_code);
ResultSet rs = queryStmt.executeQuery();

if(rs.next()) {
    oldPicFromDB = rs.getString("pic");
    System.out.println("資料庫中的舊圖片路徑: " + oldPicFromDB);
}
rs.close();
queryStmt.close();

// 處理圖片上傳
String pic = oldPicFromDB; // 預設使用舊圖片
String fileName = multi.getFilesystemName("clothingImage");

if(fileName != null && !fileName.isEmpty()) {
    System.out.println("📤 偵測到新上傳的檔案: " + fileName);
    
    // ✅ 取得副檔名
    String ext = "";
    int dotIndex = fileName.lastIndexOf(".");
    if(dotIndex > 0) {
        ext = fileName.substring(dotIndex).toLowerCase();
    }
    
    // ✅ 產生安全的英數字檔名
    String newFileName = memberId + "_" + clothing_number + "_" + System.currentTimeMillis() + ext;
    
    // ✅ 重新命名上傳的檔案
    File uploadedFile = new File(savePath, fileName);
    File newFile = new File(savePath, newFileName);
    
    if(uploadedFile.renameTo(newFile)) {
        System.out.println("✅ 檔案重新命名成功: " + fileName + " → " + newFileName);
        
        // ✅ 嘗試刪除舊圖片
        if(oldPicFromDB != null && !oldPicFromDB.isEmpty()) {
            // 處理可能的路徑格式
            String oldPicPath = oldPicFromDB;
            if(oldPicPath.startsWith("images/")) {
                oldPicPath = oldPicPath; // 已經是相對路徑
            }
            
            File oldPicFile = new File(application.getRealPath("/"), oldPicPath);
            System.out.println("🔍 嘗試刪除舊圖片: " + oldPicFile.getAbsolutePath());
            System.out.println("   檔案是否存在: " + oldPicFile.exists());
            
            if(oldPicFile.exists()) {
                boolean deleted = oldPicFile.delete();
                if(deleted) {
                    System.out.println("✅ 舊圖片已刪除: " + oldPicFromDB);
                } else {
                    System.out.println("⚠️ 舊圖片刪除失敗: " + oldPicFromDB);
                }
            } else {
                System.out.println("⚠️ 找不到舊圖片檔案(可能是亂碼檔名): " + oldPicFromDB);
                
                // 列出資料夾中的檔案供參考
                File folder = new File(savePath);
                System.out.println("📁 資料夾中實際存在的檔案:");
                File[] files = folder.listFiles();
                if(files != null) {
                    for(File f : files) {
                        if(f.isFile()) {
                            System.out.println("   - " + f.getName());
                        }
                    }
                }
            }
        }
        
        // ✅ 更新為新檔名
        pic = "images/my_wardrobe/" + newFileName;
        System.out.println("✅ 新圖片路徑: " + pic);
    } else {
        System.out.println("❌ 檔案重新命名失敗!");
    }
} else {
    System.out.println("ℹ️ 沒有上傳新圖片,保持原圖片");
}

System.out.println("\n=== 準備更新資料庫 ===");
System.out.println("memberId: " + memberId);
System.out.println("clothing_number: " + clothing_number);
System.out.println("clothing_code: " + clothing_code);
System.out.println("text_description: " + text_description);
System.out.println("brand: " + brand);
System.out.println("color_code: " + color_code);
System.out.println("pic: " + pic);

// 更新資料
String sql = "UPDATE my_wardrobe SET text_description = ?, brand = ?, pic = ?, color_code = ? WHERE clothing_number = ? AND memberId = ? AND clothing_code = ?";
PreparedStatement pstmt = con.prepareStatement(sql);
pstmt.setString(1, text_description);
pstmt.setString(2, brand);
pstmt.setString(3, pic);
pstmt.setString(4, color_code);
pstmt.setLong(5, clothingNumberLong);
pstmt.setString(6, memberId);
pstmt.setString(7, clothing_code);

// 執行 SQL
int result = pstmt.executeUpdate();
System.out.println("\n✅ 受影響的資料筆數: " + result);

// ✅ 驗證更新結果
if(result > 0) {
    String verifySql = "SELECT text_description, brand, pic, color_code FROM my_wardrobe WHERE clothing_number = ? AND memberId = ? AND clothing_code = ?";
    PreparedStatement verifyStmt = con.prepareStatement(verifySql);
    verifyStmt.setLong(1, clothingNumberLong);
    verifyStmt.setString(2, memberId);
    verifyStmt.setString(3, clothing_code);
    ResultSet verifyRs = verifyStmt.executeQuery();
    
    if(verifyRs.next()) {
        System.out.println("\n=== 更新後的資料 ===");
        System.out.println("text_description: " + verifyRs.getString("text_description"));
        System.out.println("brand: " + verifyRs.getString("brand"));
        System.out.println("pic: " + verifyRs.getString("pic"));
        System.out.println("color_code: " + verifyRs.getString("color_code"));
    }
    verifyRs.close();
    verifyStmt.close();
}

// 關閉連接
pstmt.close();
con.close();

// 根據結果跳轉
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