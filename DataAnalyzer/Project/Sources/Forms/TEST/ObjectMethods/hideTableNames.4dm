var $event : Object

$event:=FORM Event:C1606

If ($event.code=On Load:K2:1) || ($event.code=On Clicked:K2:4)
	
	Form:C1466.toggleTableNames()
	
End if 