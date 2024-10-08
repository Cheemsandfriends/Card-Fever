package;

import flxanimate.effects.FlxBrightness;
import flxanimate.animate.FlxLayer;
import flixel.tweens.FlxTween;
import Card.CardType;
import flxanimate.FlxAnimate;

class CardDeck extends FlxAnimate 
{
    var center:FlxLayer = null;
    public function new(x:Float, y:Float)
    {
        super(x, y, "assets/images/battle/cards");
        antialiasing = true;
        this.center = anim.curSymbol.timeline.get("Center");
    }


    var brightness = new FlxBrightness(0);
    public function updateCards(left:CardType, center:CardType, right:CardType)
    {
        var layers = ["Left", "Center", "Right"];

        var types = [left, center, right];
        trace(types);
        
        for (i in 0...layers.length)
        {
            if (types[i] == INVISIBLE)
                anim.curSymbol.timeline.get(layers[i]).visible = false;
            else
            {                
                anim.curSymbol.timeline.get(layers[i]).visible = true;
                anim.curSymbol.timeline.get(layers[i]).get(0).get(0).symbol.firstFrame = cast types[i];
            }
        }
    }
    public function selectCard(?onComplete:()->Void)
    {
        var element = center.get(0); 
        element.colorEffect = brightness;
        FlxTween.tween(brightness, {brightness: 1}, {onComplete: function(_)
        {
            element.colorEffect = null;

            brightness.brightness = 0;
            
            if (onComplete != null)
                onComplete();
        }});
    }
}