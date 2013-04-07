package Events 
{
	import flash.events.Event;
	import Events.structs.*;
	
	/**
	 * ...
	 * @author 
	 */
	public class MainMenuToMain extends Event 
	{
		public static const MAINMENU:String = "MainMenuToMain";
		private var _settings:MainMenuSettings;
		
		public function MainMenuToMain(type:String, bubbles:Boolean=false, cancelable:Boolean=false, setts:MainMenuSettings = null) 
		{ 
			super(type, bubbles, cancelable);
			_settings = setts;
		} 
		
		public override function clone():Event 
		{ 
			return new MainMenuToMain(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MainMenuToMain", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get settings():MainMenuSettings { return _settings; }
	}
	
}