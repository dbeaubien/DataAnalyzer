//%attributes = {"shared":true}
#DECLARE($params : Object)

If ($params=Null:C1517)
	
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	$form:=cs:C1710.DataInfoController.new()
	
	$form.tableInfo:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
	$window:=Open form window:C675("TEST")
	DIALOG:C40("TEST"; $form; *)
	
End if 