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
	#AutoIt3Wrapper_Outfile=binary\CoinAlert.exe
	#AutoIt3Wrapper_Compression=4
	#AutoIt3Wrapper_UseX64=y
	#AutoIt3Wrapper_Res_Comment=CoinAlert
	#AutoIt3Wrapper_Res_Description=CoinAlert
	#AutoIt3Wrapper_Res_Fileversion=0.0.0.1
	#AutoIt3Wrapper_Res_ProductVersion=0.0.0.1
	#AutoIt3Wrapper_Res_LegalCopyright=Vu Quang Trong
	#AutoIt3Wrapper_Res_Language=1033
	#AutoIt3Wrapper_Res_Field=ProductName|CoinAlert
	#AutoIt3Wrapper_Res_Field=OriginalFilename|CoinAlert.exe
	#AutoIt3Wrapper_Res_Field=CompanyName|N/A
	#AutoIt3Wrapper_Run_AU3Check=y
	#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
	#AutoIt3Wrapper_AU3Check_Parameters=-d -w 4 -w 6
	#AutoIt3Wrapper_Run_Tidy=y
	#Tidy_Parameters=/reel /ri /sci 9

#EndRegion ========== DIRECTIVES  ==========

#cs ========== FEATURE ==========

	* Add your favorite coins
	* Update the prices of coins in realtime in adjustable interval
	* Popup alert if price goes up or down to a threashold vaule
	* Coins are grouped in group in listview
	* Edit value in-place of listview item

#ce

#cs ========== CHANGE LOG ==========

	Note:
	Change $APP_VER when version's changed. i.e: 1.0.0.9 -> 9
	Do not use sub-number bigger than 9. i.e: 1.0.0.9 -> 1.0.1.0, not 1.0.0.10

	Log:

	DEV		0.0.0.0		20/09/2017		20:00
	* 	Initialize file

	DEV		0.0.0.1		25/09/2017		16:00
	+	Add markets, only support Bittrex
	+ 	Update the price of markets, and alert when the price is down to/ up to a set value
	+ 	Show alert popup, the number of popups can be limited. Click on popups to dimiss them.
	+	Sound beep when showing alert is optional
	+ 	Edit/Delete price with mouse click
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

; Use event mode
Opt("GUIOnEventMode", 1)

; To prevent issues
Opt("MustDeclareVars", 1)

; Hotkeys and startup/shutdown callback
OnAutoItExitRegister("__OnExit")

; Type
Global Const $TYPE_NONE = 0x0
Global Const $TYPE_LESS = 0x1
Global Const $TYPE_MORE = 0x2

; Window List
Global $g_aWindowsList[1]
Global $g_bBeep = True
Global $g_iNotificationMax = 10
Global $g_iUpdateTime = 2
Global $g_bMonitoring = False

