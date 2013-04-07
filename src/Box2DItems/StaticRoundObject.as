package Box2DItems 
{
	import Box2D.Collision.Shapes.b2CircleShape;
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
	public class StaticRoundObject 
	{
		public static const NAME:String = "StaticRoundObject";
		
		private var _centerPoint:Point;
		private var _radius:Number;
		private var _body:b2Body;
		private var _angle:Number;
		
		public function Init(point:Point, clip:Sprite, parentClip:Sprite, parentAngle:Number):void
		{
			_radius = clip.width / 2;
			_centerPoint = App.TurnVectorToAngle(new Point(0, 0), new Point(clip.x, clip.y), parentAngle);
			_centerPoint.x = point.x + _centerPoint.x;
			_centerPoint.y = point.y + _centerPoint.y;
			_body = CreateBody();
		//	App.universe.addEventListener(Destroying.DESTROY, Destroy, false , 0, true);
		}
		
		private function CreateBody():b2Body
		{
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(_centerPoint.x/App.WORLD_SCALE, _centerPoint.y/App.WORLD_SCALE);
			var myBall:b2CircleShape = new b2CircleShape(_radius / App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBall;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
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