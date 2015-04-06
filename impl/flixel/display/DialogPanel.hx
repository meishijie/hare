package impl.flixel.display;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import rpg.event.ScriptHost.InputNumberOptions;
import rpg.event.ScriptHost.ShowChoicesChoice;
import rpg.event.ScriptHost.ShowChoicesOptions;
import rpg.event.ScriptHost.ShowTextOptions;
import rpg.Events;
import rpg.input.InputManager.InputKey;

/**
 * TODO handle disabled and hidden choices
 * @author Kevin
 */
class DialogPanel extends FlxSpriteGroup
{
	/**
	 * Text by default are shown letter by letter.
	 * This Bool indicates if the text has been completely shown
	 */
	public var completed(get, never):Bool;
	
	/**
	 * The border sprite
	 */
	private var border:Slice9Sprite;
	
	/**
	 * The selector sprite for choices
	 */
	private var selector:Slice9Sprite;
	private var background:FlxSprite;
	private var downArrow:FlxSprite;
	private var tween:FlxTween;
	private var text:Text;
	private var message:String;
	private var inputNumberPanel:InputNumberPanel;
	
	private var showTextListener:Int;
	private var showChoicesListener:Int;
	private var inputNumberListener:Int;
	
	private var showTextCallback:Void->Void;
	private var showChoicesCallback:Int->Void;
	private var inputNumberCallback:Int->Void;
	
	private var numChoices:Int;
	private var selected(default, set):Int;
	
	public function new() 
	{
		super();
		
		border = new Border(0, 0, 640, 150);
		
		selector = new Selector(95, 40, 500, 25);
		
		downArrow = new FlxSprite();
		downArrow.loadGraphic("assets/images/system/system.png", true, 16, 16);
		downArrow.animation.add("move", [38, 39, 46, 47], 5);
		downArrow.animation.play("move");
		downArrow.setPosition((FlxG.width - downArrow.width) / 2, 120);
		
		background = new FlxSprite();
		background.loadGraphic("assets/images/system/system.png", true, 64, 64);
		background.origin.set();
		background.alpha = 0.9;
		background.setGraphicSize(FlxG.width, 150);
		
		text = new Text(100, 15, 1000, "", 20);
		
		inputNumberPanel = new InputNumberPanel();
		inputNumberPanel.y = -30;
		
		add(background);
		add(border);
		add(text);
		add(selector);
		add(downArrow);
		add(inputNumberPanel);
		
		visible = false;
		scrollFactor.set();
		y = 480 - 150;
		
		
		showTextListener = Events.on("key.justPressed", function(key:InputKey)
		{
			if (key == KEnter)
			{
				if (!completed)
				{
					// immediately show all text
					showAll();
				}
				else
				{
					// dismiss this text panel
					visible = false;
					Events.disable(showTextListener);
					showTextCallback();
				}
			}
		});
		// disable the listener for now, it will be enabled when showText
		Events.disable(showTextListener);
		
		
		showChoicesListener = Events.on("key.justPressed", function(key:InputKey)
		{
			switch (key) 
			{
				case KUp:
					if(completed)
						selected -= 1;
					
				case KDown:
					if(completed)
						selected += 1;
					
				case KEnter:
					if (!completed)
					{
						// immediately show all text
						showAll();
					}
					else
					{
						// dismiss this text panel
						visible = false;
						Events.disable(showChoicesListener);
						showChoicesCallback(selected + 1);
					}
					
				default:
					
			}
		});
		// disable the listener for now, it will be enabled when showChoices
		Events.disable(showChoicesListener);
		
		
		inputNumberListener = Events.on("key.justPressed", function(key:InputKey)
		{
			switch (key) 
			{
				case KEnter:
					if (!completed)
					{
						// immediately show all text
						showAll();
					}
					else
					{
						// dismiss this text panel
						visible = false;
						Events.disable(inputNumberListener);
						inputNumberPanel.hide(); // disable its event listener
						inputNumberCallback(inputNumberPanel.number);
					}
					
				default:
					
			}
		});
		// disable the listener for now, it will be enabled when showChoices
		Events.disable(inputNumberListener);
	}
	
	public function showChoices(callback:Int->Void, prompt:String, choices:Array<ShowChoicesChoice>, options:ShowChoicesOptions):Void
	{
		visible = true;
		selector.visible = false;
		inputNumberPanel.visible = false;
		handleOptions(options);
		
		showChoicesCallback = callback;
		numChoices = choices.length;
		selected = 0;
		
		message = prompt;
		for (c in choices)
		{
			message += "\n" + c.text;
		}
		text.text = "";
		tween = FlxTween.num(0, message.length, message.length / 15, {onComplete:function(t) selector.visible = true}, function(v) text.text = message.substr(0, Std.int(v)));
		
		Events.enable(showChoicesListener);
	}
	
	public function showText(callback:Void->Void, characterId:String, message:String, options:ShowTextOptions):Void
	{
		visible = true;
		selector.visible = false;
		inputNumberPanel.visible = false;
		handleOptions(options);
		
		showTextCallback = callback;
		
		this.message = message = (characterId == "" ? message : characterId + ": " + message);
		text.text = "";
		tween = FlxTween.num(0, message.length, message.length / 15, null, function(v) text.text = message.substr(0, Std.int(v)));
		
		Events.enable(showTextListener);
	}
	
	public function inputNumber(callback:Int->Void, prompt:String, numDigit:Int, options:InputNumberOptions):Void
	{
		visible = true;
		selector.visible = false;
		inputNumberPanel.visible = false;
		handleOptions(options);
		
		inputNumberCallback = callback;
		
		message = prompt;
		text.text = "";
		tween = FlxTween.num(0, message.length, message.length / 15, { onComplete: function(t) inputNumberPanel.show(numDigit) }, function(v) text.text = message.substr(0, Std.int(v)));
		
		Events.enable(inputNumberListener);
	}
	
	private function showAll():Void
	{
		if (!completed)
		{
			if (tween.onComplete != null) 
				tween.onComplete(tween);
			tween.cancel();
		}
		text.text = message;
	}
	
	private function handleOptions(options:ShowTextOptions):Void
	{
		y = switch (options.position) 
		{
			case PTop: 0;
			case PCenter: (480 - 150) / 2;
			case PBottom: 480 - 150;
		}
		
		switch (options.background) 
		{
			case BTransparent:
				background.alpha = 0;
				border.visible = false;
			case BDimmed:
				background.alpha = 0.5;
				border.visible = false;
			case BNormal:
				background.alpha = 0.9;
				border.visible = true;
		}
	}
	
	private inline function get_completed():Bool 
	{
		return tween == null || !tween.active;
	}
	
	private function set_selected(v:Int):Int
	{
		if (v < 0) v = numChoices - 1;
		else if (v >= numChoices) v = 0;
		
		selector.y = y + 40 + 25 * v;
		
		return selected = v;
	}
}