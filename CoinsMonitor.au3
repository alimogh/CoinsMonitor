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
	Script Function:	Monitor your coins' price and popup alerts

#ce

#cs ========== COMPILATION NOTES ==========

	DO NOT PACK THE EXECUTABLE FILE USING ANY PACKER
	therefore do not use #AutoIt3Wrapper_UseUpx=y

	DO NOT USE AU3STRIPPER
	Au3Stripper causes unwanted behavior, do NOT use #AutoIt3Wrapper_Run_Au3Stripper=y

#ce

#Region ========== DIRECTIVES  ==========

	#AutoIt3Wrapper_Icon=Coin.ico
	#AutoIt3Wrapper_Outfile=binary\CoinsMonitor.exe
	#AutoIt3Wrapper_Compression=4
	#AutoIt3Wrapper_UseX64=y
	#AutoIt3Wrapper_Res_Comment=CoinsMonitor
	#AutoIt3Wrapper_Res_Description=CoinsMonitor
	#AutoIt3Wrapper_Res_Fileversion=0.0.0.1
	#AutoIt3Wrapper_Res_ProductVersion=0.0.0.1
	#AutoIt3Wrapper_Res_LegalCopyright=Vu Quang Trong
	#AutoIt3Wrapper_Res_Language=1033
	#AutoIt3Wrapper_Res_Field=ProductName|CoinsMonitor
	#AutoIt3Wrapper_Res_Field=OriginalFilename|CoinsMonitor.exe
	#AutoIt3Wrapper_Res_Field=CompanyName|N/A
	#AutoIt3Wrapper_Run_AU3Check=y
	#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
	#AutoIt3Wrapper_AU3Check_Parameters=-d -w 4 -w 6
	#AutoIt3Wrapper_Run_Tidy=y
	#Tidy_Parameters=/reel /ri /sci 9

#EndRegion ========== DIRECTIVES  ==========

#cs ========== FEATURE ==========

	* Select a market, save markets
	* Auto backfill market history
	* Update coin's price in realtime

#ce

#cs ========== CHANGE LOG ==========

	Note:
	Change $APP_VER when version's changed. i.e: 1.0.0.9 -> 9
	Do not use sub-number bigger than 9. i.e: 1.0.0.9 -> 1.0.1.0, not 1.0.0.10

	Log:

	DEV	0.0.0.0		26/09/2017		10:00
	* 	Initialize file

	DEV	0.0.0.1		29/09/2017		16:00
	* 	Add Stack Component, each stack display info of a coin

#ce

#include <Array.au3>
#include <WinAPIvkeysConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <GuiEdit.au3>
#include <GuiMenu.au3>
#include <GuiComboBox.au3>
#include <WinAPIShellEx.au3>
#include <Timers.au3>
#include "Debug.au3"
#include "Bittrex.au3"
#include "Stack_Component.au3"

; Application settings
Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)

; Hotkeys and startup/shutdown callback
OnAutoItExitRegister("__onExit")
HotKeySet("{ESC}", "__onHide")

;==============================================================================
; Program starts here
;==============================================================================
Global $g_hGUI = GUICreate("", Default, Default, Stack_GetItemWidthMin(), 38, _
		BitOR($WS_POPUP, $WS_BORDER), _
		BitOR($WS_EX_TOPMOST, $WS_EX_WINDOWEDGE) _
		)
GUISetBkColor(0x243746, $g_hGUI)

