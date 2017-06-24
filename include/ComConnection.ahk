#Include %A_LineFile%/../GameData.ahk

class comChannel extends baseClientChannel
{
	
	__New()
	{
		ObjRegisterActive(This, "{40677553-fdbd-444d-a9dd-6dce43b0cd58}")
		This.clients := []
	}
	
	join( obj )
	{
		This.clients[ &obj ] := obj
	}
	
	leave( obj )
	{
		This.clients.Delete( &Obj )
	}
	
	sendPublic( message )
	{
		For each, client in This.clients
			client.Recv( message )
	}
	
}

class comClientHandler extends baseClientHandler
{
	
	__New()
	{
		This.server := ComObjActive("{40677553-fdbd-444d-a9dd-6dce43b0cd56}")
		This.server.join( This )
	}
	
	__Delete()
	{
		This.server.leave( This )
	}
	
}