
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
	Script Function:	Stack Component

#ce

#include-once
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

; #INDEX# ===================================================================================
; Title ...............: Stack_Component
; File Name............: Stack_Component.au3
; File Version.........: 1.0.0.1
; Min. AutoIt Version..: v3.3.7.20
; Description .........: AutoIt wrapper for creating stackable layout
; Author... ...........: vuquangtrong
; Dll .................: none
; ===========================================================================================

; ===========================================================================================
; Public Functions:
; 	Stack_SetRootGUI($hRoot)
;	Stack_SetDrawFunction($pFunction)
;	Stack_SetUpdateFunction($pFunction)
;	Stack_CreateStack($title = "", $height = Default)
; ===========================================================================================

; ===========================================================
; Stack Global Variables
; ===========================================================
Global $g_iProperties = 22
Global $g_aStacks[1][$g_iProperties] = [[ _
		Null, _	 ; 0 - handler
		"", _ 	 ; 1 - title
		38, _ 	 ; 2 - height
		0, _	 ; 3 - idPrice
		0, _	 ; 4 - idChangePeriod
		0, _	 ; 5 - idChange
		0, _	 ; 6 - idTotal
		0, _	 ; 7 - idAvailable
		0, _	 ; 8 - idPending
		0, _ 	 ; 9 - idIsBuyAuto
		0, _	 ; 10 - idBuyPrice
		0, _	 ; 11 - idBuyWhen
		0, _	 ; 12 - idBuyLimit
		0, _ 	 ; 13 - idIsSellAuto
		0, _	 ; 14 - idSellPrice
		0, _	 ; 15 - idSellWhen
		0, _	 ; 16 - idSellLimit
		0, _	 ; 17 - idProfit
		0, _	 ; 18 - idIsProtectProfit
		0, _	 ; 19 - idProfitLimit
		0, _ 	 ; 20 - idTimer
		0 _
		]]
Global $g_iWidthMin = 640
Global $g_iHeightDefault = 38
Global $g_iBACKGROUND = 0x051119
Global $g_iHIGHLIGHT = 0x04263E
Global $g_iDISABLED = 0x6C7881 ; 0xA0A0A0
Global $g_iUPTREND = 0x33AA33
Global $g_iDOWNTREND = 0xAA3333
Global $g_pDrawFunction = Null
Global $g_pUpdateFunction = Null

Global $UDF_WS_EX_STATICEDGE = -1 ; $WS_EX_STATICEDGE
; ===========================================================
; Stack_SetRootGUI($hRoot)
; ===========================================================
Func Stack_SetRootGUI($hRoot)
	$g_aStacks[0][0] = $hRoot
EndFunc   ;==>Stack_SetRootGUI

; ===========================================================
; Stack_GetRootGUI()
; ===========================================================
Func Stack_GetRootGUI()
	Return $g_aStacks[0][0]
EndFunc   ;==>Stack_GetRootGUI

; ===========================================================
; Stack_GetItemsCount()
; ===========================================================
Func Stack_GetItemsCount()
	Return UBound($g_aStacks) - 1
EndFunc   ;==>Stack_GetItemsCount

; ===========================================================
; Stack_GetItemWidthMin()
; ===========================================================
Func Stack_GetItemWidthMin()
	Return $g_iWidthMin
EndFunc   ;==>Stack_GetItemWidthMin

; ===========================================================
; Stack_GetItemHandler($i)
; ===========================================================
Func Stack_GetItemHandler($i)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Return $g_aStacks[$i][0]
	EndIf
EndFunc   ;==>Stack_GetItemHandler

; ===========================================================
; Stack_GetItemTitle($i)
; ===========================================================
Func Stack_GetItemTitle($i)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Return $g_aStacks[$i][1]
	EndIf
EndFunc   ;==>Stack_GetItemTitle

; ===========================================================
; Stack_GetItemHeight($i)
; ===========================================================
Func Stack_GetItemHeight($i)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Return $g_aStacks[$i][2]
	EndIf
EndFunc   ;==>Stack_GetItemHeight

; ===========================================================
; Stack_SetItemHeight($i, $height)
; ===========================================================
Func Stack_SetItemHeight($i, $height)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		$g_aStacks[$i][2] = $height
		If $g_pDrawFunction <> Null Then Call($g_pDrawFunction)
	EndIf
