property countCores : Integer
property useMultipleCores : Boolean
property hideTableNames : Boolean
property isRunning : Boolean
property JSON : Object
property exportFileJson : 4D:C1709.File
property dispatchInterval : Integer
property updateInterval : Real
property updateIntervalUnit : Integer
property startTime : Integer
property duration : Text
property tableInfo : Object
property objectName : Text
property objectNamePP : Text
property isInterpretedMode : Boolean

Class constructor
	
	This:C1470.countCores:=System info:C1571.cores
	If (This:C1470.countCores>3)
		This:C1470.countCores-=2  //save for UI and system
	Else 
		This:C1470.countCores:=1
	End if 
	This:C1470.isInterpretedMode:=Not:C34(Is compiled mode:C492)
	This:C1470.hideTableNames:=True:C214
	This:C1470.isRunning:=False:C215
	This:C1470.JSON:={}
	This:C1470.exportFileJson:=Folder:C1567(fk desktop folder:K87:19).file("DataAnalyzer.json")
	This:C1470.dispatchInterval:=This:C1470.isInterpretedMode ? 12 : 6  //every 0.1 seconds
	This:C1470.updateIntervalUnit:=This:C1470.isInterpretedMode ? 200 : 100  //every 0.1 seconds
	
	This:C1470.useMultipleCores:=False:C215
	
	This:C1470.toggleParallelProcessing()
	
Function toJson() : 4D:C1709.File
	
	var $fileName : cs:C1710.FileName
	$fileName:=cs:C1710.FileName.new(This:C1470.exportFileJson)
	
	var $file : 4D:C1709.File
	$file:=$fileName.file
	
	$file.setText(JSON Stringify:C1217(Form:C1466.JSON; *))
	
	return $file
	
Function toXlsx() : 4D:C1709.File
	
	var $XLSX : cs:C1710.XLSX
	$XLSX:=cs:C1710.XLSX.new()
	
	$file:=File:C1566("/RESOURCES/XLSX/DataAnalyzer.xlsx")
	$status:=$XLSX.read($file)
	
	$values:={}
	
	var $value : Object
	var $i : Integer
	
	$i:=1
	
	For each ($value; Form:C1466.JSON.data)
		
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
	$file:=Folder:C1567(fk desktop folder:K87:19).file($file.fullName)
	$file:=cs:C1710.FileName.new($file).file
	$status:=$XLSX.write($file)
	
	return $file
	
Function launch($file : 4D:C1709.File)
	
	OPEN URL:C673($file.platformPath)
	
Function show($file : 4D:C1709.File)
	
	SHOW ON DISK:C922($file.platformPath)
	
	//MARK:-Form Object States
	
Function toggleSelectDataFile() : cs:C1710.DataAnalyzerForm
	
	OBJECT SET ENABLED:C1123(*; "open"; Not:C34(This:C1470.isRunning))
	
	return This:C1470
	
Function toggleParallelProcessing() : cs:C1710.DataAnalyzerForm
	
	OBJECT SET ENABLED:C1123(*; "useMultipleCores"; This:C1470.countCores>1)
	
	return This:C1470
	
