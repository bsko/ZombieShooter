package Weapons 
{
	/**
	 * ...
	 * @author 
	 */
	public class BaseWeapon 
	{
		
		protected var _shootingDelay:int;
		protected var _bulletsCount:int;
		protected var _reloadingDelay:int;
		protected var _caliber:int;
		protected var _bulletDamage:int;
		
		public function get shootingDelay():int { return _shootingDelay; }
		
		public function get bulletsCount():int { return _bulletsCount; }
		
		public function get reloadingDelay():int { return _reloadingDelay; }
		
		public function get caliber():int { return _caliber; }
		
		public function get bulletDamage():int { return _bulletDamage; }
	}

}