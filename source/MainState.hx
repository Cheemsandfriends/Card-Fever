package;

import flixel.util.FlxTimer;
import flixel.FlxSprite;
import openfl.Assets;
import PlayState.InfiniteGrid;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.filters.ShaderFilter;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.ui.FlxUIState;
import flixel.graphics.FlxGraphic;
import flxanimate.FlxAnimate;

class MainState extends FlxUIState
{
	static var initialized:Bool = false;

	var fade:FlxSprite;

	var selected:Bool = false;
	public override function create()
	{
		if (!initialized)
		{
			initialized = true;
			MainState.initialized = true;
			// If this is the first time we've run the program, we initialize the TransitionData
			// When we set the default static transIn/transOut values, on construction all
			// FlxTransitionableStates will use those values if their own transIn/transOut states are null
			FlxTransitionableState.defaultTransIn = new TransitionData();
			FlxTransitionableState.defaultTransOut = new TransitionData();
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;
			FlxTransitionableState.defaultTransIn.tileData = {asset: diamond, width: 32, height: 32};
			FlxTransitionableState.defaultTransOut.tileData = {asset: diamond, width: 32, height: 32};
			// Of course, this state has already been constructed, so we need to set a transOut value for it right now:
			transOut = FlxTransitionableState.defaultTransOut;
			transIn = FlxTransitionableState.defaultTransIn;
			FlxG.game.setFilters([new ShaderFilter(new Dithering().shader)]);
			
			FlxG.mouse.useSystemCursor = true;
			FlxG.fixedTimestep = false;
		}
		camera.fade(3, true);
		#if SHOP
		Player.gold = 200;
		FlxG.switchState(new ShopState());
		return;
		#elseif BATTLE
		FlxG.switchState(new PlayState());
		return;
		#end
		FlxG.sound.playMusic("assets/music/intro.ogg", 0);
		FlxG.sound.music.fadeIn(2);
		var bg = new FlxSprite();
		bg.makeGraphic(1, 1);
		bg.color = 0x7d7d7d;
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);

		createGrid();

		var logo = new FlxAnimate("assets/images/logo");

		FlxTween.tween(logo, {y: logo.x + 30}, 1, {type: PINGPONG, ease: FlxEase.backOut});
		add(logo);

		fade = new FlxSprite();
		fade.makeGraphic(1, 1);
		fade.color = 0;
		fade.alpha = 0;
		fade.setGraphicSize(FlxG.width, FlxG.height);
		fade.updateHitbox();
		add(fade);
	}

	function createGrid()
	{
		var clampShader = new InfiniteGrid();
		clampShader.grid.input = Assets.getBitmapData("assets/images/battle/grid.png");
		var infiniteGrid = new FlxSprite(0, 0);
		infiniteGrid.makeGraphic(1, 1, 0xFFFFFFFF);
		infiniteGrid.setGraphicSize(FlxG.width * 3, FlxG.height * 3);
		infiniteGrid.updateHitbox();
		infiniteGrid.color = 0xAFAFAF;
		FlxTween.tween(infiniteGrid, {x: -175.0, y: -130.0}, 3.5, {type: LOOPING});
		infiniteGrid.shader = clampShader;
		add(infiniteGrid);
		
		var infiniteGrid2 = new FlxSprite(-200, -200);
		infiniteGrid2.makeGraphic(1, 1, 0xFFFFFFFF);
		infiniteGrid2.setGraphicSize(FlxG.width * 3, FlxG.height * 3);
		infiniteGrid2.updateHitbox();
		infiniteGrid2.color = 0;
		FlxTween.tween(infiniteGrid2, {x: -25.0, y: -70.0}, 0.9, {type: LOOPING});
		infiniteGrid2.shader = clampShader;
		add(infiniteGrid2);
	}
	override function update(elapsed:Float) 
	{
		super.update(elapsed);
		if ((FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed) && !selected)
		{
			selected = true;
			FlxG.sound.music.stop();

			camera.flash(()->FlxTween.tween(fade, {alpha: 1}, 4));
			FlxG.sound.play("assets/music/intro confirm.ogg");

			new FlxTimer().start(5, (_)->FlxG.switchState(new PlayState()));

		}
	}
}
