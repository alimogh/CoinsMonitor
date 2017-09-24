#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI

$hGUI = GUICreate("������ ����� �� ��� Y", 590, 320)
GUISetBkColor(0x999980)

; ������ ������
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1B1B1B)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_RangeX($aGraph, -15, 15, 10, 1, 0) ; ���, ����, �������, ����� ,����������
_GraphGDIPlus_Set_RangeY($aGraph, -6, 6, 6, 1, 0)

; ������ ��� ���������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF555555) ; ����� ���� �����
_GraphGDIPlus_Plot_Start($aGraph, 0, -6) ; ����� ��������� �����
_GraphGDIPlus_Plot_Line($aGraph, 0, 6) ; ����� ��������� �����
_GraphGDIPlus_Plot_Start($aGraph, -15, 0) ; ����� ��������� �����
_GraphGDIPlus_Plot_Line($aGraph, 15, 0) ; ����� ��������� �����

; ������ �������� �����
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF008CFF)
_GraphGDIPlus_Plot_Start($aGraph, -15, -4) ; � ������ �������
For $i = -30 To 30
	_GraphGDIPlus_Plot_Line($aGraph, $i/2, 3 * ATan($i * 1/3))
	_GraphGDIPlus_Plot_Point($aGraph, $i/2, 3 * ATan($i * 1/3))
Next

GUISetState()
Do
Until GUIGetMsg() = -3

; ������� ������, ����������� �������
_GraphGDIPlus_Delete($hGUI, $aGraph)