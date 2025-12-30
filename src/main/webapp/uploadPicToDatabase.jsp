<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.util.*" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="CZ.group.tool.upload.FolderConfig2" %>
<%@ page import="CZ.group.tool.database.DBConfig" %>

<%
    // 初始化配置对象
    FolderConfig2 objFolderConfig = new FolderConfig2();
    DBConfig objDBConfig = new DBConfig();
    
    Connection con = null;
    PreparedStatement pstmt = null;
    
    try {
        // 处理文件上传
        MultipartRequest theMultipartRequest = new MultipartRequest(
            request,
            objFolderConfig.FilePath(),
            10 * 1024 * 1024, // 10MB 限制
            "UTF-8"
        );
        
        // 获取表单参数
        String fileName = theMultipartRequest.getFilesystemName("pic");
        String wearId = theMultipartRequest.getParameter("wearId");
        String memberId = theMultipartRequest.getParameter("memberId");
        
        if (fileName != null && !fileName.trim().isEmpty()) {
            // 验证文件是否存在
            String fullPath = objFolderConfig.FilePath() + fileName;
            File uploadedFile = new File(fullPath);
            
            if (!uploadedFile.exists()) {
                throw new Exception("文件未成功保存到服务器!");
            }
            
            // 连接 Access 数据库
            String dbPath = "C:\\Users\\user\\Documents\\OOTD1\\src\\main\\webapp\\OOTD1.accdb";
            Class.forName("net.ucanaccess.jdbc.UcanaccessDriver");
            
            // 建立数据库连接
            con = DriverManager.getConnection(
                "jdbc:ucanaccess://" + dbPath + ";memory=false"
            );
            
            // 构建相对路径
            String relativePath = objFolderConfig.WebsiteRelativeFilePath() + fileName;
            
            // 插入数据到 personal_wear 表
            String sql = "INSERT INTO personal_wear (memberId, pic, wearId) VALUES (?, ?, ?)";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, memberId);
            pstmt.setString(2, relativePath);
            pstmt.setString(3, wearId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                // 上传成功，重定向到首页
                String accessId = (String) session.getAttribute("accessId");
                response.sendRedirect("index1.jsp?NewPost=true&accessId=" + accessId + "#postArea");
            } else {
                out.println("<h3>数据插入失败，请重试!</h3>");
            }
            
        } else {
            out.println("<h3>文件上传失败，请重新选择文件!</h3>");
            out.println("<a href='javascript:history.back()'>返回</a>");
        }
        
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        out.println("<h3>错误: 找不到数据库驱动程序!</h3>");
        out.println("<p>请确保已添加 UCanAccess 相关 JAR 文件</p>");
        out.println("<p>错误详情: " + e.getMessage() + "</p>");
        
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<h3>数据库错误!</h3>");
        out.println("<p>错误详情: " + e.getMessage() + "</p>");
        
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<h3>发生错误!</h3>");
        out.println("<p>错误详情: " + e.getMessage() + "</p>");
        
    } finally {
        // 关闭数据库资源
        try {
            if (pstmt != null) pstmt.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>