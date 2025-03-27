property isThrowAvailable : Boolean
property isTryAvailable : Boolean

Class constructor
	
	//%W-550.26
	This:C1470._isThrowAvailable:=($version>="2020")
	This:C1470._isTryAvailable:=($version>="2040")
	//%W+550.26
	
Function get isThrowAvailable() : Boolean
	
	//%W-550.26
	return This:C1470._isThrowAvailable
	//%W+550.26
	
Function get isTryAvailable() : Boolean
	
	//%W-550.26
	return This:C1470._isTryAvailable
	//%W+550.26
	
Function addressToOffset($address : Text; $swap : Boolean) : Real
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	var $flIsBlockNb; $flDataAddr4D : Boolean
	var $prefix; $where2go : Text
	If (Match regex:C1019("([$#&]|(?:0x))([:Hex_Digit:]+)"; $address; 1; $pos; $len))
		$prefix:=Substring:C12($address; $pos{1}; $len{1})
		$where2go:=Substring:C12($address; $pos{2}; $len{2})
		Case of 
			: ($prefix="$")
				$flDataAddr4D:=True:C214
			: ($prefix="#")
				$flIsBlockNb:=True:C214
		End case 
	End if 
	
	$len:=Length:C16($where2go)
	If (This:C1470.isOdd($len))
		$len+=1
		$where2go:="0"+$where2go
	End if 
	
	If ($swap)
		$where2go:=This:C1470.byteSwap($where2go)
	End if 
	
	If ((Length:C16($where2go)=16) & ($where2go="0000@"))
		$where2go:=Substring:C12($where2go; 5)
		return This:C1470.toReal($where2go; False:C215)
	Else 
		return This:C1470.toReal($where2go; False:C215)
	End if 
	
Function byteSwap($value : Text) : Text
	
	var $prefix; $result : Text
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	If (Match regex:C1019("([&]|(?:0x))([:Hex_Digit:]+)"; $value; 1; $pos; $len))
		$prefix:=Substring:C12($value; $pos{1}; $len{1})
		$hexString:=Substring:C12($value; $pos{2}; $len{2})
	Else 
		$prefix:=""
		$hexString:=$value
	End if 
	
	$len:=Length:C16($hexString)
	If (This:C1470.isOdd($len))
		$hexString:="0"+$hexString
		$len+=1
	End if 
	
	Case of 
		: ($len=2)
			$result:=$hexString
			
		: ($len=4)
			$result:=Substring:C12($hexString; 3; 2)+Substring:C12($hexString; 1; 2)
			
		: ($len=6)
			$result:=Substring:C12($hexString; 5; 2)+Substring:C12($hexString; 3; 2)+Substring:C12($hexString; 1; 2)
			
		: ($len=8)
			$result:=Substring:C12($hexString; 7; 2)+Substring:C12($hexString; 5; 2)+Substring:C12($hexString; 3; 2)+Substring:C12($hexString; 1; 2)
			
		: ($len=10)
			$result:=Substring:C12($hexString; 9; 2)+This:C1470.byteSwap(Substring:C12($hexString; 1; 8))
			
		: ($len=12)
			$result:=This:C1470.byteSwap(Substring:C12($hexString; 9; 4))+This:C1470.byteSwap(Substring:C12($hexString; 1; 8))
			
		: ($len=14)
			$result:=This:C1470.byteSwap(Substring:C12($hexString; 9; 6))+This:C1470.byteSwap(Substring:C12($hexString; 1; 8))
			
		: ($len=16)
			$result:=This:C1470.byteSwap(Substring:C12($hexString; 9; 8))+This:C1470.byteSwap(Substring:C12($hexString; 1; 8))
			
		Else 
			
	End case 
	
	If (Length:C16($result)=0)
		return $result
	Else 
		return $prefix+$result
	End if 
	
Function chunkToHex($data : 4D:C1709.Blob; $offsetPtr : Pointer; $length : Integer; $swap : Boolean) : Text
	
	var $offset : Integer
	$offset:=$offsetPtr->
	var $blob : Blob
	$blob:=$data.slice($offset; $offset+$length)
	
	$offsetPtr->+=$length
	
	var $result : Text
	$l:=BLOB size:C605($blob)
	
	If ($l>0)
		If ($swap)
			var $blob2 : Blob
			SET BLOB SIZE:C606($blob2; $l)
			For ($i; 0; $l-1)
				$blob2{$i}:=$blob{$l-$i-1}
			End for 
			$blob:=$blob2
		End if 
		
		For ($i; 0; $l-1)
			$char:=Substring:C12(String:C10($blob{$i}; "&$00"); 2)
			$result:=$result+$char
		End for 
		$result:=$result
	End if 
	
	return $result
	
