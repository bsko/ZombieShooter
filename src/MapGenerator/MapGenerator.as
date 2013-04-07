package MapGenerator 
{
	/**
	 * ...
	 * @author 
	 */
	import Box2DItems.ContactDispatcher;
	import Box2DItems.SegmentSensor;
	import Enemies.BaseEnemy;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import MapGenerator.*;
	import GameModes.*;
	 
	 
	public class MapGenerator extends Sprite
	{
		public static const GENERATING_TIMER_DELAY:int = 500;
		public static const STARTING_MATRIX_SIZE:int = 5;
		public static const UPDATE_DELAY:int = 1000;
		private var _update_hero_pos_timer:Timer = new Timer(UPDATE_DELAY);
		private var _hero:Hero;
		private var _matrix:Array;
		private var layer:Sprite;
		private var upperLayer:Sprite;
		private var _dispatcher:ContactDispatcher = App.contactDispatcher;
		private var _parser_matrix:Array;
		private var _generating:Boolean = false;
		private var _generatingTimer:Timer = new Timer(GENERATING_TIMER_DELAY);
		private var _step:int = 0;
		private var _listener_count:int = 0;
		private var _generateArray:Array = [];
		private var _tileID:int;
		private var _isAddingSectors:Boolean = false;
		
		//-- enterframe checking parsed/unparsed tiles
		private var i_index:int = 0;
		private var j_index:int = 0;
		private var _array_of_tiles_to_make:Array = [];
		// -- end enterframe
		
		public static const CENTER_INDEX:int = int(STARTING_MATRIX_SIZE * STARTING_MATRIX_SIZE / 2);
		
		public static const UPPER_INDEX:int = (int(STARTING_MATRIX_SIZE / 2) - 1) * STARTING_MATRIX_SIZE + int(STARTING_MATRIX_SIZE / 2);
		public static const LEFT_INDEX:int = (int(STARTING_MATRIX_SIZE / 2)) * STARTING_MATRIX_SIZE + int(STARTING_MATRIX_SIZE / 2) - 1;
		public static const RIGHT_INDEX:int = (int(STARTING_MATRIX_SIZE / 2)) * STARTING_MATRIX_SIZE + Math.ceil(STARTING_MATRIX_SIZE / 2);
		public static const BOTTOM_INDEX:int = (int(STARTING_MATRIX_SIZE / 2) + 1) * STARTING_MATRIX_SIZE + int(STARTING_MATRIX_SIZE / 2);
		
		public static const BOTTOM_RIGHT_INDEX:int = (int(STARTING_MATRIX_SIZE / 2) + 1) * STARTING_MATRIX_SIZE + int(STARTING_MATRIX_SIZE / 2) + 1;
		public static const BOTTOM_LEFT_INDEX:int = (int(STARTING_MATRIX_SIZE / 2) + 1) * STARTING_MATRIX_SIZE + int(STARTING_MATRIX_SIZE / 2) - 1;
		public static const UPPER_RIGHT_INDEX:int = (int(STARTING_MATRIX_SIZE / 2) - 1) * STARTING_MATRIX_SIZE + int(STARTING_MATRIX_SIZE / 2) + 1;
		public static const UPPER_LEFT_INDEX:int = (int(STARTING_MATRIX_SIZE / 2) - 1) * STARTING_MATRIX_SIZE + int(STARTING_MATRIX_SIZE / 2) - 1;
		
		//remove zombies things
		private var _removing_timer:Timer = new Timer(200);
		private var _removing_direction:int;
		private var _removing_x_line:int;
		private var _removing_y_line:int;
		// end removing
		
		public function MapGenerator(map_layer:Sprite, upper_layer:Sprite)
		{
			layer = map_layer;
			upperLayer = upper_layer;
		}
		
		public function Init():void
		{
			InitMapMatrix();
		}
		
		private function UpdateMapGrid(arg:int):void 
		{
			var tmpSegment:MapGenerator.MapSegment;
			var newSegment:MapGenerator.MapSegment;
			var tmpNeighbor:MapGenerator.MapSegment;
			var startX:int;
			var startY:int;
			var i:int;
			var length:int;
			var index:int;
			_generateArray.length = 0;
			
			if (arg == UPPER_INDEX)
			{	
				_removing_y_line = _hero.visual_owner.y + TileInfo.TILE_SIZE;
				
				tmpNeighbor = _matrix[0][0];
				
				startX = tmpNeighbor.x;
				startY = tmpNeighbor.y - TileInfo.TILE_SIZE;
				_generateArray.length = 0;
				
				for (i = 0; i < STARTING_MATRIX_SIZE; i++)
				{
					tmpSegment = _matrix[i][STARTING_MATRIX_SIZE - 1];
					tmpSegment.Destroy();
					_matrix[i].pop();
					newSegment = App.pools.getPoolObject(MapSegment.NAME);
					_matrix[i].unshift(newSegment);
					index = i;
					
					var tmpAddedSegm:AddingSegmentStruct = new AddingSegmentStruct(newSegment, index, startX + i * TileInfo.TILE_SIZE , startY, layer, upperLayer);
					
					_generateArray.push(tmpAddedSegm);
				}
			}
			else if (arg == LEFT_INDEX)
			{
				_removing_x_line = _hero.visual_owner.x + TileInfo.TILE_SIZE;
				
				tmpNeighbor = _matrix[0][0];
				
				startX = tmpNeighbor.x - TileInfo.TILE_SIZE;
				startY = tmpNeighbor.y;
				_generateArray.length = 0;
				
				for (i = 0; i < STARTING_MATRIX_SIZE; i++)
				{
					tmpSegment = _matrix[STARTING_MATRIX_SIZE - 1][i];
					tmpSegment.Destroy();
				}
				
				var tmpArray:Array = [];
				
				for (i = 0; i < STARTING_MATRIX_SIZE; i++)
				{
					newSegment = App.pools.getPoolObject(MapSegment.NAME);
					tmpArray.push(newSegment);
					index = STARTING_MATRIX_SIZE * i;
					tmpAddedSegm = new AddingSegmentStruct(newSegment, index, startX, startY + i * TileInfo.TILE_SIZE, layer, upperLayer);
					_generateArray.push(tmpAddedSegm);
				}
				
				_matrix.pop();
				_matrix.unshift(tmpArray);
			}
			else if (arg == RIGHT_INDEX)
			{
				_removing_x_line = _hero.visual_owner.x;
				
				tmpNeighbor = _matrix[STARTING_MATRIX_SIZE - 1][0];
				
				startX = tmpNeighbor.x + TileInfo.TILE_SIZE;
				startY = tmpNeighbor.y;
				_generateArray.length = 0;
				
				for (i = 0; i < STARTING_MATRIX_SIZE; i++)
				{
					tmpSegment = _matrix[0][i];
					tmpSegment.Destroy();
				}
				
				tmpArray = [];
				
				for (i = 0; i < STARTING_MATRIX_SIZE; i++)
				{
					newSegment = App.pools.getPoolObject(MapSegment.NAME);
					tmpArray.push(newSegment);
					index = STARTING_MATRIX_SIZE * i + STARTING_MATRIX_SIZE - 1;
					tmpAddedSegm = new AddingSegmentStruct(newSegment, index, startX, startY + i * TileInfo.TILE_SIZE, layer, upperLayer);
					_generateArray.push(tmpAddedSegm);
				}
				
				_matrix.shift();
				_matrix.push(tmpArray);
			}
			else if (arg == BOTTOM_INDEX)
			{
				_removing_y_line = _hero.visual_owner.y;
				
				tmpNeighbor = _matrix[0][STARTING_MATRIX_SIZE - 1];
				
				startX = tmpNeighbor.x;
				startY = tmpNeighbor.y + TileInfo.TILE_SIZE;
				_generateArray.length = 0;
				
				for (i = 0; i < STARTING_MATRIX_SIZE; i++)
				{
					tmpSegment = _matrix[i][0];
					tmpSegment.Destroy();
					_matrix[i].shift();
					newSegment = App.pools.getPoolObject(MapSegment.NAME);
					_matrix[i].push(newSegment);
					index = STARTING_MATRIX_SIZE * (STARTING_MATRIX_SIZE - 1) + i;
					tmpAddedSegm = new AddingSegmentStruct(newSegment, index, startX + i * TileInfo.TILE_SIZE, startY, layer, upperLayer);
					_generateArray.push(tmpAddedSegm);
				}
			}
			
			_listener_count = 0;
			_isAddingSectors = true;
			addEventListener(Event.ENTER_FRAME, onAddSegment, false, 0, true);
		}
		
		private function onAddSegment(e:Event):void 
		{
			var length:int = _generateArray.length;
			
			if (_listener_count == length)
			{
				UpdateMapIndexes();
				removeEventListener(Event.ENTER_FRAME, onAddSegment, false);
				_listener_count = 0;
				_isAddingSectors = false;
			}
			else
			{
				GenerateSegmentType(_generateArray[_listener_count]);
				_listener_count++;
			}
		}
		
		public function StartUpdating():void
		{
			_hero = App.universe.hero;
			
			var tmpSegment:MapGenerator.MapSegment;
			for (var i:int = 0; i < STARTING_MATRIX_SIZE; i++)
			{
				for(var j:int = 0 ; j < STARTING_MATRIX_SIZE; j++)
				{
					tmpSegment = _matrix[i][j];
					if ((_hero.x > tmpSegment.x) && (_hero.x < tmpSegment.x + TileInfo.TILE_SIZE) && (_hero.y > tmpSegment.y) && (_hero.y < tmpSegment.y + TileInfo.TILE_SIZE))
					{
						_hero.visual_owner = tmpSegment;
					}
				}
			}
			
			_update_hero_pos_timer.start();
			_update_hero_pos_timer.addEventListener(TimerEvent.TIMER, onCheckForRightTile, false, 0, true);
		}
		
		private function onCheckForRightTile(e:TimerEvent):void 
		{
			if ((_hero.x > _hero.visual_owner.x) && (_hero.x < _hero.visual_owner.x + TileInfo.TILE_SIZE) && (_hero.y > _hero.visual_owner.y) && (_hero.y < _hero.visual_owner.y + TileInfo.TILE_SIZE))
			{
				return;
			}
			
			if (!_generating && !_isAddingSectors)
			{
				_generating = true;
				_step = 0;
				_generatingTimer.addEventListener(TimerEvent.TIMER, onStartFilling, false, 0, true);
				_generatingTimer.start();
				onStartFilling();
			}
		}
		
		private function onStartFilling(e:TimerEvent = null):void 
		{
			if (_step == 0)
			{
				_tileID = FindRightTileID();
				if (_tileID == -1) 
				{ 
					_generatingTimer.removeEventListener(TimerEvent.TIMER, onStartFilling, false);
					_step = 0;
					_generating = false;
					return;
				}
			}
			else if (_step == 1)
			{
				_removing_direction = _tileID;
				
				var a:int = getTimer();
				if (_tileID == UPPER_LEFT_INDEX || _tileID == UPPER_RIGHT_INDEX)
				{
					UpdateMapGrid(UPPER_INDEX);
				}
				else if (_tileID == BOTTOM_LEFT_INDEX || _tileID == BOTTOM_RIGHT_INDEX)
				{
					UpdateMapGrid(BOTTOM_INDEX);
				}
				else
				{
					UpdateMapGrid(_tileID);
				}
				var b:int = getTimer();
			}
			else if (_step == 2)
			{
				if (_tileID == UPPER_LEFT_INDEX || _tileID == BOTTOM_LEFT_INDEX)
				{
					UpdateMapGrid(LEFT_INDEX);
				}
				else if (_tileID == UPPER_RIGHT_INDEX || _tileID == BOTTOM_RIGHT_INDEX)
				{
					UpdateMapGrid(RIGHT_INDEX);
				}
			}
			else if (_step == 3)
			{
				FindHerosVisualTile();
				
				_removing_timer.start();
				_removing_timer.addEventListener(TimerEvent.TIMER, onRemoveZombies, false, 0, true);
			}
			else if (_step == 4)
			{
				_generatingTimer.removeEventListener(TimerEvent.TIMER, onStartFilling, false);
				_generatingTimer.reset();
				_step = 0;
				_generating = false;
			}
			_step++;
		}
		
		private function onRemoveZombies(e:TimerEvent):void 
		{
			_removing_timer.reset();
			_removing_timer.removeEventListener(TimerEvent.TIMER, onRemoveZombies, false);
			var length:int = BaseEnemy.ZombiesArray.length;
			var i:int;
			var enemy:BaseEnemy;
			
			switch(_removing_direction)
			{
				case UPPER_INDEX:
				for (i = 0; i < length; i++)
				{
					enemy = BaseEnemy.ZombiesArray[i];
					if (enemy.y > _removing_y_line)
					{
						enemy.Destroy();
						BaseEnemy.ZombiesArray.splice(i, 1);
						i--;
						length--;
					}
				}
				break;
				case BOTTOM_INDEX:
				for (i = 0; i < length; i++)
				{
					enemy = BaseEnemy.ZombiesArray[i];
					if (enemy.y < _removing_y_line)
					{
						enemy.Destroy();
						BaseEnemy.ZombiesArray.splice(i, 1);
						i--;
						length--;
					}
				}
				break;
				case LEFT_INDEX:
				for (i = 0; i < length; i++)
				{
					enemy = BaseEnemy.ZombiesArray[i];
					if (enemy.x > _removing_x_line)
					{
						enemy.Destroy();
						BaseEnemy.ZombiesArray.splice(i, 1);
						i--;
						length--;
					}
				}
				break;
				case RIGHT_INDEX:
				for (i = 0; i < length; i++)
				{
					enemy = BaseEnemy.ZombiesArray[i];
					if (enemy.x < _removing_x_line)
					{
						enemy.Destroy();
						BaseEnemy.ZombiesArray.splice(i, 1);
						i--;
						length--;
					}
				}
				break;
				case UPPER_RIGHT_INDEX:
				for (i = 0; i < length; i++)
				{
					enemy = BaseEnemy.ZombiesArray[i];
					if (enemy.x < _removing_x_line || enemy.y > _removing_y_line)
					{
						enemy.Destroy();
						BaseEnemy.ZombiesArray.splice(i, 1);
						i--;
						length--;
					}
				}
				break;
				case BOTTOM_RIGHT_INDEX:
				for (i = 0; i < length; i++)
				{
					enemy = BaseEnemy.ZombiesArray[i];
					if (enemy.x < _removing_x_line || enemy.y < _removing_y_line)
					{
						enemy.Destroy();
						BaseEnemy.ZombiesArray.splice(i, 1);
						i--;
						length--;
					}
				}
				break;
				case UPPER_LEFT_INDEX:
				for (i = 0; i < length; i++)
				{
					enemy = BaseEnemy.ZombiesArray[i];
					if (enemy.x > _removing_x_line || enemy.y > _removing_y_line)
					{
						enemy.Destroy();
						BaseEnemy.ZombiesArray.splice(i, 1);
						i--;
						length--;
					}
				}
				break;
				case BOTTOM_LEFT_INDEX:
				for (i = 0; i < length; i++)
				{
					enemy = BaseEnemy.ZombiesArray[i];
					if (enemy.x > _removing_x_line || enemy.y < _removing_y_line)
					{
						enemy.Destroy();
						BaseEnemy.ZombiesArray.splice(i, 1);
						i--;
						length--;
					}
				}
				break;
			}
		}
		
		private function FindHerosVisualTile():void 
		{
			var segm:MapGenerator.MapSegment;
			for (var i:int = 0; i < STARTING_MATRIX_SIZE; i++)
			{
				for (var j:int = 0; j < STARTING_MATRIX_SIZE; j++)
				{
					segm = _matrix[i][j];
					if (segm.index == CENTER_INDEX)
					{
						_hero.visual_owner = segm;
						return;
					}
				}
			}
		}
		
		private function FindRightTileID():int 
		{
			var segm:MapGenerator.MapSegment = _hero.visual_owner;
			if (_hero.x < segm.x)
			{
				if (_hero.y < segm.y)
				{
					return UPPER_LEFT_INDEX;
				}
				else if (_hero.y > segm.y + TileInfo.TILE_SIZE)
				{
					return BOTTOM_LEFT_INDEX;
				}
				else
				{
					return LEFT_INDEX;
				}
			}
			else if (_hero.x > segm.x + TileInfo.TILE_SIZE)
			{
				if (_hero.y < segm.y)
				{
					return UPPER_RIGHT_INDEX;
				}
				else if (_hero.y > segm.y + TileInfo.TILE_SIZE)
				{
					return BOTTOM_RIGHT_INDEX;
				}
				else
				{
					return RIGHT_INDEX;
				}
			}
			else
			{
				if (_hero.y > segm.y + TileInfo.TILE_SIZE)
				{
					return BOTTOM_INDEX;
				}
				else if(_hero.y < segm.y)
				{
					return UPPER_INDEX;
				}
			}
			
			return -1;
		}
		
		private function UpdateMapIndexes():void 
		{
			var tmpSegment:MapGenerator.MapSegment;
			var index:int;
			for (var i:int = 0; i < STARTING_MATRIX_SIZE; i++)
			{
				for (var j:int = 0; j < STARTING_MATRIX_SIZE; j++)
				{
					tmpSegment = _matrix[i][j];
					index = j * STARTING_MATRIX_SIZE + i;
					tmpSegment.SetIndex(index);
					CheckIfParsedOrNot(tmpSegment, index);
				}
			}
			//addEventListener(Event.ENTER_FRAME, onCheckForParsedTiles, false, 0, true);
		}
		
		private function onCheckForParsedTiles(e:Event):void 
		{
			var tmpSegment:MapGenerator.MapSegment;
			var index:int = j_index * STARTING_MATRIX_SIZE + i_index;
			tmpSegment = _matrix[i_index][j_index];
			CheckIfParsedOrNot(tmpSegment, index);
			if (j_index != STARTING_MATRIX_SIZE - 1)
			{
				j_index++;
			}
			else if (i_index != STARTING_MATRIX_SIZE - 1)
			{
				j_index = 0;
				i_index++;
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME, onCheckForParsedTiles, false);
				j_index = 0;
				i_index = 0;
			}
		}
		
		private function CheckIfParsedOrNot(tmpSegment:MapSegment, index:int):void 
		{
			if (index == CENTER_INDEX || index == LEFT_INDEX || index == UPPER_LEFT_INDEX || index == BOTTOM_LEFT_INDEX || index == UPPER_INDEX || index == BOTTOM_INDEX || index == UPPER_RIGHT_INDEX || index == BOTTOM_RIGHT_INDEX || index == RIGHT_INDEX)
			{
				if (!tmpSegment.parsed)
				{
					tmpSegment.Parse();
				}
			}
			else
			{
				if (tmpSegment.parsed)
				{
					tmpSegment.Unparse();
				}
			}
		}
		
		private function GenerateSegmentType(arg:MapGenerator.AddingSegmentStruct):void 
		{
			arg.mapSegment.Init(arg.index, arg.startX, arg.startY, arg.parent, arg.upperParent);
			
			var index:int = arg.mapSegment.index;
			var x_index:int = index / STARTING_MATRIX_SIZE;
			var y_index:int = index % STARTING_MATRIX_SIZE;
			
			var tmpTypesArray:Array = [];
			for (var i:int = 0; i < TileInfo.TILES_ARRAY.length; i++)
			{
				var a:int = TileInfo.TILES_ARRAY[i];
				tmpTypesArray.push(a);
			}
			
			var tmpSegment:MapGenerator.MapSegment;
			if (x_index - 1 >= 0)
			{
				tmpSegment = _matrix[y_index][x_index - 1];
				if (tmpSegment.type == TileInfo.TYPE_TOWN || tmpSegment.type == TileInfo.TYPE_LEFT_RIGHT)
				{
					DeleteTypeFromArray(tmpTypesArray, TileInfo.TYPE_CROSS, TileInfo.TYPE_UP_DOWN);
				}
				else if (tmpSegment.type == TileInfo.TYPE_CROSS || tmpSegment.type == TileInfo.TYPE_UP_DOWN)
				{
					DeleteTypeFromArray(tmpTypesArray, TileInfo.TYPE_TOWN, TileInfo.TYPE_LEFT_RIGHT);
				}
			}
			if (x_index + 1 < STARTING_MATRIX_SIZE)
			{
				tmpSegment = _matrix[y_index][x_index + 1];
				if (tmpSegment.type == TileInfo.TYPE_TOWN || tmpSegment.type == TileInfo.TYPE_LEFT_RIGHT)
				{
					DeleteTypeFromArray(tmpTypesArray, TileInfo.TYPE_CROSS, TileInfo.TYPE_UP_DOWN);
				}
				else if (tmpSegment.type == TileInfo.TYPE_CROSS || tmpSegment.type == TileInfo.TYPE_UP_DOWN)
				{
					DeleteTypeFromArray(tmpTypesArray, TileInfo.TYPE_TOWN, TileInfo.TYPE_LEFT_RIGHT);
				}
			}
			if (y_index - 1 >= 0)
			{
				tmpSegment = _matrix[y_index - 1][x_index];
				if (tmpSegment.type == TileInfo.TYPE_TOWN || tmpSegment.type == TileInfo.TYPE_UP_DOWN)
				{
					DeleteTypeFromArray(tmpTypesArray, TileInfo.TYPE_CROSS, TileInfo.TYPE_LEFT_RIGHT);
				}
				else if (tmpSegment.type == TileInfo.TYPE_CROSS || tmpSegment.type == TileInfo.TYPE_LEFT_RIGHT)
				{
					DeleteTypeFromArray(tmpTypesArray, TileInfo.TYPE_TOWN, TileInfo.TYPE_UP_DOWN);
				}
			}
			if (y_index + 1 < STARTING_MATRIX_SIZE)
			{
				tmpSegment = _matrix[y_index + 1][x_index];
				if (tmpSegment.type == TileInfo.TYPE_TOWN || tmpSegment.type == TileInfo.TYPE_UP_DOWN)
				{
					DeleteTypeFromArray(tmpTypesArray, TileInfo.TYPE_CROSS, TileInfo.TYPE_LEFT_RIGHT);
				}
				else if (tmpSegment.type == TileInfo.TYPE_CROSS || tmpSegment.type == TileInfo.TYPE_LEFT_RIGHT)
				{
					DeleteTypeFromArray(tmpTypesArray, TileInfo.TYPE_TOWN, TileInfo.TYPE_UP_DOWN);
				}
			}
			arg.mapSegment.SetType(tmpTypesArray[App.randomInt(0, tmpTypesArray.length)]);
		}
		
		private function DeleteTypeFromArray(arg1:Array, arg2:int, arg3:int):void 
		{
			var length:int = arg1.length;
			var a:int;
			for (var i:int = 0; i < length; i++)
			{
				a = arg1[i];
				if (a == arg2 || a == arg3)
				{
					arg1.splice(i, 1);
					i--;
					length--;
				}
			}
		}
		
		private function InitMapMatrix():void 
		{
			_matrix = [];
			for (var i:int = 0; i < STARTING_MATRIX_SIZE; i++)
			{
				_matrix[i] = [];
				for (var j:int = 0; j < STARTING_MATRIX_SIZE; j++)
				{
					_matrix[i][j] = 0;
				}
			}
		}
		
		public function CreateNewMap():void 
		{
			ClearMatrix();
			FillStartingTiles();
			UpdateMapIndexes();
			StartUpdating();
		}
		
		private function FillStartingTiles():void 
		{
			for (var i:int = 0; i < STARTING_MATRIX_SIZE; i++)
			{
				for (var j:int = 0; j < STARTING_MATRIX_SIZE; j++)
				{
					var type:int;
					if (i == 0)
					{
						if (j == 0)
						{
							type = TileInfo.TILES_ARRAY[App.randomInt(0, TileInfo.TILES_ARRAY.length)];
						}
						else
						{
							var tmpTile:MapSegment = _matrix[i][j - 1];
							var applyable:Array = [];
							switch(tmpTile.type)
							{
								case TileInfo.TYPE_CROSS:
								case TileInfo.TYPE_UP_DOWN:
								applyable.push(TileInfo.TYPE_UP_DOWN);
								applyable.push(TileInfo.TYPE_CROSS);
								break;
								case TileInfo.TYPE_TOWN:
								case TileInfo.TYPE_LEFT_RIGHT:
								applyable.push(TileInfo.TYPE_LEFT_RIGHT);
								applyable.push(TileInfo.TYPE_TOWN);
								break;
							}
							type = applyable[App.randomInt(0, applyable.length)];
						}
					}
					else 
					{
						if (j == 0)
						{
							tmpTile = _matrix[i - 1][j];
							applyable = [];
							switch(tmpTile.type)
							{
								case TileInfo.TYPE_CROSS:
								case TileInfo.TYPE_LEFT_RIGHT:
								applyable.push(TileInfo.TYPE_LEFT_RIGHT);
								applyable.push(TileInfo.TYPE_CROSS);
								break;
								case TileInfo.TYPE_TOWN:
								case TileInfo.TYPE_UP_DOWN:
								applyable.push(TileInfo.TYPE_UP_DOWN);
								applyable.push(TileInfo.TYPE_TOWN);
								break;
							}
							type = applyable[App.randomInt(0, applyable.length)];
						}
						else
						{
							var upperTile:MapSegment = _matrix[i][j - 1];
							var leftTile:MapSegment = _matrix[i - 1][j];
							if (upperTile.type == TileInfo.TYPE_LEFT_RIGHT || upperTile.type == TileInfo.TYPE_TOWN)
							{
								if (leftTile.type == TileInfo.TYPE_UP_DOWN || leftTile.type == TileInfo.TYPE_TOWN)
								{
									type = TileInfo.TYPE_TOWN;
								}
								else
								{
									type = TileInfo.TYPE_LEFT_RIGHT;
								}
							}
							else
							{
								if (leftTile.type == TileInfo.TYPE_UP_DOWN || leftTile.type == TileInfo.TYPE_TOWN)
								{
									type = TileInfo.TYPE_UP_DOWN;
								}
								else
								{
									type = TileInfo.TYPE_CROSS;
								}
							}
						}
					}
					
					var tmpMapTile:MapSegment = App.pools.getPoolObject(MapSegment.NAME);
					var index:int = j * STARTING_MATRIX_SIZE + i;
					tmpMapTile.Init(index, (i - int(STARTING_MATRIX_SIZE / 2)) * TileInfo.TILE_SIZE - TileInfo.TILE_SIZE / 2, (j - int(STARTING_MATRIX_SIZE / 2)) * TileInfo.TILE_SIZE - TileInfo.TILE_SIZE / 2, layer, upperLayer, type);
					_matrix[i][j] = tmpMapTile;
				}
			}
		}
		
		public function ClearMatrix():void 
		{
			for (var i:int = 0; i < STARTING_MATRIX_SIZE; i++)
			{
				for (var j:int = 0; j < STARTING_MATRIX_SIZE; j++)
				{
					_matrix[i][j] = 0;
				}
			}
		}
		
		public function Destroy():void 
		{
			_update_hero_pos_timer.reset();
			_update_hero_pos_timer.removeEventListener(TimerEvent.TIMER, onCheckForRightTile, false);
		}
		
		public function GetMatrix():Array { return _matrix; }
	}
}