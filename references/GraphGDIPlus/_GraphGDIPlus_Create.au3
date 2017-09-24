#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI, $iMax = 12

$hGUI = GUICreate("Создаёт график", 590, 320)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFFCEE3E0)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, 0, 20, 10, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, 0, $iMax, 10, 1, 1)

; Устанавливает сетку по осям XY
_GraphGDIPlus_Set_GridX($aGraph, 1, 0xFF6993BE)
_GraphGDIPlus_Set_GridY($aGraph, $iMax / 10, 0xFF6993BE)

; Рисует график
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF339966) ; Задаёт цвет линии графика
_GraphGDIPlus_Plot_Start($aGraph, 0, 11) ; Задаёт начальную точку
_GraphGDIPlus_Plot_Line($aGraph, 20, 2) ; Задаёт следующую точку

GUISetState()
Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)