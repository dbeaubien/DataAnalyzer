property dataFile : 4D:C1709.File
property dataFileHandle : 4D:C1709.FileHandle
property isDataLittleEndian : Boolean
property dataFileVersion : Text
property lastOperation : Integer
property lastOperationDescription : Text
property dataSegmentsCount : Integer
property productVersionCode : Text
property synchronizationIdentifier : Text
property logicalEOF : Text
property limitSegments : Text
property primaryBlockAllocationAddressTable : Text
property hasSecondaryBlockAllocationAddressTable : Boolean
property dataFileNeedsRepair : Boolean
property dataFileInformation : Collection
property dataFileContainsStructure : Boolean
property indexStoredInSeparateSegment : Boolean
property addressTablesOfDataTablesSize : Integer
property randomValueForDuplicateIndexDetection : Text
property numberOfLogFiles : Integer
property lastLogAction : Text
property numberOfHeaderModifications : Integer
property randomValueToLinkWithIndexes : Text
property segmentHeaderSize : Integer
property segmentHeaderAddress : Text
property blockSize : Integer
property ratio : Integer
property addressTableHasHoles : Boolean
property firstHolePositionInAddressTable : Text
property numberOfDataTables : Integer
property dataTableHeadersAddress : Text
property numberOfRelations : Integer
property relationsTableHasHoles : Boolean
property firstHolePositionInRelationsTable : Text
property relationsTableAddress : Text
property sequenceNumbersTableHasHoles : Boolean
property firstHolePositionInSequenceNumbersTable : Text
property sequenceNumbersAddress : Text
property numberOfSequenceNumbers : Integer
property numberOfIndexes : Integer
property indexDefinitionsTableHasHoles : Boolean
property firstHolePositionInIndexDefinitionsTable : Text
property indexDefinitionsTableAddress : Text
property numberOfIndexesDefinedInStructure : Integer
property indexDefinitionsTableInStructureHasHoles : Boolean
property firstHolePositionInIndexDefinitionsTableInStructure : Text
property indexDefinitionsTableInStructureAddress : Text
property extraPropertiesSize : Integer
property extraPropertiesTableAddress : Text
property extraPropertiesTableHasHoles : Boolean
property addressTablesTableHasHoles : Boolean
property firstHolePositionInAddressTablesTable : Text
property numberOfDataFlushes : Integer
property dialectCode : Integer
property dialectDescription : Text
property withICU : Boolean
property ignoreWildCharInMiddle : Boolean
property useSecondaryCollationStrengthForfMatching : Boolean
property useQuaternaryCollationStrengthForSorting : Boolean
property sortHiraganaCodePointsFirstOnQuaternaryLevel : Boolean
property useLanguageNeutralDeadcharAlgorithmInsteadOfBreakIterator : Boolean
property useTraditionalStyleSorting : Boolean
property PAT_Addresses : Object
property tableAddress : Object
property tableInfo : Collection

Class extends Info

