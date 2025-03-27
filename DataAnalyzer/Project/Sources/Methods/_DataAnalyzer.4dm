//%attributes = {"invisible":true,"preemptive":"capable"}
#DECLARE($dataInfo : cs:C1710.DataInfo; $tableInfo : Object; $tableStats : Object; $ctx : Object)

$dataInfo:=OB Copy:C1225($dataInfo)
$dataInfo.dataFileHandle:=$dataInfo.dataFile.open("read")

$tableStats:=$dataInfo.getTableStats($tableInfo.address_Taba_rec1; $tableStats; $ctx)
$tableStats:=$dataInfo.getTableStats($tableInfo.address_Taba_Blob; $tableStats; $ctx)
$dataInfo.gotTableStats($tableStats; $ctx)