//%attributes = {"invisible":true}
#DECLARE($mode : Text)

If (Application info:C1599.headless)
	
/*
	
this method is designed to be executed in utility mode
https://developer.4d.com/docs/Admin/cli/#tool4d
	
*/
	
	$options:=Split string:C1554($mode; ","; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
	
	$CLI:=cs:C1710.CLI.new()
	
	$CLI.logo().version()
	
	ON ERR CALL:C155(Formula:C1597(generic_error_handler).source)
	
	$CLI.LF()
	
	var $userParamValue : Text
	$param:=Get database parameter:C643(User param value:K37:94; $userParamValue)
	
	ON ERR CALL:C155("")
	
End if 