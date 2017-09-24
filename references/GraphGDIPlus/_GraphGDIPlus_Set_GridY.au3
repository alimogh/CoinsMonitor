#include <GraphGDIPlus.au3>

Local Const $pi = 3.14159265358979
Local Const $iRad = $pi / 180
Local $aGraph, $hGUI

$hGUI = GUICreate("Создаёт Y-линии сетки", 590, 320)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFFEEFFFF)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, -400, 400, 10, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, -2, 2, 10, 1, 1)

; Устанавливает сетку по оси Y
_GraphGDIPlus_Set_GridY($aGraph, 0.4, 0xFF6993BE)

; Рисует сумму чётных и нечётных гармоник
SRandom(3)
For $j = 1 To 5
	If $j = 5 Then $j = 20
	_GraphGDIPlus_Plot_Start($aGraph, -400, -1) ; К началу графика
	_GraphGDIPlus_Set_PenColor($aGraph, Random(0xFF000000, 0xFFFFFFFF, 1))
	For $i = -400 To 400 Step 4
		$iSin = 0
		For $r = 1 To $j
			$iSin += Sin($i * $iRad * $r) / $r
		Next
		_GraphGDIPlus_Plot_Line($aGraph, $i, $iSin)
	Next
Next

GUISetState()
Do
Until GUIGetMsg() = -3

; Удаляет график, освобождает ресурсы
_GraphGDIPlus_Delete($hGUI, $aGraph)