package;

import Player.PowerUps;
import flixel.text.FlxText;
import flxanimate.frames.FlxAnimateFrames;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSubState;

class UpsSubstate extends FlxSubState 
{
    
    var names = ["Health Boost", "Damage Boost", "Additional Card"];

    var stuff:Array<PowerUps> = [Health, Damage, Card];
    
    var texts:Array<FlxText> = [];
    var sprites:Array<FlxSprite> = [];

    var amounts:Array<FlxText> = [];

    var choose:Int = 0;

    var _state:PlayState;

    override public function create()
    {
        super.create();

        _state = cast _parentState;

        var bg = new FlxSprite();
        bg.makeGraphic(1, 1);
        bg.color = 0;
        bg.alpha = 0.6;
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.updateHitbox();
        add(bg);
        var grp = new FlxSpriteGroup();
        
        for (i in 0...names.length)
        {
            var oldSpr = null;
            if (i > 0)
                oldSpr = sprites[i - 1];
            var sprite = new FlxSprite();
            sprite.frames = FlxAnimateFrames.fromSparrow(AssetPaths.awards__xml);
            sprite.animation.frameIndex = i;
            sprite.setGraphicSize(sprite.width * 0.8);
            sprite.updateHitbox();
            if (oldSpr != null)
            {
                sprite.setPosition(oldSpr.x, oldSpr.y + oldSpr.height + 30);
            }

            
            grp.add(sprite);
            sprites.push(sprite);

            var amount = new FlxText(0, 0, Std.string(_state.player.powerups.get(stuff[i])), 16);
            amount.setPosition(sprite.x + sprite.width - amount.width, sprite.y + sprite.height - amount.height);

            grp.add(amount);
            amounts.push(amount);

            var text = new FlxText(sprite.x + sprite.width + 30, sprite.y + sprite.height / 2, names[i], 24);
            grp.add(text);
            texts.push(text);
        }

        grp.screenCenter();
        add(grp);

        updateChoosing(0);
    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.BACKSPACE)
            close();

        if (FlxG.keys.justReleased.UP)
        {
            FlxG.sound.play("assets/sounds/click.ogg").pitch = 1.;
            updateChoosing(-1);
        }
        if (FlxG.keys.justReleased.DOWN)
        {
            FlxG.sound.play("assets/sounds/click.ogg").pitch = 0.7;
            updateChoosing(1);
        }
        if (FlxG.keys.justReleased.ENTER)
        {
            _state.player.usePowerup(stuff[choose]);
            amounts[choose].text = Std.string(_state.player.powerups[stuff[choose]]);
        }
    }

    function updateChoosing(num:Int)
    {
        var oldChoose = choose;
        choose += num;
        
        if (choose < 0)
            choose = texts.length - 1;
        if (choose > texts.length - 1)
            choose = 0;

        if (num != 0)
        {
            texts[oldChoose].color = 0xFFFFFFFF;
            amounts[oldChoose].color = 0xFFFFFFFF;
        }

        texts[choose].color = 0xFFFFBB00;
        amounts[choose].color = 0xFFFFBB00;

    }
}