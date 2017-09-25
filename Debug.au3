
; Donations are welcome and will be accepted via below addresses:
; 	BTC:	13e2SdFuyEzqw8dPjRNkyp6rDuTGKaW2rY
; 	LTC:	LTAJo4s5eGGMtao5gVjXSCULXV7iSc9ZnL
; Thank you for the shiny stuff :kiss:

#cs License

	Copyright 2017 Vu Quang Trong <vuquangtrong at gmail dot com>

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.

#ce

#cs

	AutoIt Version: 	3.3.14.2
	Author:				Vu Quang Trong
	Project:			Bitcoin Alert System
	Script Function:	Debugging

#ce

#include-once
#include <File.au3>

; #INDEX# ===================================================================================
; Title ...............: Debug
; File Name............: Debug.au3
; File Version.........: 1.0.0.1
; Min. AutoIt Version..: v3.3.7.20
; Description .........: AutoIt wrapper for writting debug information to console or file
; Author... ...........: vuquangtrong
; Dll .................: none
; ===========================================================================================

; ===========================================================================================
; Public Functions:
; 	Debug_init($sFilename="")
; 	Debug($sLogString="")
; ===========================================================================================

; Hotkeys and startup/shutdown callback
OnAutoItExitRegister("__OnDebugExit")

; Debug File
If @Compiled Then
	Global $g_IsEnableDebug = True
	Global $g_DebugFileHandler = -1
EndIf

; ===========================================================
; Debug_init($sFilename="")
; ===========================================================
Func Debug_init($sFilename = "")

	; create debug file
	If @Compiled Then
		If ($g_IsEnableDebug) Then
			$g_DebugFileHandler = FileOpen(@ScriptDir & "\" & $sFilename & "_" & @YEAR & @MON & @MDAY & "-" & @HOUR & @MIN & @SEC & ".log", $FO_OVERWRITE + $FO_CREATEPATH)
		EndIf
	EndIf

EndFunc   ;==>Debug_init

;==============================================================================
; Debug($sLogString="")
;==============================================================================
Func Debug($sLogString = "")

	Local $logLine = "[" & @YEAR & @MON & @MDAY & "-" & @HOUR & @MIN & @SEC & "]" & $sLogString

	If @Compiled Then
		If $g_IsEnableDebug Then
			If ($g_DebugFileHandler <> -1) Then
				FileWriteLine($g_DebugFileHandler, $logLine)
			EndIf
		EndIf
	Else
		ConsoleWrite($logLine & @CRLF)

	EndIf
EndFunc   ;==>Debug


; ===========================================================
; __OnDebugExit
; ===========================================================
Func __OnDebugExit()

	; close debug
	Debug("Release debug file, exit")

	If @Compiled Then
		If ($g_DebugFileHandler <> -1) Then
			FileClose($g_DebugFileHandler)
			$g_DebugFileHandler = -1
		EndIf
	EndIf

EndFunc   ;==>__OnDebugExit
