package;

import flixel.math.FlxMath;
import openfl.filters.ShaderFilter;
import flixel.tweens.misc.VarTween;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import flxanimate.FlxAnimate;
import flxanimate.frames.FlxAnimateFrames;
import openfl.Assets;
import Player.PowerUps;

class ShopState extends FlxUIState
{

    
    static var soldOutItems:Map<Int, Bool> = [];
    static var introTexts:Array<String> = [
        "Oh... its you....",
        "...Welcome to Melle Inc. If you even care",
        "Just buy your shizz already....."
    ];

    static var purchaseTexts:Array<String> = [
        "Oh Wow, you're that pathetic aren't you?",
        "Hooray.... I guess....",
        "What if I sold you a suicide pill and kys for once?",
        "Oh shut up Jesus....",
        "Just buy your stuff and leave.....",
        "You done yet?",
        "Don't forget to get killed now!",
        "uuugh.....",
        "Kyle, just.... Just go I can't stand your face today."
    ];
    static var soldOutTexts:Array<String> = [
        "Its.... Its literally sold out",
        "read the fucking sign",
        "You blind? Look what it says",
        "what part of \"Out of stock\" dont you understand?",
        "Dumbass"
    ];
    static var poorTexts:Array<String> = [
        "Homeless people are richer than you",
        "Look at you, cannot even afford this piece of crap",
        "No wonder you dress like that, you can't even afford this!!!",
        "Stop wasting my time and get out.....",
        "I'd hire a circus if I wanted a show yknow...."
    ];

    static var infoTexts = [
        "Health Boost",
        "Damage Boost",
        "Additional Card",
        "Random",
        "Out of stock"
    ];
    static var byeTexts = [
        "Finally, took you long enough",
        "And don't come back!!!",
        "Finally some peace alone.....",
        "I'll miss you is what would say if I cared",
        "*yawn*",
        "Instead of buying stuff, why don't you die?"
    ];

    static var cost = [20, 50, 100, 40];
	var text:FlxTypeText;
	var bubble:FlxSprite;
    #if true
	var lucy:FlxAnimate;
    #end
    
    var awards:FlxSprite;
    var outOf:FlxSprite;
    var awardsInt:Int = 0;
    var awardsText:FlxText;

    var arrowLeft:FlxSprite;
    var arrowRight:FlxSprite;

    var purchasedCamera:FlxCamera;
    var purchasedText:FlxText;
    var glitter:Glitter;

    var costText:FlxText;

    public var leaving:Bool = false;

    var fade:FlxSprite;

	public override function create()
	{
        FlxSprite.defaultAntialiasing = true;

        FlxG.sound.playMusic(AssetPaths.shop__ogg, 0., true);
        FlxG.sound.music.fadeIn();
        
        purchasedCamera = new FlxCamera();
        purchasedCamera.bgColor = 0;
        FlxG.cameras.add(purchasedCamera, false);
        glitter = new Glitter();
        // camera.filters = [new ShaderFilter(glitter.shader)];


		var gradient = new FlxSprite();
        gradient.blend = NORMAL;
		gradient.makeGraphic(1, 1);
		gradient.setGraphicSize(FlxG.width, FlxG.height);
		gradient.updateHitbox();
		gradient.shader = new GradientStuff(0xFBDDFF, 0xF162F2).shader;
		add(gradient);


        #if true
		lucy = new FlxAnimate("assets/images/shop/attendant", {Antialiasing: true});
		lucy.antialiasing = true;
        lucy.anim.play();
		add(lucy);
        #end

		bubble = new FlxSprite();
		bubble.frames = FlxAnimateFrames.fromSparrow(AssetPaths.speechbubble__xml);
		bubble.animation.addByPrefix("idle", "SpeechBubble", 24);
		bubble.animation.play("idle");
		bubble.setPosition(0, FlxG.height - bubble.height);

		add(bubble);

        awards = new FlxSprite(133.6, 120);
        awards.frames = FlxAnimateFrames.fromSparrow(AssetPaths.awards__xml);
        
        
        outOf = new FlxSprite(awards.x, awards.y);
        outOf.frames = awards.frames;
        outOf.animation.frameIndex = outOf.frames.frames.length - 1;
        outOf.visible = false;

        awardsText = new FlxText(awards.x, awards.y + awards.height, 0, 24);

        costText = new FlxText("", 24);
        

        updateSelection(0);

        arrowLeft = new FlxSprite(50, 135.65);
        arrowLeft.frames = FlxAnimateFrames.fromSparrow(AssetPaths.arrows__xml);
        arrowLeft.animation.addByPrefix("press", "ArrowL", 24, false);
        arrowLeft.animation.play("press");
        add(arrowLeft);


        arrowRight = new FlxSprite(284.1, 130.5);
        arrowRight.frames = FlxAnimateFrames.fromSparrow(AssetPaths.arrows__xml);
        arrowRight.animation.addByPrefix("press", "ArrowR", 24, false);
        arrowRight.animation.play("press");
        add(arrowRight);

        add(awards);
        add(outOf);
        add(awardsText);
        add(costText);


		text = new FlxTypeText(bubble.x + 50, bubble.y + bubble.height * 0.5, Std.int(bubble.width - 50), "", 16);
		text.color = 0;
		text.sounds = [
			FlxG.sound.load(Assets.getSound(AssetPaths.beep1__ogg)),
			FlxG.sound.load(Assets.getSound(AssetPaths.beep2__ogg)),
			FlxG.sound.load(Assets.getSound(AssetPaths.beep3__ogg)),
			FlxG.sound.load(Assets.getSound(AssetPaths.beep4__ogg)),
			FlxG.sound.load(Assets.getSound(AssetPaths.beep5__ogg)),
		];

		text.cursorBlinkSpeed = 0.6;
		text.skipKeys = [SPACE];
        #if true
		text.completeCallback = () -> lucy.anim.symbolDictionary["Head"].getElementByName("Mouth", 0).symbol.loop = SingleFrame;
        #end
		add(text);

        purchasedText = new FlxText(0, 0, 0, "PURCHASED\n", 32);
        
        purchasedText.camera = purchasedCamera;
        purchasedText.alpha = 0;
        add(purchasedText);

		startText(introTexts[FlxG.random.int(0, introTexts.length - 1)]);
        
        fade = new FlxSprite();
		fade.makeGraphic(1, 1);
		fade.color = 0;
		fade.alpha = 0;
		fade.setGraphicSize(FlxG.width, FlxG.height);
		fade.updateHitbox();
		add(fade);
	}

