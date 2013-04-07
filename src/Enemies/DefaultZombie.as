package Enemies 
{
	import Events.Destroying;
	import MapGenerator.MapSegment;
	import Enemies.GenerateZones.BaseGenerateZone;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class DefaultZombie extends BaseEnemy
	{
		public static const NAME:String = "DefaultZombie";
		
		public static const HEALTH:int = 50;
		public static const ARMOR:int = 0;
		public static const SPEED:int = 1;
		
		public function DefaultZombie()
		{
			_movie = new Zombie_01();
			_movie.stop();
			_full_armor = ARMOR;
			_full_health = HEALTH;
			_full_speed = SPEED;
			_zombie_type = ZTYPE_DEFAULT;
		}
		
		override protected function returnToPool():void 
		{
			App.pools.returnPoolObject(NAME, this);
		}
	}

}