Class constructor
	
	Super:C1705()
	
	$blockType:={}
	$blockType.DTab:="DataTable"
	$blockType.TDEF:="TableDefElem"
	$blockType.rec1:="Record"
	$blockType["set "]:="SetDisk"
	$blockType.setT:="SetDiskTable"
	$blockType.blob:="Blob"
	$blockType.blbT:="BlobText"
	$blockType.blbP:="BlobPict"
	$blockType._DEF:="StructDefElem"
	$blockType.iDEF:="IndexDefElem"
	$blockType.IDEF:="IndexInStructDefElem"
	$blockType.treP:="BtreePage"
	$blockType.SelP:="PetiteSel"
	$blockType.SelL:="LongSel"
	$blockType.RDEF:="RelationDefElem"
	$blockType.xTAB:="ExtraTableProperties"
	$blockType.xFLD:="ExtraFieldProperties"
	$blockType.xREL:="ExtraRelationProperties"
	$blockType.xDAT:="ExtraDataBaseProperties"
	$blockType.Seq1:="AutoSeqNumberSimple"
	$blockType.segs:="MultiSegHeader"
	$blockType.TabA:="TableAddress"
	$blockType.Taba:="TableAddressWithStamps"
	$blockType.BitT:="Bittab"
	
	$listOfBlocks:=["TabA"; "Taba"; "BitT"]
	
	This:C1470.blockType:={}
	
	var $resType : Text
	For each ($resType; $blockType)
		$blockType:={}
		$blockType.resType:=$resType
		$blockType.name:=$blockType[$resType]
		$blockType.longSwap:=(Character code:C91($resType[[4]]) << 24)+(Character code:C91($resType[[3]]) << 16)+(Character code:C91($resType[[2]]) << 8)+Character code:C91($resType[[1]])
		$blockType.longNoSwap:=(Character code:C91($resType[[1]]) << 24)+(Character code:C91($resType[[2]]) << 16)+(Character code:C91($resType[[3]]) << 8)+Character code:C91($resType[[4]])
		$blockType.headerSize:=28+(4*Num:C11($resType="rec1"))
		$blockType.isListOfBlocks:=$listOfBlocks.indexOf($resType)#-1
		This:C1470.blockType[$resType]:=$blockType
	End for each 
	
	This:C1470.tableInfo:=[]
	This:C1470.tableAddress:={}
	This:C1470.tableAddress.TDEF:=[]
	This:C1470.tableAddress.DTab:=[]
	
