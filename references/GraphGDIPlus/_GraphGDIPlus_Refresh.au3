#include <GraphGDIPlus.au3>

Local Const $pi = 3.14159265358979
Local Const $iRad = $pi / 180
Local $aGraph, $hGUI

$hGUI = GUICreate("���������� �������", 590, 320)
GUISetBkColor(0x999980)

; ������ ������
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1B1B1B)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_RangeX($aGraph, -270, 270, 12, 1, 0) ; ���, ����, �������, ����� ,����������
_GraphGDIPlus_Set_RangeY($aGraph, -1.5, 1.5, 12, 1, 1)

GUISetState()

; ������ ���������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFCBB100)

_GraphGDIPlus_Plot_Start($aGraph, -270, Cos(-270)) ; � ������ �������
For $i = -270 To 270 Step 10
	_GraphGDIPlus_Plot_Line($aGraph, $i, (270 - $i) / 540 * Cos($i * $iRad))
	_GraphGDIPlus_Refresh($aGraph)
	Sleep(30)
Next

For $j = 1 To 60
	_GraphGDIPlus_Plot_Start($aGraph, -270, (270 - $i) / 540 * Cos($j / 5)) ; � ������ �������
	For $i = -270 To 270 Step 10
		_GraphGDIPlus_Plot_Line($aGraph, $i, (270 - $i) / 540 * Cos($i * $iRad - $j / 5))
	Next
	_GraphGDIPlus_Refresh($aGraph)
	Sleep(10)
	If $j < 60 Then _GraphGDIPlus_Clear($aGraph)
Next

Do
Until GUIGetMsg() = -3

; ������� ������, ����������� �������
_GraphGDIPlus_Delete($hGUI, $aGraph)