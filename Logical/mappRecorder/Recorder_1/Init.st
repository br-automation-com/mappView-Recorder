//******************************************************************************************************
//	Function:	Data recorder management with mappData																			
//  Version:	0.3																				
//	Changed:	31.03.2019															
//******************************************************************************************************

PROGRAM _INIT
	// ----------------------------------------------------------------------------------------
	// The following settings can be adjusted
	Recorder_1.PAR.RecordVariable := 'RecorderData';		// Top variable structure with recorder data
	IF(DiagCpuIsSimulated()) THEN
		Recorder_1.PAR.DeviceName 	:= 'SIM_DEVICE';		// Device name from the CPU configuration for simulation
	ELSE
		Recorder_1.PAR.DeviceName 	:= 'RECORDER_DEVICE';	// Device name from the CPU configuration for X20CPU
	END_IF
	// ----------------------------------------------------------------------------------------
	this								:= 'Recorder_1';		// Name of the global variable structure and this task name
	Recorder_1.PAR.MpLink 				:= gDataRecorder_1; 	// MpLink from mappData configuration in physical view
	
	// ---------------------------------------------------------------------------------------- 
	// Dont change anything below this line
	// ---------------------------------------------------------------------------------------- 

	// ---------------------------------------------------------------------------------------- 
	// Make sure global variable structure and task name are correct
	taskStatus := ST_ident(ADR(this), taskGroup, ADR(taskID));
	pvStatus := PV_xgetadr(ADR(this), ADR(pvADR), ADR(pvLEN));
	// Connect global and local structure
	IF(pvStatus = 0) THEN
		RECORDER ACCESS pvADR;
		brsmemset(ADR(RECORDER.ERR), 0 , SIZEOF(RECORDER.ERR));
		RECORDER.PAR.Initialized := FALSE;
	END_IF
	RecorderData;
	
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