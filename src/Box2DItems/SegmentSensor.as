package Box2DItems 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Events.Destroying;
	import Events.MapSegmentEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import MapGenerator.MapSegment;
	import MapGenerator.TileInfo;
	/**
	 * ...
	 * @author 
	 */
	public class SegmentSensor extends Sprite
	{
		public static const NAME:String = "SegmentSensor";
		public static const TYPE_ARRAY:Array = [201, 202, 203, 204];
		public static const TYPE_LEFT:int = 201;
		public static const TYPE_RIGHT:int = 202;
		public static const TYPE_DOWN:int = 203;
		public static const TYPE_UP:int = 204;
		
		public static const TYPE_1:int = 1;
		public static const TYPE_2:int = 2;
		public static const TYPE_3:int = 3;
		public static const TYPE_4:int = 4;
		
		public static const SENSOR_SIZE:int = 10;
		public static const SECTOR_SIZE:int = 300;
		
		private var _owner:MapSegment;
		private var _sensor:b2Body;
		private var _centerPoint:Point;
		private var _isVertical:Boolean;
		private var _type:int;
		private var _timer:Timer = new Timer(1);
		
		public function Init(parent:MapSegment, type:int):void
		{
			_owner = parent;
			_type = type;
			switch(type)
			{
				case TYPE_UP:
				_centerPoint = new Point(TileInfo.TILE_SIZE / 2, SENSOR_SIZE / 2);
				_isVertical = false;
				break;
				case TYPE_DOWN:
				_centerPoint = new Point(TileInfo.TILE_SIZE / 2, TileInfo.TILE_SIZE - SENSOR_SIZE / 2);
				_isVertical = false;
				break;
				case TYPE_LEFT:
				_centerPoint = new Point(SENSOR_SIZE / 2, TileInfo.TILE_SIZE / 2);
				_isVertical = true;
				break;
				case TYPE_RIGHT:
				_centerPoint = new Point(TileInfo.TILE_SIZE - SENSOR_SIZE / 2, TileInfo.TILE_SIZE / 2);
				_isVertical = true;
				break;
			}
			_centerPoint.x += _owner.x;
			_centerPoint.y += _owner.y;
			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, onCreateBody, false, 0, true);
			_owner.addEventListener(MapSegmentEvent.DESTROYING, msDestroy, false, 0, true);
			App.universe.addEventListener(Destroying.DESTROY, Destroy, false, 0, true);
		}
		
		private function onCreateBody(e:TimerEvent):void 
		{
			_timer.reset();
			_timer.removeEventListener(TimerEvent.TIMER, onCreateBody, false);
			_sensor = CreateBody();
		}
		
		private function msDestroy(e:MapSegmentEvent):void 
		{
			Destroy();
		}
		
		private function CreateBody():b2Body
		{
			var px:Number = _centerPoint.x / App.WORLD_SCALE;
			var py:Number = _centerPoint.y / App.WORLD_SCALE;
			var w:Number;
			var h:Number;
			if (_isVertical)
			{
				w = SENSOR_SIZE / App.WORLD_SCALE;
				h = TileInfo.TILE_SIZE / App.WORLD_SCALE;
			}
			else
			{
				w = TileInfo.TILE_SIZE / App.WORLD_SCALE;
				h = SENSOR_SIZE / App.WORLD_SCALE;
			}
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(px, py);
			var myBox:b2PolygonShape = new b2PolygonShape();
			myBox.SetAsBox(w / 2 , h / 2);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBox;
			myFixture.isSensor = true;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.SetUserData(this);
			worldBody.CreateFixture(myFixture);
			return worldBody;
		}
		
		private function Destroy(e:Destroying = null):void 
		{
			_owner.removeEventListener(MapSegmentEvent.DESTROYING, msDestroy, false);
			_owner = null;
			_centerPoint = null;
			App.world.DestroyBody(_sensor);
			App.universe.removeEventListener(Destroying.DESTROY, Destroy, false);
			App.pools.returnPoolObject(NAME, this);
		}
		
		public function get type():int { return _type; }	
		
		public function get owner():MapSegment { return _owner; }
	}

}