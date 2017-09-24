#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI

$hGUI = GUICreate("Удаляет график", 590, 320)
GUISetBkColor(0x999980)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1B1B1B)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, -12, 12, 12, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, -4, 4, 12, 1, 1)

; Рисует цикл
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF0099)
_GraphGDIPlus_Plot_Start($aGraph, -12, 0) ; К началу графика
For $i = -12 To 12
	$iSin = ($i - 2 * Floor(($i + 1) / 2)) * (-1) ^ Floor(($i + 1) / 2) ; Треугольный
	_GraphGDIPlus_Plot_Line($aGraph, $i, $iSin)
Next

; Рисует график
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF00A880) ; Задаёт цвет линии графика
_GraphGDIPlus_Plot_Start($aGraph, -12, -3) ; Задаёт начальную точку
_GraphGDIPlus_Plot_Line($aGraph, 12, 3) ; Задаёт следующую точку

GUISetState()

MsgBox(0, 'Сообщение', 'Удаляет график')
; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)

Do
Until GUIGetMsg() = -3