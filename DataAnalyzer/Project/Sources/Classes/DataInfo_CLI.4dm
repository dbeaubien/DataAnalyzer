Class extends CLI

property tableInfo : Object
property JSON : Object

Class constructor()
	
	Super:C1705()
	
Function toJson($outputFile : 4D:C1709.File) : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	If ($CLI.JSON#Null:C1517)
		$outputFile.setText(JSON Stringify:C1217($CLI.JSON; *))
	End if 
	
	return $CLI
	
Function toXlsx($outputFile : 4D:C1709.File) : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	If ($CLI.JSON.data#Null:C1517)
		
		var $XLSX : cs:C1710.XLSX
		$XLSX:=cs:C1710.XLSX.new()
		
		$file:=File:C1566("/RESOURCES/XLSX/DataAnalyzer.xlsx")
		$status:=$XLSX.read($file)
		
		$values:={}
		
		var $value : Object
		var $i : Integer
		
		$i:=1
		
		For each ($value; $CLI.JSON.data)
			
			$i+=1
			$idx:=String:C10($i)
			
			$values["A"+$idx]:=$value.tableNumber
			$values["B"+$idx]:=$value.tableName
			$values["C"+$idx]:=$value.tableUUID
			$values["D"+$idx]:=$value.records.number
			$values["E"+$idx]:=$value.records.count
			$values["F"+$idx]:=$value.records.size
			$values["G"+$idx]:=$value.records.max
			$values["H"+$idx]:=$value.records.min
			$values["I"+$idx]:=$value.records.average
			$values["J"+$idx]:=$value.blob.number
			$values["K"+$idx]:=$value.blob.count
			$values["L"+$idx]:=$value.blob.size
			$values["M"+$idx]:=$value.blob.max
			$values["N"+$idx]:=$value.blob.min
			$values["O"+$idx]:=$value.blob.average
			
		End for each 
		
		$status:=$XLSX.setValues($values; 1)
		
		If ($outputFile.exists)
			$outputFile.delete()
		End if 
		
		$status:=$XLSX.write($outputFile)
		
	End if 
	
	return $CLI
	
Function open($dataFile : 4D:C1709.File) : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	$CLI.tableInfo:={col: []}
	$CLI.JSON:={}
	
	$status:={}
	
	$CLI._printTask("Start Analysis of Data File").LF()
	$CLI._printPath($dataFile)
	$CLI._open($dataFile)
	
	return $CLI
	
Function _open($dataFile : 4D:C1709.File) : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	If ($dataFile.isAlias)
		$dataFile:=$dataFile.original
	End if 
	
	var $dataInfo : cs:C1710.DataInfo
	$dataInfo:=cs:C1710.DataInfo.new()
	$dataInfo.open($dataFile)
	$dataInfo.readFileInfo()
	
	var $fileInfo : Object
	$fileInfo:=$dataInfo.getFileInfo()
	$CLI._onFileInfo($fileInfo)
	
	var $tableInfo : Object
	
	For each ($tableAddress; $dataInfo.tableAddress.DTab)
		$tableInfo:=$dataInfo.readTableInfo($tableAddress)
		If ($tableInfo#Null:C1517)
			$CLI._onTableInfo($tableInfo)
		End if 
	End for each 
	
	For each ($tableAddress; $dataInfo.tableAddress.TDEF)
		$tableInfo:=$dataInfo.readTableDefinition($tableAddress)
		If ($tableInfo#Null:C1517)
			$CLI._onTableInfo($tableInfo)
		End if 
	End for each 
	
	$dataInfo.tableInfo:=$dataInfo.tableInfo.orderBy("nbRecords asc")
	
	var $tableStats : cs:C1710._TableStats
	
	If ($dataInfo.tableInfo.length=0)
		$CLI._onFinish()
	Else 
		$CLI.hideCursor()
		For each ($tableInfo; $dataInfo.tableInfo)
			$tableStats:=cs:C1710._TableStats.new($tableInfo.tableUUID)
			$CLI._processTable($dataInfo; $tableInfo; $tableStats)
		End for each 
		$CLI.showCursor()
		$CLI._onFinish()
	End if 
	$CLI.CR().ES2(13)
	
	return $CLI
	
Function _processTable($dataInfo : cs:C1710.DataInfo; $tableInfo : Object; $tableStats : Object) : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	$tableStats:=$dataInfo.getTableStats($tableInfo.address_Taba_rec1; $tableStats)
	$tableStats:=$dataInfo.getTableStats($tableInfo.address_Taba_Blob; $tableStats)
	
	$CLI._onTableStats($tableStats)
	
	$col:=$CLI.tableInfo.col
	
	var $table : Object
	$table:=$col.query("tableUUID === :1"; $tableStats.tableUUID).first()
	
	If ($table#Null:C1517)
		$CLI._printTask($tableInfo.genericTableName).ES2().LF()
		$CLI.print("Nb Records: "; "39").print(String:C10($table.nbRecords); "white").LF()
		$CLI.print("Records Count: "; "39").print(String:C10($table.countOf_rec1); "white").LF()
		$CLI.print("Size Records: "; "39").print(String:C10($table.sizeOf_rec1); "white").LF()
		$CLI.print("Max Record: "; "39").print(String:C10($table.maxOf_rec1); "white").LF()
		$CLI.print("Min Record: "; "39").print(String:C10($table.minOf_rec1); "white").LF()
		$CLI.print("Avg Record: "; "39").print(String:C10($table.avgOf_rec1); "white").LF()
		$CLI.print("Nb Blobs: "; "39").print(String:C10($table.nbBlobs); "white").LF()
		$CLI.print("Blobs Count: "; "39").print(String:C10($table.countOf_blob); "white").LF()
		$CLI.print("Size Blobs: "; "39").print(String:C10($table.sizeOf_blob); "white").LF()
		$CLI.print("Max Blob: "; "39").print(String:C10($table.maxOf_blob); "white").LF()
		$CLI.print("Min Blob: "; "39").print(String:C10($table.minOf_blob); "white").LF()
		$CLI.print("Avg Blob: "; "39").print(String:C10($table.avgOf_blob); "white").LF()
		$CLI.CR().UP(13)
	End if 
	
	return $CLI
	
Function _onTableStats($tableStats : Object) : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	var $table : Object
	var $col : Collection
	
	$col:=$CLI.tableInfo.col
	
	$table:=$col.query("tableUUID === :1"; $tableStats.tableUUID).first()
	
	If ($table#Null:C1517)
		$table.sizeOf_rec1:=$tableStats.sizeOf_rec1
		$table.countOf_rec1:=$tableStats.countOf_rec1
		$table.maxOf_rec1:=$tableStats.maxOf_rec1
		$table.minOf_rec1:=$tableStats.minOf_rec1
		$table.sizeOf_blob:=$tableStats.sizeOf_blob
		$table.countOf_blob:=$tableStats.countOf_blob
		$table.maxOf_blob:=$tableStats.maxOf_blob
		$table.minOf_blob:=$tableStats.minOf_blob
		$table.avgOf_rec1:=$tableStats.avgOf_rec1
		$table.avgOf_blob:=$tableStats.avgOf_blob
	End if 
	
	return $CLI
	
Function _onFileInfo($fileInfo : Object) : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	var $property : Text
	For each ($property; $fileInfo)
		$CLI._printPropertyValue($property; $fileInfo[$property]).LF()
	End for each 
	
	return $CLI
	
Function _onTableInfo($tableInfo : Object) : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	var $table : Object
	var $col : Collection
	
	$col:=$CLI.tableInfo.col
	
	$table:=$col.query("tableUUID === :1"; $tableInfo.tableUUID).first()
	If ($table=Null:C1517)
		$col.push($tableInfo)
	Else 
		var $attr : Text
		For each ($attr; $tableInfo)
			$table[$attr]:=$tableInfo[$attr]
		End for each 
	End if 
	
	return $CLI
	
Function _onFinish() : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	var $col : Collection
	
	$col:=$CLI.tableInfo.col
	
	$CLI.JSON.data:=$col.extract(\
		"tableNumber"; "tableNumber"; \
		"tableName"; "tableName"; \
		"tableUUID"; "tableUUID"; \
		"nbRecords"; "records.number"; \
		"countOf_rec1"; "records.count"; \
		"sizeOf_rec1"; "records.size"; \
		"maxOf_rec1"; "records.max"; \
		"minOf_rec1"; "records.min"; \
		"avgOf_rec1"; "records.average"; \
		"nbBlobs"; "blobs.number"; \
		"countOf_blob"; "blobs.count"; \
		"sizeOf_blob"; "blobs.size"; \
		"maxOf_blob"; "blobs.max"; \
		"minOf_blob"; "blobs.min"; \
		"avgOf_blob"; "blobs.average")
	
	$CLI.JSON.info:=$CLI.fileInfo
	
	return $CLI
	
	//MARK:-Console
	
Function _printPropertyValue($property : Text; $value : Variant)->$CLI : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	$CLI.print($property+": "; "39").print(String:C10($value); "white")
	
	return $CLI
	
Function _printItem($item : Text)->$CLI : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	$CLI.print($item; "39").LF()
	
Function _printItemToList($item : Text; $count : Integer)->$CLI : cs:C1710.DataInfo_CLI
	
	If ($count#0)
		$CLI.print(","+$item; "39")
	Else 
		$CLI.print($item; "39")
	End if 
	
Function _printList($list : Collection)->$CLI : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	$CLI.print($list.join(","); "39").LF()
	
Function _printPath($path : Object)->$CLI : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	If (OB Instance of:C1731($path; 4D:C1709.File) || OB Instance of:C1731($path; 4D:C1709.Folder))
		$CLI.print($path.path; "244").LF()
	End if 
	
Function _printStatus($success : Boolean)->$CLI : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	If ($success)
		$CLI.print("success"; "82;bold").LF()
	Else 
		$CLI.print("failure"; "196;bold").LF()
	End if 
	
Function _printTask($task : Text)->$CLI : cs:C1710.DataInfo_CLI
	
	$CLI:=This:C1470
	
	$CLI.print($task; "bold").print("...")