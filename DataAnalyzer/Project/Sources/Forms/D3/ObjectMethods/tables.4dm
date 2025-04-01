var $event : Object

$event:=FORM Event:C1606

Case of 
	: ($event.code=On Selection Change:K2:29) || ($event.code=On Clicked:K2:4)
		
		Form:C1466.drill(Form:C1466.tables.item)
		
End case 