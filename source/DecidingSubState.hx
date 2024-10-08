package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;

class DecidingSubState extends FlxSubState 
{
      
    var choose:Int = 0;
    var store:FlxText;
    var leave:FlxText;
    var _state:ShopState;
    override function create() 
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


        var fledTxt = new FlxText("Leave the store?", 32);
        fledTxt.screenCenter();
        fledTxt.y -= 50;
        add(fledTxt);

        store = new FlxText("Yes", 24);
        store.screenCenter();
        store.x -= 10 + store.width;
        add(store);

        leave = new FlxText("No", 24);
        leave.screenCenter();
        leave.x += 10 + leave.width;
        add(leave);
        updateChoosing(0);

    }

    override function update(elapsed:Float) 
    {
        super.update(elapsed);

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
            if (choose == 0)
                _state.leaving = true;

            close();
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