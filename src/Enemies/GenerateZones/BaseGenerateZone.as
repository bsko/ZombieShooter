package Enemies.GenerateZones 
{
	import Enemies.*;
	import Events.Destroying;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import MapGenerator.MapSegment;
	/**
	 * ...
	 * @author 
	 */
	public class BaseGenerateZone extends Sprite
	{
		public static const TYPE_PASSIVE_ZONE:int = 101;
		public static const TYPE_AGRO_ZONE:int = 102;
		public static const DEFAUL_ADDING_DELAY:int = 5000;
		public static const DEFAULT_NUMBER_OF_ZOMBIES:int = 3;
		
		protected var _sprite:Sprite;
		protected var _owner:MapSegment;
		protected var _center_x:int;
		protected var _center_y:int;
		protected var _hero:Hero;
		protected var _zombie_type:String;
		protected var _agro_zombie:int;
		protected var _zombie_count:int = 0;
		protected var _universe:Universe;
		public static var numberOfZones:int = 0;
		
		public function Init(sprite:Sprite, owner:MapSegment, zombie_type:String = "DefaultZombie"):void 
		{
			_universe = App.universe;
			_zombie_count = 0;
			_hero = App.universe.hero;
			_sprite = sprite;
			_owner = owner;
			_center_x = _owner.x + _sprite.x;
			_center_y = _owner.y + _sprite.y;
			_zombie_type = zombie_type;
			_agro_zombie = BaseEnemy.ATYPE_PASSIVE;
			//_universe.addEventListener(Destroying.DESTROY, Destroy, false, 0, true);
			numberOfZones++;
		}
		
		public function Destroy():void//e:Destroying = null):void 
		{
			//_universe.removeEventListener(Destroying.DESTROY, Destroy, false);
			_zombie_count = 0;
			numberOfZones--;
		}
		
		public function get zombie_count():int { return _zombie_count; }
		
		public function set zombie_count(value:int):void 
		{
			_zombie_count = value;
		}
	}

}