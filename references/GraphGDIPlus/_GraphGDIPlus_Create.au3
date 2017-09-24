#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI, $iMax = 12

$hGUI = GUICreate("������ ������", 590, 320)

; ������ ������
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFFCEE3E0)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_RangeX($aGraph, 0, 20, 10, 1, 0) ; ���, ����, �������, ����� ,����������
_GraphGDIPlus_Set_RangeY($aGraph, 0, $iMax, 10, 1, 1)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_GridX($aGraph, 1, 0xFF6993BE)
_GraphGDIPlus_Set_GridY($aGraph, $iMax / 10, 0xFF6993BE)

; ������ ������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF339966) ; ����� ���� ����� �������
_GraphGDIPlus_Plot_Start($aGraph, 0, 11) ; ����� ��������� �����
_GraphGDIPlus_Plot_Line($aGraph, 20, 2) ; ����� ��������� �����

GUISetState()
Do
Until GUIGetMsg() = -3

; ������� ������, ����������� �������
_GraphGDIPlus_Delete($hGUI, $aGraph)