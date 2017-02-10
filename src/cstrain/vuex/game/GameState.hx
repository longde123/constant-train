package cstrain.vuex.game;
import cstrain.core.Card;
import cstrain.core.CardResult;
import cstrain.core.GameSettings;
import cstrain.core.IRules;
import cstrain.core.Penalty;
import cstrain.core.PlayerStats;
import cstrain.core.Polynomial;

/**
 * Vue model
 * @author Glidias
 */
class GameState
{
	// exposed viewmodel properties
	public var cards:Array<Card>;
	public var curCardIndex:Int = 0;
	
	public var playerStats:PlayerStats;
	public var settings:GameSettings;
	
	public var topCard:Card = null;

	public var isPopup:Bool = false;
	public var cardResult:CardResult= null;
	public var polynomial:Polynomial = null;
	public var showExpression:Bool = false;
	
	
	
	public var delayTimeLeft:Float = 0;
	public var curPenalty:Penalty = null;
	public var penaltySwipeCorrect:Bool = true;
	
	public var chosenSwipe:Int = SWIPE_NONE;
	public static inline var SWIPE_NONE:Int = 0;
	public static inline var SWIPE_LEFT:Int = 1;
	public static inline var SWIPE_RIGHT:Int = 2;
	

	
	// internal properties to be injected later to avoid Vuex vuemodel reactivity
	public var _rules:IRules;
	
	

	public function new(rules:IRules) 
	{
		this.cards = rules.getAllCards();
		this.settings = rules.getGameSettings();
		this.playerStats = rules.getPlayerStats();
		
		
	}
	
}

