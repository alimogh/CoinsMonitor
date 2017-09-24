#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI, $iMax = 12

$hGUI = GUICreate("Цвет линий или точек", 590, 320)
GUISetBkColor(0xADADBD)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF000044)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, 0, 30, 10, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, 0, $iMax, 15, 1, 1)

; Устанавливает сетку по осям XY
_GraphGDIPlus_Set_GridX($aGraph, 1, 0xFF6C6342)
_GraphGDIPlus_Set_GridY($aGraph, $iMax / 15, 0xFF6C6342)

_GraphGDIPlus_Set_PenSize($aGraph, 4) ; Устанавливает толщину линии

; Рисует линии графика
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF00A880) ; Задаёт цвет линии графика
_GraphGDIPlus_Plot_Start($aGraph, 0, 2) ; Задаёт начальную точку
_GraphGDIPlus_Plot_Line($aGraph, 6, 4.8) ; Задаёт следующую точку
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
_GraphGDIPlus_Plot_Line($aGraph, 9, 3.2) ; Задаёт следующую точку
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF00A880)
_GraphGDIPlus_Plot_Line($aGraph, 13, 6.4) ; Задаёт следующую точку
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFCBB100)
_GraphGDIPlus_Plot_Line($aGraph, 15, 6.4) ; Задаёт следующую точку
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
_GraphGDIPlus_Plot_Line($aGraph, 21, 4.8) ; Задаёт следующую точку
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF00A880)
_GraphGDIPlus_Plot_Line($aGraph, 30, 11) ; Задаёт следующую точку

; Рисует точки графика
_GraphGDIPlus_Set_PenSize($aGraph, 18) ; Устанавливает толщину линии
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF00FF)
_GraphGDIPlus_Plot_Point($aGraph, 6, 4.8) ; Задаёт следующую точку
_GraphGDIPlus_Plot_Point($aGraph, 13, 6.4) ; Задаёт следующую точку

GUISetState()
Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)