#Region MAIN GUI
	Global $g_guiMain = GUICreate("CoinAlert", 400, 640)
	GUISetOnEvent($GUI_EVENT_CLOSE, "OnWindowClose")
	GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "OnMouseClick")
	GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, "OnMouseClick")
	$g_aWindowsList[0] = $g_guiMain

	#Region GROUP SELECTION
		Global $g_grSelection = GUICtrlCreateGroup("Selection", 8, 8, 213, 150)
		Global $g_cbMarket = GUICtrlCreateCombo("", 16, 32, 200, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
		GUICtrlSetOnEvent(-1, "OnMarketSelected")

		Global $g_rdMore = GUICtrlCreateRadio("  Upto", 16, 64, 75, 17)

		Global $g_rdLess = GUICtrlCreateRadio("Downto", 16, 88, 75, 17)
		GUICtrlSetState(-1, $GUI_CHECKED)

		Global $g_txtPrice = GUICtrlCreateInput("0.000", 96, 72, 120, 21)

		Global $g_btnReset = GUICtrlCreateButton("Reset", 40, 120, 60, 25)
		GUICtrlSetOnEvent(-1, "OnResetPressed")

		Global $g_btnAdd = GUICtrlCreateButton("Add", 136, 120, 60, 25)
		GUICtrlSetOnEvent(-1, "OnAddPressed")

	#EndRegion GROUP SELECTION

	#Region NOTIFICATION
		Global $g_grNotification = GUICtrlCreateGroup("Notification", 224, 8, 168, 150)

		GUICtrlCreateLabel("Update time (s):", 8 + 218 + 1 + 8, 32, 120, 25)
		Global $g_txtUpdateTime = GUICtrlCreateInput($g_iUpdateTime, 328, 32, 48, 25)
		GUICtrlSetOnEvent(-1, "OnUpdateTimeEdited")

		Global $g_btnUpdateTimeUpDown = GUICtrlCreateUpdown($g_txtUpdateTime)
		GUICtrlSetOnEvent(-1, "OnUpdateTimeEdited")

		Global $g_cbBeep = GUICtrlCreateCheckbox("Beep", 8 + 218 + 1 + 8, 32 + 25, 132, 25)
		GUICtrlSetOnEvent(-1, "OnBeepSelected")
		GUICtrlSetState(-1, $g_bBeep ? $GUI_CHECKED : $GUI_UNCHECKED)

		GUICtrlCreateLabel("Notification Max:", 8 + 218 + 1 + 8, 72 + 18, 120, 25)

		Global $g_txtNotification = GUICtrlCreateInput($g_iNotificationMax, 8 + 218 + 1 + 8 + 96, 68 + 18, 48, 25)
		GUICtrlSetOnEvent(-1, "OnNotificationEdited")

		Global $g_btnNotificationUpDown = GUICtrlCreateUpdown($g_txtNotification)
		GUICtrlSetOnEvent(-1, "OnNotificationEdited")

		Global $g_btnWatch = GUICtrlCreateButton("Watch", 8 + 218 + 1 + 8, 120, 144, 25)
		GUICtrlSetOnEvent(-1, "OnWatchPressed")

		GUICtrlCreateGroup("", -99, -99, 1, 1)
	#EndRegion NOTIFICATION

	; Main List View
	Global $g_WatchList = GUICtrlCreateListView("", 8, 150 + 10, 400 - 16, 800 - 152 - 18)
	_GUICtrlListView_SetExtendedListViewStyle($g_WatchList, BitOR($LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER, $LVS_EX_FULLROWSELECT))

	_GUICtrlListView_EnableGroupView($g_WatchList)
	Global $iGroupID = 0

	; Below code for direct edit with mouse click on listview
	Global $hGui = $g_guiMain, $iItem = -1, $iSubItem = 0, $aRect
	Global $hEdit, $idEditOpen, $idEditClose, $bEditOpen = False, $bDoNotOpenControl = False, $bEditEscape = False
	Global $hListView = GUICtrlGetHandle($g_WatchList)
	; Open Edit control on double or single click
	Global $bEditOpenOnDoubleClick = True

	; Add 3 columns
	Global $aColLeftEdgePosAcc[3]
	Global $aColumnWidths[3]

	_GUICtrlListView_AddColumn($hListView, "Type", 48)
	$aColLeftEdgePosAcc[0] = 0
	$aColumnWidths[0] = 48

	_GUICtrlListView_AddColumn($hListView, "Price", 165)
	$aColLeftEdgePosAcc[2] = 48
	$aColumnWidths[1] = 165

	_GUICtrlListView_AddColumn($hListView, "Offset", 165)
	$aColLeftEdgePosAcc[2] = 48 + 165
	$aColumnWidths[2] = 165

	Global $aColumnOrder = _GUICtrlListView_GetColumnOrderArray($hListView)

	; Edit control open and close events
	$idEditOpen = GUICtrlCreateDummy()
	GUICtrlSetOnEvent(-1, "OnEditOpened")

	$idEditClose = GUICtrlCreateDummy()
	GUICtrlSetOnEvent(-1, "OnEditClosed")

	; Handle WM_NOTIFY messages for the ListView
	; Open Edit control on click/double click
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

	; Subclass callback functions
	Global $pListViewCallback = DllCallbackGetPtr(DllCallbackRegister("ListViewCallback", "lresult", "hwnd;uint;wparam;lparam;uint_ptr;dword_ptr"))
	Global $pEditCallback = DllCallbackGetPtr(DllCallbackRegister("EditCallback", "lresult", "hwnd;uint;wparam;lparam;uint_ptr;dword_ptr"))
	Global $pGuiCallback = DllCallbackGetPtr(DllCallbackRegister("GuiCallback", "lresult", "hwnd;uint;wparam;lparam;uint_ptr;dword_ptr"))

	; Subclass ListView to handle messages related to Edit control
	_WinAPI_SetWindowSubclass($hListView, $pListViewCallback, 9998, 0)

	Global Enum $idDelete = 1000

#EndRegion MAIN GUI
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
	; WatchList
	Local $iGroupCount
	Local $aGroupInfo
	Local $aGroupPrice[255][2]
	Local $iItemCount
	Local $aItemType
	Local $aItemPrice
	Local $aItemOldOffset
	Local $aItemNewOffset
	Local $aItemGroup

	; create debug file
	Debug_init("CoinAlert")
	Debug("START")

	; Bittrex start
	bittrex_openConnection()

	If FileExists(@ScriptDir & "\markets.txt") Then
		GUICtrlSetData($g_cbMarket, FileRead(@ScriptDir & "\markets.txt"))
	Else
		GUICtrlSetData($g_cbMarket, "<< New >>")
	EndIf

	; Show UI
	GUISetState(@SW_SHOW, $g_guiMain)

	; Main Loop
	While (True)

		If $g_bBeep And (UBound($g_aWindowsList) > 1) Then

			For $i = 0 To $g_iUpdateTime
				Beep(2000, 500)
				Sleep(500)
			Next
			; Sleep($g_iUpdateTime * 1000 - 500)
		Else
			Sleep($g_iUpdateTime * 1000)
		EndIf

		If (UBound($g_aWindowsList) - 1 > $g_iNotificationMax) Then
			RemovePopup($g_aWindowsList[1])
		EndIf

		Debug(".")

		If ($g_bMonitoring) Then
			; find group of market
			$iGroupCount = _GUICtrlListView_GetGroupCount($g_WatchList)
			Debug("Found " & $iGroupCount & " market")

			For $i = 0 To $iGroupCount - 1
				$aGroupInfo = _GUICtrlListView_GetGroupInfoByIndex($g_WatchList, $i)
				; get market and save price
				$aGroupPrice[$i][0] = StringLeft($aGroupInfo[0], StringInStr($aGroupInfo[0], ":") - 1)
				$aGroupPrice[$i][1] = bittrex_getTicker($aGroupPrice[$i][0])
				_GUICtrlListView_SetGroupInfo($g_WatchList, $i, $aGroupPrice[$i][0] & ": " & StringFormat("%.8f", $aGroupPrice[$i][1]))
				Sleep(200)
			Next

			; assert all items
			$iItemCount = _GUICtrlListView_GetItemCount($g_WatchList)
			Debug("Found " & $iItemCount & " items")

			For $i = 0 To $iItemCount - 1
				If _GUICtrlListView_GetItemChecked($g_WatchList, $i) Then

					$aItemGroup = _GUICtrlListView_GetItemGroupID($g_WatchList, $i)
					$aItemType = _GUICtrlListView_GetItem($g_WatchList, $i)[3]
					$aItemPrice = _GUICtrlListView_GetItem($g_WatchList, $i, 1)[3]
					$aItemOldOffset = _GUICtrlListView_GetItem($g_WatchList, $i, 2)[3]
					$aItemNewOffset = Number($aItemPrice) - Number($aGroupPrice[$aItemGroup][1])

					Debug("$i = " & $i & " $aItemType = " & $aItemType & " $aItemPrice = " & $aItemPrice & " $aItemOldOffset = " & $aItemOldOffset & " currentPrice = " & $aGroupPrice[$aItemGroup][1] & " $aItemNewOffset = " & $aItemNewOffset)

					_GUICtrlListView_SetItem($g_WatchList, StringFormat("%.8f", $aItemNewOffset), $i, 2)

					If ($aItemType == ">=" And Number($aItemOldOffset) > 0 And Number($aItemNewOffset) <= 0) Then
						Debug("ALERT!!! " & $aGroupPrice[$aItemGroup][0] & " more than " & $aItemPrice)
						PopupAlert($aGroupPrice[$aItemGroup][0] & " more than " & StringFormat("%.8f", $aItemPrice))

					ElseIf ($aItemType == "<=" And Number($aItemOldOffset) < 0 And Number($aItemNewOffset) >= 0) Then
						Debug("ALERT!!! " & $aGroupPrice[$aItemGroup][0] & " less than " & $aItemPrice)
						PopupAlert($aGroupPrice[$aItemGroup][0] & " less than " & StringFormat("%.8f", $aItemPrice))

					EndIf
				EndIf
			Next

		EndIf

	WEnd
EndFunc   ;==>Main

; ===========================================================
; ListView_RClick()
; ===========================================================
Func ListView_RClick()
	Local $aHit
	Local $hMenu

	$aHit = _GUICtrlListView_SubItemHitTest($hListView)
	If ($aHit[0] <> -1) Then
		; Create a standard popup menu
		$hMenu = _GUICtrlMenu_CreatePopup()
		_GUICtrlMenu_AddMenuItem($hMenu, "Delete", $idDelete)

		; capture the context menu selections
		Switch _GUICtrlMenu_TrackPopupMenu($hMenu, $hListView, -1, -1, 1, 1, 2)
			Case $idDelete
				Debug("$idDelete: " & StringFormat("Item, SubItem [%d, %d]", $aHit[0], $aHit[1]))
				_GUICtrlListView_DeleteItem($g_WatchList, $aHit[0]) ; If a group has no item, it's deleted automatically
		EndSwitch
		_GUICtrlMenu_DestroyMenu($hMenu)
	EndIf
EndFunc   ;==>ListView_RClick

; ===========================================================
; PopupAlert($sNotice)
; ===========================================================
Func PopupAlert($sNotice)

	If (UBound($g_aWindowsList) > $g_iNotificationMax) Then
		RemovePopup($g_aWindowsList[1])
	EndIf

	Local $hWnd = GUICreate("", 320, 32, @DesktopWidth - 320, @DesktopHeight - (UBound($g_aWindowsList) + 1) * 32, $WS_POPUPWINDOW, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
	Local $hLabel = GUICtrlCreateLabel($sNotice, 8, 0, 320, 32, $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, 12, 600, 0, "")
	GUICtrlSetOnEvent(-1, "OnPopupClicked")

	If StringInStr($sNotice, "more") Then
		GUICtrlSetColor($hLabel, 0x0000FF)
	Else
		GUICtrlSetColor($hLabel, 0xFF0000)
	EndIf

	; show the popup, but do not focus on it
	GUISetState(@SW_SHOWNOACTIVATE, $hWnd)

	_ArrayAdd($g_aWindowsList, $hWnd)

EndFunc   ;==>PopupAlert

; ===========================================================
; OnBeepSelected
; ===========================================================
Func OnBeepSelected()
	Debug("OnBeepSelected()")
	$g_bBeep = (GUICtrlRead($g_cbBeep) = $GUI_CHECKED)
	Debug("$g_cbBeep = " & $g_bBeep)
EndFunc   ;==>OnBeepSelected

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
; OnNotificationEdited
; ===========================================================
Func OnNotificationEdited()
	Debug("OnNotificactionEdited()")
	$g_iNotificationMax = Number(GUICtrlRead($g_txtNotification))
	If $g_iNotificationMax < 10 Then
		$g_iNotificationMax = 10
		GUICtrlSetData($g_txtNotification, $g_iNotificationMax)
	EndIf
	Debug("$g_iNotificationMax = " & $g_iNotificationMax)
EndFunc   ;==>OnNotificationEdited

; ===========================================================
; OnWatchPressed
; ===========================================================
Func OnWatchPressed()
	Debug("OnWatchPressed()")
	If ($g_bMonitoring) Then
		$g_bMonitoring = False
		GUICtrlSetData($g_btnWatch, "Watch")
		GUICtrlSetColor($g_btnWatch, 0x0000FF)
		$g_iNotificationMax = 0
	Else
		GUICtrlSetData($g_btnWatch, "Stop")
		GUICtrlSetColor($g_btnWatch, 0xFF0000)
		$g_iNotificationMax = Number(GUICtrlRead($g_txtNotification))
		$g_bMonitoring = True
	EndIf
EndFunc   ;==>OnWatchPressed

; ===========================================================
; OnMarketSelected
; ===========================================================
Func OnMarketSelected()
	Debug("OnMarketSelected()")
	If (GUICtrlRead($g_cbMarket) == "<< New >>") Then
		Local $newMarket = InputBox("Add new market", "You can add new market on Bittrex here", "BTC-")
		If IsMarket($newMarket) Then
			GUICtrlSetData($g_cbMarket, $newMarket)
			Debug("Added market: " & $newMarket)
			Local $fMarket = FileOpen(@ScriptDir & "\markets.txt", $FO_OVERWRITE)
			FileWrite($fMarket, _GUICtrlComboBox_GetList($g_cbMarket))
			FileClose($fMarket)
		EndIf
	EndIf

	; load the current price
	GUICtrlSetData($g_txtPrice, StringFormat("%.8f", bittrex_getTicker(GUICtrlRead($g_cbMarket))))

EndFunc   ;==>OnMarketSelected

; ===========================================================
; IsMarket
; ===========================================================
Func IsMarket($sMarketName)
	If IsMarket <> "" Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>IsMarket

; ===========================================================
; OnResetPressed
; ===========================================================
Func OnResetPressed()
	Debug("OnResetPressed()")
	GUICtrlSetState($g_rdMore, $GUI_UNCHECKED)
	GUICtrlSetState($g_rdLess, $GUI_UNCHECKED)
	GUICtrlSetData($g_txtPrice, "")
EndFunc   ;==>OnResetPressed

; ===========================================================
; RemovePopup
; ===========================================================
Func RemovePopup($hWnd)
	Debug("RemovePopup()")
	GUIDelete($hWnd)
	_ArrayDelete($g_aWindowsList, String(_ArraySearch($g_aWindowsList, $hWnd)))
	Debug("Number of windows = " & UBound($g_aWindowsList))
	For $i = 1 To UBound($g_aWindowsList) - 1
		WinMove($g_aWindowsList[$i], "", @DesktopWidth - 320, @DesktopHeight - ($i + 1) * 32)
	Next
EndFunc   ;==>RemovePopup

; ===========================================================
; OnPopupClicked
; ===========================================================
Func OnPopupClicked()
	Debug("OnPopupClicked()")
	Debug("Delete Child window: " & @GUI_WinHandle)
	RemovePopup(@GUI_WinHandle)
EndFunc   ;==>OnPopupClicked

; ===========================================================
; OnAddPressed
; ===========================================================
Func OnAddPressed()

	Debug("OnAddPressed()")

	; create a watch item
	Local $market = GUICtrlRead($g_cbMarket)
	Local $type = BitOR(BitAND(GUICtrlRead($g_rdMore), $GUI_CHECKED) * 2, BitAND(GUICtrlRead($g_rdLess), $GUI_CHECKED))
	Local $price = Number(GUICtrlRead($g_txtPrice))

	; check new item
	If $market == "" Then
		MsgBox(0, "Warning", "Please select a market", 5000)
		Return
	EndIf

	If $type = $TYPE_NONE Then
		MsgBox(0, "Warning", "Please choose a type of signal: MORE or LESS", 5000)
		Return
	EndIf

	If $price = 0 Then
		MsgBox(0, "Warning", "Please fill correct number as watching price", 5000)
		Return
	EndIf

	; find group of market
	Local $iGroupCount = _GUICtrlListView_GetGroupCount($g_WatchList)
	Local $aGroupInfo
	Local $bGroupFound = False
	For $i = 0 To $iGroupCount - 1
		$aGroupInfo = _GUICtrlListView_GetGroupInfoByIndex($g_WatchList, $i)

		; found group
		If StringInStr($aGroupInfo[0], $market) Then
			$bGroupFound = True
			ExitLoop
		EndIf
	Next

	Local $newItem = _GUICtrlListView_AddItem($g_WatchList, ($type = $TYPE_MORE) ? ">=" : "<=")
	_GUICtrlListView_AddSubItem($g_WatchList, $newItem, StringFormat("%.8f", $price), 1)
	_GUICtrlListView_AddSubItem($g_WatchList, $newItem, "-", 2)
	_GUICtrlListView_SetItemChecked($g_WatchList, $newItem)

	If $bGroupFound Then
		_GUICtrlListView_SetItemGroupID($g_WatchList, $newItem, $aGroupInfo[2])
	Else
		_GUICtrlListView_InsertGroup($g_WatchList, -1, $iGroupID, $market & ": -")
		_GUICtrlListView_SetItemGroupID($g_WatchList, $newItem, $iGroupID)
		$iGroupID += 1
	EndIf

EndFunc   ;==>OnAddPressed

; ===========================================================
; OnWindowClose
; ===========================================================
Func OnWindowClose()
	Debug("OnWindowClose()")
	If @GUI_WinHandle = $g_guiMain Then
		Debug("Delete Main window: " & $g_guiMain)
		$bEditEscape = False
		_WinAPI_RemoveWindowSubclass($hListView, $pListViewCallback, 9998)
		Exit
	Else
		Debug("Delete Child window: " & @GUI_WinHandle)
		GUIDelete(@GUI_WinHandle)
	EndIf
EndFunc   ;==>OnWindowClose

; ===========================================================
; OnMouseClick
; ===========================================================
Func OnMouseClick()
	Debug("OnMouseClick()")
	If @GUI_WinHandle = $g_guiMain Then
		If Not $bEditOpen Then Return
		; Clicks in Edit control itself should not delete it
		Local $aPos = MouseGetWindowPos($hListView)
		If Not ($aPos[0] > $aRect[0] And $aPos[0] < $aRect[2] And $aPos[1] > $aRect[1] And $aPos[1] < $aRect[1] + 20) Then _
				GUICtrlSendToDummy($idEditClose) ; Delete Edit control
	EndIf
EndFunc   ;==>OnMouseClick

; ===========================================================
; OnEditOpened
; ===========================================================
Func OnEditOpened()
	Debug("OnEditOpened()")
	If $bEditOpen Then
		; If another Edit control is open then delete it
		_WinAPI_RemoveWindowSubclass($hEdit, $pEditCallback, 9999)
		_WinAPI_RemoveWindowSubclass($hGui, $pGuiCallback, 9999)
		_GUICtrlEdit_Destroy($hEdit)
	EndIf
	; Create Edit control
	; Do not open control if the column is too narrow
	If $aColumnWidths[$iSubItem] < 20 Then Return ; UDF => Error message
	; Make column visible if column is only partially visible along left or right edge of the ListView
	Local $iCtrlWidth = MakeColumnVisible($hListView, $iSubItem, $aRect, $iItem)
	$hEdit = _GUICtrlEdit_Create($hListView, "", $aRect[0], $aRect[1], $iCtrlWidth, 20, $ES_AUTOHSCROLL)
	_GUICtrlEdit_SetText($hEdit, _GUICtrlListView_GetItemText($hListView, $iItem, $iSubItem))
	_GUICtrlEdit_SetSel($hEdit, 0, -1)
	; Create subclasses to handle Windows messages
	_WinAPI_SetWindowSubclass($hEdit, $pEditCallback, 9999, 0) ; Handle messages from the Edit control
	_WinAPI_SetWindowSubclass($hGui, $pGuiCallback, 9999, 0) ; Handle GUI messages related to Edit control
	; Set focus to Edit control                                  ; Subclasses are used only when Edit control is open
	_WinAPI_SetFocus($hEdit)
	$bEditOpen = True
EndFunc   ;==>OnEditOpened

; ===========================================================
; OnEditClosed
; ===========================================================
Func OnEditClosed()
	Debug("OnEditClosed()")
	If Not $bEditOpen Then Return
	If GUICtrlRead($idEditClose) Then _ ; Save value from Edit control in ListView item/subitem text
			_GUICtrlListView_SetItemText($hListView, $iItem, _GUICtrlEdit_GetText($hEdit), $iSubItem)
	; Delete Edit control
	_WinAPI_RemoveWindowSubclass($hEdit, $pEditCallback, 9999)
	_WinAPI_RemoveWindowSubclass($hGui, $pGuiCallback, 9999)
	_GUICtrlEdit_Destroy($hEdit)
	$bEditOpen = False
EndFunc   ;==>OnEditClosed

; ===========================================================
; WM_NOTIFY
; ===========================================================
; Open Edit control on click/double click
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hListView
			Switch $iCode
				Case $NM_CLICK
					If Not $bDoNotOpenControl And Not $bEditOpenOnDoubleClick And $iItem > -1 And $iSubItem > -1 Then _
							GUICtrlSendToDummy($idEditOpen) ; Send message to open Edit control
				Case $NM_DBLCLK
					If $bEditOpenOnDoubleClick And $iItem > -1 And $iSubItem > -1 Then _
							GUICtrlSendToDummy($idEditOpen) ; Send message to open Edit control
				Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
					ListView_RClick()
					Return 0
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
	#forceref $hWnd, $iMsg, $wParam
EndFunc   ;==>WM_NOTIFY

; ===========================================================
; ListViewCallback
; ===========================================================
; Handle ListView messages related to Edit control
Func ListViewCallback($hWnd, $iMsg, $wParam, $lParam, $iSubclassId, $pData)
	Switch $iMsg
		; Manage multiple selections
		; Prevent Edit control from opening
		Case $WM_KEYDOWN
			Switch $wParam
				Case $VK_SHIFT, $VK_CONTROL
					$bDoNotOpenControl = True
			EndSwitch
		Case $WM_KEYUP
			Switch $wParam
				Case $VK_SHIFT, $VK_CONTROL
					$bDoNotOpenControl = False
			EndSwitch

			; Left click in ListView
			; Sent on single and double click
			; Determines item/subitem of the cell that's clicked
		Case $WM_LBUTTONDOWN
			Local $aHit = _GUICtrlListView_SubItemHitTest($hListView)
			$iItem = $aHit[0]
			$iSubItem = $aHit[1]
			If $bEditOpen Then
				; If another Edit control is open then delete it
				_GUICtrlEdit_Destroy($hEdit)
				GUICtrlSendToDummy($idEditClose)
			EndIf
			If $iItem > -1 And $iSubItem = 1 Then
				; Pos and size of ListView cell determines pos and size of Edit control
				If $iSubItem Then
					$aRect = _GUICtrlListView_GetSubItemRect($hListView, $iItem, $iSubItem)
				Else
					$aRect = _GUICtrlListView_GetItemRect($hListView, $iItem, 2) ; 2 - The bounding rectangle of the item text
					$aRect[0] -= 4
				EndIf
			EndIf

			; Delete the Edit control on right click in ListView and on
			; left or right click in non-client ListView area (Scrollbars).
		Case $WM_RBUTTONDOWN, $WM_NCLBUTTONDOWN, $WM_NCRBUTTONDOWN
			_GUICtrlEdit_Destroy($hEdit)
			GUICtrlSendToDummy($idEditClose)
	EndSwitch

	; Call next function in subclass chain
	Return DllCall("comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)[0]
	#forceref $iSubclassId, $pData
EndFunc   ;==>ListViewCallback

; ===========================================================
; EditCallback
; ===========================================================
; Handle messages from the Edit control
Func EditCallback($hWnd, $iMsg, $wParam, $lParam, $iSubclassId, $pData)
	Switch $iMsg
		; Dialog codes
		Case $WM_GETDLGCODE
			Switch $wParam
				Case $VK_TAB ; Close
					GUICtrlSendToDummy($idEditClose)
				Case $VK_RETURN ; Accept and close
					GUICtrlSendToDummy($idEditClose, True)
				Case $VK_ESCAPE ; Close
					GUICtrlSendToDummy($idEditClose)
					$bEditEscape = True
			EndSwitch

			; Double click in Edit control
		Case $WM_LBUTTONDBLCLK
			GUICtrlSendToDummy($idEditClose, True)
	EndSwitch

	; Call next function in subclass chain
	Return DllCall("comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)[0]
	#forceref $iSubclassId, $pData
EndFunc   ;==>EditCallback

; ===========================================================
; GuiCallback
; ===========================================================
; Handle GUI messages related to Edit control
Func GuiCallback($hWnd, $iMsg, $wParam, $lParam, $iSubclassId, $pData)
	Switch $iMsg
		; Delete Edit control on left or right mouse click in non-client GUI area and on GUI deactivate
		Case $WM_NCLBUTTONDOWN, $WM_NCRBUTTONDOWN, $WM_ACTIVATE
			_GUICtrlEdit_Destroy($hEdit)
			GUICtrlSendToDummy($idEditClose)
	EndSwitch

	; Call next function in subclass chain
	Return DllCall("comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam)[0]
	#forceref $iSubclassId, $pData
EndFunc   ;==>GuiCallback

; ===========================================================
; __OnExit
; ===========================================================
Func __OnExit()

	bittrex_closeConnection()

	; actual exit
	Exit 0

EndFunc   ;==>__OnExit

