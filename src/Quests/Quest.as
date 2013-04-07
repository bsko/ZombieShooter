package Quests 
{
	/**
	 * ...
	 * @author ...
	 */
	public class Quest 
	{
		/*
		 * 		5 типов квестов:
		 * 1. сюжетная линия
		 * 2. принести медикоменты: генерица медикомент в локации показанной стрелочкой,
		 * его необходимо взять и отнести в локацию, показанную стрелочкой
		 * 3. найти и доставить транспорт
		 * 4. сопроводить кого нибудь куда нибудь
		 * 5. убить n-зомби
		*/
		
		public static const QTYPE_MAIN:int = 101;
		public static const QTYPE_MEDIC:int = 102;
		public static const QTYPE_CAR:int = 103;
		public static const QTYPE_CONVOY:int = 104;
		public static const QTYPE_KILLZOMBIE:int = 105;
		
		public function Quest() 
		{
			
		}
		
	}

}