Function chunkToText($data : 4D:C1709.Blob; $offsetPtr : Pointer; $length : Integer; $swap : Boolean; $short : Boolean) : Text
	
	var $offset : Integer
	$offset:=$offsetPtr->
	var $blob : Blob
	$blob:=$data.slice($offset; $offset+$length)
	
	$offsetPtr->+=$length
	
	$length1:=$length
	
	var $result : Text
	$l:=BLOB size:C605($blob)
	
	If ($l>0)
		$offset2:=0
		If ($short)
			$length:=BLOB to integer:C549($blob; Native byte ordering:K22:1; $offset2)
		Else 
			$length:=BLOB to longint:C551($blob; Native byte ordering:K22:1; $offset2)
		End if 
		
		If (($length<0) & $short)
			$length:=-$length
		End if 
		
		If ($short)
			$flOK:=True:C214
		Else 
			$flOK:=(($length*2)+2+(2*Num:C11(Not:C34($short)))=$l)
		End if 
		
		If ($flOK)
			
			If (($length>0) & ((($length*2)+4)<=$l))
				
				var $blob2 : Blob
				SET BLOB SIZE:C606($blob2; 0)
				COPY BLOB:C558($blob; $blob2; $offset2; 0; $length*2)
				$result:=Convert to text:C1012($blob2; "utf-16")
				If (Length:C16($result)>0)
					For ($i; Length:C16($result); 1; -1)
						If (Character code:C91($result[[$i]])<32)
							$result:=Substring:C12($result; 1; $i-1)+Substring:C12($result; $i+1)
						End if 
					End for 
				End if 
			End if 
			
		Else 
			
		End if 
	End if 
	
	return $result
	
Function expand($in : Object) : Object
	
	return OB Class:C1730($in).new($in.platformPath; fk platform path:K87:2)
	
