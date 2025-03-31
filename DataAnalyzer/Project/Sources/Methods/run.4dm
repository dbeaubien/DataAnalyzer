//%attributes = {"invisible":true,"preemptive":"capable"}
#DECLARE($mode : Text)

If (Application info:C1599.headless) || True:C214
	
/*
	
this method is designed to be executed in utility mode
https://developer.4d.com/docs/Admin/cli/#tool4d
	
*/
	
	$options:=Split string:C1554($mode; ","; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
	
	$CLI:=cs:C1710.DataInfo_CLI.new()
	
	$CLI.logo().version()
	
	//ON ERR CALL(Formula(generic_error_handler).source)
	
	$CLI.LF()
	
	var $userParamValue : Text
	$param:=Get database parameter:C643(User param value:K37:94; $userParamValue)
	
	Case of 
		: ($userParamValue="")
			$CLI.print("--user-param is missing!"; "red;bold").LF()
		Else 
			
			$paths:=Split string:C1554($userParamValue; ","; sk trim spaces:K86:2 | sk ignore empty strings:K86:1)
			
			var $dataFile : 4D:C1709.File
			var $outputFileJson; $outputFileXlsx : 4D:C1709.File
			
			var $isPathPOSIX : Boolean
			
			For each ($path; $paths)
				Case of 
					: ([".4DD"; ".data"].includes(Path to object:C1547($path).extension))
						If (Is Windows:C1573)
							$dataFile:=File:C1566($path; fk platform path:K87:2)
							If ($dataFile.exists)
								$isPathPOSIX:=False:C215
							Else 
								$isPathPOSIX:=True:C214
								$dataFile:=File:C1566($path; fk posix path:K87:1)
							End if 
						Else 
							$dataFile:=File:C1566($path; fk posix path:K87:1)
							If ($dataFile.exists)
								$isPathPOSIX:=True:C214
							Else 
								$isPathPOSIX:=False:C215
								$dataFile:=File:C1566($path; fk platform path:K87:2)
							End if 
						End if 
				End case 
			End for each 
			
			For each ($path; $paths)
				Case of 
					: ([".json"].includes(Path to object:C1547($path).extension))
						$outputFileJson:=File:C1566($path; $isPathPOSIX ? fk posix path:K87:1 : fk platform path:K87:2)
					: ([".xlsx"].includes(Path to object:C1547($path).extension))
						$outputFileXlsx:=File:C1566($path; $isPathPOSIX ? fk posix path:K87:1 : fk platform path:K87:2)
				End case 
			End for each 
			
			If ($dataFile#Null:C1517)
				$CLI.open($dataFile)
				Case of 
					: ($outputFileXlsx=Null:C1517) && ($outputFileJson=Null:C1517)
						$CLI.print("output file path not specified in --user-param!"; "red;bold").LF()
				End case 
				If ($outputFileJson#Null:C1517)
					$CLI.toJson($outputFileJson)
				End if 
				If ($outputFileXlsx#Null:C1517)
					$CLI.toXlsx($outputFileXlsx)
				End if 
			Else 
				$CLI.print("data file path not specified in --user-param!"; "red;bold").LF()
			End if 
			
	End case 
	
	ON ERR CALL:C155("")
	
End if 