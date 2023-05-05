## Table of Contents
* [Description](#Description)
* [Pre Configuration](#Pre-Configuration)
* [Error numbers](#Errors)
* [Revision History](#Revision-History)

<a name="Description"></a>
## Description
The sample consists of two main components. The sample page is used to operate the recorder management. The task mappRecorder_01 drives the recorder management. The following functions are currently supported.

* Create new recordings
* Delete recordings
* View record data
* Download record data

Up to 3 web clients can connect at the same time. While the task itself can only execute one command at a time the commands are executed so fast that this should not be an issue. The init command may take longer but the response data is distributed to all sessions. The task uses a variable structure to communicate with the outside world that can also be used to interact with other tasks. The structure *Recorder_01* looks as follows:

<table>

  <tr>
    <td width=100>Level 1</td>
    <td>Level 2</td>
    <td>Level Description</td>
  </tr>
  <tr style="font-weight:bold">
    <th>CMD</th>
    <td colspan="3">Used to trigger commands like Init, record, delete, ... A command is triggered by setting it to true, when the command is finished the task will reset the command. This indicates that the command is finished. Do not change any parameters or set another command until the previous command is finished.</td>
  </tr>
  <tr>
   <td></td>
   <td>Init</td>
   <td colspan="3">Initializes the record management and reads the names of previous recordings.</td>
  </tr>
  <tr>
   <td></td>
   <td>Record</td>
   <td colspan="3">Starts a new recording session. This value must be true to all recording types. </td>
  </tr>
   <tr>
   <td></td>
   <td>Trigger</td>
   <td colspan="3">Creates a trigger based entry.</td>
  </tr>
   <tr>
   <td></td>
   <td>Delete</td>
   <td colspan="3">Deletes the selected record file</td>
  </tr>
     <tr>
   <td></td>
   <td>View</td>
   <td colspan="3">View the selected recording file</td>
  </tr>
   <tr>
   <td></td>
   <td>ErrorReset</td>
   <td colspan="3">Resets pending errors</td>
  </tr>
    <th> PAR </th>
    <td colspan="3">Parameters like record variables, name, ...</td>
  </tr>
      <tr>
   <td></td>
   <td>RecordVariable</td>
   <td colspan="3">String of the global variable structure. All data in this structure is recorded.</td>
  </tr>
   <tr>
   <td></td>
   <td>RecordName</td>
   <td colspan="3">Record name for command delete and view</td>
  </tr>
    <tr>
   <td></td>
   <td>RecordMode</td>
   <td colspan="3">Type of recording. Trigger, event, timer based or a combination of the three.</td>
  </tr>
    <tr>
   <td></td>
   <td>RecordIntervall</td>
   <td colspan="3">Time for timer based record mode.</td>
  </tr>
      <tr>
   <td></td>
   <td>IsRecording</td>
   <td colspan="3">Indicates that a recording is active</td>
  </tr>
    <tr>
   <td></td>
   <td>SamplesNum</td>
   <td colspan="3">Samples in active recording</td>
  </tr>
   <td></td>
   <td>DeviceName</td>
   <td colspan="3">Device name defined under the CPU configuration. This is where the recipes are stored, use SIM_DEVICE for simulation</td>
  </tr>
    <tr>
   <td></td>
   <td>MpLink</td>
   <td colspan="3">MpLink from the mappRecipe configuration under the physical view.</td>
  </tr>
    <tr>
   <td></td>
   <td>Initialized</td>
   <td colspan="3">Shows that the record managment was initialized.</td>
  </tr>
      <tr>
   <td></td>
   <td>VisuSlotID</td>
   <td colspan="3">This is the session ID for the current command. This is used to identify where to send response messages.</td>
  </tr>
  <tr>
    <th> DAT </th>
    <td colspan="3">Recipe lists as well as status information</td>
  </tr>
  <tr>
   <td></td>
   <td>RecordNames</td>
   <td colspan="3">List with all record names</td>
  </tr>
  <tr>
   <td></td>
   <td>RecordNum</td>
   <td colspan="3">Number of recipes in the list</td>
  </tr>
   <tr>
   <td></td>
   <td>Status</td>
   <td colspan="3">Shows the result for the last command</td>
  </tr>
  <tr>
    <th> VIS </th>
    <td colspan="3">Data specific for the visualization. The structure is an array, one for each client session</td>
  <tr>
   <td></td>
   <td>RecordNames</td>
   <td colspan="3">List with all recipes formated as data provider for the mappView listbox</td>
  </tr>
  <tr>
  </tr>
  <tr>
   <td></td>
   <td>RecordNum</td>
   <td colspan="3">Number of visible records in the list. Depending on the filter this number can be lower than the total number of records stored under DAT.</td>
  </tr>
    <tr>
   <td></td>
   <td>RecordFilter</td>
   <td colspan="3">Only show records that fit the filter pattern.</td>
  </tr>
  <tr>
   <td></td>
   <td>RecordSelected</td>
   <td colspan="3">Selected record used with the command delete and view.</td>
  </tr>
    <tr>
   <td></td>
   <td>RecordDoubleClick</td>
   <td colspan="3">Helper variable to detect a double click on a record. When a double click is detected the record is opened.</td>
  </tr>
      <tr>
   <td></td>
   <td>EnableButtons</td>
   <td colspan="3">Enable buttons delete and view if at least one record is available.</td>
  </tr>
      <tr>
   <td></td>
   <td>ViewFilePath</td>
   <td colspan="3">File path used for the web widget that shows the file content.</td>
  </tr>
      <tr>
   <td></td>
   <td>FileView</td>
   <td colspan="3">Trigger to open the fly out window and view the file content.</td>
  </tr>
  <tr>
   <td></td>
   <td>ShowMessageBoxError</td>
   <td colspan="3">Show a message box when command was not successful</td>
  </tr>
   <tr>
    <th> ERR </th>
    <td colspan="3">Information about errors</td>
  </tr>
   <tr>
   <td></td>
   <td>No</td>
   <td colspan="3">Error number</td>
  </tr>
  <tr>
   <td></td>
   <td>State</td>
   <td colspan="3">State where the error occurred</td>
  </tr>
  <tr>
   <td></td>
   <td>Text</td>
   <td colspan="3">Error text</td>
  </tr>
</table>

<a name="Pre-Configuration"></a>
## Pre-Configuration
The sample communicates with the outside world via the global structure 'Recorder_01'. If more than one recorder management is needed the complete package 'mappRecord' should be duplicated. It is important that the new task name and new global structure use the same name. 

After importing the sample go to the package 'mappRecord' under task 'Recorder_01' edit the file 'init.st'. The parameter 'RecorderData' contains the name of the variable structure that contains the recipe data. The default variable has a few sample values. After importing the task these can be replaced with "real" variables that should be saved. The parameter 'DeviceName' defines the location where the recipes are stored. Make sure that the default entries 'RECORDER_DEVICE' and 'SIM_DEVICE' are defined under the files devices of the CPU configuration. The sample automatically switches between the device strings when using simulation mode.

	// ----------------------------------------------------------------------------------------
	// The following settings can be adjusted
	Recorder_1.PAR.RecipeVariable      := 'RecorderData';     // Top variable structure with recipe data
	IF(DiagCpuIsSimulated()) THEN
  		Recorder_1.PAR.DeviceName  := 'SIM_DEVICE';       // Device name from the CPU configuration for simulation
	ELSE
  		Recorder_1.PAR.DeviceName  := 'RECORDER_DEVICE';  // Device name from the CPU configuration for X20CPU
	END_IF
	// ----------------------------------------------------------------------------------------
	this := 'Recorder_1';                            // Name of the global variable structure and this task name
  	Recorder_1.PAR.MpLink := gDataRecorder_1;  	// MpLink from mappRecipe configuration in physical view

The following constants located in the package mappRecorder under Variables.var can be adjusted if necessary.

| Constant | Default | Text |
|---|---|---|
| DAT_MAX_NUM | 100 | Maximum number of recipes. |
| DAT_NAME_LENGTH | 40 | Maximum length for a recipe name. |
| DAT_VIS_LENGTH  | 120 | Make this REC_NAME_LENGTH x 3. |
| DAT_MAX_CLIENTS_ID | 2 | Maximum number of concurrent web client connections. Do not change this number. |
| DAT_VIEW_FILTER | csv, xml | Files extensions than can be used with the view command. Filter is case sensitive. |
| DAT_DOWNLOAD_SIZE | 500000 | Maximum size of memory allocated for uploading and downloading files |

<a name="Errors"></a>
## Error
The sample generates the following list of error messages. All other error numbers are generated from included libraries that can be found in the Automation Studio help.

| No | Constant | Text |
|---|---|---|
| 50010 | ERR_REC_TOO_MANY_CLIENTS  | More than 3 clients try to connect to user management  |
| 50100 | ERR_REC_NAME_EMPTY  | Recipe name is empty  |
| 50101 | ERR_REC_NAME_EXISTS  | Recipe name already exists  |
| 50102 | ERR_REC_NAME_LOST  | Recipe name was not found  |
| 50103 | ERR_REC_NAME_LENGTH  | One or more recipe names exceeds maximum length  |
| 50110 | ERR_REC_DEV_NAME_EMPTY  | Device name is empty  |
| 50120 | ERR_REC_VAR_NAME_EMPTY  | Variable name is empty  |
| 50130 | ERR_REC_NOT_INITIALIZED  | Recipe management is not initialized  |
| 50200 | ERR_REC_MAX_NUM  | Recipe management is not initialized  |
| 50300 | ERR_REC_TASK_NAME  | Task name is incorrect. Make sure task name and global variable structure share the same name and that the string "this" is correct in the init task.  |
| 50400 | ERR_MEM_ALLOC | Memory allocation for file upload and download failed | |	
| 50410 | ERR_MEM_DOWNLOAD | Size of download file exceeds maximum | Increase value of REC_UPLOAD_DOWNLOAD_SIZE |	
| 50420 | ERR_TIMEOUT_DOWNLOAD | Download response timed out | This error occurs with Microsoft Edge and Internet Explorer. Use Chrome or Firefox instead |	

<a name="Revision-History"></a>
## Revision History

#### Version 0.1
First public release
