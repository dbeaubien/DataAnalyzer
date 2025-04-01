var $event : Object

$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		If (Not:C34(OB Instance of:C1731(Form:C1466; cs:C1710.D3Form)))
			
			ARRAY LONGINT:C221($events; 1)
			$events{1}:=On Unload:K2:2
			OBJECT SET EVENTS:C1239(*; ""; $events; Disable events others unchanged:K42:39)
			OBJECT SET ENABLED:C1123(*; "@"; False:C215)
			
			return   //please use "D3" method! 
			
		End if 
		
		$data:=JSON Parse:C1218(Folder:C1567(fk desktop folder:K87:19).file("DataAnalyzer.json").getText())
		$data:={data: []}
		
		Form:C1466.onLoad().bind("d3").open($data)
		
	: ($event.code=On Unload:K2:2)
		
		Form:C1466.onUnload()
		
End case 