EndFunc   ;==>Stack_SetItemHeight

; ===========================================================
; Stack_SetItemPrice($i, $fPrice)
; ===========================================================
Func Stack_SetItemPrice($i, $fPrice)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $fPrice)
		GUICtrlSetData($g_aStacks[$i][3], $data)
	EndIf
EndFunc   ;==>Stack_SetItemPrice

; ===========================================================
; Stack_GetItemPrice($i)
; ===========================================================
Func Stack_GetItemPrice($i)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Return Number(ControlGetText($g_aStacks[$i][0], "", $g_aStacks[$i][3]))
	EndIf
EndFunc   ;==>Stack_GetItemPrice

; ===========================================================
; Stack_GetItemPriceID($i)
; ===========================================================
Func Stack_GetItemPriceID($i)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Return $g_aStacks[$i][3]
	EndIf
EndFunc   ;==>Stack_GetItemPriceID

; ===========================================================
; Stack_SetItemChangePeriod($i, $sChangePeriod)
; ===========================================================
Func Stack_SetItemChangePeriod($i, $sChangePeriod)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		GUICtrlSetData($g_aStacks[$i][4], $sChangePeriod)
	EndIf
EndFunc   ;==>Stack_SetItemChangePeriod

; ===========================================================
; Stack_SetItemChange($i, $sChange)
; ===========================================================
Func Stack_SetItemChange($i, $sChange)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%+5.2f%%", $sChange)
		GUICtrlSetData($g_aStacks[$i][5], $data)
	EndIf
EndFunc   ;==>Stack_SetItemChange

; ===========================================================
; Stack_GetItemChangeID($i)
; ===========================================================
Func Stack_GetItemChangeID($i)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		return $g_aStacks[$i][5]
	EndIf
EndFunc   ;==>Stack_SetItemChange

; ===========================================================
; Stack_SetItemTotal($i, $sTotal)
; ===========================================================
Func Stack_SetItemTotal($i, $sTotal)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $sTotal)
		GUICtrlSetData($g_aStacks[$i][6], $data)
	EndIf
EndFunc   ;==>Stack_SetItemTotal

; ===========================================================
; Stack_SetItemAvailable($i, $sAvailable)
; ===========================================================
Func Stack_SetItemAvailable($i, $sAvailable)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $sAvailable)
		GUICtrlSetData($g_aStacks[$i][7], $data)
	EndIf
EndFunc   ;==>Stack_SetItemAvailable

; ===========================================================
; Stack_SetItemPending($i, $sPending)
; ===========================================================
Func Stack_SetItemPending($i, $sPending)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $sPending)
		GUICtrlSetData($g_aStacks[$i][8], $data)
	EndIf
EndFunc   ;==>Stack_SetItemPending

; ===========================================================
; Stack_SetItemBuyPrice($i, $sBuyPrice)
; ===========================================================
Func Stack_SetItemBuyPrice($i, $sBuyPrice)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $sBuyPrice)
		GUICtrlSetData($g_aStacks[$i][10], $data)
	EndIf
EndFunc   ;==>Stack_SetItemBuyPrice

; ===========================================================
; Stack_SetItemBuyWhen($i, $sBuyWhen)
; ===========================================================
Func Stack_SetItemBuyWhen($i, $sBuyWhen)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $sBuyWhen)
		GUICtrlSetData($g_aStacks[$i][11], $data)
	EndIf
EndFunc   ;==>Stack_SetItemBuyWhen

; ===========================================================
; Stack_SetItemBuyLimit($i, $sBuyLimit)
; ===========================================================
Func Stack_SetItemBuyLimit($i, $sBuyLimit)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $sBuyLimit)
		GUICtrlSetData($g_aStacks[$i][12], $data)
	EndIf
EndFunc   ;==>Stack_SetItemBuyLimit

; ===========================================================
; Stack_SetItemSellPrice($i, $sSellPrice)
; ===========================================================
Func Stack_SetItemSellPrice($i, $sSellPrice)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $sSellPrice)
		GUICtrlSetData($g_aStacks[$i][14], $data)
	EndIf
