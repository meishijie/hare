package rpg.save;
import haxe.Serializer;
import haxe.Unserializer;
import rpg.config.Config.ItemData;
import rpg.Engine;
import rpg.geom.Direction;
import rpg.geom.IntPoint;

/**
 * ...
 * @author Kevin
 */
class SaveManager
{
	private var engine:Engine;
	
	public function new(engine:Engine) 
	{
		this.engine = engine;
	}
	
	public function save(id:Int):Void
	{
		var data = new SaveData();
		data.gameData = engine.eventManager.getGameData();
		data.mapId = engine.mapManager.currentMap.id;
		data.playerFacing = engine.interactionManager.player.facing;
		data.playerPosition = engine.interactionManager.player.position;
		data.items = engine.itemManager.itemData;
		engine.assetManager.setSaveData(id, Serializer.run(data));
	}
	
	public function load(id:Int):Void
	{
		var s = engine.assetManager.getSaveData(id);
		var data:SaveData = Unserializer.run(s);
		engine.eventManager.setGameData(data.gameData);
		engine.itemManager.init(data.items);
		engine.eventManager.scriptHost.teleportPlayer(data.mapId, data.playerPosition.x, data.playerPosition.y, {facing:Direction.toString(data.playerFacing)});
	}
}

class SaveData
{
	public var mapId:Int;
	public var playerPosition:IntPoint;
	public var playerFacing:Int;
	public var gameData:GameData;
	public var items:Array<ItemData>;
	
	public function new()
	{
		
	}
}

typedef GameData = 
{
	variables:Dynamic,
	eventVariables:Dynamic,
}