var $event : Object

$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		WA OPEN URL:C1020(*; OBJECT Get name:C1087; File:C1566(File:C1566("/RESOURCES/HTML/graph.html").platformPath; fk platform path:K87:2).platformPath)
		
		WA SET PREFERENCE:C1041(*; OBJECT Get name:C1087; WA enable URL drop:K62:8; False:C215)
		WA SET PREFERENCE:C1041(*; OBJECT Get name:C1087; WA enable contextual menu:K62:6; True:C214)
		WA SET PREFERENCE:C1041(*; OBJECT Get name:C1087; WA enable Web inspector:K62:7; True:C214)
		
	: ($event.code=On End URL Loading:K2:47)
		
		//$data:=JSON Parse(Folder(fk desktop folder).file("flare-2.json").getText())
		
		$data:=JSON Parse:C1218(Folder:C1567(fk desktop folder:K87:19).file("DataAnalyzer.json").getText())
		
		$f:=cs:C1710._JSONFormatter.new()
		
		$data:=$f.test($data)
		
		var $l; $t; $r; $b : Integer
		OBJECT GET COORDINATES:C663(*; OBJECT Get name:C1087; $l; $t; $r; $b)
		$width:=$r-$l
		$height:=$b-$t
		$size:=$width>$height ? $height : $width
		
		WA EXECUTE JAVASCRIPT FUNCTION:C1043(*; OBJECT Get name:C1087; "chart"; *; $data; $size)
		
End case 