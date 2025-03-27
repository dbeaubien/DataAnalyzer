property countCores : Integer
property useMultipleCores : Boolean
property hideTableNames : Boolean
property isRunning : Boolean

Class constructor
	
	This:C1470.countCores:=System info:C1571.cores
	This:C1470.useMultipleCores:=(This:C1470.countCores>3) && (Is compiled mode:C492)
	If (This:C1470.useMultipleCores)
		This:C1470.countCores-=2  //save for UI and system
	End if 
	
	This:C1470.hideTableNames:=True:C214
	This:C1470.isRunning:=False:C215
	
Function toggleTableNames() : cs:C1710.DataInfoController
	
	If (This:C1470.hideTableNames)
		OBJECT SET VISIBLE:C603(*; "tableName"; False:C215)
		OBJECT SET VISIBLE:C603(*; "genericTableName"; True:C214)
	Else 
		OBJECT SET VISIBLE:C603(*; "tableName"; True:C214)
		OBJECT SET VISIBLE:C603(*; "genericTableName"; False:C215)
	End if 
	
	return This:C1470
	
Function _dropItemToFile() : 4D:C1709.File
	
	var $path : Text
	$path:=Get file from pasteboard:C976(1)
	
	If (Test path name:C476($path)#Is a document:K24:1)
		return 
	End if 
	
	var $file : 4D:C1709.File
	$file:=File:C1566($path; fk platform path:K87:2)
	
	If ($file.isAlias)
		$file:=$file.original
	End if 
	
	If ([".4DD"; ".data"].indexOf($file.extension)=-1)
		return 
	End if 
	
	return $file
	
Function onDragOver() : Integer
	
	If (This:C1470.isRunning)
		return -1
	End if 
	
	var $file : 4D:C1709.File
	$file:=This:C1470._dropItemToFile()
	
	If ($file#Null:C1517)
		return 0
	Else 
		return -1
	End if 
	
Function onDrop()
	
	var $file : 4D:C1709.File
	$file:=This:C1470._dropItemToFile()
	
	If ($file#Null:C1517)
		This:C1470.open($file)
	End if 
	
Function open($dataFile : 4D:C1709.File)
	
	Form:C1466.tableInfo:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
	$ctx:={file: $dataFile; window: Current form window:C827}
	$ctx.onFileInfo:=This:C1470._onFileInfo
	$ctx.onTableInfo:=This:C1470._onTableInfo
	$ctx.onTableStats:=This:C1470._onTableStats
	$ctx.onFinish:=This:C1470._onFinish
	$ctx.objectName:="open"
	$ctx.countCores:=This:C1470.countCores
	$ctx.useMultipleCores:=This:C1470.useMultipleCores
	
	OBJECT SET ENABLED:C1123(*; $ctx.objectName; False:C215)
	This:C1470.isRunning:=True:C214
	
	$workerName:="DataAnalyzer"
	CALL WORKER:C1389($workerName; Formula:C1597(preemptiveWorker); $ctx)
	CALL WORKER:C1389($workerName; This:C1470._open; $ctx)
	
Function _open($ctx : Object)
	
	var $dataInfo : cs:C1710.DataInfo
	$dataInfo:=cs:C1710.DataInfo.new()
	$dataInfo.open($ctx.file)
	$dataInfo.readFileInfo()
	
	$fileInfo:={}
	$properties:=[\
		"useTraditionalStyleSorting"; \
		"useLanguageNeutralDeadcharAlgorithmInsteadOfBreakIterator"; \
		"sortHiraganaCodePointsFirstOnQuaternaryLevel"; \
		"useQuaternaryCollationStrengthForSorting"; \
		"useSecondaryCollationStrengthForMatching"; \
		"ignoreWildCharInMiddle"; \
		"withICU"; \
		"dialectCode"; \
		"numberOfDataFlushes"; \
		"firstHolePositionInAddressTablesTable"; \
		"addressTablesTableHasHoles"; \
		"extraPropertiesSize"; \
		"extraPropertiesTableAddress"; \
		"extraPropertiesTableHasHoles"; \
		"indexDefinitionsTableInStructureAddress"; \
		"firstHolePositionInIndexDefinitionsTableInStructure"; \
		"indexDefinitionsTableInStructureHasHoles"; \
		"indexDefinitionsTableAddress"; \
		"numberOfIndexesDefinedInStructure"; \
		"firstHolePositionInIndexDefinitionsTable"; \
		"indexDefinitionsTableHasHoles"; \
		"numberOfIndexes"; \
		"sequenceNumbersAddress"; \
		"firstHolePositionInSequenceNumbersTable"; \
		"sequenceNumbersTableHasHoles"; \
		"numberOfSequenceNumbers"; \
		"relationsTableAddress"; \
		"firstHolePositionInRelationsTable"; \
		"relationsTableHasHoles"; \
		"numberOfRelations"; \
		"numberOfDataTables"; \
		"dataTableHeadersAddress"; \
		"firstHolePositionInAddressTable"; \
		"addressTableHasHoles"; \
		"indexStoredInSeparateSegment"; \
		"dataFileContainsStructure"; \
		"dataFileNeedsRepair"; \
		"addressTablesOfDataTablesSize"; \
		"randomValueForDuplicateIndexDetection"; \
		"numberOfLogFiles"; \
		"lastLogAction"; \
		"numberOfHeaderModifications"; \
		"randomValueToLinkWithIndexes"; \
		"segmentHeaderSize"; \
		"segmentHeaderAddress"; \
		"addressTablesOfDataTablesAddress"; \
		"ratio"; \
		"blockSize"; \
		"hasSecondaryBlockAllocationAddressTable"; \
		"primaryBlockAllocationAddressTable"; \
		"limitSegments"; \
		"logicalEOF"; \
		"synchronizationIdentifier"; \
		"productVersionCode"; \
		"numberOfDataSegments"; \
		"lastOperationDescription"; \
		"lastOperation"; \
		"dataFileVersion"; \
		"isDataLittleEndian"\
		]
	
	For each ($property; $properties)
		$fileInfo[$property]:=$dataInfo[$property]
	End for each 
	
	CALL FORM:C1391($ctx.window; $ctx.onFileInfo; $fileInfo)
	
	var $tableInfo : Object
	
	For each ($tableAddress; $dataInfo.tableAddress.DTab)
		$tableInfo:=$dataInfo.readTableInfo($tableAddress)
		If ($tableInfo#Null:C1517)
			CALL FORM:C1391($ctx.window; $ctx.onTableInfo; $tableInfo)
		End if 
	End for each 
	
	For each ($tableAddress; $dataInfo.tableAddress.TDEF)
		$tableInfo:=$dataInfo.readTableDefinition($tableAddress)
		If ($tableInfo#Null:C1517)
			CALL FORM:C1391($ctx.window; $ctx.onTableInfo; $tableInfo)
		End if 
	End for each 
	
	var $workerNames : Collection
	var $workerFunction : 4D:C1709.Function
	$workerFunction:=Formula:C1597(_DataAnalyzer)
	
	If ($ctx.useMultipleCores)
		$workerNames:=[]
		For ($i; 1; $ctx.countCores)
			$workerName:=["DataAnalyzer"; " "; "("; $i; ")"].join("")
			$workerNames.push($workerName)
			CALL WORKER:C1389($workerName; Formula:C1597(preemptiveWorker); $ctx)
		End for 
	End if 
	
	var $dataInfo2 : cs:C1710.DataInfo
	$dataInfo2:=$dataInfo.clone()
	
	var $tableStats : cs:C1710._TableStats
	
	If ($dataInfo.tableInfo.length=0)
		CALL FORM:C1391($ctx.window; $ctx.onFinish; {tableUUID: ""}; $ctx)
	Else 
		For each ($tableInfo; $dataInfo.tableInfo)
			$tableStats:=cs:C1710._TableStats.new($tableInfo.tableUUID)
			If ($ctx.useMultipleCores)
				$workerName:=$workerNames[$tableInfo.tableNumber%$ctx.countCores]
				CALL WORKER:C1389($workerName; $workerFunction; $dataInfo; $tableInfo; $tableStats; $ctx)
			Else 
				$tableStats:=$dataInfo.getTableStats($tableInfo.address_Taba_rec1; $tableStats; $ctx)
				$tableStats:=$dataInfo.getTableStats($tableInfo.address_Taba_Blob; $tableStats; $ctx)
				$dataInfo.gotTableStats($tableStats; $ctx)
			End if 
		End for each 
	End if 
	
Function _onTableStats($tableStats : Object)
	
	var $table : Object
	
	$table:=Form:C1466.tableInfo.col.query("tableUUID === :1"; $tableStats.tableUUID).first()
	If ($table=Null:C1517)
		
	Else 
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
		Form:C1466.tableInfo.col:=Form:C1466.tableInfo.col
	End if 
	
Function _onFileInfo($fileInfo : Object)
	
	Form:C1466.fileInfo:=$fileInfo
	
Function _onTableInfo($tableInfo : Object)
	
	var $table : Object
	
	$table:=Form:C1466.tableInfo.col.query("tableUUID === :1"; $tableInfo.tableUUID).first()
	If ($table=Null:C1517)
		Form:C1466.tableInfo.col.push($tableInfo)
	Else 
		var $attr : Text
		For each ($attr; $tableInfo)
			$table[$attr]:=$tableInfo[$attr]
		End for each 
	End if 
	
Function _onFinish($tableStats : Object; $ctx : Object)
	
	var $table : Object
	
	$table:=Form:C1466.tableInfo.col.query("tableUUID === :1"; $tableStats.tableUUID).first()
	If ($table=Null:C1517)
		
	Else 
		$table.complete:=$tableStats.complete
	End if 
	
	If (Form:C1466.tableInfo.col.query("complete === :1"; True:C214).length=Form:C1466.tableInfo.col.length)
		OBJECT SET ENABLED:C1123(*; $ctx.objectName; True:C214)
		Form:C1466.isRunning:=False:C215
	End if 