//******************************************************************************************************
// Create mappView data provider string
//******************************************************************************************************
FUNCTION String2DataProvider
	brsstrcpy(TargetString, ADR('{"value":"'));
	brsstrcat(TargetString, SourceString);
	brsstrcat(TargetString, ADR('","text":"'));	
	brsstrcat(TargetString, SourceString);
	brsstrcat(TargetString, ADR('"}'));

	String2DataProvider := TRUE;
END_FUNCTION

//******************************************************************************************************
// Create error																						
//******************************************************************************************************
FUNCTION CreateError
	RECORDER.ERR.No := No;
	RECORDER.ERR.State := State;
	RECORDER.ERR.Text := Text;
	CreateError := DAT_ERROR;
END_FUNCTION

//******************************************************************************************************
// Create status meesage																						
//******************************************************************************************************
FUNCTION CreateMessage
	brwcscpy(ADR(tmpWStr1), Text);
	brwcscat(ADR(tmpWStr1), ADR(" "));
	brwcscat(ADR(tmpWStr1), RecordName);
	brwcscat(ADR(tmpWStr1), ADR(" on web client ID "));
	VisuSlotIDStr := DINT_TO_WSTRING(VisuSlotID);
	brwcscat(ADR(tmpWStr1), ADR(VisuSlotIDStr));
	brwcscpy(TargetString, ADR(tmpWStr1));

	CreateMessage := TRUE;
END_FUNCTION

//******************************************************************************************************
// Working status																						
//******************************************************************************************************
FUNCTION WorkingStatus
	animation := animation+1;
	
	IF (animation = 80) THEN
		animation := 0;
	END_IF
	
	brsmemset(ADR(RECORDER.DAT.Status), 0, SIZEOF(RECORDER.DAT.Status));
	brwcscpy(ADR(RECORDER.DAT.Status), str);
	CASE(animation) OF
		0..19	: brwcscat(ADR(RECORDER.DAT.Status), ADR("/"));
		20..39	: brwcscat(ADR(RECORDER.DAT.Status), ADR("-"));
		40..59	: brwcscat(ADR(RECORDER.DAT.Status), ADR("\"));
		60..79	: brwcscat(ADR(RECORDER.DAT.Status), ADR("|"));
	END_CASE;
	WorkingStatus := animation;
END_FUNCTION


//******************************************************************************************************
// Fill new folder or directory name																	
//******************************************************************************************************
FUNCTION InsertRecName
	// Set up start values for iteration																
	IF (RECORDER.DAT.RecordNum <> 0) THEN 
		idy := RECORDER.DAT.RecordNum - 1;
	END_IF
	idx := idy;

	// Start iteration	search																			
	WHILE (idy > 1) DO
		// Check current entry																			
		lSort := brsstrcmp(ADR(new_name), ADR(RECORDER.DAT.RecordNames[idy]));
		// Solve new search range																		
		IF (idy MOD 2 = 0) THEN
			idy := idy / 2;
		ELSE				
			idy := idy / 2 + 1;
		END_IF
		// New range is lower or higher than current													
		IF (lSort > 0) THEN
			idx := idx + idy;
			IF (idx > UINT_TO_INT(RECORDER.DAT.RecordNum)) THEN
				idx := RECORDER.DAT.RecordNum;  
			END_IF
		ELSE
			idx := idx - idy;
			IF (idx < 1) THEN
				idx := 1;
			END_IF
		END_IF		
	END_WHILE;
			
	// New entry is this, next or previous 																
	lSort := brsstrcmp(ADR(new_name), ADR(RECORDER.DAT.RecordNames[idx]));
	IF (lSort > 0 AND idx <> UINT_TO_INT(RECORDER.DAT.RecordNum)) THEN 
		idx := idx +1;
	ELSIF (idx > 0) THEN
		lSort := brsstrcmp(ADR(new_name), ADR(RECORDER.DAT.RecordNames[idx-1]));
		IF (lSort < 0) THEN 
			idx := idx - 1;
		END_IF
	END_IF
	
	// Move all data entrys backwards and fill in new entry
	IF(idx < DAT_MAX_NUM) THEN
		brsmemmove(ADR(RECORDER.DAT.RecordNames[idx+1]),ADR(RECORDER.DAT.RecordNames[idx]), (RECORDER.DAT.RecordNum - idx) * SIZEOF(RECORDER.DAT.RecordNames[1]));
	END_IF
	brsstrcpy(ADR(RECORDER.DAT.RecordNames[idx]), ADR(new_name));
	
	RECORDER.DAT.RecordNum := RECORDER.DAT.RecordNum + 1;
	InsertRecName := idx;
END_FUNCTION

//******************************************************************************************************
// Is second string in first string																		
//******************************************************************************************************
FUNCTION IsInstr	
	IF (brsstrlen(string1) >= brsstrlen(string2)) THEN
		FOR idx:=0 TO brsstrlen(string1) - brsstrlen(string2) DO
			IF (brsmemcmp(string1 + (2*idx), string2, brsstrlen(string2)) = 0) THEN
				IsInstr := TRUE;
				EXIT;
			END_IF
		END_FOR;
	END_IF
END_FUNCTION

//******************************************************************************************************
// Find and replace string																	
//******************************************************************************************************
FUNCTION ReplaceString
	IF (brsstrlen(dataSTR) > brsstrlen(searchSTR)) THEN
		FOR idx:=0 TO brsstrlen(dataSTR) - brsstrlen(searchSTR) DO
			IF (brsmemcmp(dataSTR + idx, searchSTR, brsstrlen(searchSTR)) = 0) THEN
				brsmemmove(dataSTR + idx + brsstrlen(replaceSTR), dataSTR + idx + brsstrlen(searchSTR), brsstrlen(dataSTR) - idx - brsstrlen(searchSTR));
				brsmemcpy(dataSTR + idx, replaceSTR, brsstrlen(replaceSTR));
				ReplaceString := TRUE;
				EXIT;
			END_IF
		END_FOR;
	END_IF
END_FUNCTION



