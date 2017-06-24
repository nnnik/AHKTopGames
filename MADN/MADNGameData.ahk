#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#Include %A_LineFile%\..\..\include\GameData.ahk




class specificGameData
{
	
	class Player extends baseGameData.basePlayer
	{
		
		static Offset := { green: 0, yellow: 10, red: 20, blue: 30 }
		
		__New( color, name := "" )
		{
			baseGameData.basePlayer.__New.Call( This, name ? name : color )
			This.color := color
		}
		
		__Delete()
		{
			baseGameData.basePlayer.__Delete.Call( This )
		}
		
	}
	
	class Unit extends baseGameData.GameObj
	{
		
		__New()
		{
			baseGameData.GameObj.__New.Call( This )
		}
		
		setPosition( region, fieldNr )
		{
			This.field.remove( This )
			This.field := gameData.getField( region, mod( fieldNr + this.player.offset[ this.player.color ], 40 ) )
			This.field.placeOn( This )
		}
		
		setPlayer( player )
		{
			This.player := player
			This.updateVisual()
		}
		
		getVisual()
		{
			return This.player.color . ".jpg"
		}
		
		__Delete()
		{
			baseGameData.GameObj.__Delete.Call( This )
		}
		
	}
	
}