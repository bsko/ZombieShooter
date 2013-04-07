package MapGenerator 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 
	 */
	public class MapObject 
	{
		private var _object:Sprite;
		private var _object_owner:MovieClip;
		
		public function MapObject(object:Sprite, owner:MovieClip) 
		{
			_object = object;
			_object_owner = owner;
		}
		
		public function get object():Sprite { return _object; }
		
		public function set object(value:Sprite):void 
		{
			_object = value;
		}
		
		public function get object_owner():MovieClip { return _object_owner; }
		
		public function set object_owner(value:MovieClip):void 
		{
			_object_owner = value;
		}
		
	}

}