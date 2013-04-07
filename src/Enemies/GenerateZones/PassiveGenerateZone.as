package Enemies.GenerateZones 
{
	import Enemies.BaseEnemy;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import MapGenerator.MapSegment;
	import Events.Destroying;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class PassiveGenerateZone extends BaseGenerateZone
	{
		public static const NAME:String = "PassiveGenerateZone";
		public static const ADDING_DELAY:int = 5000;
		public static const UPDATE_TIME:int = 3000;
		public static const DEFAULT_NUMBER_OF_ZOMBIES:int = 3;
		public static const MIN_DISTANCE_TO_GENERATE:int = 400;
		public static const MAX_DISTANCE_TO_GENERATE:int = 550;
		
		private var _timer:Timer = new Timer(UPDATE_TIME);
		private var _zombiesGenerated:Boolean = false;
		
		public function PassiveGenerateZone() 
		{
			
		}
		
		override public function Init(sprite:Sprite, owner:MapSegment, zombie_type:String = "DefaultZombie"):void 
		{
			super.Init(sprite, owner, zombie_type);
			
			_zombiesGenerated = false;
			
			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, onSearchForHeroInPlace, false, 0, true);
		}
		
		private function onSearchForHeroInPlace(e:TimerEvent):void 
		{
			if (!_zombiesGenerated)
			{
				var distance:int = Point.distance(new Point(_center_x, _center_y), new Point(_hero.x, _hero.y));
				if (distance > MIN_DISTANCE_TO_GENERATE && distance < MAX_DISTANCE_TO_GENERATE)
				{
					GenerateZombies();
				}
			}
		}
		
		private function GenerateZombies():void 
		{
			for (var i:int = 0; i < DEFAULT_NUMBER_OF_ZOMBIES; i++)
			{
				var _baseEnemy:BaseEnemy = App.pools.getPoolObject(_zombie_type);
					
				var point_x:int = _center_x + int(Math.random() * _sprite.width - _sprite.width / 2);
				var point_y:int = _center_y + int(Math.random() * _sprite.height - _sprite.height / 2);
				
				_baseEnemy.Init(_sprite, this, _owner, point_x, point_y, BaseEnemy.ATYPE_PASSIVE);
				_zombie_count++;
			}
			
			_zombiesGenerated = true;
		}
		
		override public function Destroy():void//e:Destroying = null):void 
		{
			super.Destroy();
			_timer.reset();
			_timer.removeEventListener(TimerEvent.TIMER, onSearchForHeroInPlace, false);
			App.pools.returnPoolObject(NAME, this);
		}
		
		override public function set zombie_count(value:int):void 
		{
			super.zombie_count = value;
			if (value == 0)
			{
				_zombiesGenerated = false;
			}
		}
	}

}