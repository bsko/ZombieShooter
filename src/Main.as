package 
{
	import Box2DItems.ContactDispatcher;
	import Events.MainMenuToMain;
	import Events.QuitGame;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import Interface.MainMenu;

	/**
	 * ...
	 * @author 
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{

		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			InitFirstStart();
		}
		
		private function InitFirstStart():void 
		{
			App.universe = new Universe();
			App.stage = stage;
			App.mainInterface = new MainMenu();
			App.InitPool();
			App.InitWorld();
			App.contact_listener
			addChild(App.mainInterface);
			App.mainInterface.Init();
			App.mainInterface.addEventListener(MainMenuToMain.MAINMENU, onMainMenuEvent, false, 0, true);
		}
		
		private function onMainMenuEvent(e:MainMenuToMain):void 
		{
			App.mainInterface.removeEventListener(MainMenuToMain.MAINMENU, onMainMenuEvent, false);
			App.mainInterface.Destroy();
			removeChild(App.mainInterface);
			addChild(App.universe);
			addChild(App.gameInterface);
			App.universe.Init();
			App.gameInterface.Init();
			App.gameInterface.addEventListener(QuitGame.QUITGAME, onQuitGame, false, 0, true);
		}
		
		private function onQuitGame(e:QuitGame):void 
		{
			App.gameInterface.removeEventListener(QuitGame.QUITGAME, onQuitGame, false);
			if (e.levelQuit)
			{
				removeChild(App.universe);
				removeChild(App.gameInterface);
				App.gameInterface.Destroy();
				App.universe.Destroy();
				addChild(App.mainInterface);
				App.mainInterface.Init();
				App.mainInterface.addEventListener(MainMenuToMain.MAINMENU, onMainMenuEvent, false, 0, true);
			}
			else if (e.levelWon)
			{
				
			}
			else if (e.levelLost)
			{
				
			}
		}
	}

}