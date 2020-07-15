package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class VersionControl extends Sprite
	{
		
		private var targetFile:File;
		private var targetDic:Dictionary=new Dictionary();
		
		private var str:String="";
		private var root:String="";
		private var textField:TextField;
		
		public function VersionControl()
		{
			this.textField=new TextField();
			this.textField.width=400;
			this.textField.height=400;
			this.addChild(this.textField);
			
			targetFile=new File();
			targetFile.browseForDirectory("请选择要存储的目标目录");
			targetFile.addEventListener(Event.SELECT,onTargetSelect); 
		}
		private function onTargetSelect(evt:Event):void
		{
			str='"resources":[\n';
			var current:File=evt.target as File;
			this.root=current.nativePath;
			var myPattern:RegExp = /\\/g;
			this.root=this.root.replace(myPattern,"/")+"/";
			targetPop(current);
			
			str=str.slice(0,str.length-2);
			
			str+='\n]\n';
			
			this.textField.text=""+str;
		}
		
		private function targetPop(file:File):void  
		{
			if(file.isDirectory)
			{  
				var arr:Array=file.getDirectoryListing();  
				for each(var files:File in arr)
				{
					if(files.isDirectory)
					{
						targetPop(files);  
					}
					else
					{
						this.targetDic[files.nativePath]=files.nativePath;
						createItem(files);
//						var stream:FileStream = new FileStream();
//						stream.open(files,FileMode.READ);
//						var bytes:ByteArray=new ByteArray();
//						stream.readBytes(bytes);
//						stream.close();
						
						
					}
				}
			}
			else
			{
				this.targetDic[file.nativePath]=file.nativePath;
				createItem(file);
			}
		}
		
		private function createItem(file:File):void
		{
			var names:String=""+file.name.replace(".","_");
			var data:Date=file.creationDate;
			var times:String=data.fullYear+"."+data.month+"."+data.day+"-"+data.hours+":"+data.minutes+":"+data.seconds;
			var version:String="?v"+ MD5.hash(times)+"";
			var ext:String="";
			var type:String="";
			var startIdx:int=file.name.lastIndexOf(".");
			if(startIdx>0)
			{
				ext=file.name.substring(startIdx+1,file.name.length);
			}
			switch(ext)
			{
				case "png":
				case "jpg":
					type="image";
					break;
				case "mp3":
					type="sound";
					break;
			}
			var myPattern:RegExp = /\\/g;
			
			var url:String=file.nativePath.replace(myPattern,"/");
			url=url.replace(this.root,"");
			str+="{";
			str+='"name":'+'"'+names+''+version+'",'+"\n";
//			str+='"type":"image",'+"\n";
			str+='"type":"'+type+'",'+"\n";
			str+='"url":'+'"'+url+'"'+"\n";
			str+='},'+"\n";
		}
		
	}
}