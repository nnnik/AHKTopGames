#Include %A_LineFile%\..\displayOut.ahk
#Include %A_LineFile%\..\GameData.ahk

class baseGameGuiClient
{
	
	__New( gameData, clientHandler )
	{
		This.gameData := gameData
		GUI, New:1
		GUI +hwndHWND
		This.display := new display( HWND, [ 11, 11 ] )
		For each, value in gameData.base
		{
			if ( isObject( value ) && isFunc( value.getVisual ) )
				value.updateVisuals := This.updateVisuals.bind( This )
		}
		gameData.field.placeOn := This.placeOn
		clientHandler.finishRecv := This.finishRecv.bind( This )
	}
	
	placeOn( visualObj )
	{
		baseGameData.Field.placeOn.Call( This, visualObj )
		if visualObj.getVisual()
		{
			visualObj.updateVisuals()
			pos := This.position.clone()
			pos.Push( 2 )
			visualObj.displayObj.setPosition( pos )
		}
	}
	
	updateVisuals( visualObj )
	{
		if !visualObj.hasKey("displayPic") && visualObj.getVisual()
			visualObj.displayObj := This.display.addPicture( visualObj.getVisual() )
		else if visual.getVisual()
			visualObj.displayObj.setVisible(), visualObj.displayObj.setFile( visualObj.getVisual() )
		else
			visualObj.displayObj.setVisible( 0 )
		
	}
	
	finishRecv( clientHandler )
	{
		This.display.flush()
	}
	
}