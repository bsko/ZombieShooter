package  
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2World;
	import Box2DItems.*;
	import Cars.BaseCar;
	import Enemies.DefaultZombie;
	import Enemies.GenerateZones.*;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import Interface.*;
	import MapGenerator.*;
	import pool.PoolManager;
	import Quests.QuestPerson;
	
	/**
	 * ...
	 * @author 
	 */
	
	public class App 
	{	
		public static const DEG_TO_RAD:Number = Math.PI / 180;
		public static const RAD_TO_DEG:Number = 180 / Math.PI;
		
		public static var universe:Universe;
		public static var stage:Stage;
		public static var mainInterface:MainMenu;
		public static var contactDispatcher:ContactDispatcher = new ContactDispatcher();
		public static var gameInterface:GameInterface = new GameInterface();
		public static var current_game_mode:int;
		
		public static var soundOn:Boolean = true;
		public static var musicOn:Boolean = true;
		
		public static var pools:PoolManager = new PoolManager();
		
		public static var world:b2World = new b2World(new b2Vec2(0, 0), true);
		static public var WORLD_SCALE:int = 30;
		public static var world_step:Number = 1 / WORLD_SCALE;
		public static var contact_listener:ContactListener = new ContactListener();
		
		public static function InitWorld():void
		{
			world.SetContactListener(contact_listener);
			contact_listener.Init();
		}
		
		public static function InitPool():void
		{
			pools.addPool(MapSegment.NAME, MapSegment, 25);
			pools.addPool(StaticObject.NAME, StaticObject, 1300);
			pools.addPool(StaticRoundObject.NAME, StaticRoundObject, 800);
			
			// zombies
			pools.addPool(ActiveGenerateZone.NAME, ActiveGenerateZone, 36);
			pools.addPool(PassiveGenerateZone.NAME, PassiveGenerateZone, 36);
			pools.addPool(DefaultZombie.NAME, DefaultZombie, 100);
			
			// other
			pools.addPool(Bullet.NAME, Bullet, 100);
			pools.addPool(BaseCar.NAME, BaseCar, 40);
			pools.addPool(QuestPerson.NAME, QuestPerson, 20);
			pools.addPool(Helicopter.NAME, Helicopter, 10);
		}
		
		public static function randomInt(a:int, b:int):int 
		{
			if (a > b) { 
				throw(Error("invalid variables"));
			}
			if (a == b) {
				return a;
			}
			return int((Math.random() * (b - a)  + a));
		}
		
		public static function angleFinding(currentPoint:Point, nextPoint:Point):Number 
		{
			var angle:Number;
			angle = (Math.atan((nextPoint.x - currentPoint.x) / (nextPoint.y - currentPoint.y)) * 180 / Math.PI);
			angle = 360 - angle;
			if (nextPoint.y >= currentPoint.y) { angle += 180; } 
			return angle;
		}
		
		public static function GetAngle(FirstPoint:Point, SecondPoint:Point):Number
		{
			var angle:Number = angleFinding(FirstPoint, SecondPoint);
			angle += 180;
			angle %= 360;
			angle -= 180;
			return angle;
		}
		
		public static function TurnVectorToAngle(startPoint:Point, endPoint:Point, angle:Number):Point
		{
			var tmpAngle:int = angleFinding(startPoint, endPoint);
			var length:Number = Point.distance(startPoint, endPoint);
			var tmpPoint:Point = Point.polar(length, (tmpAngle + angle - 90) * DEG_TO_RAD);
			return tmpPoint;
		}
	}

}