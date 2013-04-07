package  
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Cars.BaseCar;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import MapGenerator.MapSegment;
	import Weapons.Autogun;
	import Weapons.BaseWeapon;
	
	/**
	 * ...
	 * @author 
	 */
	
	public class Hero extends Sprite
	{	
		private static const LABEL_WALKING:String = "walking";
		private static const LABEL_STANDING:String = "standing";
		public static const HERO_DIAMETER:int = 10;
		private static const DEFAULT_SPEED:Number = 2;
		public static const DISTANCE_TO_SIT_IN_CAR:int = 50;
		//private static const DEFAULT_SPEED:Number = 10;
		
		public static const STATE_WALKING:int = 201;
		public static const STATE_RUNNING:int = 202;
		public static const STATE_STANDING:int = 203;
		
		private var _left:Boolean = false;
		private var _right:Boolean = false;
		private var _up:Boolean = false;
		private var _down:Boolean = false;
		
		private var _weapon:BaseWeapon;
		
		private var _hero_movie:MovieClip = new Hero2Fire();
		
		private var _visual_owner:MapSegment;
		
		private var _speed:Number = DEFAULT_SPEED;
		
		private var _isMoving:Boolean = false;
		private var _state:int;
		
		private var _universe:Universe;
		private var _body:b2Body;
		private var _shootingTimer:Timer = new Timer(1000);
		private var _inCarMode:Boolean = false;
		private var _car:BaseCar;
		
		public function Hero() 
		{
			x = 0;
			y = 0;
			addChild(_hero_movie);
			_hero_movie.scaleX = _hero_movie.scaleY = 0.8;
			_weapon = new Autogun();
		}
		
		public function Init():void 
		{
			_universe = App.universe;
			_body = CreateBody();
			App.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			App.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onMovement, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateLook, false, 0, true);
			_universe.addEventListener(MouseEvent.MOUSE_DOWN, onStartShoot, false, 0, true);
			_universe.addEventListener(MouseEvent.MOUSE_UP, onStopShoot, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onResumeEvent, false, 0, true);
		}
		
		private function onResumeEvent(e:PauseEvent):void 
		{
			App.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			App.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			addEventListener(Event.ENTER_FRAME, onUpdateLook, false, 0, true);
			_universe.addEventListener(MouseEvent.MOUSE_DOWN, onStartShoot, false, 0, true);
			_universe.addEventListener(MouseEvent.MOUSE_UP, onStopShoot, false, 0, true);
			if (_inCarMode)
			{
				addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
			}
			else 
			{
				addEventListener(Event.ENTER_FRAME, onMovement, false, 0, true);
			}
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			App.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
			App.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateLook, false);
			_universe.removeEventListener(MouseEvent.MOUSE_DOWN, onStartShoot, false);
			_universe.removeEventListener(MouseEvent.MOUSE_UP, onStopShoot, false);
			if (_inCarMode)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdate, false);
			}
			else 
			{
				removeEventListener(Event.ENTER_FRAME, onMovement, false);
			}
		}
		
		private function onStopShoot(e:MouseEvent):void 
		{
			if (!_inCarMode)
			{
				_shootingTimer.reset();
				_shootingTimer.removeEventListener(TimerEvent.TIMER, onShoot, false);
			}
		}
		
		private function onStartShoot(e:MouseEvent):void 
		{
			if (!_inCarMode)
			{
				onShoot();
				_shootingTimer.delay = _weapon.shootingDelay;
				_shootingTimer.start();
				_shootingTimer.addEventListener(TimerEvent.TIMER, onShoot, false, 0, true);
			}
		}
		
		public function updateState():void
		{
			if (_inCarMode) { return; }
			if (!isMoving)
			{
				_hero_movie.gotoAndStop(LABEL_STANDING);
			}
			else
			{
				_hero_movie.gotoAndPlay(LABEL_WALKING);
			}
		}
		
		private function onShoot(e:TimerEvent = null):void 
		{
			var bullet:Bullet = App.pools.getPoolObject(Bullet.NAME);
			bullet.Init(_weapon, this, stage.mouseX - Camera.STAGE_HALF_WIDTH + x, stage.mouseY - Camera.STAGE_HALF_HEIGHT + y);
		}
		
		private function onUpdateLook(e:Event):void 
		{
			if (!_inCarMode)
			{
				this.x = _body.GetPosition().x * App.WORLD_SCALE;
				this.y = _body.GetPosition().y * App.WORLD_SCALE;
			}
		}
		
		private function onMovement(e:Event):void 
		{
			var vec:b2Vec2 = new b2Vec2(0, 0);
			if (_left)
			{
				vec.x -= _speed;
			}
			if (_right)
			{
				vec.x += _speed;
			}
			if (_up)
			{
				vec.y -= _speed;
			}
			if (_down)
			{
				vec.y += _speed;
			}
			
			if (!_left && !_right && !_up && !_down)
			{
				if (isMoving) { isMoving = false; updateState(); }
			}
			else
			{
				if (!isMoving) { isMoving = true; updateState(); }
			}
			
			var angle:int = App.angleFinding(new Point(0, 0), new Point(App.stage.mouseX - Camera.STAGE_HALF_WIDTH, App.stage.mouseY - Camera.STAGE_HALF_HEIGHT));
			var tmpPoint:Point = App.TurnVectorToAngle(new Point(0, 0), new Point(vec.x, vec.y), angle);
			vec.x = tmpPoint.x;
			vec.y = tmpPoint.y;
			
			var tmpVec:b2Vec2 = _body.GetLinearVelocity();
			if (Math.abs(tmpVec.x - vec.x) > (DEFAULT_SPEED/5))
			{
				tmpVec.x += (tmpVec.x > vec.x) ? -(DEFAULT_SPEED/5) : (DEFAULT_SPEED/5);
			}
			else
			{
				tmpVec.x = vec.x;
			}
			if (Math.abs(tmpVec.y - vec.y) > DEFAULT_SPEED/5)
			{
				tmpVec.y += (tmpVec.y > vec.y) ? - (DEFAULT_SPEED/5) : (DEFAULT_SPEED/5);
			}
			else
			{
				tmpVec.y = vec.y;
			}
			
			_body.SetLinearVelocity(tmpVec);
			rotation = angle;
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case 87:
				_up = false;
				break;
				case 83:
				_down = false;
				break;
				case 65:
				_left = false;
				break;
				case 68:
				_right = false;
				break;
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case 87:
				_up = true;
				break;
				case 83:
				_down = true;
				break;
				case 65:
				_left = true;
				break;
				case 68:
				_right = true;
				break;
				case 13:
				if (!_inCarMode)
				{ SearchForCarToSitIn(); }
				else { LeaveCar(); }
				break;
			}
		}
		
		private function LeaveCar():void 
		{
			if (!_inCarMode) { return; }
			if (!_car) { return; }
			
			removeEventListener(Event.ENTER_FRAME, onUpdate, false);
			visible = true;
			_inCarMode = false;
			_body = CreateBody();
			_car.TransformToBody();
			addEventListener(Event.ENTER_FRAME, onMovement, false, 0, true);
		}
		
		private function SearchForCarToSitIn():void 
		{
			var length:int = BaseCar.carsArray.length;
			var car:BaseCar;
			var distance:int = DISTANCE_TO_SIT_IN_CAR;
			var curCar:BaseCar = null;
			for (var i:int = 0; i < length; i++)
			{
				car = BaseCar.carsArray[i];
				var curDistance:Number = Point.distance(new Point(x, y), new Point(car.x, car.y));
				if (curDistance < distance)
				{
					distance = curDistance;
					curCar = car;
				}
			}
			
			if (!curCar) { return; }
			
			SitInCar(curCar);
		}
		
		private function SitInCar(car:BaseCar):void 
		{
			car.TransformToCar();
			_car = car;
			App.world.DestroyBody(_body);
			x = car.x;
			y = car.y;
			removeEventListener(Event.ENTER_FRAME, onMovement, false);
			_inCarMode = true;
			visible = false;
			addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
		}
		
		private function onUpdate(e:Event):void 
		{
			x = _car.x;
			y = _car.y;
		}
		
		private function CreateBody():b2Body 
		{
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(x / App.WORLD_SCALE, y / App.WORLD_SCALE);
			myBody.type = b2Body.b2_dynamicBody;
			myBody.allowSleep = false;
			var myBall:b2CircleShape = new b2CircleShape(HERO_DIAMETER/App.WORLD_SCALE);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBall;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			worldBody.SetUserData(this);
			worldBody.SetAngle(0);
			return worldBody; 
		}
		
		public function Destroy():void 
		{
			App.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
			App.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
			removeEventListener(Event.ENTER_FRAME, onMovement, false);
			removeEventListener(Event.ENTER_FRAME, onUpdateLook, false);
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onResumeEvent, false);
		}
		
		public function get visual_owner():MapSegment { return _visual_owner; }
		
		public function set visual_owner(value:MapSegment):void 
		{
			_visual_owner = value;
		}
		
		public function get body():b2Body { return _body; }
		
		public function get isMoving():Boolean { return _isMoving; }
		
		public function set isMoving(value:Boolean):void 
		{
			_isMoving = value;
		}
		
		public function get state():int { return _state; }
		
		public function set state(value:int):void 
		{
			_state = value;
		}
		
	}

}