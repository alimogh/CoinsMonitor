#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI, $iMax = 12

$hGUI = GUICreate("Тип штрихпунктира", 590, 320)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFFF4F6CE)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, 0, 30, 10, 1) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, 0, $iMax, 4, 1)

; Устанавливает сетку по осям XY
_GraphGDIPlus_Set_GridX($aGraph, 3, 0xFFE7D897)
_GraphGDIPlus_Set_GridY($aGraph, $iMax / 8, 0xFFE7D897)

; Рисует график
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF2A9DFF) ; Задаёт цвет линии графика
_GraphGDIPlus_Set_PenSize($aGraph, 5)

For $i = 0 To 4
_GraphGDIPlus_Set_PenDash($aGraph, $i) ; Задаёт тип штрихпунктира
_GraphGDIPlus_Plot_Start($aGraph, 0, $i) ; Задаёт начальную точку
_GraphGDIPlus_Plot_Line($aGraph, 30, $i + 7) ; Задаёт следующую точку
Next

GUISetState()
Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)