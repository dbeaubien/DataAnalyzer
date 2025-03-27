var $event : Object

$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		Form:C1466.toggleExportButton()
		
	: ($event.code=On Clicked:K2:4)
		
		var $file : 4D:C1709.File
		$file:=Folder:C1567(fk desktop folder:K87:19).file("DataAnalyzer.json")
		
		var $fileName : cs:C1710.FileName
		$fileName:=cs:C1710.FileName.new($file)
		$file:=$fileName.file
		
		$file.setText(JSON Stringify:C1217(Form:C1466.JSON; *))
		
		SHOW ON DISK:C922($file.platformPath)
		
End case 