Function isDataFile($dataFile : 4D:C1709.File) : Boolean
	
	
	If (OB Instance of:C1731($dataFile; 4D:C1709.File)) && ($dataFile.exists)
		var $extenions : Collection
		$extenions:=[".4dd"; ".data"]
		If ($extenions.indexOf($dataFile.extension)#-1)
			return True:C214
		End if 
	End if 
	
	return False:C215
	
Function isOdd($value : Real) : Boolean
	
	var $temp : Integer
	$temp:=$value\2
	return (($temp*2)#$value)
	
Function isSignatureLittleEndian($data : 4D:C1709.Blob) : Boolean
	
	var $long : Integer
	$long:=BLOB to longint:C551($data; Macintosh byte ordering:K22:2)
	
	return ($long=0x02440144)
	
Function getBlockHeader($data : 4D:C1709.Blob; $byteSwap : Boolean) : Object
	
	$flNull:=False:C215
	
	If (OB Instance of:C1731($data; 4D:C1709.Blob))
		If ($data.size<28)
			$flNull:=True:C214
		Else 
			var $blob : Blob
			$blob:=$data.slice(0; 28)
			$tag:=""
			If ($byteSwap)
				$swap:=PC byte ordering:K22:3
				$swapName:="longSwap"
				For ($i; 3; 0; -1)
					$tag:=$tag+Char:C90($blob{$i})
				End for 
			Else 
				$swap:=Macintosh byte ordering:K22:2
				$swapName:="longNoSwap"
				For ($i; 0; 3)
					$tag:=$tag+Char:C90($blob{$i})
				End for 
			End if 
			
			$offset:=0
			$tagNum:=BLOB to longint:C551($blob; $swap; $offset)
			$found:=False:C215
			$typeName:=""
			$headerSize:=0
			
			$blockLength:=BLOB to longint:C551($blob; $swap; $offset)  //Block length
			$blockTS:=This:C1470.chunkToHex($blob; ->$offset; 8; False:C215)  //Block Timestamp
			$blockCSNum:=BLOB to longint:C551($blob; Macintosh byte ordering:K22:2; $offset)  //Block Chechsum
			$blockPos:=BLOB to longint:C551($blob; $swap; $offset)
			$bockParent:=BLOB to longint:C551($blob; $swap; $offset)
			
			If ($tag="rec1")
				$blockNbFields:=BLOB to longint:C551($data; $swap; $offset)
			Else 
				$blockNbFields:=0
			End if 
			
			$blockInfo:={}
			$blockInfo.success:=True:C214
			$blockInfo.resType:=$tag
			$blockInfo.size:=$blockLength
			$blockInfo.resTypeLong:=$tagNum
			$blockInfo.position:=$blockPos
			$blockInfo.offset:=$offset
			
		End if 
	End if 
	
	If ($flNull)
		return {resType: ""; offset: 0; success: False:C215}
	End if 
	
	return $blockInfo
	
Function hex2Num($hex : Text; $fl_RemoveSignBit : Boolean) : Real
	
	var $l; $i; $sign : Integer
	var $result; $long : Real
	
	$result:=0
	$l:=Length:C16($hex)
	If ($l>0)
		$hex:=Uppercase:C13($hex)
		$digit:=0
		$sign:=1
		For ($i; 1; $l)
			$asc:=Character code:C91($hex[[$i]])
			$good:=True:C214
			If (($asc>47) & ($asc<58))
				$digit:=$asc-48
			Else 
				If (($asc>64) & ($asc<71))
					$digit:=$asc-55
				Else 
					$good:=False:C215
				End if 
			End if 
			If (($l=8) & ($i=1) & $fl_RemoveSignBit)  //uLong8 -> Have to test the sign bit
				If ($digit>7)
					$sign:=-1
					$digit:=$digit-8
				End if 
			End if 
			If ($good)
				$long:=($digit*(16^($l-$i)))
				$result:=$result+$long
			End if 
		End for 
		If ($sign=-1)  //4 009 318 272
			$result:=($result-MAXLONG:K35:2-1)
		End if 
	End if 
	
	return $result
	
Function hex2Real($hex : Text) : Real
	
	var $result; $real : Real
	var $l; $i; $long; $sign : Integer
	
	$result:=0
	$l:=Length:C16($hex)
	If ($l>0)
		$hex:=Uppercase:C13($hex)
		$digit:=0
		$sign:=1
		For ($i; 1; $l)
			$asc:=Character code:C91($hex[[$i]])
			$good:=True:C214
			If (($asc>47) & ($asc<58))
				$digit:=$asc-48
			Else 
				If (($asc>64) & ($asc<71))
					$digit:=$asc-55
				Else 
					$good:=False:C215
				End if 
			End if 
			If (($l=8) & ($i=1))  //uLong8  -> Have to test the sign bit
				If ($digit>7)
					$sign:=-1
					$digit:=$digit-8
				End if 
			End if 
			If ($good)
				$real:=($digit*(16^($l-$i)))
				$result:=$result+$real
			End if 
		End for 
		If ($sign=-1)
			$result:=($result-MAXLONG:K35:2-1)
		End if 
	End if 
	
	return $result
	
Function toReal($value : Text; $swap : Boolean) : Real
	
	var $longHi; $longLo; $result : Real
	var $long : Integer
	var $prefix : Text
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	If (Match regex:C1019("([&]|(?:0x))([:Hex_Digit:]+)"; $value; 1; $pos; $len))
		$prefix:=Substring:C12($value; $pos{1}; $len{1})
		$longHex:=Substring:C12($value; $pos{2}; $len{2})
	Else 
		$prefix:=""
		$longHex:=$value
	End if 
	
	$l:=Length:C16($longHex)
	If ($swap)
		$longHex:=This:C1470.byteSwap($longHex)
	End if 
	
	Case of 
		: ($l<=8)
			$result:=This:C1470.hex2Num($longHex; True:C214)
			
		: ($l<=12)  // We use for addresses FFFF FFFF FFFF = 2^48 = 281 474 976 710 655 = 281 Tb
			$result:=This:C1470.hex2Real($longHex)
			
		: ($l<=16)
			$sign:=1
			Case of 
				: ($longHex="FFFFFFFFFFFFFFFF")  //Special cases for speed
					$result:=-1
				: ($longHex="FFFFFFFFFFFFFFFE")
					$result:=-2
				: ($longHex="FFFFFFFFFFFFFFFD")
					$result:=-3
					
				: ($longHex="FFFFFFFFFFFF@")
					$long:=This:C1470.hex2Num(Substring:C12($longHex; 13); True:C214)
					$result:=-(0xFFFF-$long)
					
				: ($longHex="FFFFFFFF00000000")
					$result:=0
					
				: ($longHex="FFFFFFFF@")
					$result:=This:C1470.hex2Num(Substring:C12($longHex; 9); False:C215)
					
				: ($longHex="FF@")
					$sign:=-1
					$longHex:="00"+Substring:C12($longHex; 3)
				: ($longHex="00@")
					$sign:=1
					
				Else 
					$sign:=1
			End case 
			If ($result=0)
				$longHi:=This:C1470.hex2Num(Substring:C12($longHex; 1; 8); True:C214)
				$longLo:=This:C1470.hex2Num(Substring:C12($longHex; 9); False:C215)
				$result:=(($longHi*(2^32))+$longLo)*$sign
			End if 
	End case 
	
	return $result
	