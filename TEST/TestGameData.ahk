#Include %A_LineFile%\..\..\include\GameData.ahk

class GameData extends baseGameData
{
	
	__Get( key )
	{
		if ( !( key = "base" ) && This.base.hasKey( key ) && isObject( obj := This.base[ key ] ) )
		{
			obj := obj.Clone()
			obj.GameData := This
			return obj
		}
	}
	
	class testObj extends baseGameData.GameObj
	{
		
		__New()
		{
			baseGameData.GameObj.__New.Call( This )
		}
		
		setCustomAttribute( val )
		{
			This.val := val
		}
		
		getCutomAttribute()
		{
			return This.val
		}
		
		__Delete()
		{
			baseGameData.GameObj.__New.Call( This )
		}
		
	}
	
}
