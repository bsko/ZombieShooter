package  
{
	import Box2D.Collision.b2Bound;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Events.PauseEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import Weapons.BaseWeapon;
	/**
	 * ...
	 * @author 
	 */
	public class Bullet extends Sprite
	{
		public static const NAME:String = "Bullet";
		public static const SPEED:int = 100;
		public static const HERO_DIAMETER:int = 10;
		public static const BULLET_LIFE_TIME:int = 8;
		private var _hero:Hero;
		private var worldBody:b2Body;
		private var _sprite:Sprite = new Sprite();
		private var _counter:int = 0;
		private var _weapon:BaseWeapon;
		private var _contacted:Boolean = false;
		
		public function Bullet()
		{
			_sprite.graphics.beginFill(0xF2C204, 0.8);
			_sprite.graphics.drawRect(0, 0, 1, 10);
			_sprite.graphics.endFill();
			addChild(_sprite);
		}
		
		public function Init(weapon:BaseWeapon, hero:Hero, mouse_x:int, mouse_y:int):void
		{
			_weapon = weapon;
			_hero = hero;
			rotation = App.angleFinding(new Point(_hero.x, _hero.y), new Point(mouse_x, mouse_y));
			
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(_hero.x / App.WORLD_SCALE, _hero.y / App.WORLD_SCALE);
			myBody.type = b2Body.b2_dynamicBody;
			var myBall:b2CircleShape = new b2CircleShape(1 / App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBall;
			worldBody = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			worldBody.SetUserData(this);
			worldBody.SetBullet(true);
			
			var distance:Number = Point.distance(new Point(_hero.x, _hero.y), new Point(mouse_x, mouse_y));
			var b2vec:b2Vec2 = new b2Vec2();
			var x_delay:Number = (mouse_x - _hero.x) / distance;
			var y_delay:Number = (mouse_y - _hero.y) / distance;
			b2vec.x = x_delay * SPEED;
			b2vec.y = y_delay * SPEED;
			var b2vec2:b2Vec2 = new b2Vec2();
			b2vec2.x = _hero.body.GetPosition().x + (x_delay * HERO_DIAMETER) / App.WORLD_SCALE;
			b2vec2.y = _hero.body.GetPosition().y + (y_delay * HERO_DIAMETER) / App.WORLD_SCALE;
			worldBody.SetPosition(b2vec2);
			worldBody.SetLinearVelocity(b2vec);
			addEventListener(Event.ENTER_FRAME, onUpdateLook, false, 0, true);
			x = worldBody.GetPosition().x * App.WORLD_SCALE;
			y = worldBody.GetPosition().y * App.WORLD_SCALE;
			App.universe.heroSprite.addChild(this);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onResumeEvent, false, 0, true);
		}
		
		private function onResumeEvent(e:PauseEvent):void 
		{
			
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			
		}
		
		private function onUpdateLook(e:Event):void 
		{
			_counter++;
			x = worldBody.GetPosition().x * App.WORLD_SCALE;
			y = worldBody.GetPosition().y * App.WORLD_SCALE;
			if (_counter == BULLET_LIFE_TIME || contacted)
			{
				_counter = 0;
				Destroy();
			}
		}
		
		public function Destroy():void
		{
			_weapon = null;
			_contacted = false;
			App.universe.heroSprite.removeChild(this);
			removeEventListener(Event.ENTER_FRAME, onUpdateLook, false);
			App.world.DestroyBody(worldBody);
			App.pools.returnPoolObject(NAME, this);
		}
		
		public function get contacted():Boolean { return _contacted; }
		
		public function set contacted(value:Boolean):void 
		{
			_contacted = value;
		}
		
		public function get weapon():BaseWeapon { return _weapon; }
	}

}