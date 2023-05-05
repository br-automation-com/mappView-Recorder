## Table of Contents
* [Introduction](#Introduction)
* [Requirements](#Requirements)
* [Revision History](#Revision-History)

<a name="Introduction"></a>
## Introduction
This is a sample project for a data recorder with mappView. It uses B&R mappData to record data and supports up to 3 concurrent web clients.

![](Logical/mappView/Resources/Media/screenshot.png)

Also see [**How to import the recorder management into an existing project.**](/Logical/mappRecorder/HowToImport.pdf) Download the latest release from [**here.**](../../releases) When upgrading from a previous version make sure to delete the files that were imported before. Detailed information are available in the [**Wiki**](https://github.com/br-automation-com/mappView-Recorder/wiki). This sample can run in simualtion mode (http://127.0.0.1:81/).

<a name="Requirements"></a>
## Requirements
* Automation Studio 4.9
* mappView 5.15
* mappServices 5.15
* Automation Runtime C4.90

Recommended task class is #8 with a 10ms cycle time.

<a name="Revision-History"></a>
## Revision History

#### Version 0.6 (05.05.2023)
- Updated Automation Studio and mapp components
- Added new command LoadConfig to load a variable list from a file
- Minor bug fixes