Global $g_sPorfilo = GUICtrlCreateLabel("-", 8, 2, 104, 34, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetFont(-1, 18, 700, 0, "Consolas")
GUICtrlSetColor(-1, 0xFFFFFF)

Global $g_sAddMarket = GUICtrlCreateLabel("+", Stack_GetItemWidthMin() - 12 - 18, 0, 18, 34, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetFont(-1, 28, 700, 0, "Consolas")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetOnEvent(-1, "onMarketAdded")

Global $g_sMarket = GUICtrlCreateEdit("USDT-BTC", Stack_GetItemWidthMin() - 12 - 18 - 10 - 110, 6, 110, 26, $ES_RIGHT, $UDF_WS_EX_STATICEDGE)
GUICtrlSetResizing(-1, $GUI_DOCKALL)
GUICtrlSetFont(-1, 12, 400, 0, "Consolas")
GUICtrlSetState(-1, $GUI_HIDE)

GUISetOnEvent($GUI_EVENT_CLOSE, "onWindowClosed", $g_hGUI)

GUIRegisterMsg($WM_NCHITTEST, "onWindowDragging")

Main()

;==============================================================================
; Program ends here
;==============================================================================

;==============================================================================
; Main()
;==============================================================================
Func Main()

	; create debug file
	Debug_init("Stack")
	Debug("START")

	Stack_SetRootGUI($g_hGUI)
	Stack_SetDrawFunction("DockWindow")
	Stack_SetUpdateFunction("ThreadUpdate")

	bittrex_openConnection()

	; TEST FUNCTIONS
	#cs
		Local $iStackCount = Random(1, 10, 1)
		Debug("Create $iStackCount = " & $iStackCount)

		For $i = 1 To $iStackCount
		Stack_CreateStack($i & $i & $i & $i & $i & "-" & $i & $i & $i & $i)
		Next
	#ce
	; END OF TESTING

	; read settings
	Debug("Start watching")
	Local $watch = IniRead(@ScriptDir & "\settings.ini", "Bittrex", "watch", "")
	Local $watchList = StringSplit($watch, "|")
	If (Not @error) And $watchList[0] > 0 Then
		For $i = 1 To $watchList[0]
			Stack_CreateStack($watchList[$i])
			Sleep(1000)
		Next
	EndIf

	; update markets
	Local $dayUpdate = IniRead(@ScriptDir & "\settings.ini", "Bittrex", "lastUpdateMarket", "")
	Local $dayDiff = _DateDiff('D', $dayUpdate, _NowCalc())
	If @error Or $dayDiff > 0 Then
		Debug("Fetch markets")
		Local $markets = bittrex_getMarkets()
		IniWrite(@ScriptDir & "\settings.ini", "Bittrex", "markets", _ArrayToString($markets, "|"))
		IniWrite(@ScriptDir & "\settings.ini", "Bittrex", "lastUpdateMarket", _NowCalc())
	EndIf

	; Show window
	Debug("Show UI")
	DockWindow()
	GUISetState(@SW_SHOW, $g_hGUI)

	; Loop forever
	While (1)
		Sleep(1000)
	WEnd
EndFunc   ;==>Main

; ===========================================================
; AddMarket
; ===========================================================
Func AddMarket($sMarket)
	; check market
	Local $allMarket = IniRead(@ScriptDir & "\settings.ini", "Bittrex", "markets", "")

	If StringInStr($allMarket, $sMarket) Then

		; if market is already shown, skip adding
		For $i = 1 To Stack_GetItemsCount()
			If Stack_GetItemTitle($i) = $sMarket Then Return
		Next

		; add to watch
		IniWrite(@ScriptDir & "\settings.ini", "Bittrex", "watch", IniRead(@ScriptDir & "\settings.ini", "Bittrex", "watch", "") & $sMarket & "|")
		Stack_CreateStack($sMarket)
	EndIf
EndFunc   ;==>AddMarket

; ===========================================================
; onMarketAdded
; ===========================================================
Func onMarketAdded()
	Debug("onMarketAdded")
	If @GUI_WinHandle = $g_hGUI Then
		If (BitAND(GUICtrlGetState($g_sMarket), $GUI_HIDE)) Then
			GUICtrlSetState($g_sMarket, $GUI_SHOW)
		Else
			AddMarket(GUICtrlRead($g_sMarket))
			GUICtrlSetState($g_sMarket, $GUI_HIDE)
		EndIf
	EndIf
EndFunc   ;==>onMarketAdded

; ===========================================================
; DockWindow
; ===========================================================
Func DockWindow()
	Debug("DockWindow")

	Local $RootPos = WinGetPos($g_hGUI)

	; update main window
	Local $height = 38
	For $i = 1 To Stack_GetItemsCount()
		;;;Debug("Pick item " & $i)
		$height = $height + Stack_GetItemHeight($i) + 1
	Next

	WinMove($g_hGUI, "", $RootPos[0], $RootPos[1], Stack_GetItemWidthMin(), $height)

	; udpate children windows
	$RootPos = WinGetPos($g_hGUI)

	Local $y = 0
	For $i = 1 To Stack_GetItemsCount()
		$y = $y + Stack_GetItemHeight($i - 1)
		WinMove(Stack_GetItemHandler($i), "", 0, $y + $i - 1, $RootPos[2], Stack_GetItemHeight($i))
	Next

EndFunc   ;==>DockWindow

; ===========================================================
; ThreadUpdate($hWnd, $iMsg, $iIDTimer, $iTime)
; ===========================================================
Func ThreadUpdate($hWnd, $iMsg, $iIDTimer, $iTime)

	;Return

	Local $index = 0
	Local Static $counter = 0

	; get index
	For $i = 1 To Stack_GetItemsCount()
		If $hWnd = Stack_GetItemHandler($i) Then
			$index = $i
			ExitLoop
		EndIf
	Next

	; update price
	Local $oldPrice = Stack_GetItemPrice($index)
	Local $newPrice = bittrex_getTicker(Stack_GetItemTitle($index))

	If ($newPrice >= $oldPrice) Then
		GUICtrlSetColor(Stack_GetItemPriceID($index), $g_iUPTREND)
	Else
		GUICtrlSetColor(Stack_GetItemPriceID($index), $g_iDOWNTREND)
	EndIf
	Stack_SetItemPrice($index, $newPrice)

	#cs
		; update change
		$counter = $counter + 1
		If $counter > 2 Then
		$counter = 0
		Local $summary = bittrex_getMarketSummary(Stack_GetItemTitle($index))
		If ($newPrice >= $summary[2]) Then
		GUICtrlSetColor(Stack_GetItemChangeID($index), $g_iUPTREND)
		Else
		GUICtrlSetColor(Stack_GetItemChangeID($index), $g_iDOWNTREND)
		EndIf
		Stack_SetItemChange($index, ($newPrice - $summary[2]) * 100 / $summary[2])
		EndIf
	#ce

EndFunc   ;==>ThreadUpdate

; ===========================================================
; onWindowDragging
; ===========================================================
Func onWindowDragging($hWnd, $uMsg, $wParam, $lParam)
	;;;Debug("onWindowDragging")
	If $hWnd = $g_hGUI Then
		Local $aPos = WinGetPos($hWnd)
		If Abs(BitShift($lParam, 16) - $aPos[1]) <= 38 Then Return $HTCAPTION
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>onWindowDragging

; ===========================================================
; onWindowClosed
; ===========================================================
Func onWindowClosed()
	Debug("onWindowClosed")
	If @GUI_WinHandle = $g_hGUI Then
		Exit
	Else
		GUIDelete(@GUI_WinHandle)
	EndIf
EndFunc   ;==>onWindowClosed

; ===========================================================
; __onHide
; ===========================================================
Func __onHide()
	Local $state = WinGetState($g_hGUI)
	If BitAND($state, 2) Then
		WinSetState($g_hGUI, "", @SW_HIDE)
	Else
		WinSetState($g_hGUI, "", @SW_SHOW)
	EndIf

EndFunc   ;==>__onHide

; ===========================================================
; __onExit
; ===========================================================
Func __onExit()

	bittrex_closeConnection()

	; actual exit
	Exit 0
EndFunc   ;==>__onExit
