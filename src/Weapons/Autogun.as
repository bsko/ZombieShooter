package Weapons 
{
	/**
	 * ...
	 * @author 
	 */
	public class Autogun extends BaseWeapon
	{
		
		public function Autogun() 
		{
			_shootingDelay = 100;
			_bulletsCount = 30;
			_reloadingDelay = 1000;
			_bulletDamage = 45;
		}
		
	}

}