Class constructor
	
Function open($dataFile : 4D:C1709.File)
	
	$ctx:={file: $dataFile; window: Current form window:C827}
	$ctx.onFileInfo:=This:C1470._onFileInfo
	$ctx.onTableInfo:=This:C1470._onTableInfo
	$ctx.onFinish:=This:C1470._onFinish
	$ctx.objectName:=OBJECT Get name:C1087(Object current:K67:2)
	
	OBJECT SET ENABLED:C1123(*; $ctx.objectName; False:C215)
	
	CALL WORKER:C1389(Current method name:C684; Formula:C1597(preemptiveWorker); $ctx)
	
	CALL WORKER:C1389(Current method name:C684; This:C1470._open; $ctx)
	
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
	
	CALL FORM:C1391($ctx.window; $ctx.onFinish; $ctx)
	
Function _onFileInfo($fileInfo : Object)
	
	Form:C1466.fileInfo:=$fileInfo
	
Function _onTableInfo($tableInfo : Object)
	
	var $table : Object
	$table:=Form:C1466.tableInfo.col.query("tableNumber === :1"; $tableInfo.tableNumber).first()
	If ($table=Null:C1517)
		Form:C1466.tableInfo.col.push($tableInfo)
	Else 
		var $attr : Text
		For each ($attr; $tableInfo)
			$table[$attr]:=$tableInfo[$attr]
		End for each 
	End if 
	
Function _onFinish($ctx : Object)
	
	OBJECT SET ENABLED:C1123(*; $ctx.objectName; True:C214)