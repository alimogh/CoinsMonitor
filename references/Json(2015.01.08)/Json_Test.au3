#Include "Json.au3"

If Test1() And Test2() And Test3() Then MsgBox(0, "Json UDF Test", "All Passed !")

Func Test1()
	Local $Json1 = FileRead(@ScriptDir & "\test.json")
	Local $Data1 = Json_Decode($Json1)
	Local $Json2 = Json_Encode($Data1)

	Local $Data2 = Json_Decode($Json2)
	Local $Json3 = Json_Encode($Data2)

	ConsoleWrite("Test1 Result: " & $Json3 & @LF)
	Return ($Json2 = $Json3)
EndFunc

Func Test2()
	Local $Json1 = '["100","hello world",{"key":"value","number":100}]'
	Local $Data1 = Json_Decode($Json1)

	Local $Json2 = Json_Encode($Data1, $Json_UNQUOTED_STRING)
	Local $Data2 = Json_Decode($Json2)

	Local $Json3 = Json_Encode($Data2, $Json_PRETTY_PRINT, "  ", "\n", "\n", ",")
	Local $Data3 = Json_Decode($Json3)

	Local $Json4 = Json_Encode($Data3, $Json_STRICT_PRINT)

	ConsoleWrite("Test3 Unquoted Result: " & $Json2 & @LF)
	ConsoleWrite("Test3 Pretty Result: " & $Json3 & @LF)
	Return ($Json1 = $Json4)
EndFunc

Func Test3()
	Local $Obj
	Json_Put($Obj, ".foo", "foo")
	Json_Put($Obj, ".bar[0]", "bar")
	Json_Put($Obj, ".test[1].foo.bar[2].foo.bar", "Test") ; dot notation

	Local $Json = Json_Encode($Obj)
	ConsoleWrite("Test3 Result: " & $Json & @LF)

	Return Json_Get($Obj, '["test"][1]["foo"]["bar"][2]["foo"]["bar"]') = "Test" ; square bracket notation
EndFunc
