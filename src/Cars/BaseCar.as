package Cars 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Math;
	import Box2D.Common.Math.b2Transform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import MapGenerator.MapSegment;
	/**
	 * ...
	 * @author 
	 */
	public class BaseCar extends Sprite
	{
		public static const NAME:String = "BaseCar";
		public static var carsArray:Array = [];
		public static const MAX_DISTANCE_TO_HERO:int = 1800;
		private var _angle:Number;
		private var _width:Number;
		private var _height:Number;
		private var _centerPoint:Point = new Point();
		private var _layer:Sprite;
		private var _owner:MapSegment;
		private var _body:b2Body;
		private var _carsMovie:MovieClip = new CarsMovie();
		private var _isTransformed:Boolean = false;
		private var _carArrow:MovieClip = new CarArrow();
		private var _hero:Hero;
		
		private var _leftUpWheel:b2Body;
		private var _leftDownWheel:b2Body;
		private var _rightUpWheel:b2Body;
		private var _rightDownWheel:b2Body;
		
		private var _checkForHeroTimer:Timer = new Timer(5000);
		
		public static const MAX_STEER_ANGLE:Number = Math.PI/3;
		public static const STEER_SPEED:Number = 1.5;
		public static const SIDEWAYS_FRICTION_FORCE:Number = 10;
		public static const HORSEPOWERS:Number = 40
		public static const CAR_STARTING_POS:b2Vec2 = new b2Vec2(10,10);
		 
		public static const leftRearWheelPosition:b2Vec2 = new b2Vec2(-1.5,1.90);
		public static const rightRearWheelPosition:b2Vec2 = new b2Vec2(1.5,1.9);
		public static const leftFrontWheelPosition:b2Vec2 = new b2Vec2(-1.5,-1.9);
		public static const rightFrontWheelPosition:b2Vec2 = new b2Vec2(1.5, -1.9);
		public static const WheelSizeX:Number = 0.1;
		public static const WheelSizeY:Number = 0.25;
		public static const WheelDelayX:Number = 0.5;
		 
		private var engineSpeed:Number = 0;
		private var steeringAngle:Number = 0
		private var leftJoint:b2RevoluteJoint;
		private var rightJoint:b2RevoluteJoint;
		
		public function BaseCar() 
		{
			_carsMovie.gotoAndStop(1);
			addChild(_carsMovie);
			addChild(_carArrow);
		}
		
		public function Init(clip:Sprite, owner:MapSegment, layer:Sprite):void 
		{
			_hero = App.universe.hero;
			ChooseCarType();
			_isTransformed = false;
			_layer = layer;
			_layer.addChild(this);
			
			_carArrow.visible = true;
			
			var tmpMovie:MovieClip = _carsMovie.getChildAt(0) as MovieClip;
			var tmpMovie2:Sprite = tmpMovie.getChildAt(1) as Sprite;
			
			_width = tmpMovie2.width;
			_height = tmpMovie2.height;
			
			tmpMovie2.visible = false;
			
			
			
			_centerPoint.x = clip.x + owner.x;
			_centerPoint.y = clip.y + owner.y;
			
			x = _centerPoint.x;
			y = _centerPoint.y;
			rotation = clip.rotation;
			_carArrow.rotation = - rotation;
			_angle = clip.rotation;
			_angle *= App.DEG_TO_RAD;
			_body = CreateStaticBody();
			App.universe.addEventListener(Destroying.DESTROY, Destroy, false , 0, true);
			
			carsArray.push(this);
			
			_checkForHeroTimer.start();
			_checkForHeroTimer.addEventListener(TimerEvent.TIMER, onCheckForHero, false, 0, true);
			
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onResumeEvent, false, 0, true);
		}
		
		private function onCheckForHero(e:TimerEvent):void 
		{
			if (Point.distance(new Point(_hero.x, _hero.y), new Point(x, y)) > MAX_DISTANCE_TO_HERO)
			{
				Destroy();
			}
		}
		
		private function onResumeEvent(e:PauseEvent):void 
		{
			if (_isTransformed)
			{
				addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
				App.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				App.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			}
			else
			{
				_checkForHeroTimer.start();
			}
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			if (_isTransformed)
			{
				removeEventListener(Event.ENTER_FRAME, onUpdate, false);
				App.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
				App.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
			}
			else
			{
				_checkForHeroTimer.stop();
			}
		}
		
		private function ChooseCarType():void 
		{
			_carsMovie.gotoAndStop(App.randomInt(1, _carsMovie.totalFrames + 1));
		}
		
		private function CreateStaticBody():b2Body 
		{
			var px:Number = _centerPoint.x / App.WORLD_SCALE;
			var py:Number = _centerPoint.y / App.WORLD_SCALE;
			var w:Number = _width / App.WORLD_SCALE;
			var h:Number = _height / App.WORLD_SCALE;
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(px , py );
			myBody.allowSleep = true;
			var myBox:b2PolygonShape = new b2PolygonShape();
			myBox.SetAsBox(w / 2 , h / 2);
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture2(myBox, 0);
			worldBody.SetAngle(_angle);
			worldBody.SetUserData(this);
			return worldBody;
		}
		
		private function CreateDynamicBody():b2Body 
		{
			var px:Number = _centerPoint.x / App.WORLD_SCALE;
			var py:Number = _centerPoint.y / App.WORLD_SCALE;
			var w:Number = _width / App.WORLD_SCALE;
			var h:Number = _height / App.WORLD_SCALE;
			var myBody:b2BodyDef = new b2BodyDef();
			myBody.position.Set(px , py );
			myBody.type = b2Body.b2_dynamicBody;
			myBody.allowSleep = true;
			var myBox:b2PolygonShape = new b2PolygonShape();
			myBox.SetAsBox(w / 2 , h / 2);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = myBox;
			myFixture.density = 5;
			myFixture.friction = 1;
			myFixture.restitution = 0;
			myFixture.isSensor = false;
			var worldBody:b2Body = App.world.CreateBody(myBody);
			worldBody.CreateFixture(myFixture);
			worldBody.SetAngle(_angle);
			worldBody.SetUserData(this);
			return worldBody;
		}
		
		public function Destroy(e:Destroying = null):void 
		{
			_layer.removeChild(this);
			_centerPoint = null;
			App.universe.removeEventListener(Destroying.DESTROY, Destroy, false);
			
			if (_isTransformed)
			{
				TransformToBody();
			}
			
			_checkForHeroTimer.reset();
			_checkForHeroTimer.removeEventListener(TimerEvent.TIMER, onCheckForHero, false);
			
			App.world.DestroyBody(_body);
			
			App.gameInterface.removeEventListener(PauseEvent.PAUSE, onPauseEvent, false);
			App.gameInterface.removeEventListener(PauseEvent.UNPAUSE, onResumeEvent, false);
			
			for (var i:int = 0; i < carsArray.length; i++)
			{
				if (this == carsArray[i])
				{
					carsArray.splice(i, 1);
					break;
				}
			}
			
			App.pools.returnPoolObject(NAME, this);
		}
		
		public function TransformToCar():void 
		{
			if (_isTransformed) { return; }
			
			_carArrow.visible = false;
			
			_centerPoint.x = _body.GetPosition().x * App.WORLD_SCALE;
			_centerPoint.y = _body.GetPosition().y * App.WORLD_SCALE;
			_angle = _body.GetAngle();
			App.world.DestroyBody(_body);
			_body = CreateDynamicBody();
			
			/*App.world.DestroyBody(_body);
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.linearDamping = 1;
			bodyDef.angularDamping = 1;
			bodyDef.position.Set(_centerPoint.x / App.WORLD_SCALE, _centerPoint.y / App.WORLD_SCALE);
			var boxDef:b2PolygonShape = new b2PolygonShape();
			boxDef.SetAsBox(_width / App.WORLD_SCALE, _height / App.WORLD_SCALE);
			trace(_width, _width / App.WORLD_SCALE, _height, _height / App.WORLD_SCALE);*/
			/*var myFixture:b2FixtureDef; = new b2FixtureDef();
			myFixture.shape = boxDef;
			myFixture.density = 1;
			myFixture.friction = 1;
			myFixture.restitution = 0;
			myFixture.isSensor = false;
			_body = App.world.CreateBody(bodyDef);
			_body.CreateFixture(myFixture);
			_body.SetUserData(this);*/
			
			
			var totalPoint:Point = App.TurnVectorToAngle(new Point(0, 0), new Point(( -_width / 2 / App.WORLD_SCALE - WheelSizeX), ( -_height / 2 / App.WORLD_SCALE + WheelDelayX)), _body.GetAngle() * App.RAD_TO_DEG);
			var leftWheelDef:b2BodyDef = new b2BodyDef();
			leftWheelDef.position.Set(_centerPoint.x / App.WORLD_SCALE, _centerPoint.y / App.WORLD_SCALE);
			leftWheelDef.type = b2Body.b2_dynamicBody;
			leftWheelDef.position.Add(new b2Vec2(totalPoint.x, totalPoint.y));
			var leftWheelShapeDef:b2PolygonShape = new b2PolygonShape();
			leftWheelShapeDef.SetAsBox(WheelSizeX, WheelSizeY);
			var myFixture:b2FixtureDef = new b2FixtureDef();
			myFixture.shape = leftWheelShapeDef;
			myFixture.density = 2;
			myFixture.friction = 1;
			myFixture.restitution = 0;
			myFixture.isSensor = false;
			_leftUpWheel = App.world.CreateBody(leftWheelDef);
			_leftUpWheel.CreateFixture(myFixture);
			_leftUpWheel.SetAngle(_body.GetAngle());
			
			
			totalPoint = App.TurnVectorToAngle(new Point(0, 0), new Point((_width / 2 / App.WORLD_SCALE + WheelSizeX), ( -_height / 2 / App.WORLD_SCALE + WheelDelayX)), _body.GetAngle() * App.RAD_TO_DEG);
			var rightWheelDef:b2BodyDef = new b2BodyDef();
			rightWheelDef.position.Set(_centerPoint.x / App.WORLD_SCALE, _centerPoint.y / App.WORLD_SCALE);
			rightWheelDef.position.Add(new b2Vec2(totalPoint.x, totalPoint.y));
			rightWheelDef.type = b2Body.b2_dynamicBody;
			var rightWheelShapeDef:b2PolygonShape = new b2PolygonShape();
			rightWheelShapeDef.SetAsBox(0.1,0.25);
			myFixture = new b2FixtureDef();
			myFixture.shape = rightWheelShapeDef;
			myFixture.density = 2;
			myFixture.friction = 1;
			myFixture.restitution = 0;
			myFixture.isSensor = false;
			_rightUpWheel = App.world.CreateBody(rightWheelDef);
			_rightUpWheel.CreateFixture(myFixture);
			_rightUpWheel.SetAngle(_body.GetAngle());
			
			
			totalPoint = App.TurnVectorToAngle(new Point(0, 0), new Point((-_width / 2 / App.WORLD_SCALE - WheelSizeX), ( _height / 2 / App.WORLD_SCALE - WheelDelayX)), _body.GetAngle() * App.RAD_TO_DEG);
			var leftRearWheelDef:b2BodyDef = new b2BodyDef();
			leftRearWheelDef.position.Set(_centerPoint.x / App.WORLD_SCALE, _centerPoint.y / App.WORLD_SCALE);
			leftRearWheelDef.position.Add(new b2Vec2(totalPoint.x, totalPoint.y));
			leftRearWheelDef.type = b2Body.b2_dynamicBody;
			var leftRearWheelShapeDef:b2PolygonShape = new b2PolygonShape();
			leftRearWheelShapeDef.SetAsBox(0.1,0.25);
			myFixture = new b2FixtureDef();
			myFixture.shape = leftRearWheelShapeDef;
			myFixture.density = 2;
			myFixture.friction = 1;
			myFixture.restitution = 0;
			myFixture.isSensor = false;
			_leftDownWheel = App.world.CreateBody(leftRearWheelDef);
			_leftDownWheel.CreateFixture(myFixture);
			_leftDownWheel.SetAngle(_body.GetAngle());
			
			
			totalPoint = App.TurnVectorToAngle(new Point(0, 0), new Point((_width / 2 / App.WORLD_SCALE + WheelSizeX), ( _height / 2 / App.WORLD_SCALE - WheelDelayX)), _body.GetAngle() * App.RAD_TO_DEG);
			var rightRearWheelDef:b2BodyDef = new b2BodyDef();
			rightRearWheelDef.position.Set(_centerPoint.x / App.WORLD_SCALE, _centerPoint.y / App.WORLD_SCALE);
			rightRearWheelDef.position.Add(new b2Vec2(totalPoint.x, totalPoint.y));
			rightRearWheelDef.type = b2Body.b2_dynamicBody;
			var rightRearWheelShapeDef:b2PolygonShape = new b2PolygonShape();
			rightRearWheelShapeDef.SetAsBox(0.1,0.25);
			myFixture = new b2FixtureDef();
			myFixture.shape = rightRearWheelShapeDef;
			myFixture.density = 2;
			myFixture.friction = 1;
			myFixture.restitution = 0;
			myFixture.isSensor = false;
			_rightDownWheel = App.world.CreateBody(rightRearWheelDef);
			_rightDownWheel.CreateFixture(myFixture);
			_rightDownWheel.SetAngle(_body.GetAngle());
			
			
			var leftJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			leftJointDef.Initialize(_body, _leftUpWheel, _leftUpWheel.GetWorldCenter());
			leftJointDef.enableMotor = true;
			leftJointDef.maxMotorTorque = 100;
			 
			var rightJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			rightJointDef.Initialize(_body, _rightUpWheel, _rightUpWheel.GetWorldCenter());
			rightJointDef.enableMotor = true;
			rightJointDef.maxMotorTorque = 100;
			 
			leftJoint = App.world.CreateJoint(leftJointDef) as b2RevoluteJoint;
			rightJoint = App.world.CreateJoint(rightJointDef) as b2RevoluteJoint;
			 
			var leftRearJointDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			leftRearJointDef.Initialize(_body, _leftDownWheel, _leftDownWheel.GetWorldCenter(), new b2Vec2(0.8,0));
			leftRearJointDef.enableLimit = true;
			leftRearJointDef.lowerTranslation = leftRearJointDef.upperTranslation = 0;
			 
			var rightRearJointDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			rightRearJointDef.Initialize(_body, _rightDownWheel, _rightDownWheel.GetWorldCenter(), new b2Vec2(0.8,0));
			rightRearJointDef.enableLimit = true;
			rightRearJointDef.lowerTranslation = rightRearJointDef.upperTranslation = 0;
			 
			App.world.CreateJoint(leftRearJointDef);
			App.world.CreateJoint(rightRearJointDef);
			
			addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
			App.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			App.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			
			
			_leftDownWheel.SetAwake(true);
			_leftUpWheel.SetAwake(true);
			_rightDownWheel.SetAwake(true);
			_rightUpWheel.SetAwake(true);
			
			_checkForHeroTimer.reset();
			
			_isTransformed = true;
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			if(e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN){
				engineSpeed = 0;
			} 
			if(e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT){
				steeringAngle = 0;
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if(e.keyCode == Keyboard.UP){
				//body.WakeUp();
				engineSpeed = -HORSEPOWERS;
			}
			if(e.keyCode == Keyboard.DOWN){
				engineSpeed = HORSEPOWERS;
			}
			if(e.keyCode == Keyboard.RIGHT){
				steeringAngle = MAX_STEER_ANGLE;
			}
			if(e.keyCode == Keyboard.LEFT){
				steeringAngle = -MAX_STEER_ANGLE;
			}
		}
		
		private function onUpdate(e:Event):void 
		{
			killOrthogonalVelocity(_leftDownWheel);
			killOrthogonalVelocity(_leftUpWheel);
			killOrthogonalVelocity(_rightDownWheel);
			killOrthogonalVelocity(_rightUpWheel);
		 
			//Driving
			var ldirection:b2Vec2 = _leftUpWheel.GetTransform().R.col2.Copy();
			ldirection.Multiply(engineSpeed);
			var rdirection:b2Vec2 = _rightUpWheel.GetTransform().R.col2.Copy()
			rdirection.Multiply(engineSpeed);
			_leftUpWheel.ApplyForce(ldirection, _leftUpWheel.GetPosition());
			_rightUpWheel.ApplyForce(rdirection, _rightUpWheel.GetPosition());
		 
			//Steering
			var mspeed:Number;
			mspeed = steeringAngle - leftJoint.GetJointAngle();
			leftJoint.SetMotorSpeed(mspeed * STEER_SPEED);
			mspeed = steeringAngle - rightJoint.GetJointAngle();
			rightJoint.SetMotorSpeed(mspeed * STEER_SPEED);
			
			//visual
			x = _body.GetPosition().x * App.WORLD_SCALE;
			y = _body.GetPosition().y * App.WORLD_SCALE;
			rotation = _body.GetAngle() * App.RAD_TO_DEG;
		}
		
		private function killOrthogonalVelocity(targetBody:b2Body):void
		{
			var localPoint:b2Vec2 = new b2Vec2(0,0);
			var velocity:b2Vec2 = targetBody.GetLinearVelocityFromLocalPoint(localPoint);
		 
			var sidewaysAxis:b2Vec2 = targetBody.GetTransform().R.col2.Copy();
			sidewaysAxis.Multiply(b2Math.Dot(velocity,sidewaysAxis))
		 
			targetBody.SetLinearVelocity(sidewaysAxis);
		}
			
		public function TransformToBody():void 
		{
			if (!_isTransformed) { return; }
			
			_centerPoint.x = _body.GetPosition().x * App.WORLD_SCALE;
			_centerPoint.y = _body.GetPosition().y * App.WORLD_SCALE;
			_angle = _body.GetAngle();
			App.world.DestroyBody(_body);
			_body = CreateStaticBody();
			
			_carArrow.visible = true;
			App.world.DestroyBody(_leftDownWheel);
			App.world.DestroyBody(_leftUpWheel);
			App.world.DestroyBody(_rightDownWheel);
			App.world.DestroyBody(_rightUpWheel);
			
			removeEventListener(Event.ENTER_FRAME, onUpdate, false);
			App.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
			App.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
			
			_isTransformed = false;
			_checkForHeroTimer.start();
		}
	}

}