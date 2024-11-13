If (FORM Event:C1606.code=On Clicked:K2:4)
	
	Form:C1466.tableInfo:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
	$file:=File:C1566("Macintosh HD:Users:miyako:Documents:Customer Data:肥後物産:HigoBussanDB.4DD"; fk platform path:K87:2)
	
	Form:C1466.open($file)
	
End if 