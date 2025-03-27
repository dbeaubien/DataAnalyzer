property tableUUID : Text
property sizeOf_rec1 : Real
property countOf_rec1 : Real
property sizeOf_blob : Real
property countOf_blob : Real
property sizeOf_blbT : Real
property countOf_blbT : Real
property sizeOf_blbP : Real
property countOf_blbP : Real
property maxOf_rec1 : Real
property minOf_rec1 : Real
property avgOf_rec1 : Real
property maxOf_blob : Real
property minOf_blob : Real
property avgOf_blob : Real
property complete : Boolean

Class constructor($tableUUID : Text)
	
	This:C1470.tableUUID:=$tableUUID
	This:C1470.sizeOf_rec1:=0
	This:C1470.countOf_rec1:=0
	This:C1470.sizeOf_blob:=0
	This:C1470.countOf_blob:=0
	This:C1470.sizeOf_blbT:=0
	This:C1470.countOf_blbT:=0
	This:C1470.sizeOf_blbP:=0
	This:C1470.countOf_blbP:=0
	This:C1470.complete:=False:C215