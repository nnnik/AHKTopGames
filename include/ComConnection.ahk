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
		obj.id := This.clients.Push( obj )
	}
	
	leave( obj )
	{
		This.clients.Delete( obj.id )
	}
	
	sendPublic( message )
	{
		For each, client in This.clients
			client.Recv( message )
	}
	
}

class comClientHandler extends baseClientHandler
{
	
	__New( gamedata )
	{
		baseClientHandler.__New.Call( This, gamedata )
		This.server := ComObjActive("{40677553-fdbd-444d-a9dd-6dce43b0cd58}")
		This.server.join( This )
	}
	
	__Delete()
	{
		This.server.leave( This )
	}
	
}

ObjRegisterActive(Object, CLSID, Flags:=0) {
	static cookieJar := {}
	if (!CLSID) {
		if (cookie := cookieJar.Remove(Object)) != ""
			DllCall("oleaut32\RevokeActiveObject", "uint", cookie, "ptr", 0)
		return
	}
	if cookieJar[Object]
		throw Exception("Object is already registered", -1)
	VarSetCapacity(_clsid, 16, 0)
	if (hr := DllCall("ole32\CLSIDFromString", "wstr", CLSID, "ptr", &_clsid)) < 0
		throw Exception("Invalid CLSID", -1, CLSID)
	hr := DllCall("oleaut32\RegisterActiveObject"
	, "ptr", &Object, "ptr", &_clsid, "uint", Flags, "uint*", cookie
	, "uint")
	if hr < 0
		throw Exception(format("Error 0x{:x}", hr), -1)
	cookieJar[Object] := cookie
}