package;

import flixel.ui.FlxBar;
import Card.CardType;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flxanimate.FlxAnimate;
import flixel.tweens.FlxTween;
import openfl.Assets;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tweens.misc.VarTween;

class PlayState extends FlxState
{
	public var enemy:Character;
	public var player:Player;

	public var ui:UI;

	var fade:FlxSprite;
	
	var move:Bool = false;
	var cards:CardDeck = null;

	
	var healthText:FlxText = null;

	var bar:FlxBar = null;

	override public function create()
	{
		var uiCamera = new FlxCamera();
		FlxG.cameras.add(uiCamera, false);
		uiCamera.bgColor = 0;
		var bg = new FlxSprite();
		bg.makeGraphic(1, 1, FlxColor.GRAY);
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);

		createGrid();


		enemy = new Character(100, 0, "assets/images/battle/enemy");
		if (Player.fledCount > 0)
		{
			enemy.health += enemy.health * (0.15 * Player.fledCount);
			enemy.damageBoost += FlxG.random.float(0.1, 2) * Player.fledCount;
		}
		enemy.powerups = [Health => FlxG.random.int(0, 3), Damage => FlxG.random.int(0, 2), Card => FlxG.random.int(0, 1)];
		enemy.hurtSound = "hurtEnemy.ogg";
		enemy.deathSound = "deathEnemy.ogg";
		add(enemy);

		var gradient = new FlxSprite();
		gradient.makeGraphic(1, 1, 0);
		gradient.setGraphicSize(FlxG.width, 171);
		gradient.updateHitbox();
		gradient.setPosition(0, FlxG.height - gradient.height);
		gradient.shader = new GradientStuff(0xFF000000, 0, true).shader;
		add(gradient);
		player = new Player(-100, 0);
		add(player);

		for (i in 0...7)
		{
			var playerCard = new Card();
			playerCard._char = player;
			player.cards.push(playerCard);
			var enemyCard = new Card();
			enemyCard._char = enemy;
			enemy.cards.push(enemyCard);
		}
		FlxG.sound.play("assets/sounds/mixing cards.ogg", 0.5);

		healthText = new FlxText(0, 0, "", 24);
		healthText.visible = false;
		add(healthText);
		
		bar = new FlxBar(0, 0, LEFT_TO_RIGHT, 50);
		bar.visible = false;
		add(bar);

		ui = new UI();
		add(ui);

		cards = new CardDeck(0, FlxG.height);
		add(cards);
		var challenge = new FlxAnimate("assets/images/challenge");
		challenge.anim.play();
		challenge.anim.onComplete.add(()-> {createState(); FlxTween.tween(challenge, {alpha: 0}, {onComplete: (_)-> remove(challenge)});});
		add(challenge);

		FlxG.sound.play("assets/sounds/knife.ogg", 0.5);