EndFunc   ;==>Stack_SetItemSellPrice

; ===========================================================
; Stack_SetItemSellWhen($i, $sSellWhen)
; ===========================================================
Func Stack_SetItemSellWhen($i, $sSellWhen)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $sSellWhen)
		GUICtrlSetData($g_aStacks[$i][15], $data)
	EndIf
EndFunc   ;==>Stack_SetItemSellWhen

; ===========================================================
; Stack_SetItemSellLimit($i, $sSellLimit)
; ===========================================================
Func Stack_SetItemSellLimit($i, $sSellLimit)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%10.5f", $sSellLimit)
		GUICtrlSetData($g_aStacks[$i][16], $data)
	EndIf
EndFunc   ;==>Stack_SetItemSellLimit

; ===========================================================
; Stack_SetItemProfit($i, $sProfit)
; ===========================================================
Func Stack_SetItemProfit($i, $sProfit)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%+5.2f%%", $sProfit)
		GUICtrlSetData($g_aStacks[$i][17], $data)
	EndIf
EndFunc   ;==>Stack_SetItemProfit

; ===========================================================
; Stack_GetItemProfitID($i)
; ===========================================================
Func Stack_GetItemProfitID($i)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Return $g_aStacks[$i][17]
	EndIf
EndFunc   ;==>Stack_SetItemProfit

; ===========================================================
; Stack_SetItemProfitLimit($i, $sProfitLimit)
; ===========================================================
Func Stack_SetItemProfitLimit($i, $sProfitLimit)
	If $i >= 0 And $i <= Stack_GetItemsCount() Then
		Local $data = StringFormat("%+5.2f%%", $sProfitLimit)
		GUICtrlSetData($g_aStacks[$i][19], $data)
	EndIf
EndFunc   ;==>Stack_SetItemProfitLimit

; ===========================================================
; Stack_SetDrawFunction($pFunction)
; ===========================================================
Func Stack_SetDrawFunction($pFunction)
	$g_pDrawFunction = $pFunction
EndFunc   ;==>Stack_SetDrawFunction

; ===========================================================
; Stack_SetUpdateFunction($pFunction)
; ===========================================================
Func Stack_SetUpdateFunction($pFunction)
	$g_pUpdateFunction = $pFunction
EndFunc
; ===========================================================
; Stack_RegisterEvent($hStack, $iEvent, $pCallback)
;	$GUI_EVENT_CLOSE - dialog box being closed (either by defined button or system menu).
;	$GUI_EVENT_MINIMIZE - dialog box minimized with Windows title bar button.
;	$GUI_EVENT_RESTORE - dialog box restored by click on task bar icon.
;	$GUI_EVENT_MAXIMIZE - dialog box maximized with Windows title bar button.
;	$GUI_EVENT_MOUSEMOVE - the mouse cursor has moved.
;	$GUI_EVENT_PRIMARYDOWN - the primary mouse button was pressed.
;	$GUI_EVENT_PRIMARYUP - the primary mouse button was released.
;	$GUI_EVENT_SECONDARYDOWN - the secondary mouse button was pressed.
;	$GUI_EVENT_SECONDARYUP - the secondary mouse button was released.
;	$GUI_EVENT_RESIZED - dialog box has been resized.
;	$GUI_EVENT_DROPPED - End of a Drag&Drop action @GUI_DragId, @GUI_DragFile and @GUI_DropId will be used to retrieve the ID's/file corresponding to the involve control.
; ===========================================================
Func Stack_RegisterEvent($hStack, $iEvent, $pCallback)
	GUISetOnEvent($iEvent, $pCallback, $hStack)
EndFunc   ;==>Stack_RegisterEvent

; ===========================================================
; Stack_onItemSelected()
; ===========================================================
Func Stack_onItemSelected()
	Debug("Stack_onItemSelected")
	For $i = 1 To UBound($g_aStacks) - 1
		If @GUI_WinHandle = $g_aStacks[$i][0] Then
			GUISetBkColor($g_iHIGHLIGHT, $g_aStacks[$i][0])
		Else
			GUISetBkColor($g_iBACKGROUND, $g_aStacks[$i][0])
		EndIf
	Next
