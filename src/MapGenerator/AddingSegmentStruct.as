package MapGenerator 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author ...
	 */
	public class AddingSegmentStruct 
	{
		public var mapSegment:MapSegment;
		public var index:int;
		public var startX:int;
		public var startY:int;
		public var parent:Sprite;
		public var upperParent:Sprite;
		
		public function AddingSegmentStruct(mapSegm:MapSegment, ind:int, strtX:int, strtY:int, prnt:Sprite, upperPrnt:Sprite)
		{
			
			mapSegment = mapSegm;
			index = ind;
			startX = strtX;
			startY = strtY;
			parent = prnt;
			upperParent = upperPrnt;
		}
		
	}

}