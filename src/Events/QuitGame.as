package Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Temnov Aleksey
	 */
	public class QuitGame extends Event 
	{
		public static const QUITGAME:String = "quitgame";
		private var _levelQuit:Boolean = false;
		private var _levelWon:Boolean = false;
		private var _levelLost:Boolean = false;
		
		public function QuitGame(type:String, bubbles:Boolean=false, cancelable:Boolean=false, quit:Boolean = false, won:Boolean = false, lost:Boolean = false) 
		{ 
			super(type, bubbles, cancelable);
			
			_levelQuit = quit;
			_levelWon = won;
			_levelLost = lost;
		} 
		
		public override function clone():Event 
		{ 
			return new QuitGame(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("QuitGame", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get levelQuit():Boolean 
		{
			return _levelQuit;
		}
		
		public function get levelWon():Boolean 
		{
			return _levelWon;
		}
		
		public function get levelLost():Boolean 
		{
			return _levelLost;
		}
		
	}
	
}