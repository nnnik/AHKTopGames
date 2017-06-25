#Include %A_LineFile%\..\TestGameData.ahk
#Include %A_LineFile%\..\..\include\ComConnection.ahk


testGameData := new GameData()
testServ     := new baseServerHandler( testGameData )
testConnect  := new comChannel() 
while !testConnect.clients.Length()
	Sleep 15
testServ.addClientChannel( testConnect )
obj := new testGameData.testObj()
obj.setCustomAttribute( "Hello World" )
testServ.flush()
While testConnect.clients.Length()
	Sleep 15