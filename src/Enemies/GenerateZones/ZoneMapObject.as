package Enemies.GenerateZones 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class ZoneMapObject 
	{
		public var sprite:Sprite
		public var type:int;
		
		public function ZoneMapObject(zsprite:Sprite, ztype:int) 
		{
			sprite = zsprite;
			type = ztype;
		}
		
	}

}