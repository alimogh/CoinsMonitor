#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI

$hGUI = GUICreate("������� �����", 590, 320)
GUISetBkColor(0x99B598)

; ������ ������
$aGraph = _GraphGDIPlus_Create($hGUI, 45, 20, 530, 260, 0xFF000000, 0xFF1E3C48)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_RangeX($aGraph, -30, 30, 10, 1, 0) ; ���, ����, �������, ����� ,����������
_GraphGDIPlus_Set_RangeY($aGraph, 0, 0.02, 4, 1, 3)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_GridX($aGraph, 6, 0xFF67612F)
_GraphGDIPlus_Set_GridY($aGraph, 0.005, 0xFF67612F)

_GraphGDIPlus_Set_PenSize($aGraph, 4) ; ������������� ������� �����

; ������ ����� ����������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
_GraphGDIPlus_Plot_Start($aGraph, -20, 1 / (70 + -20 ^ 2)) ; � ������ �������
For $i = -20 To 20
	_GraphGDIPlus_Plot_Line($aGraph, $i, 1 / (70 + $i ^ 2))
Next
; ������ ����� ����������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFFC44E)
For $i = -20 To 20
	_GraphGDIPlus_Plot_Point($aGraph, $i, 1 / (70 + $i ^ 2))
Next

GUISetState()
Do
Until GUIGetMsg() = -3

; ������� ������, ����������� �������
_GraphGDIPlus_Delete($hGUI, $aGraph)