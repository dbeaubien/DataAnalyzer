If (FORM Event:C1606.code=On Clicked:K2:4)
	
	$directoryPath:=Folder:C1567(fk documents folder:K87:21).platformPath
	$title:=Localized string:C991("Select a data file…")
	
	$fileName:=Select document:C905($directoryPath; ".4dd;.data"; $title; Package open:K24:8)
	
	If (OK=1)
		$file:=File:C1566(DOCUMENT; fk platform path:K87:2)
		Form:C1466.open($file)
	End if 
	
End if 