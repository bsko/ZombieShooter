package Interface 
{
	import Events.PauseEvent;
	import Events.QuitGame;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import Quests.QuestPerson;
	/**
	 * ...
	 * @author ...
	 */
	public class GameInterface extends Sprite
	{
		private var _interface:MovieClip = new SystemBar();
		private var _isOnPause:Boolean = false;
		private var _isMenuFrame:Boolean = false;
		
		public function GameInterface() 
		{
			addChild(_interface);
		}
		
		public function Init():void
		{
			_interface.gotoAndStop(1);
			UpdateSoundButtons();
			
			_interface.weapon.stop();
			_interface.redBar.stop();
			_interface.blueBar.stop();
			
			_interface.soundBtn.addEventListener(MouseEvent.CLICK, onChangeSoundStatus, false, 0, true);
			_interface.musicBtn.addEventListener(MouseEvent.CLICK, onChangeMusicStatus, false, 0, true);
			_interface.menuBtn.addEventListener(MouseEvent.CLICK, onMenuPage, false, 0, true);
			_interface.inventoryBtn.addEventListener(MouseEvent.CLICK, onInventoryPage, false, 0, true);
		}
		
		private function onInventoryPage(e:MouseEvent):void 
		{
			
		}
		
		private function onMenuPage(e:MouseEvent):void 
		{
			if (_isMenuFrame) { return; }
			RemoveEventListenersFromMainFrame();
			
			Pause();
			
			_interface.gotoAndStop(2);
			_interface.resumeBtn.addEventListener(MouseEvent.CLICK, onResumeGame, false, 0, true);
			_interface.mainmenuBtn.addEventListener(MouseEvent.CLICK, onAbortGame, false, 0, true);
			_interface.soundBtn.addEventListener(MouseEvent.CLICK, onChangeSoundStatus, false, 0, true);
			_interface.musicBtn.addEventListener(MouseEvent.CLICK, onChangeMusicStatus, false, 0, true);
			_isMenuFrame = true;
		}
		
		private function onResumeGame(e:MouseEvent = null):void 
		{
			if (!_isMenuFrame) { return; }
			_interface.resumeBtn.removeEventListener(MouseEvent.CLICK, onResumeGame, false);
			_interface.mainmenuBtn.removeEventListener(MouseEvent.CLICK, onAbortGame, false);
			_interface.soundBtn.removeEventListener(MouseEvent.CLICK, onChangeSoundStatus, false);
			_interface.musicBtn.removeEventListener(MouseEvent.CLICK, onChangeMusicStatus, false);
			
			Resume();
			
			_interface.gotoAndStop(1);
			_interface.soundBtn.addEventListener(MouseEvent.CLICK, onChangeSoundStatus, false, 0, true);
			_interface.musicBtn.addEventListener(MouseEvent.CLICK, onChangeMusicStatus, false, 0, true);
			_interface.menuBtn.addEventListener(MouseEvent.CLICK, onMenuPage, false, 0, true);
			_interface.inventoryBtn.addEventListener(MouseEvent.CLICK, onInventoryPage, false, 0, true);
			_isMenuFrame = false;
		}
		
		private function onAbortGame(e:MouseEvent):void 
		{
			dispatchEvent(new QuitGame(QuitGame.QUITGAME, false, false, true, false, false));
		}
		
		private function UpdateSoundButtons():void 
		{
			if (App.soundOn) { _interface.soundBtn.gotoAndStop(1); }
			else { _interface.soundBtn.gotoAndStop(2); }
			if (App.musicOn) { _interface.musicBtn.gotoAndStop(1); }
			else { _interface.musicBtn.gotoAndStop(2); }
		}
		
		private function onChangeMusicStatus(e:MouseEvent):void 
		{
			App.musicOn = !App.musicOn;
			UpdateSoundButtons();
		}
		
		private function onChangeSoundStatus(e:MouseEvent):void 
		{
			App.soundOn = !App.soundOn;
			UpdateSoundButtons();
		}
		
		public function Pause():void
		{
			if (!_isOnPause)
			{
				dispatchEvent(new PauseEvent(PauseEvent.PAUSE, false, false));
				_isOnPause = true;
			}
		}
		
		public function Resume():void
		{
			if (_isOnPause)
			{
				dispatchEvent(new PauseEvent(PauseEvent.UNPAUSE, false, false));
				_isOnPause = false;
			}
		}
		
		public function Destroy():void
		{
			if (_isMenuFrame) { onResumeGame(); }
			if (_isOnPause) { Resume(); }
			RemoveEventListenersFromMainFrame();
		}
		
		private function RemoveEventListenersFromMainFrame():void 
		{
			_interface.soundBtn.removeEventListener(MouseEvent.CLICK, onChangeSoundStatus, false);
			_interface.musicBtn.removeEventListener(MouseEvent.CLICK, onChangeMusicStatus, false);
			_interface.menuBtn.removeEventListener(MouseEvent.CLICK, onMenuPage, false);
			_interface.inventoryBtn.removeEventListener(MouseEvent.CLICK, onInventoryPage, false);
		}
		
		public function BeginQuest(person:QuestPerson):void 
		{
			Pause();
			trace("OLOLOLOLED");
			//person.DeletePerson();
		}
		
		public function get isOnPause():Boolean 
		{
			return _isOnPause;
		}
	}

}