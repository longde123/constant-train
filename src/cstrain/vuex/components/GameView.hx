package cstrain.vuex.components;
import cstrain.core.Card;
import cstrain.core.CardResult;
import cstrain.vuex.components.BasicTypes.TouchVUtil;
import cstrain.vuex.game.GameMutator;
import cstrain.vuex.game.GameState;
import cstrain.vuex.store.GameStore;
import haxe.Json;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.core.VxComponent;

/**
 * ...
 * @author Glidias
 */
class GameView extends VxComponent<GameStore, NoneT, NoneT>
{

	public function new() 
	{
		super();
	}
	
	public static inline var Comp_CardView:String = "CardView";
	public static inline var Comp_PopupCardView:String = "PopupCardView";
	
	override public function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			Comp_CardView => new CardView(),
			Comp_PopupCardView => new PopupCardView()
		];
	}
	
	var currentCard(get, never):Card;
	var cardResult(get, never):CardResult;
	
	@:mutator static var mutator:GameMutator;
	
	override public function Created():Void {
		mutator._resume(store);

	}
	
	function toggleExpression() {
		
		mutator._showOrHideExpression(store);
	}
	
	var polyexpression(get, never):String;
	var toggleExprLabel(get, never):String;
	
	var showInstructions(get, never):Bool;
	function get_showInstructions():Bool 
	{
		return store.game.gameGetters.showInstructions;
	}
	
	function toggleInstructions():Void {
		mutator._toggleInstructions(store);
	
	}
	
	var helpBtnShown(get, never):Bool;
	function get_helpBtnShown():Bool {
		return store.state.game.delayTimeLeft ==  0;
	}
	
	var showGameOver(get, never):Bool;
	function get_showGameOver():Bool {
		return store.game.gameGetters.cardsLeft <=0;
	}
	
	override public function Template():String {
		#if !production
		var cheatBtn:String = '<${TouchVUtil.TAG} tag="button" class="cheat" v-on:tap="toggleExpression()" style="position:absolute;top:10px;right:0">{{ toggleExprLabel }} expression</${TouchVUtil.TAG}>';
		#else
		var cheatBtn:String = '';
		#end
		
		return '
			<div class="gameview">
				<div v-show="showInstructions">
					The Constant Train :: Polynomial Express <span style="font-size:0.5em">{{ $$store.getters.isTouchBased ? "(T)" : "(D)" }}</span>
					<hr/>
					<p>Swipe right to infer result as constant to stop the train!<br/>Swipe left to infer result as variable to move along!</p>
				</div>
				<${TouchVUtil.TAG} tag="a" class="helpbtn" :class="${" {'active':!showInstructions} "}" :style="${" {'visibility':helpBtnShown ? 'visible' : 'hidden'} "}" v-on:tap="toggleInstructions()" >
					[help]
				</${TouchVUtil.TAG}>
				<${Comp_CardView}></${Comp_CardView}>
				<${Comp_PopupCardView}></${Comp_PopupCardView}>
				<div class="blocker" v-show="showInstructions" :class="${" {showInstruct:showInstructions} "}"></div>
				<div class="traceResult" v-if="cardResult">
					<p>{{ cardResult }}</p>
				</div>
				<div class="xpression" style="font-style:italic" v-html="polyexpression"></div>
				<br/>
				${cheatBtn}
				<div class="gameover" v-show="showGameOver">
					<h1>Congratulations!</h1>
					<h2>${"You've finished the race!"}</h2>
				</div>
			</div>
		';
	}
	
	//

	function get_currentCard():Card 
	{
		return store.state.game.topCard;
	}
	function get_cardResult():CardResult 
	{
		return store.state.game.cardResult;
	}
	function get_toggleExprLabel():String 
	{
		return store.state.game.showExpression ? "Hide" : "Show";
	}
	
	function get_polyexpression():String 
	{
		return store.game.gameGetters.polynomialExpr;
	}
	
	
	
}