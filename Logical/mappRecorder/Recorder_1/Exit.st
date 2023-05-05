PROGRAM _EXIT
	// --------------------------------------------------------------------------------------------------------------------
	// Cyclic function calls
	FOR idx:=1 TO DAT_VAR_NUM DO
		MpRecorderRegPar_0[idx](Enable := FALSE);
		IF(DAT_VAR_LIST[idx] = '') THEN
			EXIT;
		END_IF
	END_FOR;
	MpDataRecorder_0(Enable := FALSE);
	
END_PROGRAM