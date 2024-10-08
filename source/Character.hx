package;

import Player.PowerUps;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flxanimate.effects.FlxTint;
import flxanimate.FlxAnimate;

class Character extends FlxAnimate 
{
    public var hurtSound:String = null;
    public var deathSound:String = null;

    public var powerups:Map<PowerUps, Int> = [Health => 0, Damage => 0, Card => 0];
    var tint = new FlxTint(0xFF0000, 0.5);

    public var damageBoost(default, set):Float = 0;

    public var cards:Array<Card> = [];
    public function new(x,y,path)
    {
        super(x, y, path);
        antialiasing = true;
        anim.play();
        health = 100;
        deathSound = "death.ogg";
        anim.curInstance.symbol.colorEffect = tint;
        tint.multiplier = 0.0;
    }

    
    override function hurt(damage:Float)
    {
        if (health - damage > 0)
        {
            if (hurtSound != null)
                FlxG.sound.play("assets/sounds/" + hurtSound);
            
            tint.tint = 0xFF0000;
            tint.multiplier = 0.5;

            FlxTween.tween(tint, {multiplier: 0.0});
            
            flickerValue(this, "x", [-3, 3], 0.06, ()->x = 0);
        }
        super.hurt(damage);
    }

    override function kill() 
    {
        alive = false;
        if (deathSound != null)
            FlxG.sound.play("assets/sounds/" + deathSound, ()->exists = false);
        anim.curInstance.symbol.colorEffect = tint;
        tint.multiplier = 0.5;
        
        flickerValue(this, "x", [-3, 3], 0.06, 0, ()-> x = 0);
    }

    public function usePowerup(powerup:PowerUps)
    {
        var num = powerups[powerup];

        if (num > 0)
        {
            switch (powerup)
            {
                case Health: 
                    heal(health * 0.05);
                    
                case Damage: damageBoost += 0.03;
                case Card:
                    var card = new Card();
                    card._char = this;
                    cards.push(card);
                case _:
            }

            num--;
            powerups.set(powerup, num);
        }
        
    }
    public function heal(amount:Float)
    {
        health += amount;
        tint.tint = 0x00FF00;
        tint.multiplier = 0.5;

        FlxTween.tween(tint, {multiplier: 0.0});
    }

    function flickerValue(object:Dynamic, value:String, values:Array<Dynamic>, endValue:Bool = true, interval:Float = 0.04, duration:Float = 1, ?onComplete:()->Void = null)
    {
        new FlxTimer().start(interval, flickerProgress.bind(object, value, values, endValue, onComplete), Std.int(duration / interval));
    }
    var i:Int = 1;
    function flickerProgress(object:Dynamic, value:String, values:Array<Dynamic>, endVisibility:Bool, ?onComplete:()->Void = null, Timer:FlxTimer):Void
	{
        i++;
        i %= 2;

        Reflect.setProperty(object, value, values[i]);

		if (Timer.loops > 0 && Timer.loopsLeft == 0)
		{
            Reflect.setProperty(object, value, (endVisibility) ? values[1] : values[0]);
            i = 0;
            if (onComplete != null)
                onComplete();
		}
	}

    function set_damageBoost(value:Float)
    {
        return damageBoost = FlxMath.bound(value, 0);
    } 
}