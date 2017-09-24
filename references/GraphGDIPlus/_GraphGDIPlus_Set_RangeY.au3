#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI

$hGUI = GUICreate("Создаёт шкалу на оси Y", 590, 320)
GUISetBkColor(0x999980)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1B1B1B)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, -15, 15, 10, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, -6, 6, 6, 1, 0)

; Рисует оси координат
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF555555) ; Задаёт цвет линии
_GraphGDIPlus_Plot_Start($aGraph, 0, -6) ; Задаёт начальную точку
_GraphGDIPlus_Plot_Line($aGraph, 0, 6) ; Задаёт следующую точку
_GraphGDIPlus_Plot_Start($aGraph, -15, 0) ; Задаёт начальную точку
_GraphGDIPlus_Plot_Line($aGraph, 15, 0) ; Задаёт следующую точку

; Рисует циклоиду жёлтую
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF008CFF)
_GraphGDIPlus_Plot_Start($aGraph, -15, -4) ; К началу графика
For $i = -30 To 30
	_GraphGDIPlus_Plot_Line($aGraph, $i/2, 3 * ATan($i * 1/3))
	_GraphGDIPlus_Plot_Point($aGraph, $i/2, 3 * ATan($i * 1/3))
Next

GUISetState()
Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)