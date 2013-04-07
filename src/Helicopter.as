package  
{
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Temnov Aleksey
	 */
	public class Helicopter extends Sprite
	{
		public static const NAME:String = "helicopter";
		public static const START_POINTS_ARRAY:Array = [new Point(-420, -340), new Point(-420, -100), new Point(-100, -340), new Point(420, -340), new Point(-420, -340), new Point(420,100)];
		public static const END_POINTS_ARRAY:Array = [new Point(420, 340), new Point(420, 100), new Point(100, 340), new Point( -420, 340), new Point(420 , 340), new Point( -420, -100)];
		public static var HelicopterOnScreen:Boolean = false;
		private var _checkpoints:Array = [];
		private var _helicopterMovie:MovieClip = new HelicopterVisual();
		private var _speed:Number;
		private var _currentCheck:int = 0;
		private var _x_delay:int;
		private var _y_delay:int;
		private var _totalFrames:int = 0;
		
		public function Helicopter() 
		{
			_speed = Math.random() * 2 + 4;
			_speed = int(_speed * 10) / 10;
			
			var pts:int = Math.random() * START_POINTS_ARRAY.length;
			
			var startPnt:Point = START_POINTS_ARRAY[pts];
			var endPnt:Point = END_POINTS_ARRAY[pts];
			
			var distance:Number = Point.distance(startPnt, endPnt);
			var framesCount:int = distance / _speed;
			var tmpPoint:Point;
			
			var delay:Number = 1 / framesCount;
			var c:Number = 0;
			
			while(c <= 1)
			{
				tmpPoint = Point.interpolate(endPnt, startPnt, c);
				_checkpoints.push(tmpPoint);
				c += delay;
				_totalFrames++;
			}
			
			rotation = App.angleFinding(startPnt, endPnt);
			addChild(_helicopterMovie);
		}
		
		public function Init(layer:Sprite, hero:Hero):void
		{
			if (HelicopterOnScreen) { return; }
			HelicopterOnScreen = true;
			App.universe.addEventListener(Destroying.DESTROY, Destroy, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onResumeEvent, false, 0, true);
			
			_x_delay = hero.x;
			_y_delay = hero.y;
			
			_currentCheck = 0;
			
			var point:Point = _checkpoints[_currentCheck];
			x = point.x + _x_delay;
			y = point.y + _y_delay;
			
			layer.addChild(this);
			addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
		}
		
		private function onUpdate(e:Event):void 
		{
			var point:Point = _checkpoints[_currentCheck];
			x = point.x + _x_delay;
			y = point.y + _y_delay;
			
			_currentCheck++;
			if (_currentCheck == _totalFrames)
			{
				Destroy();
			}
		}
		
		private function onResumeEvent(e:PauseEvent):void 
		{
			addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, onUpdate, false);
		}
		
		private function Destroy(e:Destroying = null):void 
		{
			if (parent != null) { parent.removeChild(this); }
			_currentCheck = 0;
			HelicopterOnScreen = false;
			removeEventListener(Event.ENTER_FRAME, onUpdate, false);
			App.universe.addEventListener(Destroying.DESTROY, Destroy, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onResumeEvent, false, 0, true);
			App.pools.returnPoolObject(NAME, this);
		}
	}

}