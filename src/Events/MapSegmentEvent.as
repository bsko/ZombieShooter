package Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class MapSegmentEvent extends Event 
	{
		public static const DESTROYING:String = "destroying";
		
		public function MapSegmentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new MapSegmentEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MapSegmentEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}