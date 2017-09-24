#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI

$hGUI = GUICreate("������� �� ��������", 590, 320)
GUISetBkColor(0x99B598)

; ������ ������
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1E3C48)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_RangeX($aGraph, -0.7, 0.7, 14, 1, 1) ; ���, ����, �������, ����� ,����������
_GraphGDIPlus_Set_RangeY($aGraph, -100, 1000, 11, 1, 0)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_GridX($aGraph, 0.1, 0xFF67612F)
_GraphGDIPlus_Set_GridY($aGraph, 100, 0xFF67612F)

; ������ ����� ��������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
_GraphGDIPlus_Plot_Start($aGraph, -30 / 50, -30 ^ 2) ; � ������ �������
For $i = -30 To 30
	_GraphGDIPlus_Plot_Line($aGraph, $i / 50, $i ^ 2)
Next
; ������ ����� ��������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFFC44E)
For $i = -30 To 30
	_GraphGDIPlus_Plot_Point($aGraph, $i / 50, $i ^ 2)
Next

GUISetState()

MsgBox(0, '���������', '������� �� ��������')
_GraphGDIPlus_Clear($aGraph)

Do
Until GUIGetMsg() = -3

; ������� ������, ����������� �������
_GraphGDIPlus_Delete($hGUI, $aGraph)