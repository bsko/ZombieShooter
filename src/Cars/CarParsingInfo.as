package Cars 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author ...
	 */
	public class CarParsingInfo 
	{
		private var _sprite:Sprite;
		
		public function CarParsingInfo(sprite:Sprite)
		{
			_sprite = sprite;
		}
		
		public function get sprite():Sprite { return _sprite; }
		
		public function set sprite(value:Sprite):void 
		{
			_sprite = value;
		}
		
	}

}