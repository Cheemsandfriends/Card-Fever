package;

import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxSubState;

class PauseSubstate extends FlxSubState 
{
    override public function create() 
    {
        var bg = new FlxSprite();
        bg.makeGraphic(1, 1);
        bg.color = 0;
        bg.alpha = 0.6;
        bg.setGraphicSize(FlxG.width, FlxG.height);
        bg.updateHitbox();
        add(bg);

        var text = new FlxText("PAUSED", 32);
        text.setPosition(FlxG.width - text.width, 0);

        FlxTween.tween(text, {alpha: 0}, 1, {type: PINGPONG});

        add(text);

        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ENTER)
            close();
    }

}