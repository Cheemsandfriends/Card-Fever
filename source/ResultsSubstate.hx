package;

import flixel.util.FlxTimer;
import flxanimate.FlxAnimate;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSubState;

class ResultsSubstate extends FlxSubState 
{
    var _state:PlayState;
    var choose:Int = 0;
    var options:Int = 0;

    var store:FlxText;
    var leave:FlxText;
    var move:Bool = false;
    var checkedFade:Bool = false;
    override function create() 
    {
        super.create();
        _state = cast (_parentState, PlayState);
        
        if (_state.ui.fleeing)
        {
            FlxG.sound.play("assets/sounds/running.ogg", 0.5, ()-> move = true);


            var fledTxt = new FlxText("You fled....", 32);
            fledTxt.alpha = 0;
            fledTxt.screenCenter();
            fledTxt.y -= 50;
            add(fledTxt);
            FlxTween.tween(fledTxt, {alpha: 1}, 3);
        }

        store = new FlxText("Go to the store", 24);
        store.screenCenter();
        store.alpha = 0;
        store.x -= 170;
        add(store);

        leave = new FlxText("Leave", 24);
        leave.alpha = 0;
        leave.screenCenter();
        leave.x += 50 + leave.width;
        add(leave);
        updateChoosing(0);
    }

    public function atlasResults()
    {
        var lose = !_state.player.alive;
        var results = new FlxAnimate(310, 240, "assets/images/battle/results");

        if (lose)
            results.anim.playElement(results.anim.curSymbol.getElement(0, 0));
        else
            results.anim.playElement(results.anim.curSymbol.getElement(0, 1));

        
        results.anim.onComplete.add(()-> (lose) ? FlxG.switchState(new MainState()) : move = true);

        if (lose)
            Player.gold = 0;
        else
            Player.gold += Std.int(10 + (10 * (1 - _state.player.health * 0.01)));
        if (lose)
            new FlxTimer().start(0.5, (_)->FlxG.sound.play("assets/sounds/writhing.ogg"));
        store.y = FlxG.height - store.height - 30;
        leave.y = FlxG.height - leave.height - 30;

        add(results);
    }

    override public function update(elapsed:Float) 
    {
        super.update(elapsed);

        if ((!_state.player.exists || !_state.enemy.exists) && !checkedFade)
        {
            checkedFade = true;
            atlasResults();
        }
        if (move)
        {
            if (store.alpha == 0)
            {
                FlxTween.tween(store, {alpha: 1}, 0.5);
                FlxTween.tween(leave, {alpha: 1}, 0.5);
            }

            if (FlxG.keys.justReleased.LEFT)
            {
                FlxG.sound.play("assets/sounds/click.ogg").pitch = 0.7;
                updateChoosing(-1);
            }
            if (FlxG.keys.justReleased.RIGHT)
            {
                FlxG.sound.play("assets/sounds/click.ogg").pitch = 1.;
                updateChoosing(1);
            }

            if (FlxG.keys.justReleased.ENTER)
            {
                move = false;
                if (choose == 0)
                    FlxG.switchState(new ShopState());
                else
                    FlxG.switchState(new MainState());

            }
        }
    }

    function updateChoosing(num:Int)
    {
        choose += num;
        
        if (choose < 0)
            choose = 1;
        if (choose > 1)
            choose = 0;

        if (choose == 0)
        {
            store.color = 0xFFFFBB00;
            leave.color = 0xFFFFFFFF;
        }
        else
        {
            store.color = 0xFFFFFFFF;
            leave.color = 0xFFFFBB00;
        }
    }
}