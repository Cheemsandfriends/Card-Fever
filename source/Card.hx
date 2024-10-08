package;

import flxanimate.FlxAnimate;

class Card 
{
    public var type:CardType = cast 1;

    public var damage:Float = 2;
    public var uses(default, set):Int = 999999;

    public var _char:Character = null;

    
    public dynamic function hurtChar(user:Character, ?caller:Character = null)
    {
        user.hurt(damage + (damage * user.damageBoost));
    }


    public function new()
    {
        var stats = [5, 10, 25, 35, 50, 99.99, 50];
        var uses = [5, 2, 1, 1, 2, 1, 1, 1];


        var chances = [50, 20, 10, 20, 10, 0.001, 20];

        for (i in 0...stats.length)
        {
            if (FlxG.random.bool(chances[i]))
            {
                type = cast i + 1;
            }
        }

        damage = stats[(cast type) - 1];
        this.uses = uses[(cast type) - 1];

        switch (type)
        {
            case KATT:
                hurtChar = function(char, ?player)
                {
                    if (FlxG.random.bool())
                        char.hurt((damage * char.damageBoost));
                    else
                        player.hurt((damage * char.damageBoost));
                }

			case POTION:
                hurtChar = function (char, ?player)
                {
				    char.heal((damage * char.damageBoost));
                }

            default:
        }
    }

    function set_uses(value:Int)
    {
        if (value <= 0 && _char != null)
        {
            _char.cards.remove(this);
        }

        return uses = value;
    }
}
enum abstract CardType(Int)
{
    var INVISIBLE = -1;
    var PEASANT = 1;
    var GOBLIN = 2;
    var KNIGHT = 3;
    var WIZZ = 4;
    var KATT = 5;
    var FLIXEL = 6;
    var POTION = 7;

    public function toString()
    {
        var type:CardType = cast this;
        return switch (type)
        {
            case PEASANT: "PEASANT";
            case GOBLIN: "GOBLIN";
            case KNIGHT: "KNIGHT";

            case _: "";
        }
    }
}