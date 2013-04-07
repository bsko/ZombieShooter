package Box2DItems 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Events.Destroying;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	public class StaticObject 
	{
		public static const NAME:String = "StaticObject";
		private var _centerPoint:Point;
		private var _width:Number;
		private var _height:Number;
		private var _body:b2Body;
		private var _angle:Number;
		
		public function Init(point:Point, clip:Sprite, parentClip:Sprite, parentAngle:Number):void
		{
			_angle = clip.rotation;
			clip.rotation = 0;
			_width = clip.width;
			_height = clip.height;
			_centerPoint = App.TurnVectorToAngle(new Point(0, 0), new Point(clip.x, clip.y), parentAngle);
			_centerPoint.x = point.x + _centerPoint.x;
			_centerPoint.y = point.y + _centerPoint.y;
			clip.rotation = _angle;
			_angle = (_angle + parentAngle) * App.DEG_TO_RAD;
			_body = CreateBody();
		//	App.universe.addEventListener(Destroying.DESTROY, Destroy, false , 0, true);
		}
		
		private function CreateBody():b2Body
		{
			var px:Number = _centerPoint.x/ App.WORLD_SCALE;
			var py:Number = _centerPoint.y/ App.WORLD_SCALE;
			var w:Number = _width/ App.WORLD_SCALE;
			var h:Number = _height/ App.WORLD_SCALE;
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(px, py );
			var myBox:b2PolygonShape = new b2PolygonShape();
			myBox.SetAsBox(w / 2, h / 2);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBox;
			myFixture.density = 0;
			myFixture.friction = 1;
			myFixture.restitution = 0;
			myFixture.isSensor = false;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			worldBody.SetAngle(_angle);
			worldBody.SetUserData(this);
			return worldBody;
		}
		
		public function Destroy():void//e:Destroying = null):void
		{
			_centerPoint = null;
			App.world.DestroyBody(_body);
			//App.universe.removeEventListener(Destroying.DESTROY, Destroy, false);
			App.pools.returnPoolObject(NAME, this);
		}
	}

}