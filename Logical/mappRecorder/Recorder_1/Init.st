// -------------------------------------------------------------------------------------------------------------------
//	Function:	Data recorder management with mappData																			
// -------------------------------------------------------------------------------------------------------------------
PROGRAM _INIT
	// ----------------------------------------------------------------------------------------
	// The following settings can be adjusted
	IF(DiagCpuIsSimulated()) THEN
		DeviceName 	:= 'SIM_DEVICE';	// Device name from the CPU configuration for simulation
	ELSE
		DeviceName 	:= DAT_DEVICE;		// Device name from the CPU configuration for X20CPU
	END_IF
	
	// ---------------------------------------------------------------------------------------- 
	// Dont change anything below this line
	// ---------------------------------------------------------------------------------------- 

	// ---------------------------------------------------------------------------------------- 
	// Make sure global variable structure and task name are correct
	taskStatus := ST_ident(ADR(DAT_THIS_TASK), taskGroup, ADR(taskID));
	pvStatus := PV_xgetadr(ADR(DAT_THIS_TASK), ADR(pvADR), ADR(pvLEN));
	// Connect global and local structure
	IF(pvStatus = 0) THEN
		RECORDER ACCESS pvADR;
		brsmemset(ADR(RECORDER.ERR), 0 , SIZEOF(RECORDER.ERR));
		RECORDER.PAR.Initialized := FALSE;
	END_IF
	
	// ---------------------------------------------------------------------------------------- 
	// Get mapp link information
	MpComGetLink_0.Enable := TRUE;
	MpComGetLink_0.ComponentName := ADR(DAT_MPLINK);
	MpComGetLink_0();
	// Create error
	IF(MpComGetLink_0.Error) THEN
		rec_state := CreateError(ADR(RECORDER), ERR_DAT_MPLINK, "mplink name is incorrect", rec_state);
	END_IF
	
	// ----------------------------------------------------------------------------------------
	// Allocate memory for file upload and download
	AsMemPartCreate_0.enable	:= TRUE;
	AsMemPartCreate_0.len		:= DAT_DOWNLOAD_SIZE;
	AsMemPartCreate_0();
	IF AsMemPartCreate_0.status <> 0 THEN
		CreateError(ADR(RECORDER), ERR_MEM_ALLOC, "file upload and download alloc failed", rec_state);
	ELSE
		AsMemPartAllocClear_0.enable	:= TRUE;
		AsMemPartAllocClear_0.ident		:= AsMemPartCreate_0.ident;
		AsMemPartAllocClear_0.len		:= DAT_DOWNLOAD_SIZE;
		AsMemPartAllocClear_0();
		IF AsMemPartCreate_0.status <> 0 THEN
			CreateError(ADR(RECORDER), ERR_MEM_ALLOC, "file upload and download clear failed", rec_state);
		END_IF
	END_IF
END_PROGRAM