		fade = new FlxSprite();
		fade.makeGraphic(1, 1);
		fade.color = 0;
		fade.alpha = 0;
		fade.setGraphicSize(FlxG.width, FlxG.height);
		fade.updateHitbox();
		add(fade);
		super.create();
	}
	
	function createState()
	{
		FlxG.sound.playMusic("assets/music/battle.ogg", 0., true);
		var song = FlxG.sound.music;
		song.play(true, FlxG.random.float(0, song.length));
		song.fadeIn(1, 0, 0.5);

		subStateOpened.add((_)->song.pause());
		subStateClosed.add((_)->song.fadeIn(1, 0, 0.5));
		
		
		FlxTween.tween(enemy, {x: 0}, 1, {ease: FlxEase.backOut});
		
		FlxTween.tween(player, {x: 0}, 1, {ease: FlxEase.backOut});

		FlxTween.tween(ui, {y: 0}, 1, {ease: FlxEase.backOut});

		move = true;
	}

	function createGrid()
	{
		var clampShader = new InfiniteGrid();
		clampShader.grid.input = Assets.getBitmapData("assets/images/battle/grid.png");
		var infiniteGrid = new FlxSprite(0, 0);
		infiniteGrid.makeGraphic(1, 1, 0xFFFFFFFF);
		infiniteGrid.setGraphicSize(FlxG.width * 3, FlxG.height * 3);
		infiniteGrid.updateHitbox();
		infiniteGrid.color = 0xAFAFAF;
		FlxTween.tween(infiniteGrid, {x: -175.0, y: -130.0}, 3.5, {type: LOOPING});
		infiniteGrid.shader = clampShader;
		add(infiniteGrid);
		
		var infiniteGrid2 = new FlxSprite(-200, -200);
		infiniteGrid2.makeGraphic(1, 1, 0xFFFFFFFF);
		infiniteGrid2.setGraphicSize(FlxG.width * 3, FlxG.height * 3);
		infiniteGrid2.updateHitbox();
		infiniteGrid2.color = 0;
		FlxTween.tween(infiniteGrid2, {x: -25.0, y: -70.0}, 3.5, {type: LOOPING});
		infiniteGrid2.shader = clampShader;
		add(infiniteGrid2);
	}

	var showingCards:Bool = false;
	var playerTurn = true;

	var tw:VarTween = null;
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (ui.fleeing || !player.alive || !enemy.alive)
			return;
		
		if (FlxG.keys.justPressed.ESCAPE)
			openSubState(new PauseSubstate());
		
		if (move)
		{
			if (FlxG.keys.justReleased.LEFT)
			{
				FlxG.sound.play("assets/sounds/click.ogg").pitch = 0.7;
				ui.updateSelection(-1);
				
				updateCards();
			}
			if (FlxG.keys.justReleased.RIGHT)
			{
				FlxG.sound.play("assets/sounds/click.ogg").pitch = 1.;
				ui.updateSelection(1);
				
				updateCards();
			}
			if (FlxG.keys.justPressed.ENTER)
			{
				if (ui.state != ATTACK)
					ui.enterSelection();
				else
				{
					move = false;
					cards.selectCard(()-> 
					{
						hurt(enemy, player, ui.select);
						new FlxTimer().start(1, (_)-> FlxTween.tween(cards, {y: FlxG.height}, {ease: FlxEase.backIn}));
						showingCards = false;
						ui.resetState();
						ui.visibleButtons(false);
						if (enemy.alive)
							new FlxTimer().start(2, (_)->enemyTurn());
					});
					player.damageBoost -= 0.1;
				}
			}
			if (FlxG.keys.justPressed.BACKSPACE)
			{
				if (ui.state == ATTACK)
				{
					ui.resetState();
					showingCards = false;
					if (tw.percent != 1)
						tw.cancel();
					cards.y = FlxG.height;
				}
			}
		}
		if (ui.powerups)
		{
			ui.powerups = false;
			openSubState(new UpsSubstate());
		}
		if (ui.state == ATTACK)
		{
			if (!showingCards)
			{
				FlxG.sound.play("assets/sounds/flipcard.ogg");
				tw = FlxTween.tween(cards, {y: 0}, 1, {ease: FlxEase.backOut});
				showingCards = true;
				updateCards();
			}
		}

		if (ui.fleeing)
		{
			finish();
			Player.fledCount++;
		}
	}

	function finishStuff()
	{
		Player.Playerpowerups = (player.alive) ? player.powerups : [Health => 0, Damage => 0, Card => 0];
		finish(2);
		Player.fledCount--;
	}

	function finish(?duration:Float = 1)
	{
		FlxG.sound.music.fadeOut(duration);
		persistentUpdate = true;
		openSubState(new ResultsSubstate());
		FlxTween.tween(fade, {alpha: 1}, duration);
	}

	function hurt(char:Character, caller:Character, choose:Int = 0)
	{
		var card = caller.cards[choose];
		var boost = caller.damageBoost;
		var dmg = card.damage + (card.damage * boost);
		var callerDamage = false;
		switch (card.type)
		{
			case KATT:
				if (FlxG.random.bool())
					char.hurt(dmg);
				else
				{
					callerDamage = true;
					caller.hurt(dmg);

					char = caller;
				}

			case POTION:
				char.heal(dmg);

			default:
				char.hurt(dmg);
		}
		if (!char.alive || !caller.alive)
			finishStuff();
		var x = char.anim.curInstance.matrix.tx;
		var y = char.anim.curInstance.matrix.ty;
		healthText.setPosition(x + 20, y + char.height * 0.5 - 50);

		if (char != player)
		{
			healthText.x += 250;
			healthText.y -= 270;
		}
		healthText.text = Std.string(char.health);

		bar.setPosition(healthText.x + (healthText.width - bar.width) * 0.5, healthText.y + healthText.height);
		bar.value = char.health;

		bar.visible = true;
		healthText.visible = true;

		card.uses--;

		new FlxTimer().start(1, (_)-> {
			healthText.visible = false;
			bar.visible = false;
		});
	}

	function enemyTurn()
	{
		var healths:Int = 0;
		var attacks:Int = 0;

		for (i in 0...enemy.powerups.get(Health))
		{
			if (!FlxG.random.bool((1 - (enemy.health * 0.01)) * 100))
			{
				break;
			}
			healths++;
		}
		for (i in 0...enemy.powerups.get(Damage))
		{
			if (!FlxG.random.bool((1 - (player.health * 0.01)) * 100))
			{
				break;
			}
			attacks++;
		}

		function attackBoost()
		{
			new FlxTimer().start(FlxG.random.float(0.1, 0.3), function(_)
			{
				enemy.usePowerup(Damage);
				enemyAttack();
			});
		}

		if (healths > 0)
		{
			new FlxTimer().start(FlxG.random.float(0.2, 0.5), function(_)
			{
				enemy.usePowerup(Health);
				if (attacks > 0)
					attackBoost();
				else
					enemyAttack();
			});
		}
		else if (attacks > 0)
			attackBoost();
		else
			enemyAttack();

		
		
	}
	function enemyAttack()
	{
		new FlxTimer().start(FlxG.random.float(0.5, 1), function(_)
		{
			hurt(player, enemy, FlxG.random.int(0, enemy.cards.length - 1));
			new FlxTimer().start(function(_)
			{
				ui.resetState();
				move = true;
			});
		});
	}
	
	function updateCards()
	{
		if (showingCards)
		{
			@:privateAccess
			ui.options = player.cards.length - 1;
			var min = ui.select - 1;
			if (min < 0)
				min = player.cards.length - 1;

			var type1 = INVISIBLE;
			var type2 = INVISIBLE;
			var type3 = INVISIBLE;

			if (player.cards.length > 3)
			{
				type1 = (player.cards[min] != null) ?  player.cards[min].type : INVISIBLE;
				type2 = (player.cards[ui.select] != null) ?  player.cards[ui.select].type : INVISIBLE;
				type3 = (player.cards[(ui.select + 1) % player.cards.length] != null) ?  player.cards[(ui.select + 1) % player.cards.length].type : INVISIBLE;
			}
			else
			{
				type1 = (player.cards[ui.select - 1] != null) ?  player.cards[ui.select - 1].type : INVISIBLE;
				type2 = (player.cards[ui.select] != null) ?  player.cards[ui.select].type : INVISIBLE;
				type3 = (player.cards[ui.select + 1] != null) ?  player.cards[ui.select + 1].type : INVISIBLE;

			}


			cards.updateCards(type1, type2, type3);
		}
	}
}

class InfiniteGrid extends FlxShader
{

	@:glFragmentSource("
	#pragma header
	uniform float zoom;
	uniform sampler2D grid;

	void main()
	{
		gl_FragColor = flixel_texture2D(grid, openfl_TextureCoordv / zoom);
	}
	")
	public function new()
	{
		super();
		grid.wrap = REPEAT;
		zoom.value = [0.09];
	}
}