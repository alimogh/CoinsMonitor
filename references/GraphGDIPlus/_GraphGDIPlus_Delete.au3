#include <GraphGDIPlus.au3>

Local $aGraph, $hGUI

$hGUI = GUICreate("������� ������", 590, 320)
GUISetBkColor(0x999980)

; ������ ������
$aGraph = _GraphGDIPlus_Create($hGUI, 40, 20, 530, 260, 0xFF000000, 0xFF1B1B1B)

; ������������� ����� �� ���� XY
_GraphGDIPlus_Set_RangeX($aGraph, -12, 12, 12, 1, 0) ; ���, ����, �������, ����� ,����������
_GraphGDIPlus_Set_RangeY($aGraph, -4, 4, 12, 1, 1)

; ������ ����
_GraphGDIPlus_Set_PenColor($aGraph, 0xFFFF0099)
_GraphGDIPlus_Plot_Start($aGraph, -12, 0) ; � ������ �������
For $i = -12 To 12
	$iSin = ($i - 2 * Floor(($i + 1) / 2)) * (-1) ^ Floor(($i + 1) / 2) ; �����������
	_GraphGDIPlus_Plot_Line($aGraph, $i, $iSin)
Next

; ������ ������
_GraphGDIPlus_Set_PenColor($aGraph, 0xFF00A880) ; ����� ���� ����� �������
_GraphGDIPlus_Plot_Start($aGraph, -12, -3) ; ����� ��������� �����
_GraphGDIPlus_Plot_Line($aGraph, 12, 3) ; ����� ��������� �����

GUISetState()

MsgBox(0, '���������', '������� ������')
; ������� ������, ����������� �������
_GraphGDIPlus_Delete($hGUI, $aGraph)

Do
Until GUIGetMsg() = -3