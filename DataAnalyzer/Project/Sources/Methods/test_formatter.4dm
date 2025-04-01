//%attributes = {}
$data:=JSON Parse:C1218(Folder:C1567(fk desktop folder:K87:19).file("DataAnalyzer.json").getText())

$f:=cs:C1710._JSONFormatter.new()

$data:=$f.test($data)
