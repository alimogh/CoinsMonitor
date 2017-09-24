#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI, $iMax = 12

$hGUI = GUICreate("График из точек", 590, 320)
GUISetBkColor(0x999980)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1B1B1B)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, 0, 30, 10, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, 0, $iMax, 15, 1, 1)

; Устанавливает сетку по осям XY
_GraphGDIPlus_Set_GridX($aGraph, 1, 0xFF6C6342)
_GraphGDIPlus_Set_GridY($aGraph, $iMax / 15, 0xFF6C6342)

; Рисует график
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF00FFFF) ; Задаёт цвет линии графика
For $i = 0 To 30
	_GraphGDIPlus_Plot_Point($aGraph, $i, $i / 3 + 1.5) ; Задаёт следующую точку
Next

; Рисует синусоиду
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFCBB100)
_GraphGDIPlus_Plot_Start($aGraph, 0, $iMax - 5) ; К началу графика
For $i = 1 To 60
	_GraphGDIPlus_Plot_Line($aGraph, $i/2, ($iMax - 9) * Cos($i * 1/6) + 4)
Next
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF78F900)
For $i = 0 To 60
	_GraphGDIPlus_Plot_Point($aGraph, $i/2, ($iMax - 9) * Cos($i * 1/6) + 4)
Next

; Рисует экспоненту
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
_GraphGDIPlus_Plot_Start($aGraph, 0, $iMax) ; К началу графика
For $i = 1 To 30
	_GraphGDIPlus_Plot_Line($aGraph, $i, $iMax * Exp(- $i / 6))
	_GraphGDIPlus_Plot_Point($aGraph, $i, $iMax * Exp(- $i / 6))
Next

GUISetState()
Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)