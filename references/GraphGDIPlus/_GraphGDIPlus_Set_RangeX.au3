#include <GraphGDIPlus.au3>

Local Const $pi = 3.14159265358979
Local Const $iRad = $pi / 180
Local $aGraph, $hGUI

$hGUI = GUICreate("������ ����� �� ��� X", 590, 320)
GUISetBkColor(0x999980)

; ������ ������
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1B1B1B)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_RangeX($aGraph, -270, 270, 12, 1, 0) ; ���, ����, �������, ����� ,����������
_GraphGDIPlus_Set_RangeY($aGraph, -1.2, 1.2, 12, 1, 1)

; ������ ��� ���������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF555555) ; ����� ���� �����
_GraphGDIPlus_Plot_Start($aGraph, 0, -1.2) ; ����� ��������� �����
_GraphGDIPlus_Plot_Line($aGraph, 0, 1.2) ; ����� ��������� �����
_GraphGDIPlus_Plot_Start($aGraph, -270, 0) ; ����� ��������� �����
_GraphGDIPlus_Plot_Line($aGraph, 270, 0) ; ����� ��������� �����

; ������ �������� �������
_GraphGDIPlus_Plot_Start($aGraph, -270, -1) ; � ������ �������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
For $i = -270 To 270 Step 10
	_GraphGDIPlus_Plot_Line($aGraph, $i, Sin($i * $iRad))
Next

; ������ �������� �����
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFCBB100)
_GraphGDIPlus_Plot_Start($aGraph, -270, 1) ; � ������ �������
For $i = -270 To 270 Step 10
	_GraphGDIPlus_Plot_Point($aGraph, $i, Abs(Sin($i * $iRad)))
Next

GUISetState()
Do
Until GUIGetMsg() = -3

; ������� ������, ����������� �������
_GraphGDIPlus_Delete($hGUI, $aGraph)