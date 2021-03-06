﻿class baseGameData
{
	static fieldFile := "regions.field"
	
	__New()
	{
		This.initFields()
	}
	
	__Get( key )
	{
		if ( !( key = "base" ) && This.base.hasKey( key ) && isObject( obj := This.base[ key ] ) )
		{
			obj := obj.Clone()
			obj.GameData := This
			return obj
		}
	}
	
	initFields()
	{
		if !isObject( file := fileOpen( This.fieldFile, "r" ) )
			return
		This.fields := {}
		while !file.atEoF
		{
			if RegExMatch( text := file.readLine(), "^.*?([\d\.]+).*?([\d\.]+).*?$", numbers )
				This.fields[ region, fieldNr ] := { position: [ numbers1, numbers2 ],  base: This.field },  This.fields[ region,  fieldNr ].__New()
			else if RegExMatch( text , "^region ( \d+ )$", numbers )
				region := numbers1, This.fields[region] := {},  fieldNr := 0
			fieldNr++
		}
	}
	
	class GameObj
	{
		
		static instances := {}
		static isGameObj := 1
		
		__New()
		{
			if isObject( This.instances )
				This.base.instances := 1
			RegExMatch( This.__Class, "\w+$", out )
			This.uID := out . This.base.instances++
			baseGameData.GameObj.instances[ This.uID ] := This
		}
		
		__Delete()
		{
			baseGameData.GameObj.instances.Delete( This.uID )
		}
		
	}
	
	class Field
	{
		
		__New()
		{
			This.On := []
		}
		
		placeOn( object )
		{
			This.on[ &object ] := object
		}
		
		getOn()
		{
			return This.on
		}
		
		remove( object )
		{
			This.on.Delete( &object )
		}
		
	}
	
	class basePlayer extends baseGameData.GameObj
	{
		
		isGameObj := 1
		
		__New( name )
		{
			baseGameData.GameObj.__New.Call( This )
			This.name := name
		}
		
		getName()
		{
			return name
		}
		
		__Delete()
		{
			baseGameData.GameObj.__Delete.Call( This )
			This.base := ""
		}
		
	}
	
	getField( region, fieldNr )
	{
		return This.fields[ region,  fieldNr ]
	}
	
}

class baseServerHandler
{
	
	static wrapped := []
	
	__New( GameData )
	{
		This.buffer  := []
		This.clients := []
		if !This.wrapped[ &( GameData.base ) ]
		{
			This.wrapped[ &( GameData.base ) ] := 1
			For each, obj in GameData.base
				if obj.isGameObj
					This.wrapObj( obj )	
		}
	}
	
	wrapObj( obj )
	{
		if !This.wrapped.hasKey( &obj )
		{
			This.wrapped[ &obj ] := 1
			For each, val in obj
				if ( isFunc( val ) && ( each ~= "i)^(set|__New|__Delete)" ) )
					This.addToPipelineBuffering( obj, each )
		}
	}
	
	addToPipelineBuffering( obj, methodName )
	{
		obj[ methodName ] := This.pipelineBufferingCallBack.bind( This, obj[ methodName ], methodName )
 	}
	
	pipelineBufferingCallBack( method, methodName, obj, p* )
	{
		This.buffer.Push( [ obj, methodName, p ] )
		method.Call( obj, p* )
	}
	
	addClientChannel( clientChannel )
	{
		This.clients[ &clientChannel ] := clientChannel
	}
	
	removeClientChannel( clientChannel )
	{
		This.clients.Delete( &clientChannel )
	}
	
	flush()
	{
		messages := This.buffer
		This.buffer := []
		for each,  message in messages
		{
			cmdStr .= message.1.uID . "." . message.2 . "("
			For each,  parameter in message.3
				cmdStr .= ( isObject( parameter ) ? parameter.isGameObj ? parameter.uID : "Error" : """" . parameter . """" ) . ","
			cmdStr := message.3.Length() ? SubStr( cmdStr, 1, -1 ) . ")" : cmdStr . ")"
		}
		For each, clientChannel in This.clients
			clientChannel.notify( cmdStr )
	}
	
}

class baseClientChannel
{
	
	notify( messages )
	{
		This.sendPublic( messages )
	}
	
}

class baseClientHandler
{
	
	data := {}
	
	__New( gameData )
	{
		This.gameData := gameData
	}
	
	recv( message )
	{
		lastFound := 1
		funcCall  := ""
		While lastFound := RegExMatch( message, "([A-Za-z_]+)(\d*)(?:\.([\w_]+))?\(([^\)]*)\)", funcCall, lastFound + strLen( funcCall ) )
		{
			params := StrSplit( funcCall4, "," )
			for each, param in params
			{
				if param ~= "^"".*""$"
					params[each] := SubStr( param, 2, -1 )
				else
					params[each] := This.data[param]
			}
			if ( funcCall3 = "__New" )
				objBase := This.gameData[ funcCall1 ], This.data[ funcCall1 . funcCall2 ] := New objBase( params* )
			else if ( funcCall3 = "__Delete" )
				This.data[ funcCall1 . funcCall2 ].__Delete(), This.data.delete( funcCall1 . funcCall2 )
			else
				This.data[ funcCall1 . funcCall2 ][ funcCall3 ].Call( This.data[ funcCall1 . funcCall2 ] ,params* )
		}
		This.finishRecv()
	}
	
}