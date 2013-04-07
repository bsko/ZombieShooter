package  
{
	import Box2D.Dynamics.b2DebugDraw;
	import Cars.BaseCar;
	import Enemies.BaseEnemy;
	import Enemies.GenerateZones.BaseGenerateZone;
	import Events.Destroying;
	import Events.PauseEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	import MapGenerator.*;
	/**
	 * ...
	 * @author 
	 */
	public class Universe extends Sprite
	{
		// layers
		private var _mapSprite:Sprite = new Sprite();
		private var _heroSprite:Sprite = new Sprite();
		private var _upperMapSprite:Sprite = new Sprite();
		private var _carSprite:Sprite = new Sprite();
		private var _helicopterSprite:Sprite = new Sprite();
		// ------
		private var _hero:Hero = new Hero();
		private var _camera:Camera = new Camera();
		private var _mapGenerator:MapGenerator = new MapGenerator(_mapSprite, _upperMapSprite);
		// test
		private var debugSprite:Sprite = new Sprite();
		// ----
		
		public function Universe() 
		{
			addChild(_mapSprite);
			addChild(_heroSprite);
			addChild(_carSprite);
			addChild(_upperMapSprite);
			addChild(_helicopterSprite);
		}
		
		public function Init():void 
		{
			_hero.Init();
			_heroSprite.addChild(_hero);
			_mapGenerator.Init();
			_mapGenerator.CreateNewMap();
			_camera.Init(_hero, this);
			//debugDraw();
			BaseEnemy.ZombiesArray.length = 0;
			App.world_step = 1 / App.WORLD_SCALE;
			addEventListener(Event.ENTER_FRAME, onUpdateWorld, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.PAUSE, onPauseEvent, false, 0, true);
			App.gameInterface.addEventListener(PauseEvent.UNPAUSE, onResumeEvent, false, 0, true);
		}
		
		private function onResumeEvent(e:PauseEvent):void 
		{
			App.world_step = 1 / App.WORLD_SCALE;
		}
		
		private function onPauseEvent(e:PauseEvent):void 
		{
			App.world_step = 0;
		}
		
		private function onUpdateWorld(e:Event):void 
		{
			App.world.Step(App.world_step, 10, 10);
			App.world.ClearForces();
			//App.world.DrawDebugData();
		}
		
		private function debugDraw():void 
		{
			var debugDrawVar:b2DebugDraw = new b2DebugDraw();
			addChild(debugSprite);
			debugDrawVar.SetFillAlpha(0.5);
			debugDrawVar.SetSprite(debugSprite);
			debugDrawVar.SetDrawScale(App.WORLD_SCALE);
			debugDrawVar.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
			App.world.SetDebugDraw(debugDrawVar);
		}
		
		public function AddHelicopter():void
		{
			var heli:Helicopter = App.pools.getPoolObject(Helicopter.NAME);
			heli.Init(_helicopterSprite, _hero);
		}
		
		public function Destroy():void 
		{
			dispatchEvent(new Destroying(Destroying.DESTROY, true, false));
			BaseEnemy.ZombiesArray.length = 0;
			BaseCar.carsArray.length = 0;
			while (App.world.GetBodyCount() > 0)
			{
				App.world.DestroyBody(App.world.GetBodyList());
			}
		}
		
		public function get mapSprite():Sprite { return _mapSprite; }
		
		public function get hero():Hero { return _hero; }
		
		public function get heroSprite():Sprite { return _heroSprite; }
		
		public function get upperMapSprite():Sprite { return _upperMapSprite; }
		
		public function get carSprite():Sprite { return _carSprite; }
	}

}