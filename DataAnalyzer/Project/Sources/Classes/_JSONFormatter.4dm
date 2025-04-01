Class constructor
	
Function d3sunburst($obj : Object) : Object
	
	$root:={name: "file"; children: []}
	$format:="#,###,###,###,###,##0"
	
	$records:=Localized string:C991("records")
	$blob:=Localized string:C991("blob")
	$text:=Localized string:C991("text")
	$table_:=Localized string:C991("Table_")
	
	If ($obj.data#Null:C1517)
		
		For each ($data; $obj.data)
			
			If ($data.tableName=Null:C1517)
				$data.tableName:=$table_+String:C10($data.tableNumber)
			End if 
			
			If (($data.records.size=Null:C1517) || ($data.records.size=0))\
				 && (($data.blobs.size=Null:C1517) || ($data.blobs.size=0))
				continue
			End if 
			
			$cid:="data-table-"+String:C10($data.tableNumber)
			$table:={name: $data.tableName; children: []; cid: $cid}
			$root.children.push($table)
			
			$total:=0
			$components:=0
			
			If ($data.records.size#0)
				$components+=1
				$total+=$data.records.size
			End if 
			
			If ($data.blobs.size#0)  //includes text, object, picture
				$components+=1
				$total+=$data.blobs.size
			End if 
			
			$totalSize:=String:C10($total; $format)
			
			If ($components=1)
				$table.children.push({name: $totalSize; value: $total})
			Else 
				
				$children:=[]
				$cid:=$cid+"-details"
				$table.children.push({name: $totalSize; children: $children; cid: $cid})
				
				If ($data.records.size#Null:C1517)
					$children.push({name: $records; value: $data.records.size})
				End if 
				If ($data.blobs.size#Null:C1517)
					$other:=$data.blobs.size
					If ($data.texts.size#Null:C1517)
						$other-=$data.texts.size
						$children.push({name: $text; value: $data.texts.size})
					End if 
					$children.push({name: $blob; value: $other})
				End if 
			End if 
			
		End for each 
		
	End if 
	
	return $root