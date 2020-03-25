// --------------------------------------------------------------------------------------------------------------------********
//	Cylic task for data recorder management
//	Version 0.1																	
// --------------------------------------------------------------------------------------------------------------------********

// --------------------------------------------------------------------------------------------------------------------********
// Cyclic task																	
// --------------------------------------------------------------------------------------------------------------------********
PROGRAM _CYCLIC
	// --------------------------------------------------------------------------------------------------------------------
	// Make sure task name and global structure correct
	IF(pvStatus <> 0) THEN
		RETURN;
	END_IF
	IF(taskStatus <> 0) THEN
		rec_state := CreateError(ADR(RECORDER), ERR_DAT_TASK_NAME, "Task name is incorrect", rec_state);
		RETURN;
	END_IF
	
	// --------------------------------------------------------------------------------------------------------------------
	// Make sure we dont exceed maximum number of web clients
	IF(RECORDER.PAR.VisuSlotID > DAT_MAX_CLIENTS_ID) THEN
		rec_state := CreateError(ADR(RECORDER), ERR_DAT_TOO_MANY_CLIENTS, "More than 3 clients try to connect to data recorder", rec_state);
		RETURN;
	END_IF
	
	// --------------------------------------------------------------------------------------------------------------------
	// Cyclic function calls
	MpDataRecorder_0();
	RECORDER.PAR.IsRecording := MpDataRecorder_0.Recording;
	RECORDER.PAR.SamplesNum := MpDataRecorder_0.Info.TotalSamples;
	MpDataRecorder_0.RecordMode := RECORDER.PAR.RecordMode;
	MpDataRecorder_0.SamplingTime := RECORDER.PAR.RecordInterval;
	
	// --------------------------------------------------------------------------------------------------------------------****
	// Recorder managment state machine																						
	// --------------------------------------------------------------------------------------------------------------------****	
	CASE rec_state OF
		// --------------------------------------------------------------------------------------------------------------------
		// Wait for command																				
		// --------------------------------------------------------------------------------------------------------------------
		DAT_WAIT:
			// --------------------------------------------------------------------------------------------------------------------
			// Track filter change and data refresh																				
			IF ((brwcscmp(ADR(RecordFilterOld[VisuSlotID]), ADR(RECORDER.VIS[VisuSlotID].RecordFilter)) <> 0) OR (RecordNumOld[VisuSlotID] <> RECORDER.DAT.RecordNum)) THEN
				brsmemset(ADR(RECORDER.VIS[VisuSlotID].RecordNames), 0, SIZEOF(RECORDER.VIS[VisuSlotID].RecordNames));
				idy := 0;
				IF(RECORDER.DAT.RecordNum > 0) THEN
					FOR idx:=0 TO RECORDER.DAT.RecordNum - 1 DO
						// -------------------------------------------------------------------------------- 		
						// Verify that file name contains filter											
						IF (brsstrlen(ADR(RECORDER.VIS[VisuSlotID].RecordFilter)) = 0 OR IsInstr(ADR(RECORDER.DAT.RecordNames[idx]), ADR(RECORDER.VIS[VisuSlotID].RecordFilter))) THEN	
							String2DataProvider(ADR(RECORDER.DAT.RecordNames[idx]), ADR(tmpStr1));
							RECORDER.VIS[VisuSlotID].RecordNames[idy] := tmpStr1;
							idy := idy + 1;
						END_IF
					END_FOR;
					brsstrcpy(ADR(RecordFilterOld[VisuSlotID]), ADR(RECORDER.VIS[VisuSlotID].RecordFilter));
				END_IF
				RecordNumOld[VisuSlotID] := RECORDER.DAT.RecordNum;
				RECORDER.VIS[VisuSlotID].RecordNum := idy;
				// Enable/Disable delete button
				IF(RECORDER.VIS[VisuSlotID].RecordNum > 0) THEN
					RECORDER.VIS[VisuSlotID].EnableButtons := TRUE;
				ELSE
					RECORDER.VIS[VisuSlotID].EnableButtons := FALSE;					
				END_IF
			END_IF
			
			// ------------------------------------------------------------------------------------------------
			// Handle double click for file open
			IF(RECORDER.VIS[VisuSlotID].RecordDoubleClick > 0) THEN
				DoubleClickRecordName[VisuSlotID].PT := 50;
				DoubleClickRecordName[VisuSlotID].IN := 1;
				DoubleClickRecordName[VisuSlotID]();
				// Open selected file
				IF(RECORDER.VIS[VisuSlotID].RecordDoubleClick > 1) THEN
					DoubleClickRecordName[VisuSlotID].IN := 0;
					DoubleClickRecordName[VisuSlotID]();
					RECORDER.VIS[VisuSlotID].RecordDoubleClick := 0;
					RECORDER.PAR.VisuSlotID := VisuSlotID;
					RECORDER.CMD.View := TRUE;
				END_IF
			END_IF
			IF(DoubleClickRecordName[VisuSlotID].Q) THEN
				DoubleClickRecordName[VisuSlotID].IN := 0;
				DoubleClickRecordName[VisuSlotID]();
				IF(RECORDER.VIS[VisuSlotID].RecordDoubleClick > 0) THEN
					RECORDER.VIS[VisuSlotID].RecordDoubleClick := RECORDER.VIS[VisuSlotID].RecordDoubleClick - 1;
				END_IF
			END_IF
			
			// Cylce through the client web seesions
			VisuSlotID := VisuSlotID + 1;
			IF(VisuSlotID > DAT_MAX_CLIENTS_ID) THEN
				VisuSlotID := 0;
			END_IF
							
			// ---------------------------------------------------------------------------------------- 
			// Reset error reset
			MpDataRecorder_0.ErrorReset := FALSE;
			MpRecorderRegPar_0.ErrorReset := FALSE;

			// ---------------------------------------------------------------------------------------- 
			// Command refresh																			
			IF (RECORDER.CMD.Init = TRUE) THEN
				// Reset data structure and trigger name refresh for vis
				brsmemset(ADR(RECORDER.DAT), 0, SIZEOF(RECORDER.DAT));
				brsmemset(ADR(RecordNumOld), 16#FF, SIZEOF(RecordNumOld));
				IF(RECORDER.PAR.Initialized) THEN
					rec_state := DAT_READ_DIR;
				ELSE
					rec_state := DAT_REG_VAR;
				END_IF
			// ---------------------------------------------------------------------------------------- 
			// Command continues recording
			ELSIF (RECORDER.CMD.Record = TRUE) THEN																		
				tmpWStr1 := "continues recording...";
				rec_state := DAT_RECORD;
			// ---------------------------------------------------------------------------------------- 
			// Command trigger recording
			ELSIF (RECORDER.CMD.Trigger = TRUE) THEN																		
				tmpWStr1 := "recording by trigger...";
				rec_state := DAT_RECORD;
			// ---------------------------------------------------------------------------------------- 
			// Command delete recording
			ELSIF (RECORDER.CMD.Delete = TRUE AND RECORDER.PAR.RecordName <> '') THEN																	
				animation := WorkingStatus(ADR(RECORDER), ADR("deleting recording..."), animation);
				RecordName := RECORDER.PAR.RecordName;
				rec_state := DAT_DELETE;
			// ---------------------------------------------------------------------------------------- 
			// Command view file
			ELSIF (RECORDER.CMD.View = TRUE AND RECORDER.VIS[RECORDER.PAR.VisuSlotID].RecordSelected <> '') THEN																	
				RECORDER.VIS[RECORDER.PAR.VisuSlotID].ViewFilePath := '';
				//RecordName := RECORDER.PAR.RecordName;
				rec_state := DAT_VIEW;
			// ----------------------------------------------------------------------------------------
			// Download selected file
			ELSIF (RECORDER.CMD.Download = 1 AND RECORDER.PAR.RecordName <> '') THEN
				RECORDER.VIS[RECORDER.PAR.VisuSlotID].DownloadFileUrl := '';
				RecordName := RECORDER.PAR.RecordName;
				rec_state := DAT_DOWNLOAD;
			END_IF

			// ---------------------------------------------------------------------------------------- 
			// Check parameters																					
			IF (RECORDER.CMD.Init OR RECORDER.CMD.Delete OR RECORDER.CMD.View OR RECORDER.CMD.Download) THEN
				// Make sure recorder was intialized
				IF (NOT RECORDER.CMD.Init AND (RECORDER.CMD.Delete OR RECORDER.CMD.View) AND NOT RECORDER.PAR.Initialized) THEN
					rec_state := CreateError(ADR(RECORDER), ERR_DAT_NOT_INITIALIZED, "recorder is not initialized", rec_state);
				END_IF
				// Make sure device name is valid
				IF(RECORDER.PAR.DeviceName = '') THEN
					rec_state := CreateError(ADR(RECORDER), ERR_DAT_DEV_NAME_EMPTY, "device name is empty", rec_state);
				END_IF
				// Make sure record name is valid
				IF(RECORDER.PAR.RecordName = '' AND (RECORDER.CMD.Delete OR RECORDER.CMD.Download)) THEN
					rec_state := CreateError(ADR(RECORDER), ERR_DAT_NAME_EMPTY, "record name is empty", rec_state);
				END_IF
				// Make sure variable name is valid
				IF(RECORDER.PAR.RecordVariable = '') THEN
					rec_state := CreateError(ADR(RECORDER), ERR_DAT_VAR_NAME_EMPTY, "variable name is empty", rec_state);
				END_IF

			END_IF	
			// --------------------------------------------------------------------------------------------------------------------
			// Register variable structure																
			// --------------------------------------------------------------------------------------------------------------------
		DAT_REG_VAR:
			MpRecorderRegPar_0.Enable := 1;
			MpRecorderRegPar_0.MpLink := ADR(RECORDER.PAR.MpLink);
			MpRecorderRegPar_0.PVName := ADR(RECORDER.PAR.RecordVariable);	
										
			// ---------------------------------------------------------------------------------------- 		
			// OK																																				
			IF (NOT MpRecorderRegPar_0.Active AND NOT MpRecorderRegPar_0.Error) THEN
				rec_state := DAT_READ_DIR;
			// Error
			ELSIF (MpRecorderRegPar_0.Error) THEN
				tmpWStr1 := "error trying to register variable name ";
				brwcsconv(ADR(tmpWStr2), ADR(RECORDER.PAR.RecordVariable), brwU8toUC);
				brwcscat(ADR(tmpWStr1), ADR(tmpWStr2));
				rec_state := CreateError(ADR(RECORDER), MpRecorderRegPar_0.StatusID, tmpWStr1, rec_state);
			END_IF	
			// --------------------------------------------------------------------------------------------------------------------
			// Read directory information																	
			// --------------------------------------------------------------------------------------------------------------------
		DAT_READ_DIR:
			// Show current state																		
			animation := WorkingStatus(ADR(RECORDER), ADR("reading records..."), animation);
			// ---------------------------------------------------------------------------------------- 
			// Clear all entrys																			
			brsmemset(ADR(RECORDER.DAT), 0, SIZEOF(RECORDER.DAT));
			RECORDER.DAT.RecordNum := 0;
			// ---------------------------------------------------------------------------------------- 		
			// Set values and get device dir															
			DInfo.enable 	:= 1;
			DInfo.pDevice	:= ADR(RECORDER.PAR.DeviceName);
			DInfo();
						
			// ---------------------------------------------------------------------------------------- 		
			// OK																																				
			IF (DInfo.status = OK) THEN
				rec_state := DAT_READ_DIR_1;
			ELSIF (DInfo.status = fiERR_DEVICE_MANAGER) THEN
				tmpWStr1 := "file device ";
				brwcsconv(ADR(tmpWStr2), ADR(RECORDER.PAR.DeviceName), brwU8toUC);
				brwcscat(ADR(tmpWStr1), ADR(tmpWStr2));
				brwcscat(ADR(tmpWStr1), ADR(" is unavailable"));
				rec_state := CreateError(ADR(RECORDER), DInfo.status, tmpWStr1, rec_state);
			// Error																	
			ELSIF (DInfo.status <> ERR_FUB_BUSY) THEN
				rec_state := CreateError(ADR(RECORDER), DInfo.status, "error dir info", rec_state);
			END_IF
			// --------------------------------------------------------------------------------------------------------------------
			// Open directory 																				
			// --------------------------------------------------------------------------------------------------------------------
		DAT_READ_DIR_1:														
			DOpen.enable 	:= 1;
			DOpen.pDevice	:= ADR(RECORDER.PAR.DeviceName);
			DOpen();
						
			// ---------------------------------------------------------------------------------------- 		
			// OK																																				
			IF (DOpen.status = OK) THEN
				has_oversized_items := FALSE;
				rec_state := DAT_READ_DIR_2;
			// Error
			ELSIF (DOpen.status <> ERR_FUB_BUSY) THEN
				rec_state := CreateError(ADR(RECORDER), DOpen.status, "error dir open", rec_state);
			END_IF;
			// --------------------------------------------------------------------------------------------------------------------
			// Read file directory information																
			// --------------------------------------------------------------------------------------------------------------------
		DAT_READ_DIR_2:													
			DRead.enable 	:= 1;
			DRead.ident		:= DOpen.ident;
			DRead.pData 	:= ADR(lDirReadData);
			DRead.data_len 	:= SIZEOF(lDirReadData);
			DRead();
										
			// ---------------------------------------------------------------------------------------- 		
			// OK																																				
			IF (DRead.status = OK AND lDirReadData.Mode = fiFILE) THEN
				animation := WorkingStatus(ADR(RECORDER), ADR("reading record data..."), animation);
				// Make sure file name does not exceed maximum string size
				IF (brsstrlen(ADR(lDirReadData.Filename)) < DAT_NAME_LENGTH) THEN
					// Copy dir info to string
					brsmemset(ADR(RECORDER.PAR.RecordName), 0, SIZEOF(RECORDER.PAR.RecordName));
					brsstrcpy(ADR(RECORDER.PAR.RecordName), ADR(lDirReadData.Filename));
					// Make sure file extension is CSV or XML
					IF(brsstrlen(ADR(RECORDER.PAR.RecordName)) > 4 AND ((brsmemcmp(ADR(RECORDER.PAR.RecordName) + (brsstrlen(ADR(RECORDER.PAR.RecordName)) - 4), ADR('.csv'), 4) = 0))) THEN
						// ------------------------------------------------------------------------------------ 		
						// Verify that we still have space in list												
						IF (RECORDER.DAT.RecordNum <= DAT_MAX_NUM) THEN
							// Generate ASCII data, insert record into list
							InsertRecName(ADR(RECORDER), RECORDER.PAR.RecordName);
						// Error
						ELSE
							rec_state := CreateError(ADR(RECORDER), ERR_DAT_MAX_NUM, "maximum number of records reached", rec_state);
						END_IF		
					END_IF
				ELSE
					has_oversized_items := TRUE;
				END_IF
				// Last entry reached
			ELSIF (DRead.status = fiERR_NO_MORE_ENTRIES) THEN 
				rec_state := DAT_READ_DIR_3;
				// Error		
			ELSIF (DRead.status <> ERR_FUB_BUSY AND DRead.status <> OK) THEN
				rec_state := CreateError(ADR(RECORDER), DRead.status, "error record list read", rec_state);
			END_IF
			// --------------------------------------------------------------------------------------------------------------------
			// Close directory information																	
			// --------------------------------------------------------------------------------------------------------------------
		DAT_READ_DIR_3:														
			DClose.enable 	:= 1;
			DClose.ident	:= DOpen.ident;
			DClose();
										
			// ---------------------------------------------------------------------------------------- 		
			// OK																																				
			IF (DClose.status = OK) THEN
				// Reset command and return to wait state												
				RECORDER.DAT.Status := "initializing complete";
				RECORDER.CMD.Init	:= 0;
				RECORDER.CMD.Delete := 0;
				RECORDER.PAR.RecordName := '';
				RECORDER.PAR.Initialized := TRUE;
				DClose.ident	:= 0;
				IF(has_oversized_items) THEN
					rec_state := CreateError(ADR(RECORDER), ERR_DAT_NAME_LENGTH, "one or more record names exceeds maximum length", rec_state);
				ELSE
					rec_state := DAT_WAIT;
				END_IF
				// Error 		
			ELSIF (DClose.status <> ERR_FUB_BUSY) THEN
				rec_state := CreateError(ADR(RECORDER), DClose.status, "error dir close", rec_state);
			END_IF

		// --------------------------------------------------------------------------------------------------------------------
		// Record data																	
		// --------------------------------------------------------------------------------------------------------------------
		DAT_RECORD:
			animation := WorkingStatus(ADR(RECORDER), ADR(tmpWStr1), animation);

			MpDataRecorder_0.Enable := TRUE;
			MpDataRecorder_0.MpLink := ADR(RECORDER.PAR.MpLink);
			MpDataRecorder_0.DeviceName := ADR(RECORDER.PAR.DeviceName);
			MpDataRecorder_0.Record := RECORDER.CMD.Record OR RECORDER.CMD.Trigger;
										
			// ---------------------------------------------------------------------------------------- 		
			// OK																																				
			IF (MpDataRecorder_0.Recording AND NOT MpDataRecorder_0.Error AND MpDataRecorder_0.StatusID = 0) THEN			
				// Command record by trigger 
				IF(RECORDER.CMD.Trigger) THEN
					// Fire trigger when recording is engaged
					IF(NOT MpDataRecorder_0.Trigger) THEN
						MpDataRecorder_0.Trigger := TRUE;
					// Reset trigger when event was recorded
					ELSE
						MpDataRecorder_0.Trigger := FALSE;
						RECORDER.CMD.Trigger := FALSE;
						IF(NOT RECORDER.CMD.Record) THEN
							MpDataRecorder_0.Record := FALSE;
							RECORDER.DAT.Status := "created new record by trigger";
							rec_state := DAT_READ_DIR;					
						END_IF
					END_IF
				// Recording disabled
				ELSIF(NOT RECORDER.CMD.Record) THEN
					rec_state := DAT_READ_DIR;					
				END_IF
			// Error
			ELSIF (MpDataRecorder_0.Error OR MpDataRecorder_0.StatusID <> 0) THEN
				rec_state := CreateError(ADR(RECORDER), MpDataRecorder_0.StatusID, "error trying to create record", rec_state);
			END_IF
		// --------------------------------------------------------------------------------------------------------------------
		// Delete selected record																			
		// --------------------------------------------------------------------------------------------------------------------
		DAT_DELETE:		
			// ---------------------------------------------------------------------------------------- 		
			// Initialize file delete structure 														
			FDelete.enable		:= 1;
			FDelete.pDevice 	:= ADR(RECORDER.PAR.DeviceName);
			FDelete.pName		:= ADR(RecordName);
			FDelete();
										
			// ---------------------------------------------------------------------------------------- 		
			// OK																																				
			IF (FDelete.status = OK) THEN		
				CreateMessage(ADR(RECORDER.DAT.Status), ADR("deleted record"), ADR(RECORDER.PAR.RecordName), RECORDER.PAR.VisuSlotID);
				rec_state := DAT_READ_DIR;
			// Error 		
			ELSIF (FDelete.status <> ERR_FUB_BUSY) THEN
				tmpWStr1 := "error deleting record ";
				brwcsconv(ADR(tmpWStr2), ADR(RecordName), brwU8toUC);
				brwcscat(ADR(tmpWStr1), ADR(tmpWStr2));
				rec_state := CreateError(ADR(RECORDER), FDelete.status, tmpWStr1, rec_state);
			END_IF
		// --------------------------------------------------------------------------------------------------------------------
		// View selected file																			
		// --------------------------------------------------------------------------------------------------------------------
		DAT_VIEW:
			IF(RECORDER.DAT.RecordNum > 0) THEN
				FOR idx:=0 TO SIZEOF(DAT_VIEW_FILTER)/SIZEOF(DAT_VIEW_FILTER[0]) - 1 DO
					IF(brsstrlen(ADR(RECORDER.VIS[RECORDER.PAR.VisuSlotID].RecordSelected)) >= brsstrlen(ADR(DAT_VIEW_FILTER[idx])) AND DAT_VIEW_FILTER[idx] <> '') THEN
						// -------------------------------------------------------------------------------- 		
						// Verify that file name contains filter											
						IF(brsmemcmp(ADR(RECORDER.VIS[RECORDER.PAR.VisuSlotID].RecordSelected) + brsstrlen(ADR(RECORDER.VIS[RECORDER.PAR.VisuSlotID].RecordSelected)) - brsstrlen(ADR(DAT_VIEW_FILTER[idx])) , ADR(DAT_VIEW_FILTER[idx]), brsstrlen(ADR(DAT_VIEW_FILTER[idx]))) = 0) THEN
							RECORDER.VIS[RECORDER.PAR.VisuSlotID].ViewFilePath := '/FileDevice:';
							brsstrcat(ADR(RECORDER.VIS[RECORDER.PAR.VisuSlotID].ViewFilePath), ADR(RECORDER.PAR.DeviceName));
							brsstrcat(ADR(RECORDER.VIS[RECORDER.PAR.VisuSlotID].ViewFilePath), ADR("/"));
							brsstrcat(ADR(RECORDER.VIS[RECORDER.PAR.VisuSlotID].ViewFilePath), ADR(RECORDER.VIS[RECORDER.PAR.VisuSlotID].RecordSelected));
							RECORDER.CMD.View := FALSE;
							RECORDER.VIS[RECORDER.PAR.VisuSlotID].ViewFile := TRUE;
							rec_state := DAT_WAIT;
							RETURN;
						END_IF
					END_IF
				END_FOR;
				RECORDER.DAT.Status := "error this file extension is not supported for viewing";
				RECORDER.CMD.View := FALSE;
				rec_state := DAT_WAIT;
			END_IF
		//**********************************************************************************************
		// Download file
		//**********************************************************************************************
		DAT_DOWNLOAD:						
			// ----------------------------------------------------------------------------------------
			// Initialize file open structure
			FOpen.enable	:= TRUE;
			FOpen.pDevice 	:= ADR(RECORDER.PAR.DeviceName);
			FOpen.pFile		:= ADR(RecordName);
			FOpen();
			
			// ----------------------------------------------------------------------------------------
			// OK
			IF (FOpen.status = OK) THEN
				// Make sure file fits into memory
				IF(FOpen.filelen <= DAT_DOWNLOAD_SIZE) THEN
					// Clear memory and reset web service
					brsmemset(AsMemPartAllocClear_0.mem, 0, DAT_DOWNLOAD_SIZE);
					WebserviceDownload.enable := FALSE;
					WebserviceDownload();
					rec_state := DAT_DOWNLOAD_1;
					// File is too large
				ELSE			
					tmpWStr1 := "download file exceeds maximum buffer size of ";
					brsitoa(DAT_DOWNLOAD_SIZE, ADR(tmpWStr2));
					brsstrcat(ADR(tmpWStr1), ADR(tmpWStr1));
					brsstrcat(ADR(tmpWStr1), ADR(" bytes"));				
					CreateError(ADR(RECORDER), ERR_MEM_DOWNLOAD, tmpWStr1, rec_state);
				END_IF;
				// Error
			ELSIF (FOpen.status <> ERR_FUB_BUSY) THEN
				CreateError(ADR(RECORDER), FOpen.status, "error opening file for download", rec_state);
			END_IF
		//**********************************************************************************************
		// Download file
		//**********************************************************************************************
		DAT_DOWNLOAD_1:			
			// ----------------------------------------------------------------------------------------
			// Initialize file read structure
			FRead.enable	:= TRUE;
			FRead.ident		:= FOpen.ident;
			FRead.len		:= FOpen.filelen;
			FRead.pDest		:= AsMemPartAllocClear_0.mem;
			FRead();
			
			// ----------------------------------------------------------------------------------------
			// OK
			IF (FRead.status = OK) THEN
				rec_state := DAT_DOWNLOAD_2;
				// Error
			ELSIF (FRead.status <> ERR_FUB_BUSY) THEN
				CreateError(ADR(RECORDER), FRead.status, "error reading file for download", rec_state);
			END_IF
		//**********************************************************************************************
		// Download file
		//**********************************************************************************************
		DAT_DOWNLOAD_2:			
			// ----------------------------------------------------------------------------------------
			// Initialize file close structure
			FClose.enable	:= TRUE;
			FClose.ident	:= FOpen.ident;
			FClose();
			
			// ----------------------------------------------------------------------------------------
			// OK
			IF (FClose.status = OK) THEN
				DownloadTimeout.IN := 0;
				DownloadTimeout();
				rec_state := DAT_DOWNLOAD_3;
				// Error
			ELSIF (FClose.status <> ERR_FUB_BUSY) THEN
				CreateError(ADR(RECORDER), FClose.status, "error closing file for download", rec_state);
			END_IF		
		//**********************************************************************************************
		// Download file - web service
		//**********************************************************************************************
		DAT_DOWNLOAD_3:
			// ----------------------------------------------------------------------------------------
			// Create response header
			ResponseHeaderData :=  'Content-Type: application/octet-stream; Content-Transfer-Encoding: binary; Content-Disposition: attachment; filename="';
			brsstrcpy(ADR(tmpStr1), ADR(RecordName));
			ReplaceString(ADR(tmpStr1), ADR(' '), ADR('%20'));
			brsstrcat(ADR(ResponseHeaderData), ADR(tmpStr1));
			brsstrcat(ADR(ResponseHeaderData), ADR('"'));
			
			// ----------------------------------------------------------------------------------------
			// Pre-configure web service for download
			ResponseHeader.rawHeader.pData 	:= ADR(ResponseHeaderData);
			ResponseHeader.rawHeader.dataSize 	:= SIZEOF(ResponseHeaderData);		
			ResponseHeader.rawHeader.dataLen 	:= brsstrlen(ADR(ResponseHeaderData));
			
			// ----------------------------------------------------------------------------------------
			// Start web service
			WebserviceDownload.enable 			:= TRUE;
			WebserviceDownload.option 			:= httpOPTION_HTTP_10 + httpOPTION_SERVICE_TYPE_NAME;
			WebserviceDownload.pResponseData 	:= AsMemPartAllocClear_0.mem;
			WebserviceDownload.pResponseHeader	:= ADR(ResponseHeader);
			WebserviceDownload.pServiceName 	:= ADR(tmpStr1);
			WebserviceDownload.responseDataLen 	:= FOpen.filelen;
			WebserviceDownload();
			
			// ----------------------------------------------------------------------------------------
			// Timeout if file is not pulled from browser
			DownloadTimeout.IN := 1;
			DownloadTimeout.PT := 300;
			DownloadTimeout();
			IF(DownloadTimeout.Q) THEN
				CreateError(ADR(RECORDER), ERR_TIMEOUT_DOWNLOAD, "error download response timed out", rec_state);
			END_IF

			// ----------------------------------------------------------------------------------------
			// Set URL
			IF (WebserviceDownload.status = ERR_FUB_BUSY AND RECORDER.VIS[RECORDER.PAR.VisuSlotID].DownloadFileUrl = '') THEN
				brsstrcat(ADR(RECORDER.VIS[RECORDER.PAR.VisuSlotID].DownloadFileUrl), ADR(RecordName));
				// Start sending data
			ELSIF (WebserviceDownload.status = OK AND WebserviceDownload.send = FALSE AND RECORDER.VIS[RECORDER.PAR.VisuSlotID].DownloadFileUrl <> '') THEN
				WebserviceDownload.send := TRUE;
				// Sending data finished
			ELSIF (WebserviceDownload.send = TRUE) THEN
				WebserviceDownload.send := FALSE;
				rec_state := DAT_DOWNLOAD_4;
				// Error
			ELSIF (WebserviceDownload.status <> ERR_FUB_BUSY AND WebserviceDownload.status <> OK) THEN
				CreateError(ADR(RECORDER), WebserviceDownload.status, "error sending web response", rec_state);
			END_IF
		//**********************************************************************************************
		// Download file - web service
		//**********************************************************************************************
		DAT_DOWNLOAD_4:			
			WebserviceDownload();
			
			// ----------------------------------------------------------------------------------------
			// Finish sending data
			IF (WebserviceDownload.phase = httpPHASE_WAITING) THEN 
				RECORDER.VIS[RECORDER.PAR.VisuSlotID].DownloadFileUrl := '';
				WebserviceDownload.send := FALSE;
				RECORDER.CMD.Download	:= 0;
				rec_state := DAT_WAIT;
			// Error
			ELSIF (WebserviceDownload.status <> ERR_FUB_BUSY) THEN
				CreateError(ADR(RECORDER), WebserviceDownload.status, "error sending web response", rec_state);
			END_IF
		// --------------------------------------------------------------------------------------------------------------------
		// Error 
		// --------------------------------------------------------------------------------------------------------------------					
		DAT_ERROR:
			RECORDER.DAT.Status := "error state triggered on web client ID ";
			tmpWStr1 := DINT_TO_WSTRING(RECORDER.PAR.VisuSlotID);
			brwcscat(ADR(RECORDER.DAT.Status), ADR(tmpWStr1));
			// --------------------------------------------------------------------------------------------------------------------											
			// Make sure we dont exceed maximum number of web clients
			IF(RECORDER.PAR.VisuSlotID <= DAT_MAX_CLIENTS_ID) THEN
				RECORDER.VIS[RECORDER.PAR.VisuSlotID].ShowMessageBoxError := TRUE;
			END_IF
			// --------------------------------------------------------------------------------------------------------------------	
			// Return to idle state
			IF RECORDER.CMD.ErrorReset THEN
				// Reset function blocks
				MpDataRecorder_0.ErrorReset := TRUE;
				MpDataRecorder_0.Record := FALSE;
				MpDataRecorder_0.Trigger := FALSE;
							
				MpRecorderRegPar_0.ErrorReset := TRUE;
				
				// Reset error structure
				brsmemset(ADR(RECORDER.ERR), 0, SIZEOF(RECORDER.ERR));
				RECORDER.DAT.Status := "";
				RECORDER.CMD.ErrorReset := FALSE;
				RECORDER.VIS[RECORDER.PAR.VisuSlotID].ShowMessageBoxError := FALSE;
				rec_state := DAT_WAIT;
			END_IF;	
			brsmemset(ADR(RECORDER.CMD), 0, SIZEOF(RECORDER.CMD));
			RETURN;
	END_CASE
	// --------------------------------------------------------------------------------------------------------------------
	// Cyclic function calls
	MpRecorderRegPar_0();
	MpDataRecorder_0();

END_PROGRAM