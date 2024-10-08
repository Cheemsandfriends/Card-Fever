package;

import flixel.math.FlxMath;


class Player extends Character
{
    public static var Playerpowerups:Map<PowerUps, Int> = [Health => 0, Damage => 0, Card => 0];

    public static var fledCount:Int = 0;

    public static var gold:Int = 0;


    



    public function new(x:Float, y:Float)
    {
        super(x, y, "assets/images/battle/player");
        hurtSound = "hurtPlayer.ogg";
        deathSound = "death.ogg";
        powerups = Playerpowerups; 
    } 
}

enum PowerUps
{
    Health;
    Damage;
    Card;
    Random;
}