Function open($dataFile : 4D:C1709.File) : cs:C1710.DataInfo
	
	If (This:C1470.isDataFile($dataFile))
		This:C1470.dataFile:=This:C1470.expand($dataFile)
	Else 
		This:C1470.dataFile:=Null:C1517
	End if 
	
	If (This:C1470.dataFile#Null:C1517)
		This:C1470.dataFileHandle:=This:C1470.dataFile.open("read")
	Else 
		This:C1470.dataFileHandle:=Null:C1517
	End if 
	
	return This:C1470
	
Function readFileInfo() : cs:C1710.DataInfo
	
	$blDataBlock:=This:C1470.readblock("0x0000"; 256; True:C214)
	
	If ($blDataBlock.size=0)
		
	Else 
		This:C1470.isDataLittleEndian:=This:C1470.isSignatureLittleEndian($blDataBlock)
		var $swap : Integer
		If (Bool:C1537(This:C1470.isDataLittleEndian))
			$swap:=PC byte ordering:K22:3
		Else 
			$swap:=Macintosh byte ordering:K22:2
		End if 
		
		$offset:=0
		$data_PlatformID:=BLOB to longint:C551($blDataBlock; Macintosh byte ordering:K22:2; $offset)
		$platformIdentifier:=String:C10($data_PlatformID; "&x")
		
		Case of 
			: ($platformIdentifier="0xFFFFFFFF")  //Macintosh
				This:C1470.dataFileVersion:="6"
			: ($platformIdentifier="0xFFFFFFFE")  //Windows
				This:C1470.dataFileVersion:="6"
			: ($platformIdentifier="0x02440144")
				This:C1470.dataFileVersion:="11"
			Else 
				This:C1470.dataFileVersion:=""
		End case 
		
		If (This:C1470.dataFileVersion="11")
			This:C1470.lastOperation:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			Case of 
				: (This:C1470.lastOperation=0)
					This:C1470.lastOperationDescription:=Get localized string:C991("The Cache has been correctly flushed")
				: (This:C1470.lastOperation=-1)
					This:C1470.lastOperationDescription:=Get localized string:C991("The Cache flushing has been interrupted!")
				Else 
					This:C1470.lastOperationDescription:=Get localized string:C991("Unknown Last Operation!")
			End case 
			
			$vdt_LastParam:=This:C1470.chunkToHex($blDataBlock; ->$offset; 4; False:C215)
			$vdt_NbDataSeg:=BLOB to integer:C549($blDataBlock; $swap; $offset)
			This:C1470.numberOfDataSegments:=$vdt_NbDataSeg
			$vdt_IDisNotAnID:=BLOB to integer:C549($blDataBlock; $swap; $offset)
			$vdt_SubVersionNb:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			$vdt_VersionNb:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.productVersionCode:=String:C10($vdt_VersionNb)+"."+String:C10($vdt_SubVersionNb)
			$vdt_VUUIDSynchro:=This:C1470.chunkToHex($blDataBlock; ->$offset; 16; False:C215)
			This:C1470.synchronizationIdentifier:=$vdt_VUUIDSynchro
			$vdt_EOF:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vReal:=This:C1470.toReal($vdt_EOF; False:C215)
			$vEOFActual:=$vReal\0x0080
			This:C1470.logicalEOF:=$vdt_EOF
			$vdt_LimitSeg:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; False:C215)
			This:C1470.limitSegments:=$vdt_LimitSeg
			
			$vdt_AddBATPagePrim:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vdt_AddBATPagePrim_R:=This:C1470.toReal($vdt_AddBATPagePrim)
			This:C1470.primaryBlockAllocationAddressTable:=$vdt_AddBATPagePrim
			This:C1470.hasSecondaryBlockAllocationAddressTable:=($vdt_AddBATPagePrim_R#0)
			
			$vdt_BlockSize:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.blockSize:=$vdt_BlockSize
			
			$vdt_Ratio:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.ratio:=$vdt_Ratio
			
			$vdt_AddTabAddTab4DTab:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			This:C1470.addressTablesOfDataTablesAddress:=$vdt_AddTabAddTab4DTab
			
			$vdt_AddSegmentHeaders:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			This:C1470.segmentHeaderAddress:=$vdt_AddSegmentHeaders
			
			$vdt_SegHdrSize:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.segmentHeaderSize:=$vdt_SegHdrSize
			
			$vdt_Filfil:=This:C1470.chunkToHex($blDataBlock; ->$offset; 4; False:C215)
			This:C1470.randomValueToLinkWithIndexes:=$vdt_Filfil
			
			$vdt_NbHdrModifs:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.numberOfHeaderModifications:=$vdt_NbHdrModifs
			
			$vdt_LogLastAction:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vReal:=This:C1470.toReal($vdt_LogLastAction; False:C215)
			This:C1470.lastLogAction:=$vdt_LogLastAction
			
			$vdt_NbLogFiles:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.numberOfLogFiles:=$vdt_NbLogFiles
			
			$vdt_LastFlushRandomStamp:=This:C1470.chunkToHex($blDataBlock; ->$offset; 4; True:C214)
			This:C1470.randomValueForDuplicateIndexDetection:=$vdt_LastFlushRandomStamp
			
			$vdt_Nb4DFiles:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.addressTablesOfDataTablesSize:=$vdt_Nb4DFiles
			
			var $blob : Blob
			$blob:=$blDataBlock.slice($offset; $offset+4)
			$vdt_Flags1:=$blob{0}
			$vdt_Flags2:=$blob{1}  // Not Used
			$vdt_Flags3:=$blob{2}
			$vdt_Flags4:=$blob{3}
			$offset+=4
			
			This:C1470.dataFileInformation:=[]
			This:C1470.dataFileNeedsRepair:=($vdt_Flags1=1)
			
			If (This:C1470.dataFileNeedsRepair)
				This:C1470.dataFileInformation.push(Get localized string:C991("Data File needs to be repaired."))
			Else 
				This:C1470.dataFileInformation.push(Get localized string:C991("Data File does not need to be repaired."))
			End if 
			
			This:C1470.dataFileContainsStructure:=($vdt_Flags3=1)
			If (This:C1470.dataFileContainsStructure)
				This:C1470.dataFileInformation.push(Get localized string:C991("Data File contains Structure."))
			Else 
				This:C1470.dataFileInformation.push(Get localized string:C991("Data File contains Data."))
			End if 
			
			This:C1470.indexStoredInSeparateSegment:=($vdt_Flags4=1)
			If (This:C1470.indexStoredInSeparateSegment)
				This:C1470.dataFileInformation.push(Get localized string:C991("Indexes are in a separate segment."))
			Else 
				This:C1470.dataFileInformation.push(Get localized string:C991("Indexes are in the same segment."))
			End if 
			
			$vdt_Addr1stTrou:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vReal:=This:C1470.toReal($vdt_Addr1stTrou; False:C215)
			This:C1470.addressTableHasHoles:=($vReal#-2000000000)
			This:C1470.firstHolePositionInAddressTable:=$vdt_Addr1stTrou
			
			$vdt_AddrTabAddr:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			This:C1470.dataTableHeadersAddress:=$vdt_AddrTabAddr
			
			$vdt_NbOf4DTables:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.numberOfDataTables:=$vdt_NbOf4DTables
			
			$vdt_NbOfRelations:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.numberOfRelations:=$vdt_NbOfRelations
			$vdt_RelAddr1stTrou:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vReal:=This:C1470.toReal($vdt_RelAddr1stTrou; False:C215)
			This:C1470.relationsTableHasHoles:=($vReal#-2000000000)
			This:C1470.firstHolePositionInRelationsTable:=$vdt_RelAddr1stTrou
			$vdt_RelAddrTabAddr:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			This:C1470.relationsTableAddress:=$vdt_RelAddrTabAddr
			
			$vdt_NbOfSeqNb:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.numberOfSequenceNumbers:=$vdt_NbOfSeqNb
			$vdt_SeqAddr1stTrou:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vReal:=This:C1470.toReal($vdt_SeqAddr1stTrou; False:C215)
			This:C1470.sequenceNumbersTableHasHoles:=($vReal#-2000000000)
			This:C1470.firstHolePositionInSequenceNumbersTable:=$vdt_SeqAddr1stTrou
			$vdt_SeqAddrTabAddr:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			This:C1470.sequenceNumbersAddress:=$vdt_SeqAddrTabAddr
			
			$vdt_NbOfIndex:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.numberOfIndexes:=$vdt_NbOfIndex
			$vdt_IdxAddr1stTrou:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vReal:=This:C1470.toReal($vdt_IdxAddr1stTrou; False:C215)
			This:C1470.indexDefinitionsTableHasHoles:=($vReal#-2000000000)
			This:C1470.firstHolePositionInIndexDefinitionsTable:=$vdt_IdxAddr1stTrou
			$vdt_IdxAddrTabAddr:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			This:C1470.indexDefinitionsTableAddress:=$vdt_IdxAddrTabAddr
			
			$vdt_NbOfIndexStruct:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.numberOfIndexesDefinedInStructure:=$vdt_NbOfIndex
			$vdt_IdxAddr1stTrouStr:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vReal:=This:C1470.toReal($vdt_IdxAddr1stTrouStr; False:C215)
			This:C1470.indexDefinitionsTableInStructureHasHoles:=($vReal#-2000000000)
			This:C1470.firstHolePositionInIndexDefinitionsTableInStructure:=$vdt_IdxAddr1stTrouStr
			$vdt_IdxAddrTabAddrStr:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			This:C1470.indexDefinitionsTableInStructureAddress:=$vdt_IdxAddrTabAddrStr
			
			$vdt_ExtraAddrTabAddr:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vReal:=This:C1470.toReal($vdt_ExtraAddrTabAddr; False:C215)
			This:C1470.extraPropertiesTableHasHoles:=($vReal#-2000000000)
			This:C1470.extraPropertiesTableAddress:=$vdt_ExtraAddrTabAddr
			$vdt_ExtraLen:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.extraPropertiesSize:=$vdt_ExtraLen
			
			$vdt_DataAddr1stTrou:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			$vReal:=This:C1470.toReal($vdt_DataAddr1stTrou; False:C215)
			This:C1470.addressTablesTableHasHoles:=($vReal#-2000000000)
			This:C1470.firstHolePositionInAddressTablesTable:=$vdt_DataAddr1stTrou
			
			$vdt_CountFlush:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.numberOfDataFlushes:=$vdt_CountFlush
			$vdt_Dialect:=BLOB to longint:C551($blDataBlock; $swap; $offset)
			This:C1470.dialectCode:=$vdt_Dialect
			Case of 
				: ($vdt_Dialect=-4444)
					This:C1470.dialectDescription:="System"
				: ($vdt_Dialect=0)
					This:C1470.dialectDescription:="4D"
			End case 
			
			$blob:=$blDataBlock.slice($offset; $offset+1)
			$vdt_Collator:=$blob{0}
			$offset+=1
			
			This:C1470.withICU:=$vdt_Collator ?? 0
			This:C1470.ignoreWildCharInMiddle:=$vdt_Collator ?? 1
			This:C1470.useSecondaryCollationStrengthForfMatching:=$vdt_Collator ?? 2
			This:C1470.useQuaternaryCollationStrengthForSorting:=$vdt_Collator ?? 3
			This:C1470.sortHiraganaCodePointsFirstOnQuaternaryLevel:=$vdt_Collator ?? 4
			This:C1470.useLanguageNeutralDeadcharAlgorithmInsteadOfBreakIterator:=$vdt_Collator ?? 5
			This:C1470.useTraditionalStyleSorting:=$vdt_Collator ?? 6
			
			This:C1470.PAT_Addresses:={\
				DTab: This:C1470.toReal($vdt_AddTabAddTab4DTab; False:C215)\0x0080; \
				TDEF: This:C1470.toReal($vdt_AddrTabAddr; False:C215)\0x0080; \
				iDEF: This:C1470.toReal($vdt_IdxAddrTabAddr; False:C215)\0x0080; \
				IDEF: This:C1470.toReal($vdt_IdxAddrTabAddrStr; False:C215)\0x0080; \
				RDEF: This:C1470.toReal($vdt_RelAddrTabAddr; False:C215)\0x0080; \
				xREL: This:C1470.toReal($vdt_RelAddrTabAddr; False:C215)\0x0080; \
				xDAT: This:C1470.toReal($vdt_ExtraAddrTabAddr; False:C215)\0x0080; \
				seq1: This:C1470.toReal($vdt_SeqAddrTabAddr; False:C215)\0x0080\
				}
			
			This:C1470.readTable(This:C1470.PAT_Addresses.DTab; "DTab")
			This:C1470.readTable(This:C1470.PAT_Addresses.TDEF; "TDEF")
			
		End if 
	End if 
	
	return This:C1470
	
Function readTable($tableAddress : Real; $tag : Text) : cs:C1710.DataInfo
	
	$byteSwap:=Bool:C1537(This:C1470.isDataLittleEndian)
	
	var $swap : Integer
	If ($byteSwap)
		$swap:=PC byte ordering:K22:3
	Else 
		$swap:=Macintosh byte ordering:K22:2
	End if 
	
	$level:=0
	
	$type:=This:C1470.blockType[$tag]
	$blockSize:=This:C1470.blockSize
	
	$nbBlocks:=96+1  //   96 * 128 = 1024 * 12 (8 bytes address + 4 bytes length) 
	
	$blDataBlock:=This:C1470.readblocks($tableAddress; $nbBlocks; True:C214)
	
	$offset:=0
	$headerInfo:=This:C1470.getBlockHeader($blDataBlock; $byteSwap)
	
	If ($headerInfo.success)
		$offset:=$headerInfo.offset
		$resType:=$headerInfo.resType
		$blockLength:=$headerInfo.size
		$resTypeLong:=$headerInfo.resTypeLong
		$nbTargets:=1024
		
		$tableAddresses:=[]
		$vTableIdx:=0
		
		For ($i; 1; $nbTargets)
			$hexAddress:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)
			If ($hexAddress#"0000000000000000")
				$vTableIdx:=$vTableIdx+1
				$curAddress:=This:C1470.toReal($hexAddress)
				$curBlock:=$curAddress\$blockSize
				If ($curBlock=0)
					
				Else 
					$tableAddresses.push({number: $vTableIdx; address: $curBlock; length: BLOB to longint:C551($blDataBlock; $swap; $offset)})
				End if 
			End if 
		End for 
	End if 
	
	This:C1470.tableAddress[$tag]:=$tableAddresses
	
	return This:C1470
	
	
	
	
	
	
Function readTableInfo($tableAddress : Object) : Object
	
	$segEOF:=This:C1470.toReal(This:C1470.logicalEOF; True:C214)
	$byteSwap:=Bool:C1537(This:C1470.isDataLittleEndian)
	$blockSize:=This:C1470.blockSize
	
	$blDataBlock:=This:C1470.readblocks($tableAddress.address; $tableAddress.length; False:C215)
	
	$offset:=0
	$headerInfo:=This:C1470.getBlockHeader($blDataBlock; $byteSwap)
	
	If ($headerInfo.success)
		$offset:=$headerInfo.offset
		$resType:=$headerInfo.resType
		$blockLength:=$headerInfo.size
		$resTypeLong:=$headerInfo.resTypeLong
		$tableNumber:=$headerInfo.position
		
		Case of 
			: ($resType="TabA")  //If more than 1024 tables
				
				This:C1470.readTable($tableAddress.address; "DTab")
				
			: ($resType="DTab")
				
				$nb_Records:=BLOB to longint:C551($blDataBlock; $swap; $offset)  //sLONG nbfic;  // nb records
				$offset:=$offset+4+8  //Infos not used here
				$addrTabAddr:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)  //DataAddr4D addrtabaddr;->Addr of Taba or TabA of records rec1
				$addressOfTabaOf_rec1:=This:C1470.toReal($addrTabAddr; False:C215)
				
				$offset:=$offset+4+8  //Infos not used here
				$addrBlobTabAddr:=This:C1470.chunkToHex($blDataBlock; ->$offset; 8; True:C214)  //DataAddr4D addrBlobtabaddr;->Addr of Taba or TabA of Blobs
				$addressOfTabaOf_Blob:=This:C1470.toReal($addrBlobTabAddr; False:C215)
				
				$nb_Blobs:=BLOB to longint:C551($blDataBlock; $swap; $offset)  //  //sLONG nbBlob;
				
				$offset:=$offset+16  //Infos not used here
				$vUUID_TableDef:=This:C1470.chunkToHex($blDataBlock; ->$offset; 16; False:C215)  //VUUIDBuffer TableDefID;  // ID TDEF 
				
				var $tableInfo : Object
				$tableInfo:=This:C1470.tableInfo.query("tableNumber === :1"; $tableNumber).first()
				If ($tableInfo=Null:C1517)
					$tableInfo:={\
						tableNumber: $tableNumber; \
						tableUUID: $vUUID_TableDef; \
						nbRecords: $nb_Records; \
						nbBlobs: $nb_Blobs; \
						address_Taba_rec1: $addressOfTabaOf_rec1\$blockSize; \
						address_Taba_Blob: $addressOfTabaOf_Blob\$blockSize}
					This:C1470.tableInfo.push($tableInfo)
				Else 
					$tableInfo.tableUUID:=$vUUID_TableDef
					$tableInfo.nbRecords:=$nb_Records
					$tableInfo.nbBlobs:=$nb_Blobs
					$tableInfo.address_Taba_rec1:=$addressOfTabaOf_rec1\$blockSize
					$tableInfo.address_Taba_Blob:=$addressOfTabaOf_Blob\$blockSize
				End if 
				
				return $tableInfo
				
		End case 
		
	End if 
	
Function readTableDefinition($tableAddress : Object) : Object
	
	$segEOF:=This:C1470.toReal(This:C1470.logicalEOF; True:C214)
	$byteSwap:=Bool:C1537(This:C1470.isDataLittleEndian)
	$blockSize:=This:C1470.blockSize
	
	$blDataBlock:=This:C1470.readblocks($tableAddress.address; $tableAddress.length; False:C215)
	
	$offset:=0
	$headerInfo:=This:C1470.getBlockHeader($blDataBlock; $byteSwap)
	
	If ($headerInfo.success)
		$offset:=$headerInfo.offset
		$resType:=$headerInfo.resType
		$blockLength:=$headerInfo.size
		$resTypeLong:=$headerInfo.resTypeLong
		
		Case of 
			: ($resType="TabA")  //If more than 1024 tables
				
				This:C1470.readTable($tableAddress.address; "TDEF")
				
			: ($resType="TDEF")
				
				$vUUID_TableID:=This:C1470.chunkToHex($blDataBlock; ->$offset; 16; False:C215)
				$vTableName:=This:C1470.chunkToText($blDataBlock; ->$offset; 64; False:C215; True:C214)
				
				var $tableInfo : Object
				$tableInfo:=This:C1470.tableInfo.query("tableUUID === :1"; $vUUID_TableID).first()
				If ($tableInfo=Null:C1517)
					$tableInfo:={\
						tableUUID: $vUUID_TableID; \
						tableName: $vTableName}
					This:C1470.tableInfo.push($tableInfo)
				Else 
					$tableInfo.tableName:=$vTableName
				End if 
				
				return $tableInfo
				
		End case 
		
	End if 
	
Function readTableDefinitions() : Collection
	
	$tables:=[]
	var $table : Object
	
	For each ($tableAddress; This:C1470.tableAddress.TDEF)
		$table:=This:C1470.readTableDefinition($tableAddress)
		If ($table#Null:C1517)
			$tables.push($table)
		End if 
	End for each 
	
	return $tables
	
Function readTableInfos() : Collection
	
	$tables:=[]
	var $table : Object
	
	For each ($tableAddress; This:C1470.tableAddress.DTab)
		$table:=This:C1470.readTableInfo($tableAddress)
		If ($table#Null:C1517)
			$tables.push($table)
		End if 
	End for each 
	
	return $tables
	
Function readblock($address : Text; $blkSize : Real; $flByteSwap : Boolean; $realAddress : Real) : 4D:C1709.Blob
	
	If (This:C1470.dataFileHandle#Null:C1517) && ($blkSize>0) && (Length:C16($address)#0)
		
		If (Count parameters:C259<4)
			This:C1470.dataFileHandle.offset:=This:C1470.addressToOffset($address; (Count parameters:C259<3) ? True:C214 : $flByteSwap)
		Else 
			This:C1470.dataFileHandle.offset:=$realAddress
		End if 
		
		return Try(This:C1470.dataFileHandle.readBlob($blkSize))
		
	End if 
	
Function readblocks($blockPosition : Real; $data2Read : Real; $flIsNbOfBlocks : Boolean) : 4D:C1709.Blob
	
	If (This:C1470.dataFileHandle#Null:C1517) && ($data2Read>0)
		
		var $realAddress : Real
		$realAddress:=$blockPosition*0x0080
		If ($flIsNbOfBlocks)
			$length:=$data2Read*0x0080
		Else 
			$length:=$data2Read
		End if 
		
		This:C1470.dataFileHandle.offset:=$realAddress
		
		return Try(This:C1470.dataFileHandle.readBlob($length))
		
	End if 