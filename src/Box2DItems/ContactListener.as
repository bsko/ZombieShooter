package Box2DItems 
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2DItems.SegmentSensor;
	import Enemies.BaseEnemy;
	import Quests.QuestPerson;
	/**
	 * ...
	 * @author 
	 */
	public class ContactListener extends b2ContactListener
	{
		private var _dispatcher:ContactDispatcher;
		
		public function Init():void
		{
			_dispatcher = App.contactDispatcher;
		}
		
		override public function BeginContact(contact:b2Contact):void 
		{
			var fixtureA:b2Fixture = contact.GetFixtureA();
			var fixtureB:b2Fixture = contact.GetFixtureB();
			var bodyA:b2Body = fixtureA.GetBody();
			var bodyB:b2Body = fixtureB.GetBody();
			
			// контакт пули с объектами:
			if (bodyA.GetUserData() is Bullet && !(bodyB.GetUserData() is Hero))
			{
				(bodyA.GetUserData() as Bullet).contacted  = true;
				if (bodyB.GetUserData() is BaseEnemy)
				{
					var dmg:int = (bodyA.GetUserData() as Bullet).weapon.bulletDamage;
					(bodyB.GetUserData() as BaseEnemy).TakingDamage(dmg);
				}
			}
			else if (bodyB.GetUserData() is Bullet && !(bodyA.GetUserData() is Hero))
			{
				(bodyB.GetUserData() as Bullet).contacted  = true
				if (bodyA.GetUserData() is BaseEnemy)
				{
					dmg = (bodyB.GetUserData() as Bullet).weapon.bulletDamage;
					(bodyA.GetUserData() as BaseEnemy).TakingDamage(dmg);
				}
			}
			// контакт героя с квестовыми персонажами:
			else if (bodyA.GetUserData() is QuestPerson && bodyB.GetUserData() is Hero)
			{
				var person:QuestPerson = (bodyA.GetUserData() as QuestPerson);
				App.gameInterface.BeginQuest(person);
			}
			else if (bodyB.GetUserData() is QuestPerson && bodyA.GetUserData() is Hero)
			{
				person = (bodyB.GetUserData() as QuestPerson);
				App.gameInterface.BeginQuest(person);
			}
		}
	}

}