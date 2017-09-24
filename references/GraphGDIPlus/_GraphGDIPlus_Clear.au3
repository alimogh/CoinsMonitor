#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI

$hGUI = GUICreate("Очищает от графиков", 590, 320)
GUISetBkColor(0x99B598)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1E3C48)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, -0.7, 0.7, 14, 1, 1) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, -100, 1000, 11, 1, 0)

; Устанавливает сетку по осям XY
_GraphGDIPlus_Set_GridX($aGraph, 0.1, 0xFF67612F)
_GraphGDIPlus_Set_GridY($aGraph, 100, 0xFF67612F)

; Рисует линию параболы
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
_GraphGDIPlus_Plot_Start($aGraph, -30 / 50, -30 ^ 2) ; К началу графика
For $i = -30 To 30
	_GraphGDIPlus_Plot_Line($aGraph, $i / 50, $i ^ 2)
Next
; Рисует точки параболы
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFFC44E)
For $i = -30 To 30
	_GraphGDIPlus_Plot_Point($aGraph, $i / 50, $i ^ 2)
Next

GUISetState()

MsgBox(0, 'Сообщение', 'Очищает от графиков')
_GraphGDIPlus_Clear($aGraph)

Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)