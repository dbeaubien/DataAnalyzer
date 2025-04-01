//%attributes = {"invisible":true,"preemptive":"capable"}
var $CLI : cs:C1710.CLI

$CLI:=cs:C1710.CLI.new()

$CLI\
.print("ERROR"; "red;bold")\
.print(": ")\
.print(String:C10(ERROR))\
.LF()

$CLI\
.print("ERROR METHOD"; "red;bold")\
.print(": ")\
.print(ERROR METHOD)\
.LF()

$CLI\
.print("ERROR LINE"; "red;bold")\
.print(": ")\
.print(String:C10(ERROR LINE))\
.LF()

$CLI\
.print("ERROR FORMULA"; "red;bold")\
.print(": ")\
.print(ERROR FORMULA)\
.LF()

$CLI\
.print("***"+Parse formula:C1576(":C1662")+"***"; "bold")\
.LF()

$chain:=Call chain:C1662

For each ($link; $chain)
	$CLI\
		.print("database")\
		.print(": ")\
		.print($link.database)\
		.LF()
	$CLI\
		.print("line")\
		.print(": ")\
		.print($link.line)\
		.LF()
	$CLI\
		.print("name")\
		.print(": ")\
		.print($link.name)\
		.LF()
	$CLI\
		.print("type")\
		.print(": ")\
		.print($link.type)\
		.LF()
End for each 

$CLI\
.print("***"+Parse formula:C1576(":C1799")+"***"; "bold")\
.LF()

var $error : Object
For each ($error; Last errors:C1799)
	$CLI\
		.print("error")\
		.print(": ")\
		.print(String:C10($error.errCode))\
		.LF()
	$CLI\
		.print("component")\
		.print(": ")\
		.print($error.componentSignature)\
		.LF()
	$CLI\
		.print("message")\
		.print(": ")\
		.print($error.$errormessage)\
		.LF()
End for each 
