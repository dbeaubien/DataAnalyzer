//%attributes = {"shared":true}
#DECLARE($params : Object)

If ($params=Null:C1517)
	
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	$form:=cs:C1710.D3Form.new("sunburst")
	
	$window:=Open form window:C675("D3")
	DIALOG:C40("D3"; $form; *)
	
End if 