EndFunc   ;==>Stack_onItemSelected

; ===========================================================
; Stack_onResized()
; ===========================================================
Func Stack_onResized()
	Debug("Stack_onResized")
	For $i = 1 To UBound($g_aStacks) - 1
		If @GUI_WinHandle = $g_aStacks[$i][0] Then
			Stack_SetItemHeight($i, Stack_GetItemHeight($i) * 2)
			ExitLoop
		EndIf
	Next
EndFunc   ;==>Stack_onResized

; ===========================================================
; Stack_onShowDetail()
; ===========================================================
Func Stack_onShowDetail()
	Debug("Stack_onShowDetail")
	For $i = 1 To UBound($g_aStacks) - 1
		If @GUI_WinHandle = $g_aStacks[$i][0] Then
			If Stack_GetItemHeight($i) = $g_iHeightDefault Then
				Stack_SetItemHeight($i, $g_iHeightDefault * 3)
			Else
				Stack_SetItemHeight($i, $g_iHeightDefault)
			EndIf
			ExitLoop
		EndIf
	Next
EndFunc   ;==>Stack_onShowDetail

; ===========================================================
; _IsChecked($idControlID)
; ===========================================================
Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

; ===========================================================
; Stack_onToggleAutoBuy()
; ===========================================================
Func Stack_onToggleAutoBuy()
	Debug("Stack_onToggleAutoBuy")
	For $i = 1 To UBound($g_aStacks) - 1
		If @GUI_WinHandle = $g_aStacks[$i][0] Then

			If _IsChecked($g_aStacks[$i][9]) Then
				GUICtrlSetColor($g_aStacks[$i][10], 0xFFFFFF)
				GUICtrlSetColor($g_aStacks[$i][11], 0xFFFFFF)
				GUICtrlSetColor($g_aStacks[$i][12], 0xFFFFFF)
			Else
				GUICtrlSetColor($g_aStacks[$i][10], $g_iDISABLED)
				GUICtrlSetColor($g_aStacks[$i][11], $g_iDISABLED)
				GUICtrlSetColor($g_aStacks[$i][12], $g_iDISABLED)
			EndIf
			ExitLoop
		EndIf
	Next
EndFunc   ;==>Stack_onToggleAutoBuy

; ===========================================================
; Stack_onToggleAutoSell()
; ===========================================================
Func Stack_onToggleAutoSell()
	Debug("Stack_onToggleAutoSell")
	For $i = 1 To UBound($g_aStacks) - 1
		If @GUI_WinHandle = $g_aStacks[$i][0] Then

			If _IsChecked($g_aStacks[$i][13]) Then
				GUICtrlSetColor($g_aStacks[$i][14], 0xFFFFFF)
				GUICtrlSetColor($g_aStacks[$i][15], 0xFFFFFF)
				GUICtrlSetColor($g_aStacks[$i][16], 0xFFFFFF)
			Else
				GUICtrlSetColor($g_aStacks[$i][14], $g_iDISABLED)
				GUICtrlSetColor($g_aStacks[$i][15], $g_iDISABLED)
				GUICtrlSetColor($g_aStacks[$i][16], $g_iDISABLED)
			EndIf
			ExitLoop
		EndIf
	Next
EndFunc   ;==>Stack_onToggleAutoSell

; ===========================================================
; Stack_onToggleProtectProfit()
; ===========================================================
Func Stack_onToggleProtectProfit()
	Debug("Stack_onToggleProtectProfit")
	For $i = 1 To UBound($g_aStacks) - 1
		If @GUI_WinHandle = $g_aStacks[$i][0] Then

			If _IsChecked($g_aStacks[$i][18]) Then
				GUICtrlSetColor($g_aStacks[$i][19], 0xFFFFFF)
			Else
				GUICtrlSetColor($g_aStacks[$i][19], $g_iDISABLED)
			EndIf
			ExitLoop
		EndIf
	Next
EndFunc   ;==>Stack_onToggleProtectProfit

