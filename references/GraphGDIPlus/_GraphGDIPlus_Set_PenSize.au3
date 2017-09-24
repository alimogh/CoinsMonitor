#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI

$hGUI = GUICreate("Толщина линии", 590, 320)
GUISetBkColor(0x99B598)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 45, 20, 530, 260, 0xFF000000, 0xFF1E3C48)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, -30, 30, 10, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, 0, 0.02, 4, 1, 3)

; Устанавливает сетку по осям XY
_GraphGDIPlus_Set_GridX($aGraph, 6, 0xFF67612F)
_GraphGDIPlus_Set_GridY($aGraph, 0.005, 0xFF67612F)

_GraphGDIPlus_Set_PenSize($aGraph, 4) ; Устанавливает толщину линии

; Рисует линию экспоненты
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
_GraphGDIPlus_Plot_Start($aGraph, -20, 1 / (70 + -20 ^ 2)) ; К началу графика
For $i = -20 To 20
	_GraphGDIPlus_Plot_Line($aGraph, $i, 1 / (70 + $i ^ 2))
Next
; Рисует точки экспоненты
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFFC44E)
For $i = -20 To 20
	_GraphGDIPlus_Plot_Point($aGraph, $i, 1 / (70 + $i ^ 2))
Next

GUISetState()
Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)