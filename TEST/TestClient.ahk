#Include %A_LineFile%\..\TestGameData.ahk
#Include %A_LineFile%\..\..\include\ComConnection.ahk

testGameData := new GameData()
testClient   := new comClientHandler( testGameData )
While !testClient.data.hasKey( "testObj1" )
	Sleep 3
Msgbox % testClient.data.testObj1.getCutomAttribute()
testClient.__Delete()