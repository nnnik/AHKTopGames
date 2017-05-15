#Include displayOut.ahk
SetBatchLines,-1

GUI, New
GUI, +hwndGUI1
CoordMode, Mouse, Client


display1 := new display( GUI1, [ 11, 11 ] )

file   := fileOpen( "Coords.txt", "r" )


redraw := display1.draw.bind( display1 )
OnMessage( 0xF, redraw )
GUi,Show, w600 h600
Test := new Game( display1 )
Test.runSimulation()
return

GUIClose:
ExitApp

class Game
{
	
	static colors := [ "green", "yellow", "red", "blue" ]
	
	__New( display )
	{
		This.map := display.addPicture( "background.png", [ ( size := display1.getFieldSize() ).1 / 2 +0.5 , size.2 / 2 + 0.5, 1 ], [ 11, 11 ] )
		This.map.setVisible()
		This.players := []
		This.display := display
		This.fields  := This.loadFields()
		Loop, 4
		{
			color := This.colors[ A_Index ]
			Msgbox, 4, Join Game?, Does the %color% player want to play?
			IfMsgBox,Yes
			This.players.push( new This.player( This, color, display ) )
		}
		display.draw()
	}
	
	runSimulation()
	{
		Loop
		{
			For each, player in This.players
			{
				Loop
				{
					Random, diceValue, 1, 6
					figures := player.getMoveableFigures( diceValue )
					Tooltip % diceValue
					if ( figures.Length() )
					{
						Random, selectValue, 1, % figures.Length()
						figures[ selectValue ].Move( diceValue )
					}
					This.display.draw()
					Sleep 200
				}Until diceValue != 6
			}
		}
	}
	
	loadFields()
	{
		fields := {}
		Loop 3
		{
			file := fileOpen( "res/region" . ( A_Index - 1 ), "r" )
			region := A_Index - 1
			fields[region] := {}
			while !file.atEoF
				if RegExMatch( file.readLine(), "([\d\.]+).*?([\d\.]+)", numbers )
					fields[ region, A_Index - 1 ] :={ position: [ numbers1, numbers2 ] }
		}
		return fields
	}
	
	getField( field )
	{
		return This.fields[ field* ]
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
			This.game := new indirectReference( game )
			This.figures := []
			Loop 4
			{
				figure := new This.Figure( This, display.addPicture( This.getNormalFileName()  ) )
				This.figures.push( figure ) 
				figure.moveToField( [ 0, A_Index - 1 ] )
			}
		}
		
		getSpawnFigures()
		{
			ret := []
			for each,figure in This.figures
				if ( figure.field.1 = 0 )
					ret.Push( figure )
			return ret
		}
		
		getMoveableFigures( xFields )
		{
			ret := []
			for each, figure in This.figures
				if ( figure.canMove( xFields ) )
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
			return This.game.getField( [ field.1, Mod( field.2 + This.offset, 40 ) ] )
		}
		
		class Figure
		{
			__New( Player, picture )
			{
				This.player  := new indirectReference( player )
				This.picture := picture
				picture.setVisible()
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
					srcField    := -1
				}
				else 
					targetField := This.field.2 + xFields, srcField := This.field.2
				if ( targetField > 3 )
					return 0
				Loop % targetField - srcField
					if isObject( This.getField( [ 2, srcField + A_Index ] ).figure )
						return 0
				return 1
			}
			
			Move( xFields )
			{
				if ( This.field.1 = 0 )
				{
					This.moveToField( [ 1, 0 ] )
					figures := This.player.getSpawnFigures()
					For each, figure in figures
					{
						While isObject( figure.getField( [ 0, target := A_Index - 1 ] ).figure )
							continue
						if ( target < figure.field.2 )
							figure.moveToField( [ 0, target ] )
					}
				}else if !( This.field.1 = 1 && This.field.2 + xFields > 39 )
					This.moveToField( [ This.field.1, This.field.2 + xFields ] )
				else
					This.moveToField( [ 2, mod( This.field.2 + xFields, 40 ) ] )
			}
			
			moveToField( field )
			{
				if This.hasKey( "field" )
					This.getField( This.field ).figure := ""
				This.field := field
				field := This.getField( field )
				if isObject( eFig := field.figure )
					eFig.moveToField( [ 0, eFig.player.getSpawnFigures().Length() ] )
				field.figure := This
				This.picture.setPosition( [ field.position.1, field.position.2, 2 ] )
			}
			
			getField( field )
			{
				return This.player.getField( field )
			}
			
		}
	}
	
}