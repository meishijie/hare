package rpg.impl.flixel;
import flixel.FlxG;

/**
 * ...
 * @author Kevin
 */
class Host implements IHost
{

	public function new() 
	{
		
	}
	
	public function showText(message:String):Void 
	{
		trace(message);
	}
	
	public function log(message:String):Void 
	{
		FlxG.log.add(message);
		trace(message);
	}
	
}