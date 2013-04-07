package Quests 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Events.Destroying;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import MapGenerator.MapSegment;
	/**
	 * ...
	 * @author Temnov Aleksey
	 */
	public class QuestPerson extends Sprite
	{
		public static const NAME:String = "QuestPerson";
		public static const TYPE_1:int = 101;
		public static const TYPE_2:int = 102;
		public static const TYPE_3:int = 103;
		public static const TYPE_4:int = 104;
		public static const SENSOR_SIZE:int = 30;
		public static const BODY_SIZE:int = 5;
		
		private var _sensor:b2Body;
		private var _body:b2Body;
		private var _personMovie:MovieClip;
		private var _owner:MapSegment;
		
		public function QuestPerson() 
		{
			
		}
		
		public function Init(clip:Sprite, owner:MapSegment, type:int = TYPE_1):void
		{
			x = clip.x + owner.x;
			y = clip.y + owner.y;
			_owner = owner;
			
			_sensor = CreateSensor();
			_body = CreateBody();
			App.universe.addEventListener(Destroying.DESTROY, Destroy, false, 0, true);
		}
		
		private function CreateBody():b2Body
		{
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(x/App.WORLD_SCALE, y/App.WORLD_SCALE);
			var myBall:b2CircleShape = new b2CircleShape(BODY_SIZE / App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBall;
			myFixture.isSensor = false;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			return worldBody;
		}
		
		private function CreateSensor():b2Body
		{
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(x/App.WORLD_SCALE, y/App.WORLD_SCALE);
			var myBall:b2CircleShape = new b2CircleShape(SENSOR_SIZE / App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBall;
			myFixture.isSensor = true;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			worldBody.SetUserData(this);
			return worldBody;
		}
		
		public function Destroy(e:Destroying = null):void
		{
			App.world.DestroyBody(_body);
			App.world.DestroyBody(_sensor);
			_owner = null;
			App.universe.removeEventListener(Destroying.DESTROY, Destroy, false);
			App.pools.returnPoolObject(NAME, this);
		}
		
		public function DeletePerson():void 
		{
			Destroy();
		}
	}

}