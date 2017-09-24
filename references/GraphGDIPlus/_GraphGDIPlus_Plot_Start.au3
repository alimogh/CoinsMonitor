#include "GraphGDIPlus.au3"

Local $hGUI, $aGraph

Opt("GUIOnEventMode", 1)

$hGUI = GUICreate("", 600, 600)
GUISetOnEvent(-3, "_Exit")
GUISetState()

; Создаёт область графика
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 30, 530, 520, 0xFF000000, 0xFF88B3DD)

; Устанавливает шкалу по осям XY, от -5 до 5
_GraphGDIPlus_Set_RangeX($aGraph, -5, 5, 10, 1, 1)
_GraphGDIPlus_Set_RangeY($aGraph, -5, 5, 10, 1, 1)

; Устанавливает сетку по осям XY
_GraphGDIPlus_Set_GridX($aGraph, 1, 0xFF6993BE)
_GraphGDIPlus_Set_GridY($aGraph, 1, 0xFF6993BE)

; Рисует график
_Draw_Graph()

While 1
	Sleep(100)
WEnd

Func _Draw_Graph()
	Local $First, $y
	; Задаёт цвет и размер линии графика
	_GraphGDIPlus_Set_PenColor($aGraph, 0xFF325D87)
	_GraphGDIPlus_Set_PenSize($aGraph, 2)

	; Рисует линию
	$First = True
	For $i = -5 To 5 Step 0.005
		$y = _GammaFunction($i)
		If $First = True Then _GraphGDIPlus_Plot_Start($aGraph, $i, $y) ; Начальная точка
		$First = False
		_GraphGDIPlus_Plot_Line($aGraph, $i, $y)
		_GraphGDIPlus_Refresh($aGraph)
	Next
EndFunc   ;==>_Draw_Graph

Func _GammaFunction($iZ)
	Local $nProduct = 2 ^ $iZ / (1 + $iZ)
	For $i = 2 To 1000
		$nProduct *= (1 / $i + 1) ^ $iZ / ($iZ / $i + 1)
	Next
	Return $nProduct / $iZ
EndFunc   ;==>_GammaFunction

Func _Exit()
	; Удаляет график, освобождает ресурсы
	_GraphGDIPlus_Delete($hGUI, $aGraph)
	Exit
EndFunc   ;==>_Exit

