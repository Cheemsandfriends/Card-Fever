package;

import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flxanimate.FlxAnimate;
import flixel.group.FlxSpriteGroup;

class UI extends FlxSpriteGroup 
{
    
    public var state:UIState;
    public var select:Int = 0;
    var table:FlxAnimate;
    var options:Int = 0;

    var typedText:FlxTypeText;

    var texts:Array<FlxText> = [];

    public var fleeing:Bool = false;

    public var powerups:Bool = false;
    public function new()
    {
        super();
        
        table = new FlxAnimate(0, 0, "assets/images/battle/UI");
        table.antialiasing = true;
        add(table);

        typedText = new FlxTypeText(0, 0, Std.int(472), "", 16);
        typedText.skipKeys = [];
        typedText.color = 0;
        typedText.screenCenter();
        typedText.y = FlxG.height - 16 * 4;
        typedText.visible = false;
        add(typedText);

        resetState();
    }

    public function resetState()
    {
        state = MAIN;
        options = table.anim.curSymbol.timeline.getList().length - 2;
        visibleButtons(true);
        updateSelection(0);
    }


    public function updateSelection(stuff:Int)
    {
        if (typedText.visible)
            return;
        var oldSelect = select;
        select += stuff;

        
        if (select < 0)
            select = options;
        if (select > options)
            select = 0;

        trace("SELECT: " + select);
        
        switch (state)
        {
            case MAIN:
                if (stuff != 0)
                {
                    var el = table.anim.curSymbol.timeline.get(oldSelect).get(0).get(0);
                    el.symbol.firstFrame = 0;
                }
                var el = table.anim.curSymbol.timeline.get(select).get(0).get(0);
                el.symbol.firstFrame = 1;
            
            case TALK:
                if (stuff != 0)
                    texts[oldSelect].color = 0x7d7d7d;

                texts[select].color = 0;
            default:

        }
    }

    public function enterSelection()
    {
        switch (state)
        {
            case MAIN:
                switch (select)
                {
                    case 0:
                        state = TALK;
                        loadTexts();
                        visibleButtons(false);
                        updateSelection(1);
                    case 1: fleeing = true;
                    case 2: 
                        visibleButtons(false);
                        updateSelection(-2);
                        state = ATTACK;
                }
            case TALK:
            if (typedText.visible)
            {
                @:privateAccess
                if (typedText._typing)
                    typedText.skip();
                else
                {
                    typedText.visible = false;
                    visibleTexts(true);
                }
                return;
            }
            switch (select)
            {
                case 0:
                visibleTexts(false);
                typedText.visible = true;
                typedText.resetText("Just the usual, a badass cyborg with a katana... \nHEALTH:100");
                typedText.start();
                typedText.skipKeys = [];

                case 1:
                    powerups = true;

                case 2: 
                    state = MAIN;
                    removeTexts();
                    visibleButtons(true);
                    updateSelection(-2);
                
            }

            default:
        }
    }

    function loadTexts()
    {
        var info:FlxText = new FlxText("Enemy Info", 24);
        info.color = 0x7d7d7d;
        info.screenCenter(X);
        info.x -= info.width;
        info.y = FlxG.height - info.height - 20;

        add(info);
        texts.push(info);

        var powerups:FlxText = new FlxText("Powerups", 24);
        powerups.color = 0x7d7d7d;
        powerups.x = info.x + info.width + 30;
        powerups.y = info.y;

        add(powerups);
        texts.push(powerups);
        
        var back:FlxText = new FlxText("Back", 24);
        back.color = 0x7d7d7d;
        back.x = powerups.x + powerups.width + 30;
        back.y = powerups.y;
        
        add(back);
        texts.push(back);
    }

    function removeTexts()
    {
        for (text in texts)
        {
            remove(text, true);
            text.destroy();
        }
        texts = [];
    }

    public function visibleButtons(visible:Bool)
    {
        table.anim.curSymbol.timeline.get(0).visible = visible;
        table.anim.curSymbol.timeline.get(1).visible = visible;
        table.anim.curSymbol.timeline.get(2).visible = visible;
    }
    function visibleTexts(visible:Bool)
    {
        for (text in texts)
        {
            text.visible = visible;
        }
    }
    
}
enum UIState 
{
    ATTACK;
    TALK;
    MAIN;    
}