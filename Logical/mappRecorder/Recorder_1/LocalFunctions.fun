
FUNCTION ReplaceString : BOOL
	VAR_INPUT
		dataSTR : UDINT;
		searchSTR : UDINT;
		replaceSTR : UDINT;
		first : BOOL;
	END_VAR
	VAR
		idx : UDINT;
	END_VAR
END_FUNCTION

FUNCTION CreateError : datSTATE
	VAR_INPUT
		RECORDER : REFERENCE TO datMAIN;
		No : DINT;
		Text : WSTRING[200];
		State : datSTATE;
	END_VAR
END_FUNCTION

FUNCTION CreateMessage : BOOL
	VAR_INPUT
		TargetString : UDINT;
		Text : UDINT;
		RecordName : UDINT;
		VisuSlotID : USINT;
	END_VAR
	VAR
		VisuSlotIDStr : WSTRING[5];
		tmpWStr1 : WSTRING[200];
	END_VAR
END_FUNCTION

FUNCTION InsertRecName : UINT
	VAR_INPUT
		RECORDER : REFERENCE TO datMAIN;
		new_name : STRING[DAT_NAME_LENGTH];
	END_VAR
	VAR
		idx : INT;
		idy : INT;
		lSort : DINT;
	END_VAR
END_FUNCTION

FUNCTION IsInstr : UDINT
	VAR_INPUT
		string1 : UDINT;
		string2 : UDINT;
	END_VAR
	VAR
		idx : UDINT;
	END_VAR
END_FUNCTION

FUNCTION WorkingStatus : USINT
	VAR_INPUT
		RECORDER : REFERENCE TO datMAIN;
		str : UDINT;
		animation : USINT;
	END_VAR
END_FUNCTION

FUNCTION String2DataProvider : BOOL
	VAR_INPUT
		SourceString : UDINT;
		TargetString : UDINT;
	END_VAR
END_FUNCTION
