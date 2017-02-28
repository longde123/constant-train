package cstrain.h2d;
import cstrain.util.CSMath;
import h2d.Sprite;
import h2d.Graphics;
import h2d.css.Fill;

import h2d.css.Defs;

/**
 * A port of  http://wonderfl.net/c/qldl  to Haxe +Heaps
 * wip.
 * @author Glidias
 */
class TrainBGScene extends hxd.App
{
	 private var debug:Bool = false;

	public function new() 
	{
		super();
	}
	
	private var entities:Array<Entity> = new Array<Entity>();
	var scene:Sprite;
	
	override function init() {
		SceneSettings.WIDTH = s2d.width;
		SceneSettings.HEIGHT = s2d.height;
	
		s2d.addChild( scene = new Sprite());
		
		

		var g = new h2d.Graphics(s2d);
	
		var fillGrad:Fill = new Fill(s2d);
		//var grad:Gradient = { spread:SMPad, interpolate:IMLinearRGB, data:[GradRecord.GRRGB(0, {r:255, g:255, b:0} ), GradRecord.GRRGB(1, {r:255,g:0,b:0} ) ]   };
		//var matrix:Matrix = { translate:{x:0, y:0 }, scale:null, rotate:{rs0:0, rs1:1} };
		//FSLinearGradient(matrix, grad)
		//fillGrad.fillRect(h2d.css.FillStyle.Gradient(0x51484A,0x51484A,0x96644E,0x96644E), 0, 0, s2d.width, s2d.height);
		fillGrad.fillRectGradient(0, 0, s2d.width, s2d.height, 0xFF51484A, 0xFF51484A, 0xFF96644E, 0xFF96644E);
		
		var fogR = 0x40;
		var fogG = 0x35;
		var fogB = 0x2c;
		
		var mountainR = 0x17;
		var mountainG = 0x13;
		var mountainB = 0x15;

		var NUMBER_OF_MOUNTAINS = 4;
		
		for (i in 0...NUMBER_OF_MOUNTAINS) {
			var blend = i / (NUMBER_OF_MOUNTAINS - 1);
			
			var _r = CSMath.lerp(fogR, mountainR, blend);
			var _g = CSMath.lerp(fogG, mountainG, blend);
			var _b = CSMath.lerp(fogB, mountainB, blend);
			
			var baseHeight = s2d.height * 0.55 + i * 25;
			var color:UInt = ( Std.int(_r) << 16) | ( Std.int(_g) << 8) | Std.int(_b);
			
			var mountain:Mountain = new Mountain( -Math.pow(i + 1, 2), baseHeight, color);
			s2d.addChild(mountain);
			entities.push(mountain);
		}
		
		  restoreFilters(debug);
		  
		  
	
	}


	// Called each frame
	override function update(dt:Float) {
		for ( entity in entities)
		{
			entity.update();
		}
		
		//emitter.step();
		
		//renderedScene.fillRect(renderedScene.rect, 0);
		//renderedScene.draw(scene);
		//sun.update();
		
		/*
		if (soundRunChannel && soundRunChannel.position >= 14025)
		{
			soundRunChannel.stop();
			soundRunChannel = soundRun.play(3169);
			trace(soundRunChannel.position);
		}
		*/
		
	}
	
	function restoreFilters(debug:Bool):Void
	{
		for (entity in entities)
		{
			entity.restoreFilter(debug);
		}
	}
	
}
