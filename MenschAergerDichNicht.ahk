#Include displayOut.ahk
SetBatchLines,-1

GUI, New
GUI, +hwndGUI1
CoordMode, Mouse, Client


display1 := new display( GUI1, [ 11, 11 ] )
map := display1.addPicture( "background.png", [ ( size := display1.getFieldSize() ).1 / 2 +0.5 , size.2 / 2 + 0.5 ], [ 11, 11, 1 ] )
map.setVisible()

figure := display1.addPicture( "background.png", [ 1, 1 ], [ -1, -1, 2 ] )
figure.setVisible()
file   := fileOpen( "Coords.txt", "r" )


redraw := display1.draw.bind( display1 )
OnMessage( 0xF, redraw )
onWMMove := func( "testShowFunc" ).bind( display1 )
GUi,Show, w600 h600

Enter::
While !RegExMatch( file.readLine(), "([\d\.]+).*?([\d\.]+)", numbers ) && !file.atEoF
	continue
figure.setPosition( [ numbers1, numbers2, 2 ] )
%redraw%()
return

class Game
{
	
	static colors := [ "green", "yellow", "red", "blue" ]
	
	__New( display )
	{
		This.players := []
		This.display := display
		This.fields  := []
		Loop, 4
		{
			color := This.colors[ A_Index ]
			Msgbox, 4, Join Game?, Does the %color% player want to play?
			IfMsgBox,Yes
				This.players.push( new This.player( This, color, display ) )
		}
	}
	
	
	
	class Player
	{
		static offsets  := { green: 0, yellow: 10, red: 20, blue: 30 }
		static fileName := "_figure.png"
		static picFolder:= "pic"
		
		__New( game, color, display )
		{
			This.color   := color
			This.offset  := This.offsets[ color ] 
			This.figures := []
			Loop 4
			{
				This.figures.push( figure := new This.Figure( This, display.addPicture( This.getNormalFileName() ) ) )
				figure.moveToField( [ 0, A_Index - 1 ] )
			}
			This.game := new indirectReference( game )
		}
		
		getSpawnFigures()
		{
			ret := []
			for each,figure in This.figures
				if ( figure.field.1 = 0 )
					ret.Push( figure )
			return ret
		}
		
		getNormalFileName()
		{
			return This.picFolder . "/" . This.color . This.fileName
		}
		
		getHighlightFileName()
		{
			return This.picFolder . "/" . This.color . "_H" . This.fileName
		}
		
		getGreyFileName()
		{
			return This.picFolder . "/" . This.color . "_D" . This.fileName
		}
		
		getField( field )
		{
			This.game.getField( [ field.1, field.2 + This.offset ] )
		}
		
		class Figure
		{
			__New( Player, picture )
			{
				This.player  := new indirectReference( player )
				This.picture := picture 
			}
			
			highlight()
			{
				This.picture.setFile( This.canMove() ? This.parent.getHighlightFileName() : This.parent.getGreyFileName() )
			}
			
			unHighlight()
			{
				This.picture.setFile( This.parent.getNormalFileName() )
			}
			
			canMove( xFields )
			{
				if ( This.getField( [ 1 ,0 ] ).figure.player = This.player && This.getField( [ 1, 0 ] ).figure != This && This.player.getSpawnFigures().Length() != 0 && This.getField( [ 1, 0 ] ).figure.canMove( xFields ) ) ; after spawn move rule
					return 0
				if ( This.field.1 = 0 )
					return xFields = 6 && This.getField( [ 1, 0 ] ).figure.player != This.player
				if ( This.field.1 = 1 )
				{
					targetField := This.field.2 + xFields
					if ( targetField < 40 )
						return This.getField( [ 1, targetField ] ).figure.player != This.player 
					targetField := mod( targetField, 40 )
					srcField    := 0
				}
				else 
					targetField := This.field.2 + xFields, srcField := This.field.2
				if ( targetField > 3 )
					return 0
				Loop % targetField - srcField
					if isObject( This.getField( [ 2, srcField + A_Index - 1 ] ).figure )
						return 0
				return 1
			}
			
			Move( xFields )
			{
				if ( This.field.1 = 0 )
				{
					This.moveToField( [ 1, 0 ] )
					For each, figure in This.player.getSpawnFigures()
					{
						While isObject( figure.getField( [ 0, target := A_Index - 1 ] ).figure )
							continue
						if ( target < This.field.2 )
							figure.moveToField( [ 0, target ] )
					}
				}
				if !( This.field.1 = 1 && This.field.2 + xFields > 40 )
					This.moveToField( [ This.field.1, This.field.2 + xFields ] )
				This.moveToField( [ 2, mod( This.field.2 + xFields, 40 ) ] )
			}
			
			moveToField( field )
			{
				This.getField( This.field ).figure := ""
				This.field := field
				field := This.getField( field )
				if isObject( eFig := field.figure )
					eFig.moveToField( eFig.getField( [ 0, eFig.player.getSpawnFigures().Length() ] ) )
				field.figure := This
				picture.setPosition( field.Position )
			}
			
			getField( field )
			{
				return This.player.getField( field )
			}
			
		}
	}
	
}