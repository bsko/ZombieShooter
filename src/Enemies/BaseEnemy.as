package Enemies 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Enemies.GenerateZones.BaseGenerateZone;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import MapGenerator.MapSegment;
	/**
	 * ...
	 * @author 
	 */
	public class BaseEnemy extends Sprite 
	{
		public static const ZTYPE_DEFAULT:String = "DefaultZombie";
		public static const ZTYPE_VALERA:int = 202;
		
		public static const ATYPE_AGRO:int = 101; 
		public static const ATYPE_PASSIVE:int = 102;
		
		public static const DEFAULT_HEALTH:int = 100;
		public static const DEFAULT_ARMOR:int = 0;
		public static const DEFAULT_SPEED:int = 1;
		public static const DEFAULT_DIAMETER:int = 10;
		
		public static const DEFAULT_PASSIVE_VISION_AREA:int = 200;
		public static const DEFAULT_PASSIVE_SMELL_AREA:int = 75;
		public static const DEFAULT_PASSIVE_VISION_ANGLE:int = 60;
		
		public static const MAX_DISTANCE_TO_EXIST:int = 550;
		// static
		public static var ZombiesArray:Array = [];
		// system
		private var _universe:Universe;
		private var _x_coord:int;
		private var _y_coord:int;
		private var _layer:Sprite = App.universe.heroSprite;
		private var _owner:MapSegment;
		private var _respawn:BaseGenerateZone;
		private var _hero:Hero;
		private var _isGoingForHero:Boolean = false;
		private var _updateTraektoryTimer:Timer = new Timer(500);
		private var _distance:int;
		private var _body:b2Body;
		protected var _isDead:Boolean = true;
		protected var _movie:MovieClip;
		protected var _diameter:int = DEFAULT_DIAMETER;
		
		// chars
		protected var _agro_type:int;
		protected var _zombie_type:String;
		protected var _health:int;
		protected var _full_health:int = DEFAULT_HEALTH;
		protected var _armor:int;
		protected var _full_armor:int = DEFAULT_ARMOR;
		protected var _speed:Number;
		protected var _full_speed:Number = DEFAULT_SPEED;
		// - passive zombies
		protected var _vision_area:int = 300;
		
		public function Init(layer:Sprite, respawn:BaseGenerateZone, owner:MapSegment, x_coord:int, y_coord:int, agr_type:int = ATYPE_PASSIVE):void
		{
			_universe = App.universe;
			
			addChild(_movie);
			_movie.gotoAndPlay(1);
			_respawn = respawn;
			_owner = owner;
			_x_coord = x_coord;
			_y_coord = y_coord;
			_agro_type = agr_type;
			_hero = App.universe.hero;
			rotation = Math.random() * 360;
			_body = CreateBody();
			_body.SetUserData(this);
			_body.SetPosition(new b2Vec2(_x_coord / App.WORLD_SCALE, _y_coord / App.WORLD_SCALE));
			
			x = int(_body.GetPosition().x * App.WORLD_SCALE);
			y = int(_body.GetPosition().y * App.WORLD_SCALE);
			
			_layer.addChild(this);
			
			SetChars();
			
			_universe.addEventListener(Destroying.DESTROY, Destroy, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateLook, false, 0, true);
			if (_agro_type == ATYPE_AGRO)
			{
				_isGoingForHero = true;
				onUpdateTraektoryThings();
				_updateTraektoryTimer.start();
				_updateTraektoryTimer.addEventListener(TimerEvent.TIMER, onUpdateTraektoryThings, false, 0, true);
				addEventListener(Event.ENTER_FRAME, onUpdateGoingForHero, false, 0, true);
			}
			else if (_agro_type == ATYPE_PASSIVE)
			{
				_isGoingForHero = false;
				_body.SetAwake(true);
				addEventListener(Event.ENTER_FRAME, onUpdatePassiveZombie, false, 0, true);
			}
			
			ZombiesArray.push(this);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onResumeEvent, false, 0, true);
		}
		
		private function onResumeEvent(e:PauseEvent):void 
		{
			if (_agro_type == ATYPE_AGRO)
			{
				_updateTraektoryTimer.start();
				addEventListener(Event.ENTER_FRAME, onUpdateGoingForHero, false, 0, true);
			}
			else if (_agro_type == ATYPE_PASSIVE)
			{
				addEventListener(Event.ENTER_FRAME, onUpdatePassiveZombie, false, 0, true);
			}
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			if (_agro_type == ATYPE_AGRO)
			{
				_updateTraektoryTimer.stop();
				removeEventListener(Event.ENTER_FRAME, onUpdateGoingForHero, false);
			}
			else if (_agro_type == ATYPE_PASSIVE)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdatePassiveZombie, false);
			}
		}
		
		private function CreateBody():b2Body 
		{
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(x / App.WORLD_SCALE, y / App.WORLD_SCALE);
			myBody.type = b2Body.b2_dynamicBody;
			myBody.allowSleep = true;
			var myBall:b2CircleShape = new b2CircleShape(_diameter/App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBall;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			worldBody.SetUserData(this);
			return worldBody;
		}
		
		private function onUpdateTraektoryThings(e:TimerEvent = null):void 
		{
			if (_agro_type == ATYPE_AGRO)
			{
				
			}
		}
		
		private function StopZombie():void
		{
			
		}
		
		private function onUpdateLook(e:Event):void 
		{
			x = int(_body.GetPosition().x * App.WORLD_SCALE);
			y = int(_body.GetPosition().y * App.WORLD_SCALE);
			_body.SetAngle(rotation * App.DEG_TO_RAD);
			
			if (Point.distance(new Point(_hero.x, _hero.y), new Point(x, y)) > MAX_DISTANCE_TO_EXIST)
			{
				Destroy();
			}
		}
		
		private function onUpdatePassiveZombie(e:Event):void 
		{
			_body.SetLinearVelocity(new b2Vec2(0, 0));
			var zombiePoint:Point = new Point(x, y);
			var heroPoint:Point = new Point(_hero.x, _hero.y);
			_distance = Point.distance(zombiePoint, heroPoint);
			if (_distance < DEFAULT_PASSIVE_SMELL_AREA)
			{
				var xi:int = x - _hero.x;
				var yi:int = y - _hero.y;
				var b2vec:b2Vec2 = new b2Vec2();
				b2vec.x = - xi / _distance * _speed;
				b2vec.y = - yi / _distance * _speed;
				_body.SetAwake(true);
				_body.SetLinearVelocity(b2vec);
				rotation = App.angleFinding(zombiePoint, heroPoint);
			}
			else if (_distance < DEFAULT_PASSIVE_VISION_AREA)
			{
				var angle:int = App.GetAngle(zombiePoint, heroPoint);
				if (Math.abs(angle - rotation) < DEFAULT_PASSIVE_VISION_ANGLE)
				{
					xi = x - _hero.x;
					yi = y - _hero.y;
					b2vec = new b2Vec2();
					b2vec.x = - xi / _distance * _speed;
					b2vec.y = - yi / _distance * _speed;
					_body.SetAwake(true);
					_body.SetLinearVelocity(b2vec);
					rotation = angle;
				}
			}
		}
		
		private function onUpdateGoingForHero(e:Event):void 
		{
			var zombiePoint:Point = new Point(x, y);
			var heroPoint:Point = new Point(_hero.x, _hero.y);
			_distance = Point.distance(zombiePoint, heroPoint);
			var xi:int = x - _hero.x;
			var yi:int = y - _hero.y;
			var b2vec:b2Vec2 = new b2Vec2();
			b2vec.x = - xi / _distance * _speed;
			b2vec.y = - yi / _distance * _speed;
			_body.SetLinearVelocity(b2vec);
			rotation = App.angleFinding(zombiePoint, heroPoint);
		}
		
		public function TakingDamage(damage:int):void
		{
			_health -= damage;
			if (_health <= 0)
			{
				removeFromZombiesArray();
				Destroy();
			}
		}
		
		public function removeFromZombiesArray():void 
		{
			var length:int = ZombiesArray.length;
			var tmpZombie:BaseEnemy;
			for (var i:int = 0; i < length; i++)
			{
				tmpZombie = ZombiesArray[i];
				if (tmpZombie == this)
				{
					ZombiesArray.splice(i, 1);
					return;
				}
			}
		}
		
		private function SetChars():void 
		{
			_health = _full_health;
			_armor = _full_armor;
			_speed = _full_speed;
			_isDead = false;
		}
		
		public function Destroy(e:Destroying = null):void
		{
			if (!_isDead)
			{
				_respawn.zombie_count--;
				_isDead = true;
				
				_layer.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, onUpdateLook, false);
				if (_agro_type == ATYPE_AGRO)
				{
					_updateTraektoryTimer.reset();
					_updateTraektoryTimer.removeEventListener(TimerEvent.TIMER, onUpdateTraektoryThings, false);
					removeEventListener(Event.ENTER_FRAME, onUpdateGoingForHero, false);
				}
				else if (_agro_type == ATYPE_PASSIVE)
				{
					removeEventListener(Event.ENTER_FRAME, onUpdatePassiveZombie, false);
				}
				_universe.removeEventListener(Destroying.DESTROY, Destroy, false);
				App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
				App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onResumeEvent, false);
				returnToPool();
				
				var timer:Timer = new Timer(1, 1);
				timer.addEventListener(TimerEvent.TIMER, DestroyBody, false, 0, true);
				timer.start();
			}
		}
		
		private function DestroyBody(e:TimerEvent):void
		{
			App.world.DestroyBody(_body);
			(e.target as Timer).reset();
			(e.target as Timer).removeEventListener(TimerEvent.TIMER, DestroyBody, false);
		}
		
		protected function returnToPool():void
		{
			
		}
	}
}