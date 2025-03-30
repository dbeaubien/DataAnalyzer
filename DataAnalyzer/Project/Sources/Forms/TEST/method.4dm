var $event : Object

$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		If (Not:C34(OB Instance of:C1731(Form:C1466; cs:C1710.DataInfoController)))
			
			TRACE:C157  //please use "DataAnalyzer" method! 
			
			CANCEL:C270
			
		End if 
		
	: ($event.code=On Unload:K2:2)
		
		Form:C1466.onUnload()
		
End case 