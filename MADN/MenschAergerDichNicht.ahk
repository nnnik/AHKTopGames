#Include displayOut.ahk
SetBatchLines,-1

GUI, New
GUI, +hwndGUI1
GUi,Show, w600 h600
Loop
	(new Game( new display( GUI1, [ 11, 11 ] ) ) ).runSimulation()
return

GUIClose:
ExitApp

class GameData
{
	
	set
	
}

class Game
{
	
	static colors := [ "green", "yellow", "red", "blue" ]
	
	__New( display := "" )
	{
		This.map := display.addPicture( "background.png", [ ( size := display1.getFieldSize() ).1 / 2 +0.5 , size.2 / 2 + 0.5, 1 ], [ 11, 11 ] )
		This.map.setVisible()
		This.players := []
		This.display := display
		This.fields  := This.loadFields()
		Loop, 4
		{
			color := This.colors[ A_Index ]
			;Msgbox, 4, Join Game?, Does the %color% player want to play?
			;IfMsgBox,Yes
			This.players.push( new This.player( This, color, display ) )
		}
		display.draw()
		This.winners := []
	}
	
	roll()
	{
		This.playerRoll++
		Random, diceValue, 1, 6
		This.setDiceValue( diceValue )
	}
	
	setDiceValue( diceValue )
	{
		This.diceValue := diceValue
	}
	
	getDiceValue()
	{
		return This.diceValue
	}
	
	changePlayer()
	{
		player            := This.players[ This.activeNr := mod( This.activeNr++, This.players.Length() ) + 1 ? This.activeNr : This.activeNr := 1 ]
		This.wasAllowed   := player.isAllowedToThrow3Times()
		This.playerRoll   := 0
		This.setActivePlayer( player )
	}
	
	setActivePlayer( player )
	{
		This.activePlayer := player
	}
	
	getActivePlayer()
	{
		return This.activePlayer
	}
	
	setFinished()
	{
		This.finished := 1
	}
	
	getFinished()
	{
		return This.hasKey( "finished" ) && This.finished
	}
	
	offerChoice()
	{
		This.clearPlayerChoice()
		This.choices := This.getActivePlayer().getMoveableUnits( This.getDiceValue() )
		if ( choiceNr := This.getActivePlayer.offerChoice( This.choices ) )
			This.setPlayerChoice( choiceNr )
	}
	
	clearPlayerChoice()
	{
		This.delete( "choiceNr" )
	}
	
	
	setPlayerChoice( choiceNr )
	{
		This.choiceNr := choiceNr
		This.doTurn()
	}
	
	getPlayerChoice()
	{
		return This.choices[ This.choiceNr ]
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
		static fileName := "_unit.png"
		static picFolder:= "pic"
		
		__New( game, color, display )
		{
			This.color   := color
			This.offset  := This.offsets[ color ]
			This.game := new indirectReference( game )
			This.units := []
			Loop 4
			{
				unit := new This.Unit( This, display.addPicture( This.getNormalFileName()  ) )
				This.units.push( unit ) 
				unit.moveToField( [ 0, A_Index - 1 ] )
			}
		}
		
		isFinished()
		{
			return This.getGoalUnits().Length() = 4
		}
		
		isAllowedToThrow3Times()
		{
			gUnit := This.getGoalUnits()
			fieldsClosed := {}
			for each, unit in gUnit
				fieldsClosed[ unit.field.2 ] := 1
			Loop 3
				if ( fieldsClosed[ A_Index - 1 ] && !fieldsClosed[ A_Index ] )
					return 0
			if ( ( gUnit.Length() + This.getSpawnUnits().Length() ) < 4 )
				return 0
			return 1
		}
		
		getSpawnUnits()
		{
			ret := []
			for each,unit in This.units
				if ( unit.field.1 = 0 )
					ret.Push( unit )
			return ret
		}
		
		getGoalUnits()
		{
			ret := []
			for each,unit in This.units
				if ( unit.field.1 = 2 )
					ret.Push( unit )
			return ret
		}
		
		getMoveableUnits( xFields )
		{
			ret := []
			for each, unit in This.units
				if ( unit.canMove( xFields ) )
					ret.Push( unit )
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
		
		getColor()
		{
			return This.color
		}
		
		class Unit
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
				if ( This.getField( [ 1 ,0 ] ).unit.player.getColor() = This.player.getColor() && This.getField( [ 1, 0 ] ).unit != This && This.player.getSpawnUnits().Length() != 0 && This.getField( [ 1, 0 ] ).unit.canMove( xFields ) ) ; after spawn move rule
					return 0
				if ( xFields = 6 && This.getField( [ 1 ,0 ] ).unit.player != This.player && This.player.getSpawnUnits().Length() > 0 && This.field.1 != 0 )
					return 0
				if ( This.field.1 = 0 )
					return xFields = 6 && This.getField( [ 1, 0 ] ).unit.player.getColor() != This.player.getColor()
				if ( This.field.1 = 1 )
				{
					targetField := This.field.2 + xFields
					if ( targetField < 40 )
						return This.getField( [ 1, targetField ] ).unit.player.getColor() != This.player.getColor()
					targetField := mod( targetField, 40 )
					srcField    := -1
				}
				else 
					targetField := This.field.2 + xFields, srcField := This.field.2
				if ( targetField > 3 )
					return 0
				Loop % targetField - srcField
					if isObject( This.getField( [ 2, srcField + A_Index ] ).unit )
						return 0
				return 1
			}
			
			Move( xFields )
			{
				if ( This.field.1 = 0 )
				{
					This.moveToField( [ 1, 0 ] )
					units := This.player.getSpawnUnits()
					For each, unit in units
					{
						While isObject( unit.getField( [ 0, target := A_Index - 1 ] ).unit )
							continue
						if ( target < unit.field.2 )
							unit.moveToField( [ 0, target ] )
					}
				}else if !( This.field.1 = 1 && This.field.2 + xFields > 39 )
					This.moveToField( [ This.field.1, This.field.2 + xFields ] )
				else
					This.moveToField( [ 2, mod( This.field.2 + xFields, 40 ) ] )
			}
			
			moveToField( field )
			{
				if This.hasKey( "field" )
					This.getField( This.field ).unit := ""
				This.field := field
				field := This.getField( field )
				if isObject( eFig := field.unit )
					eFig.moveToField( [ 0, eFig.player.getSpawnUnits().Length() ] )
				field.unit := This
				This.picture.setPosition( [ field.position.1, field.position.2, 2 ] )
			}
			
			getField( field )
			{
				return This.player.getField( field )
			}
			
		}
	}
	
}