Function toggleExportButton() : cs:C1710.DataAnalyzerForm
	
	If (This:C1470.isRunning) || (OB Is empty:C1297(This:C1470.JSON))
		OBJECT SET ENABLED:C1123(*; "exportJ"; False:C215)
		OBJECT SET ENABLED:C1123(*; "exportX"; False:C215)
	Else 
		OBJECT SET ENABLED:C1123(*; "exportJ"; True:C214)
		OBJECT SET ENABLED:C1123(*; "exportX"; This:C1470.JSON.data.length#0)
	End if 
	
	return This:C1470
	
Function toggleTableNames() : cs:C1710.DataAnalyzerForm
	
	If (This:C1470.hideTableNames)
		OBJECT SET VISIBLE:C603(*; "tableName"; False:C215)
		OBJECT SET VISIBLE:C603(*; "genericTableName"; True:C214)
	Else 
		OBJECT SET VISIBLE:C603(*; "tableName"; True:C214)
		OBJECT SET VISIBLE:C603(*; "genericTableName"; False:C215)
	End if 
	
	return This:C1470
	
	//MARK:-
	
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
	
	If (Not:C34([".4DD"; ".data"].includes($file.extension)))
		return 
	End if 
	
	return $file
	
Function _getWorkerName($i : Integer) : Text
	
	If ($i=0)
		return "DataAnalyzer"
	Else 
		return ["DataAnalyzer"; " "; "("; $i; ")"].join("")
	End if 
	
Function _killAll()
	
	var $process : Object
	$processes:=Process activity:C1495(Processes only:K5:35).processes
	If (This:C1470.useMultipleCores)
		For each ($process; $processes)
			If (Match regex:C1019("DataAnalyzer\\s\\(\\d\\)"; $process.name))
				ABORT PROCESS BY ID:C1634($process.ID)
			End if 
		End for each 
	Else 
		$process:=$processes.query("name == :1"; "DataAnalyzer").first()
		If ($process#Null:C1517)
			ABORT PROCESS BY ID:C1634($process.ID)
		End if 
	End if 
	
	//MARK:-Form Events
	
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
	
Function onLoad()
	
	Form:C1466.toggleExportButton().toggleTableNames()
	
Function onUnload()
	
	Form:C1466._killAll()
	
	//MARK:-
	
Function start() : cs:C1710.DataAnalyzerForm
	
	This:C1470.startTime:=Milliseconds:C459
	
	This:C1470.isRunning:=True:C214
	This:C1470.toggleSelectDataFile()
	
	return This:C1470
	
Function updateDuration() : cs:C1710.DataAnalyzerForm
	
	This:C1470.duration:=[String:C10(Abs:C99(Milliseconds:C459-This:C1470.startTime)/1000; "#,###,###,###,##0.0"); "s"].join(" ")
	
	return This:C1470
	
Function stop() : cs:C1710.DataAnalyzerForm
	
	This:C1470.isRunning:=False:C215
	This:C1470.toggleSelectDataFile()
	
	return This:C1470
	
Function open($dataFile : 4D:C1709.File)
	
	This:C1470.tableInfo:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	This:C1470.JSON:={}
	
	If (This:C1470.useMultipleCores)
		This:C1470.updateInterval:=This:C1470.countCores*This:C1470.updateIntervalUnit
	Else 
		This:C1470.updateInterval:=This:C1470.updateIntervalUnit
	End if 
	
	$ctx:={file: $dataFile; window: Current form window:C827}
	$ctx.onFileInfo:=This:C1470._onFileInfo
	$ctx.onTableInfo:=This:C1470._onTableInfo
	$ctx.onTableStats:=This:C1470._onTableStats
	$ctx.onFinish:=This:C1470._onFinish
	$ctx.countCores:=This:C1470.countCores
	$ctx.useMultipleCores:=This:C1470.useMultipleCores
	$ctx.workerFunction:=This:C1470._processTable
	$ctx.updateInterval:=This:C1470.updateInterval
	$ctx.dispatchInterval:=This:C1470.dispatchInterval
	
	This:C1470.start().toggleExportButton()
	
	var $workerNames : Collection
	var $workerName : Text
	
	$workerNames:=[]
	
	If (This:C1470.useMultipleCores)
		For ($i; 1; This:C1470.countCores)
			$workerName:=This:C1470._getWorkerName($i)
			$workerNames.push($workerName)
		End for 
	Else 
		$workerName:=This:C1470._getWorkerName(0)
		$workerNames.push($workerName)
	End if 
	
	$ctx.workerNames:=$workerNames
	
	For each ($workerName; $workerNames)
		CALL WORKER:C1389($workerName; Formula:C1597(preemptiveWorker); $ctx)
	End for each 
	
	CALL WORKER:C1389($workerNames[0]; This:C1470._open; $ctx)
	
	//MARK:-
	
Function _open($ctx : Object)
	
	var $dataInfo : cs:C1710.DataInfo
	$dataInfo:=cs:C1710.DataInfo.new()
	$dataInfo.open($ctx.file)
	$dataInfo.readFileInfo()
	
	var $fileInfo : Object
	$fileInfo:=$dataInfo.getFileInfo()
	
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
	
	$dataInfo.tableInfo:=$dataInfo.tableInfo.orderBy("nbRecords asc")
	
	If ($ctx.useMultipleCores)
		$ctx.tableInfo:=$dataInfo.tableInfo.copy(ck shared:K85:29)
	End if 
	
	var $tableStats : cs:C1710._TableStats
	
	If ($dataInfo.tableInfo.length=0)
		CALL FORM:C1391($ctx.window; $ctx.onFinish; {tableUUID: ""}; $ctx)
	Else 
		If ($ctx.useMultipleCores)
			For each ($workerName; $ctx.workerNames)
				$tableInfo:=Null:C1517
				$tableStats:=Null:C1517
				CALL WORKER:C1389($workerName; $ctx.workerFunction; $dataInfo; $tableInfo; $tableStats; $ctx)
			End for each 
		Else 
			For each ($tableInfo; $dataInfo.tableInfo)
				$tableStats:=cs:C1710._TableStats.new($tableInfo.tableUUID)
				$ctx.workerFunction($dataInfo; $tableInfo; $tableStats; $ctx)
			End for each 
		End if 
	End if 
	
Function _processTable($dataInfo : cs:C1710.DataInfo; $tableInfo : Object; $tableStats : Object; $ctx : Object)
	
	If ($tableInfo=Null:C1517)
		$tableInfo:=$ctx.tableInfo.shift()
		If ($tableInfo=Null:C1517)
			KILL WORKER:C1390
			return 
		Else 
			$tableInfo:=OB Copy:C1225($tableInfo)
			$dataInfo:=OB Copy:C1225($dataInfo)
			$dataInfo.dataFileHandle:=$dataInfo.dataFile.open("read")
			$tableStats:=cs:C1710._TableStats.new($tableInfo.tableUUID)
		End if 
	End if 
	
	$tableStats:=$dataInfo.getTableStats($tableInfo.address_Taba_rec1; $tableStats; $ctx)
	$tableStats:=$dataInfo.getTableStats($tableInfo.address_Taba_Blob; $tableStats; $ctx)
	$dataInfo.gotTableStats($tableStats; $ctx)
	
	If ($ctx.useMultipleCores)
		$tableInfo:=Null:C1517
		$tableStats:=Null:C1517
		CALL WORKER:C1389(Current process name:C1392; $ctx.workerFunction; $dataInfo; $tableInfo; $tableStats; $ctx)
	End if 
	
Function _onTableStats($tableStats : Object)
	
	Form:C1466.updateDuration()
	
	var $table : Object
	var $this : Object
	var $col : Collection
	
	$this:=Form:C1466
	$col:=$this.tableInfo.col
	
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
		Form:C1466.tableInfo.col:=$col
	End if 
	
Function _onFileInfo($fileInfo : Object)
	
	Form:C1466.updateDuration()
	
	Form:C1466.fileInfo:=$fileInfo
	
Function _onTableInfo($tableInfo : Object)
	
	Form:C1466.updateDuration()
	
	var $table : Object
	var $this : Object
	var $col : Collection
	
	$this:=Form:C1466
	$col:=$this.tableInfo.col
	
	$table:=$col.query("tableUUID === :1"; $tableInfo.tableUUID).first()
	If ($table=Null:C1517)
		$col.push($tableInfo)
	Else 
		var $attr : Text
		For each ($attr; $tableInfo)
			$table[$attr]:=$tableInfo[$attr]
		End for each 
	End if 
	
Function _onFinish($tableStats : Object; $ctx : Object)
	
	Form:C1466.updateDuration()
	
	var $table : Object
	var $this : Object
	var $col : Collection
	
	$this:=Form:C1466
	$col:=$this.tableInfo.col
	
	$table:=$col.query("tableUUID === :1"; $tableStats.tableUUID).first()
	
	If ($table#Null:C1517)
		$table.complete:=$tableStats.complete
	End if 
	
	If ($col.query("complete === :1"; True:C214).length=$col.length)
		
		$this.stop().toggleExportButton()
		
		$this.JSON.data:=$col.extract(\
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
		
		$this.JSON.info:=$this.fileInfo
		
		For each ($workerName; $ctx.workerNames)
			KILL WORKER:C1390($workerName)
		End for each 
	End if 