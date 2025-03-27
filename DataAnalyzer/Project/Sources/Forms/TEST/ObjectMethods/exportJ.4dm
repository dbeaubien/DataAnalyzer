var $event : Object

$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		Form:C1466.toggleExportButton()
		
	: ($event.code=On Clicked:K2:4)
		
		var $file : 4D:C1709.File
		$file:=Form:C1466.toJson()
		
		If (Macintosh option down:C545)
			Form:C1466.launch($file)
		Else 
			Form:C1466.show($file)
		End if 
		
End case 