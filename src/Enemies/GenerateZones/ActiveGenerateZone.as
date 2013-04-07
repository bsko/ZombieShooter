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
	public class ActiveGenerateZone extends BaseGenerateZone
	{
		public static const NAME:String = "ActiveGenerateZone";
		public static const ADDING_DELAY:int = 10000;
		public static const CHECK_DELAY:int = 3000;
		public static const MAX_DISTANCE_TO_GENERATE:int = 250;
		private var _adding_timer:Timer = new Timer(ADDING_DELAY);
		private var _search_for_hero:Timer = new Timer(CHECK_DELAY);
		private var _isGenerating:Boolean = false;
		
		public function ActiveGenerateZone() 
		{
			
		}
		
		override public function Init(sprite:Sprite, owner:MapSegment, zombie_type:String = "DefaultZombie"):void 
		{
			super.Init(sprite, owner, zombie_type);
			
			_search_for_hero.start();
			_search_for_hero.addEventListener(TimerEvent.TIMER, onCheckForHero, false, 0, true);
		}
		
		private function onCheckForHero(e:TimerEvent):void 
		{
			var distance:int = Point.distance(new Point(_center_x, _center_y), new Point(_hero.x, _hero.y));
			
			if (distance < MAX_DISTANCE_TO_GENERATE)
			{
				if (!_isGenerating)
				{
					StartGenerating();
				}
			}
			else
			{
				if (_isGenerating)
				{
					StopGenerating();
				}
			}
		}
		
		private function StopGenerating():void 
		{
			_adding_timer.reset();
			_adding_timer.removeEventListener(TimerEvent.TIMER, onGenerateZombie, false);
			_isGenerating = false;
		}
		
		private function StartGenerating():void 
		{
			_adding_timer.start();
			_adding_timer.addEventListener(TimerEvent.TIMER, onGenerateZombie, false, 0, true);
			_isGenerating = true;
		}
		
		private function onGenerateZombie(e:TimerEvent):void 
		{
			var _baseEnemy:BaseEnemy = App.pools.getPoolObject(_zombie_type);
			
			_baseEnemy.Init(_sprite, this, _owner, _center_x, _center_y, BaseEnemy.ATYPE_AGRO);
			_zombie_count++;
		}
		
		override public function Destroy():void//e:Destroying = null):void 
		{
			super.Destroy();
			
			_search_for_hero.reset();
			_search_for_hero.removeEventListener(TimerEvent.TIMER, onCheckForHero, false);
			
			if (_isGenerating)
			{
				StopGenerating();
			}
			
			App.pools.returnPoolObject(NAME, this);
		}
	}

}