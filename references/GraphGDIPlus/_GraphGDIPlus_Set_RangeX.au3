#include <GraphGDIPlus.au3>

Local Const $pi = 3.14159265358979
Local Const $iRad = $pi / 180
Local $aGraph, $hGUI

$hGUI = GUICreate("Создаёт шкалу на оси X", 590, 320)
GUISetBkColor(0x999980)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1B1B1B)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, -270, 270, 12, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, -1.2, 1.2, 12, 1, 1)

; Рисует оси координат
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF555555) ; Задаёт цвет линии
_GraphGDIPlus_Plot_Start($aGraph, 0, -1.2) ; Задаёт начальную точку
_GraphGDIPlus_Plot_Line($aGraph, 0, 1.2) ; Задаёт следующую точку
_GraphGDIPlus_Plot_Start($aGraph, -270, 0) ; Задаёт начальную точку
_GraphGDIPlus_Plot_Line($aGraph, 270, 0) ; Задаёт следующую точку

; Рисует циклоиду красную
_GraphGDIPlus_Plot_Start($aGraph, -270, -1) ; К началу графика
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
For $i = -270 To 270 Step 10
	_GraphGDIPlus_Plot_Line($aGraph, $i, Sin($i * $iRad))
Next

; Рисует циклоиду жёлтую
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFCBB100)
_GraphGDIPlus_Plot_Start($aGraph, -270, 1) ; К началу графика
For $i = -270 To 270 Step 10
	_GraphGDIPlus_Plot_Point($aGraph, $i, Abs(Sin($i * $iRad)))
Next

GUISetState()
Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)