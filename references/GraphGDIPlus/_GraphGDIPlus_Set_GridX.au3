#include <GraphGDIPlus.au3>

Local Const $pi = 3.14159265358979
Local Const $iRad = $pi / 180
Local $aGraph, $hGUI

$hGUI = GUICreate("Создаёт X-линии сетки", 590, 320)

; Создаёт график
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFFEEFFFF)

; Устанавливает шкалу по осям XY
_GraphGDIPlus_Set_RangeX($aGraph, -280, 280, 14, 1, 0) ; мин, макс, деление, цифры ,округление
_GraphGDIPlus_Set_RangeY($aGraph, -1.2, 1.2, 12, 1, 1)

; Устанавливает сетку по оси X
_GraphGDIPlus_Set_GridX($aGraph, 40, 0xFF6993BE)

; Рисует сумму нечётных гармоник
SRandom(3)
For $j = 1 To 5
	If $j = 5 Then $j = 20
	_GraphGDIPlus_Plot_Start($aGraph, -280, -1) ; К началу графика
	_GraphGDIPlus_Set_PenColor($aGraph, Random(0xFF000000, 0xFFFFFFFF, 1))
	For $i = -280 To 280 Step 3
		$iSin = 0
		$r = -1
		For $z = 1 To $j
			$r += 2
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