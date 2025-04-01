//%attributes = {"invisible":true,"preemptive":"incapable"}
#DECLARE($window : Integer; $name : Text; $JSON : Text)

CALL FORM:C1391($window; "chart"; JSON Parse:C1218($JSON))