// --------------------------------------------------------------------------------------------------------------------
// Use this task to add your own code for recorder managment
// --------------------------------------------------------------------------------------------------------------------
PROGRAM _INIT
	// Sample record data, the global array DAT_VAR_LIST define what variables belong to a record
	Temperature1 := 123;
	Temperature2 := 130;
	MotorSpeed := 1000;
	Position := 0;
	Recorder_1;
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

