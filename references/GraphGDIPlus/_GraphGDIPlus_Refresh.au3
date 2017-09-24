#include <GraphGDIPlus.au3>

Local Const $pi = 3.14159265358979
Local Const $iRad = $pi / 180
Local $aGraph, $hGUI

$hGUI = GUICreate("Обновление графика", 590, 320)
GUISetBkColor(0x999980)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1B1B1B)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, -270, 270, 12, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, -1.5, 1.5, 12, 1, 1)

GUISetState()

; Рисует синусоиду
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFCBB100)

_GraphGDIPlus_Plot_Start($aGraph, -270, Cos(-270)) ; К началу графика
For $i = -270 To 270 Step 10
	_GraphGDIPlus_Plot_Line($aGraph, $i, (270 - $i) / 540 * Cos($i * $iRad))
	_GraphGDIPlus_Refresh($aGraph)
	Sleep(30)
Next

For $j = 1 To 60
	_GraphGDIPlus_Plot_Start($aGraph, -270, (270 - $i) / 540 * Cos($j / 5)) ; К началу графика
	For $i = -270 To 270 Step 10
		_GraphGDIPlus_Plot_Line($aGraph, $i, (270 - $i) / 540 * Cos($i * $iRad - $j / 5))
	Next
	_GraphGDIPlus_Refresh($aGraph)
	Sleep(10)
	If $j < 60 Then _GraphGDIPlus_Clear($aGraph)
Next

Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)