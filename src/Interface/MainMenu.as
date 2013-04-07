package Interface 
{
	import Events.MainMenuToMain;
	import Events.structs.MainMenuSettings;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import GameModes.GameModesInfo;
	/**
	 * ...
	 * @author 
	 */
	public class MainMenu extends Sprite
	{
		private var mainMenuSp:MovieClip = new MainMenu_movie();
		
		public function MainMenu() 
		{
			addChild(mainMenuSp);
		}
		
		public function Init():void 
		{
			MainMenuPage();
		}
		
		private function MainMenuPage():void 
		{
			UpdateSoundButtonsBySoundStatus();
			mainMenuSp.modesMovie.gotoAndStop(1);
			mainMenuSp.startBtn.addEventListener(MouseEvent.CLICK, StartOptions, false, 0, true);
			
			mainMenuSp.sound_movie.addEventListener(MouseEvent.CLICK, onChangeSoundStatus, false, 0, true);
			mainMenuSp.music_movie.addEventListener(MouseEvent.CLICK, onChangeMusicStatus, false, 0, true);
		}
		
		private function StartOptions(e:MouseEvent):void 
		{
			mainMenuSp.modesMovie.gotoAndPlay(1);
			mainMenuSp.modesMovie.addEventListener("choose_mode", ChooseMode, false, 0, true);
		}
		
		private function ChooseMode(e:Event):void 
		{
			mainMenuSp.modesMovie.removeEventListener("choose_mode", ChooseMode, false);
			mainMenuSp.modesMovie.gotoAndStop(mainMenuSp.modesMovie.totalFrames);
			mainMenuSp.modesMovie.storyMode.addEventListener(MouseEvent.CLICK, onStartGameWithStoryMode, false, 0, true);
		}
		
		private function onStartGameWithStoryMode(e:MouseEvent):void 
		{
			App.current_game_mode = GameModesInfo.MODE_STORY;
			var setts:MainMenuSettings = new MainMenuSettings();
			setts.mode = GameModesInfo.MODE_STORY;
			
			dispatchEvent(new MainMenuToMain(MainMenuToMain.MAINMENU, false, false, setts));
		}
		
		private function onChangeMusicStatus(e:MouseEvent):void 
		{
			App.musicOn = !App.musicOn;
			UpdateSoundButtonsBySoundStatus();
		}
		
		private function onChangeSoundStatus(e:MouseEvent):void 
		{
			App.soundOn = !App.soundOn;
			UpdateSoundButtonsBySoundStatus();
		}
		
		private function UpdateSoundButtonsBySoundStatus():void 
		{
			if (App.soundOn)
			{
				mainMenuSp.sound_movie.gotoAndStop("on");
			}
			else
			{
				mainMenuSp.sound_movie.gotoAndStop("off");
			}
			
			if (App.musicOn)
			{
				mainMenuSp.music_movie.gotoAndStop("on");
			}
			else
			{
				mainMenuSp.music_movie.gotoAndStop("off");
			}
		}
		
		public function Destroy():void 
		{
			
		}
	}

}