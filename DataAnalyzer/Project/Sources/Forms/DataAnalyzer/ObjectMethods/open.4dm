If (FORM Event:C1606.code=On Clicked:K2:4)
	
	$directoryPath:=Folder:C1567(fk documents folder:K87:21).platformPath
	$title:=OBJECT Get title:C1068(*; OBJECT Get name:C1087)
	
	$fileName:=Select document:C905($directoryPath; ".4dd;.data"; $title; Package open:K24:8)
	
	If (OK=1)
		$file:=File:C1566(DOCUMENT; fk platform path:K87:2)
		Form:C1466.open($file)
	End if 
	
End if 