#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI, $iMax = 12

$hGUI = GUICreate("���� ����� ��� �����", 590, 320)
GUISetBkColor(0xADADBD)

; ������ ������
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF000044)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_RangeX($aGraph, 0, 30, 10, 1, 0) ; ���, ����, �������, ����� ,����������
_GraphGDIPlus_Set_RangeY($aGraph, 0, $iMax, 15, 1, 1)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_GridX($aGraph, 1, 0xFF6C6342)
_GraphGDIPlus_Set_GridY($aGraph, $iMax / 15, 0xFF6C6342)

_GraphGDIPlus_Set_PenSize($aGraph, 4) ; ������������� ������� �����

; ������ ����� �������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF00A880) ; ����� ���� ����� �������
_GraphGDIPlus_Plot_Start($aGraph, 0, 2) ; ����� ��������� �����
_GraphGDIPlus_Plot_Line($aGraph, 6, 4.8) ; ����� ��������� �����
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
_GraphGDIPlus_Plot_Line($aGraph, 9, 3.2) ; ����� ��������� �����
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF00A880)
_GraphGDIPlus_Plot_Line($aGraph, 13, 6.4) ; ����� ��������� �����
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFCBB100)
_GraphGDIPlus_Plot_Line($aGraph, 15, 6.4) ; ����� ��������� �����
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF042A)
_GraphGDIPlus_Plot_Line($aGraph, 21, 4.8) ; ����� ��������� �����
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF00A880)
_GraphGDIPlus_Plot_Line($aGraph, 30, 11) ; ����� ��������� �����

; ������ ����� �������
_GraphGDIPlus_Set_PenSize($aGraph, 18) ; ������������� ������� �����
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF00FF)
_GraphGDIPlus_Plot_Point($aGraph, 6, 4.8) ; ����� ��������� �����
_GraphGDIPlus_Plot_Point($aGraph, 13, 6.4) ; ����� ��������� �����

GUISetState()
Do
Until GUIGetMsg() = -3

; ������� ������, ����������� �������
_GraphGDIPlus_Delete($hGUI, $aGraph)