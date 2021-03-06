package cstrain.vuex.game;
import cstrain.core.CardResult;
import cstrain.core.OkFlags;
import cstrain.core.PenaltyDesc;
import cstrain.vuex.store.GameStoreMutator;
import format.abc.Data.Function;
import haxe.Timer;
import haxevx.vuex.core.IAction;
import haxevx.vuex.core.IVxContext;
import haxevx.vuex.core.IVxContext.IVxContext1;
import haxevx.vuex.core.NoneT;
import js.Promise;


/**
 * ...
 * @author Glidias
 */
class GameActions implements IAction<GameState, NoneT>
{

	//static inline var DELAY_TIME:Float = 2;
	@:mutator static var mutator:GameMutator;
	
	@:mutator static var storeMutator:GameStoreMutator;
	
	static var TIMER:Timer;
	public static function clearTimer():Void {
		if (TIMER != null) {
			TIMER.stop();
			TIMER = null;
		}
	}

	function swipe(context:IVxContext1<GameState>, isRight:Bool):Promise<CardResult> {

		return new Promise<CardResult>(function(resolve, reject) {
		
			var result = context.state._rules.playCard(isRight);
			
			

			switch( result) {
				case CardResult.NOT_YET_AVAILABLE(_, _) | CardResult.GAMEOVER_OUTTA_CARDS:
					
				default:
					mutator._notifySwipe(context, isRight ? GameState.SWIPE_RIGHT : GameState.SWIPE_LEFT);
			
			}

			
			switch( result) {
				case CardResult.GUESS_CONSTANT(guessCard, wildGuessing):
					// show popup mutation
					//mutator._setPopupCard(context);  // guessCard already encapcsulted within IRules api topmost card
					mutator._encounterStationStop(context);
					mutator._updateProgress(context);
					mutator._resume(context);
					
				case CardResult.PENALIZE(penalty):
					mutator._setPenalty(context, penalty);
					//penalty.delayNow;
					if (penalty.desc == PenaltyDesc.MISSED_STOP || penalty.desc == PenaltyDesc.LOST_IN_TRANSIT) {
						if (penalty.desc == PenaltyDesc.MISSED_STOP) {
							mutator._encounterStationStop(context);
						}
						mutator._updateProgress(context);
					}
					if (penalty.delayNow != null  ) {
						var calcTime:Float =  penalty.delayNow;
						mutator._setDelay(context,calcTime );
						
						if (penalty.delayNow > 0) {
							TIMER = Timer.delay( function() {
								TIMER = null;
								mutator._setDelay(context, 0);
								
									// exceptional case to always clear peanlty after wrong_constant...
		if (context.state.curPenalty != null && context.state.curPenalty.desc == PenaltyDesc.WRONG_CONSTANT) mutator._setPenalty(context, null);
								mutator._resume(context);
							}, Std.int(calcTime) );
						}
						else {
							mutator._resume(context);
						}
					}
					
					switch( penalty.desc) {
						case PenaltyDesc.CLOSER_GUESS(_):
							mutator._setPenaltySwipeCorrect(context, true);
						default:
							mutator._setPenaltySwipeCorrect(context, false);
					}
			
				case CardResult.OK(flags):
						// play OK sound, close any popups, etc.
						//mutator._setPopupCard(context,false);
						mutator._setPenalty(context, null);
						mutator._updateProgress(context);
						
						// for now, we assume this is gameover already..
						if (flags.has(OkFlags.GAME_OVER)) {
							context.state.cardsOutDetected = true;
							storeMutator._saveGameForNextLevel( context, {
								LAST_MONSTER_SPECS: context.state._monsterSpecs,
								LAST_PLAYER_SPECS: context.state._playerSpecs
							});
						}
						
						mutator._resume(context);
						
				case CardResult.NOT_YET_AVAILABLE(timeLeft, penaltyTime):
					// beep
					trace("Not yet available to swipe!:"+[timeLeft, penaltyTime]);
				
				case CardResult.GAMEOVER_OUTTA_CARDS:
					mutator._traceCardResult(context, result);
					
					
				
				default:
					trace("Uncaught case: " + result);
			}
			
			
			
			resolve(result);
		});
	
	
	}

}