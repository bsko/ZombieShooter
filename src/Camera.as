package  
{
	import Events.Destroying;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author 
	 */
	public class Camera extends Sprite
	{
		public static const STAGE_WIDTH:int = 640;
		public static const STAGE_HEIGHT:int = 480;
		public static const STAGE_HALF_WIDTH:int = STAGE_WIDTH / 2;
		public static const STAGE_HALF_HEIGHT:int = STAGE_HEIGHT / 2;
		public static const STAGE_WIDTH_TO_HEIGHT:Number = STAGE_HEIGHT / STAGE_WIDTH;
		
		private var _hero:Hero;
		private var _universe:Universe;
		
		public function Init(hero:Hero, universe:Universe):void 
		{
			_universe = universe;
			_hero = hero;
			addEventListener(Event.ENTER_FRAME, onCamera, false, 0, true);
			_universe.addEventListener(Destroying.DESTROY, Destroy, false, 0, true);
		}
		
		private function onCamera(e:Event):void 
		{
			App.stage.focus = App.stage;
			
			App.universe.x = - int(_hero.x) + STAGE_HALF_WIDTH;
			App.universe.y = - int(_hero.y) + STAGE_HALF_HEIGHT;
			//App.universe.x = - int(_hero.x * 0.5) + STAGE_HALF_WIDTH;
			//App.universe.y = - int(_hero.y * 0.5) + STAGE_HALF_HEIGHT;
			//App.universe.scaleX = App.universe.scaleY = 0.5;
		}
		
		public function Destroy(e:Destroying = null):void 
		{
			removeEventListener(Event.ENTER_FRAME, onCamera, false);
			_universe = null;
			_hero = null;
		}
	}

}