    var processL:Bool = false;
	override function update(elapsed:Float)
	{
        super.update(elapsed);
        if (processL)
            return;
        glitter.update(elapsed);
        if (leaving)
        {

            FlxG.sound.music.fadeOut(4);
            FlxTween.tween(fade, {alpha: 1}, 4, {onComplete: (_)-> FlxG.switchState(new PlayState())});
            
            startText(byeTexts[FlxG.random.int(0, byeTexts.length - 1)]);

            processL = true;
        }

        if (FlxG.keys.pressed.LEFT)
            arrowLeft.animation.play("press", true);
        if (FlxG.keys.pressed.RIGHT)
            arrowRight.animation.play("press", true);
        
        if (FlxG.keys.justReleased.LEFT)
        {
            FlxG.sound.play("assets/sounds/click.ogg").pitch = 0.7;
            updateSelection(-1);
        }
        if (FlxG.keys.justReleased.RIGHT)
        {
            FlxG.sound.play("assets/sounds/click.ogg").pitch = 1.;
            updateSelection(1);
        }

        if (FlxG.keys.justPressed.ENTER)
        {

            if (outOf.visible)
            {
                startText(soldOutTexts[FlxG.random.int(0, soldOutTexts.length - 1)]);

            }
            else
            {
                    var powerup = int2Powerup();
                    purchaseObject(powerup);
                    startText("...");
            }
        }

        if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
            openSubState(new DecidingSubState());

        
	}

    var tween:VarTween = null;
    function purchaseObject(powerup:PowerUps)
    {
        camera.flash(0xbc7d7d7d, true);
        if (tween != null)
            tween.cancel();

        purchasedText.text = "PURCHASED\n";
        purchasedText.text += switch (powerup)
        {
            case Health: "Health Boost";
            case Damage: "Damage Boost";
            case Card: "Additional Card";
            case _: "";
        }
        purchasedText.alpha = 1;
        purchasedText.screenCenter();

        tween = FlxTween.tween(purchasedText, {alpha: 0, y: purchasedText.y - 30});
        
        Player.Playerpowerups.set(powerup, Player.Playerpowerups[powerup] + 1);

        FlxG.sound.play("assets/sounds/purchase.ogg");
        startText(purchaseTexts[FlxG.random.int(0, purchaseTexts.length - 1)]);
        recalculateStuff(powerup);

    }

    function recalculateStuff(powerup:PowerUps)
    {
        var amount = Player.Playerpowerups[powerup];

        var limit = [3, 2, 1, FlxMath.MAX_VALUE_INT];

        var int = powerup2Int(powerup);

        soldOutItems.set(int, amount >= limit[int]);
        var allSold:Bool = true;
        if (soldOutItems != [])
        {
            var i = 0;
            for (item in soldOutItems.iterator())
            {
                if (!item)
                {
                    allSold = false;
                    break;
                }
                i++;
            }
            if (i < 3)
                allSold = false;
        }
        else
            allSold = false;
        if (allSold)
            soldOutItems.set(3, true);
        updateSelection(0);
    }

    function powerup2Int(powerup:PowerUps)
    {

        return switch (powerup)
        {
            case Health: 0;
            case Damage: 1;
            case Card: 2;
            case Random: 3;
        }
        return -1;
    }

    function int2Powerup(random:Bool = false)
    {
        var number = awardsInt;

        if (random)
        {
            var arr = [];
            for (item in soldOutItems.keys())
            {
                if (soldOutItems[item])
                    arr.push(item);
            }
            number = FlxG.random.int(0, 2, arr);
        }
        return switch (number)
        {
            case 0: Health;
            case 1: Damage;
            case 2: Card;
            case 3: int2Powerup(true);
            case _: null;
        }
    }

	function startText(str:String)
	{
		text.resetText(str);
		text.start();
        #if true
		lucy.anim.symbolDictionary["Head"].getElementByName("Mouth", 0).symbol.loop = Loop;
        #end
	}

    function updateSelection(select:Int)
    {
        awardsInt += select;

        if (awardsInt < 0)
            awardsInt = awards.frames.frames.length - 2;
        else if (awardsInt > awards.frames.frames.length - 2)
            awardsInt = awardsInt = 0;

        awards.animation.frameIndex = awardsInt;

        awardsText.text = infoTexts[awardsInt];
        awardsText.x = awards.x;
        costText.text = Std.string(cost[awardsInt]);
        costText.setPosition((awards.x + 72.5) - 20, awards.y - costText.height);
        
        outOf.visible = soldOutItems[awardsInt];
    }
}