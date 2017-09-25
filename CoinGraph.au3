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
	#AutoIt3Wrapper_Outfile=binary\CoinGraph.exe
	#AutoIt3Wrapper_Compression=4
	#AutoIt3Wrapper_UseX64=y
	#AutoIt3Wrapper_Res_Comment=CoinGraph
	#AutoIt3Wrapper_Res_Description=CoinGraph
	#AutoIt3Wrapper_Res_Fileversion=0.0.0.1
	#AutoIt3Wrapper_Res_ProductVersion=0.0.0.1
	#AutoIt3Wrapper_Res_LegalCopyright=Vu Quang Trong
	#AutoIt3Wrapper_Res_Language=1033
	#AutoIt3Wrapper_Res_Field=ProductName|CoinGraph
	#AutoIt3Wrapper_Res_Field=OriginalFilename|CoinGraph.exe
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

	DEV	0.0.0.0		20/09/2017		20:00
	* 	Initialize file

	DEV	0.0.0.1		25/09/2017		16:00
	+ 	Select a market, save markets
	+ 	Auto backfill market history
	+ 	Update coin's price in realtime

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

#include "Debug.au3"
#include "Bittrex.au3"
#include "ListViewExtension.au3"
#include "GraphGDIPlus.au3"

; Use event mode
Opt("GUIOnEventMode", 1)

; To prevent issues
Opt("MustDeclareVars", 1)

; Hotkeys and startup/shutdown callback
OnAutoItExitRegister("__OnExit")

; Store values
Global Const $g_BufferSize = 600
Global $g_PriceHistory[$g_BufferSize + 1]
Global $g_PriceMax = 0
Global $g_PriceMin = 0
Global $g_PriceLast = 0
Global $g_PriceFactor = 1
Global $g_PriceRound = 1

; System Setting
Global $g_sPair = ""
Global $g_bAutoRange = $GUI_CHECKED
Global $g_iUpdateTime = 2
Global $g_bMonitoring = False

