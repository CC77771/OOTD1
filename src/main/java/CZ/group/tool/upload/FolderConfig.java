package CZ.group.tool.upload;

class FolderConfig {
	public FolderConfig(){		
	}
	
	public String FilePath(){
	   //li's 
		//String DBPath="D:\\1NAS-Li\\coding\\JavaLearning\\leelabTemplate\\WebContent\\assets\\images\\member\\";
	   //Yujia's 
		 String DBPath="C:\\Users\\My\\eclipse-workspace\\CZ\\src\\main\\webapp\\images\\";
	   return DBPath;		
	}
	public String WebsiteRelativeFilePath(){
		   //li's 
		//String Path="assets/images/member/";
		   //Yujia's 
			 String Path="images/member/";
		   return Path;		
		}
}

