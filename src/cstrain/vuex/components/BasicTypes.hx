package cstrain.vuex.components;

import gajus.swing.Swing;
import cstrain.core.Card;

/**
 * Common typedefs
 * @author Glidias
 */
typedef SwingStackData = {
	var refCards:Array<RefCard>;
	var nextBeltCardIndex:Int;
	var topCardIndex:Int;
	var beltAmount(default, never):Int;

	@:optional var _stack:SwingStack;
	@:optional var _thrownSuccess:Bool;
}

typedef RefCard = {
	@:optional  var card:Card;
}

class TouchVUtil {
	public static var IS_TOUCH_BASED:Bool = false;
	
	public static inline var TAG:String = "touch";

}