#Region ### START Koda GUI section ### Form=CoinGraph.kxf
	; Turn on theme for XP, for display color in checkbox
	XPStyle(True)

	; Main GUI
	Global $g_hGUI = GUICreate("CoinGraph", 940, 350)
	GUISetOnEvent($GUI_EVENT_CLOSE, "OnWindowClose")
	GUISetIcon("Coin.ico", -1)
	GUISetBkColor(0x99999999)

	; Chart
	Global $g_aGraph = _GraphGDIPlus_Create($g_hGUI, 150, 42, 640, 240, 0xFF000000, 0xFF1B1B1B)
	_GraphGDIPlus_Set_RangeX($g_aGraph, 0, $g_BufferSize, 20, 0) ; 1, 0, 0xFF0000, True)

	; Current Price
	Global $g_lbTick = GUICtrlCreateLabel("0.00000000", 150, 10, 200, 32)
	GUICtrlSetFont(-1, 22, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0xFF0000)

	; High Price
	Global $g_lbHigh = GUICtrlCreateLabel("0.00000000", 360, 10, 200, 32)
	GUICtrlSetFont(-1, 22, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0xFF0000)

	; Low Price
	Global $g_lbLow = GUICtrlCreateLabel("0.00000000", 570, 10, 200, 32)
	GUICtrlSetFont(-1, 22, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0xFF0000)

	; Delta
	Global $g_lbDelta = GUICtrlCreateLabel("+0.00%", 800, 10, 130, 32)
	GUICtrlSetFont(-1, 22, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0xFF0000)

	; Auto-range Checkbox
	Global $g_cbAutoRange = GUICtrlCreateCheckbox("Auto Range", 800, 42, 130, 32)
	GUICtrlSetColor(-1, 0xFF0000)
	GUICtrlSetState(-1, $g_bAutoRange)
	GUICtrlSetOnEvent(-1, "OnAutoRangeSelected")

	; Pair Selector
	Global $g_lstPair = GUICtrlCreateCombo("", 800, 74, 130, 32, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetOnEvent(-1, "OnPairSelected")

	; Update intervel
	GUICtrlCreateLabel("Update time (s):", 800, 106, 120, 25)
	GUICtrlSetColor(-1, 0xFF0000)

	Global $g_txtUpdateTime = GUICtrlCreateInput($g_iUpdateTime, 882, 102, 48, 25)
	GUICtrlSetOnEvent(-1, "OnUpdateTimeEdited")

	Global $g_btnUpdateTimeUpDown = GUICtrlCreateUpdown($g_txtUpdateTime)
	GUICtrlSetOnEvent(-1, "OnUpdateTimeEdited")

	; Start monitoring button
	Global $g_btnStart = GUICtrlCreateButton("Start Monitoring", 800, 134, 130, 40)
	GUICtrlSetFont(-1, 10, 800, 0, "MS Sans Serif")
	GUICtrlSetOnEvent(-1, "OnStartSelected")

#EndRegion ### END Koda GUI section ###

;==============================================================================
; Program starts here
;==============================================================================

Main()

;==============================================================================
; Program ends here
;==============================================================================

;==============================================================================
; Main()
;==============================================================================
Func Main()

	; create debug file
	Debug_init("CoinAlert")
	Debug("START")

	; Bittrex start
	bittrex_openConnection()

	If FileExists(@ScriptDir & "\markets.txt") Then
		GUICtrlSetData($g_lstPair, FileRead(@ScriptDir & "\markets.txt"))
	Else
		GUICtrlSetData($g_lstPair, "<< New >>")
	EndIf

	; Show UI
	GUISetState(@SW_SHOW)

	; Main Loop
	While (True)

		If $g_bMonitoring Then
			getTicker()
			drawGraph()
		Else
			Sleep($g_iUpdateTime * 1000)
		EndIf

	WEnd
EndFunc   ;==>Main

;==============================================================================
; drawGraph()
;==============================================================================
Func drawGraph()

	Local $margin = 0.1 * ($g_PriceMax - $g_PriceMin)
	_GraphGDIPlus_Set_GridX($g_aGraph, 60, 0xFF6C6342)
	_GraphGDIPlus_Set_GridY($g_aGraph, ($g_PriceMax - $g_PriceMin + 2 * $margin) / 10, 0xFF6C6342)

	; draw price line
	_GraphGDIPlus_Set_PenSize($g_aGraph, 1)
	_GraphGDIPlus_Set_PenColor($g_aGraph, 0xFFFF0000)
	_GraphGDIPlus_Plot_Start($g_aGraph, 0, 0)

	For $i = 0 To $g_BufferSize Step 1
		_GraphGDIPlus_Plot_Line($g_aGraph, $i, $g_PriceHistory[$i])
	Next

	; draw heart beat
	_GraphGDIPlus_Set_PenSize($g_aGraph, 5)
	_GraphGDIPlus_Set_PenColor($g_aGraph, 0xFF00FF00)
	_GraphGDIPlus_Plot_Dot($g_aGraph, $g_BufferSize, $g_PriceHistory[$g_BufferSize])

	; show graph
	_GraphGDIPlus_Refresh($g_aGraph)

	; now you can see it
	Sleep($g_iUpdateTime * 1000)

	; clear it
	_GraphGDIPlus_Clear($g_aGraph)

EndFunc   ;==>drawGraph
;==============================================================================
; XPStyle()
;==============================================================================
Func XPStyle($OnOff = 1)

	Local $XS_n = DllCall("uxtheme.dll", "int", "GetThemeAppProperties")

	If $OnOff And StringInStr(@OSType, "WIN32_NT") Then
		DllCall("uxtheme.dll", "none", "SetThemeAppProperties", "int", 0)
		Return 1
	ElseIf StringInStr(@OSType, "WIN32_NT") And IsArray($XS_n) Then
		DllCall("uxtheme.dll", "none", "SetThemeAppProperties", "int", $XS_n[0])
		$XS_n = ""
		Return 1
	EndIf

	Return 0
EndFunc   ;==>XPStyle

;==============================================================================
; getTicker()
;==============================================================================
Func getTicker()

	$g_PriceLast = $g_PriceFactor * bittrex_getTicker($g_sPair)
	Debug("$priceLast = " & $g_PriceLast)

	; Process info
	_ArrayPush($g_PriceHistory, $g_PriceLast)

	Local $lastMax = $g_PriceMax
	Local $lastMin = $g_PriceMin

	$g_PriceMin = _ArrayMin($g_PriceHistory)
	$g_PriceMax = _ArrayMax($g_PriceHistory)

	GUICtrlSetData($g_lbTick, StringFormat("%." & $g_PriceRound & "f", $g_PriceLast / $g_PriceFactor))
	GUICtrlSetData($g_lbHigh, StringFormat("%." & $g_PriceRound & "f", $g_PriceMax / $g_PriceFactor))
	GUICtrlSetData($g_lbLow, StringFormat("%." & $g_PriceRound & "f", $g_PriceMin / $g_PriceFactor))

	Local $delta = ($g_PriceLast - $g_PriceMax) * 100 / $g_PriceMax
	If ($delta >= 0) Then
		GUICtrlSetColor($g_lbDelta, 0x00FF00)
		GUICtrlSetData($g_lbDelta, "+" & StringFormat("%.2f", $delta) & "%")
	Else
		GUICtrlSetColor($g_lbDelta, 0xFF0000)
		GUICtrlSetData($g_lbDelta, StringFormat("%.2f", $delta) & "%")
	EndIf

	If $lastMax <> $g_PriceMax Or $lastMin <> $g_PriceMin Then
		Local $margin = 0.05 * ($g_PriceMax - $g_PriceMin)
		_GraphGDIPlus_Set_RangeY($g_aGraph, $g_PriceMin - $margin, $g_PriceMax + $margin, 10, 1, $g_PriceRound, 0xFF0000, 120, $g_PriceFactor)
	EndIf

	Debug("$g_PriceMax = " & $g_PriceMax & " $g_PriceMin = " & $g_PriceMin & " $g_PriceLast = " & $g_PriceLast)

EndFunc   ;==>getTicker

;==============================================================================
; getMarketHistory()
; NOTE: this backfil function at this moment does not care about timestamp
; I'will update it later
;==============================================================================
Func getMarketHistory()
	Local $marketHistory = bittrex_getMarketHistory($g_sPair)

	Local $maxItem = $marketHistory[0][0]
	Debug("$maxItem = " & $maxItem)

	; Find multiply factor
	Local $sample = $marketHistory[1][2]
	$g_PriceFactor = 1
	$g_PriceRound = 2
	While ($sample * $g_PriceFactor < 1000)
		$g_PriceFactor *= 10
		$g_PriceRound += 1
	WEnd

	; Fill buffer
	For $i = 0 To $maxItem - 1 Step 1
		$g_PriceHistory[$g_BufferSize - $i] = $g_PriceFactor * $marketHistory[$i + 1][2]
	Next

	For $y = $maxItem To $g_BufferSize Step 1
		$g_PriceHistory[$g_BufferSize - $y] = $g_PriceHistory[$g_BufferSize - $maxItem + 1]
	Next

	$g_PriceMin = _ArrayMin($g_PriceHistory)
	$g_PriceMax = _ArrayMax($g_PriceHistory)

	Debug("$g_PriceMax = " & $g_PriceMax & " $g_PriceMin = " & $g_PriceMin)
	Local $margin = 0.05 * ($g_PriceMax - $g_PriceMin)
	_GraphGDIPlus_Set_GridY($g_aGraph, ($g_PriceMax - $g_PriceMin + 2 * $margin) / 10, 0xFF6C6342)
	_GraphGDIPlus_Set_RangeY($g_aGraph, $g_PriceMin - $margin, $g_PriceMax + $margin, 10, 1, $g_PriceRound, 0xFF0000, 120, $g_PriceFactor)

EndFunc   ;==>getMarketHistory

; ===========================================================
; OnWindowClose
; ===========================================================
Func OnWindowClose()

	Debug("OnWindowClose")
	Exit

EndFunc   ;==>OnWindowClose

; ===========================================================
; OnAutoRangeSelected
; ===========================================================
Func OnAutoRangeSelected()

	$g_bAutoRange = GUICtrlRead($g_cbAutoRange)

	Debug("OnAutoRangeSelected" & " $g_bAutoRange = " & $g_bAutoRange)
EndFunc   ;==>OnAutoRangeSelected

; ===========================================================
; OnPairSelected
; ===========================================================
Func OnPairSelected()

	If (GUICtrlRead($g_lstPair) == "<< New >>") Then
		Local $newMarket = InputBox("Add new market", "You can add new market on Bittrex here", "BTC-")
		If $newMarket <> "" Then
			GUICtrlSetData($g_lstPair, $newMarket)
			Debug("Added market: " & $newMarket)
			Local $fMarket = FileOpen(@ScriptDir & "\markets.txt", $FO_OVERWRITE)
			FileWrite($fMarket, _GUICtrlComboBox_GetList($g_lstPair))
			FileClose($fMarket)
		EndIf
	EndIf

	Debug("OnPairSelected: " & GUICtrlRead($g_lstPair))
EndFunc   ;==>OnPairSelected

; ===========================================================
; OnUpdateTimeEdited
; ===========================================================
Func OnUpdateTimeEdited()
	Debug("OnUpdateTimeEdited()")
	$g_iUpdateTime = Number(GUICtrlRead($g_txtUpdateTime))
	If $g_iUpdateTime < 1 Then
		$g_iUpdateTime = 1
		GUICtrlSetData($g_txtUpdateTime, $g_iUpdateTime)
	EndIf
	Debug("$g_iUpdateTime = " & $g_iUpdateTime)
EndFunc   ;==>OnUpdateTimeEdited

; ===========================================================
; OnStartSelected
; ===========================================================
Func OnStartSelected()

	If $g_bMonitoring Then
		$g_bMonitoring = False
		GUICtrlSetData($g_btnStart, "Start Monitoring")
		GUICtrlSetData($g_lbTick, "0")
		GUICtrlSetData($g_lbHigh, "0")
		GUICtrlSetData($g_lbLow, "0")
		GUICtrlSetData($g_lbDelta, " 0.00%")
		_GraphGDIPlus_Clear($g_aGraph)
		_GraphGDIPlus_Clear($g_aGraph)
	Else
		$g_sPair = GUICtrlRead($g_lstPair)
		If $g_sPair == "" Then
			MsgBox(0, "Warning", "Please select a market", 5000)
			Return
		EndIf
		getMarketHistory()
		GUICtrlSetData($g_btnStart, "Stop Monitoring")
		$g_bMonitoring = True
	EndIf

	Debug("OnStartSelected" & " $g_sPair = " & $g_sPair)
EndFunc   ;==>OnStartSelected

; ===========================================================
; __OnExit
; ===========================================================
Func __OnExit()

	bittrex_closeConnection()

	; Release graphics
	_GraphGDIPlus_Delete($g_hGUI, $g_aGraph)

	; actual exit
	Exit 0
EndFunc   ;==>__OnExit