; ===========================================================
; Stack_onDeleteItem()
; ===========================================================
Func Stack_onDeleteItem()
	Debug("Stack_onDeleteItem")
	For $i = 1 To UBound($g_aStacks) - 1
		If @GUI_WinHandle = $g_aStacks[$i][0] Then
			_ArrayDelete($g_aStacks, $i)
			If $g_pDrawFunction <> Null Then Call($g_pDrawFunction)
			ExitLoop
		EndIf
	Next
EndFunc   ;==>Stack_onToggleProtectProfit

; ==================================================================================
; Stack_CreateStack($title = "", $height = Default)
; ==================================================================================
Func Stack_CreateStack($title = "", $height = Default)
	Debug("Stack_CreateStack")
	If Stack_GetRootGUI() = Null Then
		Debug("No Root GUI")
		Return Null
	EndIf

	; Asset-Currency
	Local $sCurrencyAsset = StringSplit($title, "-")
	If @error Then
		Return
	EndIf

	If $height = Default Then $height = $g_iHeightDefault

	; create new window
	Local $hStack = GUICreate("", 0, 0, 0, 0, $WS_CHILD, -1, Stack_GetRootGUI())
	GUISetBkColor($g_iBACKGROUND, $hStack)
	Debug("$hStack = " & $hStack)

	; add it into list
	Local $itemCount = UBound($g_aStacks) + 1
	Debug("$itemCount = " & $itemCount)

	ReDim $g_aStacks[$itemCount][$g_iProperties]
	$g_aStacks[$itemCount - 1][0] = $hStack
	$g_aStacks[$itemCount - 1][1] = $title
	$g_aStacks[$itemCount - 1][2] = $height

	; register default event
	Stack_RegisterEvent($hStack, $GUI_EVENT_PRIMARYDOWN, "Stack_onItemSelected")

	;
	; Add component
	;
	Local $sAsset = GUICtrlCreateLabel($sCurrencyAsset[2], 2, 0, 52, 26, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 16, 700, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $sCurrency = GUICtrlCreateLabel($sCurrencyAsset[1], 2, 22, 52, 12, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)

	; !!!Remove stack button
	GUICtrlCreateLabel("X", 2, 38 + 2 + 6, 12, 12, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)
	GUICtrlSetOnEvent(-1, "Stack_onDeleteItem")

	; Current Price
	Local $sPrice = GUICtrlCreateLabel("-", 64, 0, 90, 26, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 700, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)
	$g_aStacks[$itemCount - 1][3] = $sPrice

	GUICtrlCreateLabel(">", 64 + 90 + 2, 0, 8, 26, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 700, 0, "Consolas")
	GUICtrlSetColor(-1, 0x35A1FF)
	GUICtrlSetOnEvent(-1, "Stack_onShowDetail")

	; Profit
	Local $sProfit = GUICtrlCreateLabel("-", 64, 22, 90, 12, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)
	$g_aStacks[$itemCount - 1][17] = $sProfit

	; Protect profit
	Local $sIsProtectProfit = GUICtrlCreateCheckbox("", 64, 38 + 2 + 6, 12, 12)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetOnEvent(-1, "Stack_onToggleProtectProfit")
	$g_aStacks[$itemCount - 1][18] = $sIsProtectProfit

	GUICtrlCreateLabel("auto sell if", 64 + 12 + 2, 38 + 2, 90, 12, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	GUICtrlCreateLabel("profit below", 64 + 12 + 2, 38 + 2 + 12, 90, 12, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $sProfitLimit = GUICtrlCreateLabel("-", 64, 38 + 2 + 12 + 12 + 2, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)
	$g_aStacks[$itemCount - 1][19] = $sProfitLimit

	; Change in 1h/12h/24h
	Local $sChangePeriod = GUICtrlCreateLabel("24H", 174, 2, 48, 14, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)
	$g_aStacks[$itemCount - 1][4] = $sChangePeriod

	Local $sChange = GUICtrlCreateLabel("-", 174, 16, 48, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iUPTREND)
	$g_aStacks[$itemCount - 1][5] = $sChange

	; Total assest
	GUICtrlCreateLabel("Total", 240, 2, 90, 14, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $sTotal = GUICtrlCreateLabel("-", 240, 16, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 700, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)
	$g_aStacks[$itemCount - 1][6] = $sTotal

	; Asset detail
	GUICtrlCreateLabel(">", 332, 16, 8, 20, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 700, 0, "Consolas")
	GUICtrlSetColor(-1, 0x35A1FF)
	GUICtrlSetOnEvent(-1, "Stack_onShowDetail")

	GUICtrlCreateLabel("available", 240, 38 + 2, 90, 14, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iUPTREND)

	Local $sAvailable = GUICtrlCreateLabel("-", 240, 38 + 16, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iUPTREND)
	$g_aStacks[$itemCount - 1][7] = $sAvailable

	GUICtrlCreateLabel("pending", 240, 38 + 38 + 2, 90, 14, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDOWNTREND)

	Local $sPending = GUICtrlCreateLabel("-", 240, 38 + 38 + 16, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDOWNTREND)
	$g_aStacks[$itemCount - 1][8] = $sPending

	; Auto Buy
	Local $sIsBuyAuto = GUICtrlCreateCheckbox("", 350, 2, 12, 12)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetOnEvent(-1, "Stack_onToggleAutoBuy")
	$g_aStacks[$itemCount - 1][9] = $sIsBuyAuto

	GUICtrlCreateLabel("Auto Buy", 350 + 12 + 2, 0, 64, 16, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $sBuyPrice = GUICtrlCreateLabel("-", 350, 16, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 700, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)
	$g_aStacks[$itemCount - 1][10] = $sBuyPrice

	GUICtrlCreateLabel(">", 442, 16, 8, 20, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 700, 0, "Consolas")
	GUICtrlSetColor(-1, 0x35A1FF)
	GUICtrlSetOnEvent(-1, "Stack_onShowDetail")

	GUICtrlCreateLabel("if down to", 350, 38 + 2, 90, 14, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $sBuyWhen = GUICtrlCreateLabel("-", 350, 38 + 16, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)
	$g_aStacks[$itemCount - 1][11] = $sBuyWhen

	GUICtrlCreateLabel("quantity", 350, 38 + 38 + 2, 90, 14, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $sBuyLimit = GUICtrlCreateLabel("-", 350, 38 + 38 + 16, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)
	$g_aStacks[$itemCount - 1][12] = $sBuyLimit

	; Auto Sell
	Local $sIsSellAuto = GUICtrlCreateCheckbox("", 460, 2, 12, 12)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetOnEvent(-1, "Stack_onToggleAutoSell")
	$g_aStacks[$itemCount - 1][13] = $sIsSellAuto

	GUICtrlCreateLabel("Auto Sell", 460 + 12 + 2, 0, 64, 16, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $sSellPrice = GUICtrlCreateLabel("-", 460, 16, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 700, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)
	$g_aStacks[$itemCount - 1][14] = $sSellPrice

	GUICtrlCreateLabel(">", 460 + 90 + 2, 16, 8, 20, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 700, 0, "Consolas")
	GUICtrlSetColor(-1, 0x35A1FF)
	GUICtrlSetOnEvent(-1, "Stack_onShowDetail")

	GUICtrlCreateLabel("if up to", 460, 38 + 2, 90, 14, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $sSellWhen = GUICtrlCreateLabel("-", 460, 38 + 16, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)
	$g_aStacks[$itemCount - 1][15] = $sSellWhen

	GUICtrlCreateLabel("quantity", 460, 38 + 38 + 2, 90, 14, BitOR($SS_LEFT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $sSellLimit = GUICtrlCreateLabel("-", 460, 38 + 38 + 16, 90, 20, BitOR($SS_RIGHT, $BS_CENTER), $UDF_WS_EX_STATICEDGE)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetFont(-1, 12, 400, 0, "Consolas")
	GUICtrlSetColor(-1, $g_iDISABLED)
	$g_aStacks[$itemCount - 1][16] = $sSellLimit

	; redraw stack
	If $g_pDrawFunction <> Null Then
		Call($g_pDrawFunction)
	EndIf

	; start update thread
	If $g_pUpdateFunction <> Null Then
		$g_aStacks[$itemCount - 1][20] = _Timer_SetTimer($hStack, 5000, $g_pUpdateFunction)
	EndIf

	; show it
	GUISetState(@SW_SHOW, $hStack)

	Return $hStack
EndFunc   ;==>Stack_CreateStack
