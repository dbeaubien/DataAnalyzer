//%attributes = {"shared":true}
#DECLARE($params : Object)

If ($params=Null:C1517)
	
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	$form:=cs:C1710.DataAnalyzerForm.new()
	$window:=Open form window:C675("DataAnalyzer")
	DIALOG:C40("DataAnalyzer"; $form; *)
	
End if 