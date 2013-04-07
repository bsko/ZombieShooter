package MapGenerator 
{
	import Box2DItems.SegmentSensor;
	import Box2DItems.StaticObject;
	import Box2DItems.StaticRoundObject;
	import Cars.BaseCar;
	import Cars.CarParsingInfo;
	import Enemies.DefaultZombie;
	import Enemies.GenerateZones.*;
	import Events.Destroying;
	import Events.MapSegmentEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import Quests.QuestPerson;
	/**
	 * ...
	 * @author 
	 */
	public class MapSegment extends Sprite 
	{
		public static const PARSE_OBJECTS_IN_ONE_FRAME:int = 3;
		public static const NAME:String = "MapSegment";
		private var _startX:int;
		private var _startY:int;
		private var _parent_sprite:Sprite;
		private var _upper_parent_sprite:Sprite;
		private var _type:int;
		private var _index:int;
		private var _tiles_movie:MovieClip;
		private var _tiles_upper_movie:MovieClip;
		private var _currentFrame:int;
		private var _parsed:Boolean = false;
		private var _staticObjectsArray:Array = [];
		private var _roundObjectsArray:Array = [];
		private var _carsArray:Array = [];
		private var _zonesArray:Array = [];
		private var _segment_ID:int;
		private var _questObject:MapObject;
		
		private var _staticRectBodies:Array = [];
		private var _staticRoundBodies:Array = [];
		private var _existingCarsArray:Array = [];
		private var _parsedZones:Array = [];
		
		// enterframe parser things
		private var _parsingIndex:int = 0;
		private var _mapObject:MapObject;
		private	var _tmpSO:StaticObject;
		private	var _tmpRO:StaticRoundObject;
		private var _tmpZO:BaseGenerateZone;
		private	var _tmpMovie:MovieClip;
		private	var _tmpSprite:Sprite;
		private	var _tmpMovieAngle:Number;
		private var _xc:int;
		private	var _yc:int;
		private	var _angle:int;
		private	var _staticObjectsParsed:Boolean = false;
		private var _roundObjectsParsed:Boolean = false;
		private var _zombieZonesParsed:Boolean = false;
		private var _carsParsed:Boolean = false;
		
		private var _testArray:Array = [];
		
		public static var counter:int = 0;
		//--- end of parsing things
		
		public function MapSegment() 
		{
			_segment_ID = counter;
			counter++;
		}
		
		public function Init(index:int, startX:int, startY:int, parent:Sprite, upperParent:Sprite, type:int = -1):void 
		{
			_tiles_movie = new tiles_movie_full();
			_tiles_upper_movie = new tiles_upper_movie_full();
			
			_index = index;
			_startX = startX;
			_startY = startY;
			x = _startX;
			y = _startY;
			
			_parent_sprite = parent;
			_upper_parent_sprite = upperParent;
			
			_parent_sprite.addChild(_tiles_movie);
			_upper_parent_sprite.addChild(_tiles_upper_movie);
			
			_type = type;
			
			if (type != -1)
			{
				SetType();
			}
			
			App.universe.addEventListener(Destroying.DESTROY, Destroy, false, 0, true);
		}
		
		public function FillObjectsArrays():void 
		{
			var tmpMovie:MovieClip;
			var movieInMovie:box2d_object;
			var circleMovie:box2d_circle;
			var zombie_gnrt:zombiy_kryg;
			var zombie_gnrt2:zombie_kryg2;
			
			var xIndex:int;
			var yIndex:int;
			var map_object:MapGenerator.MapObject;
			var zone_object:ZoneMapObject;
			
			for(var i:int = 0; i < _tiles_movie.numChildren; i++)
			{
				if (_tiles_movie.getChildAt(i) is MovieClip)
				{
					if (_tiles_movie.getChildAt(i) is zombiy_kryg)
					{
						zombie_gnrt = _tiles_movie.getChildAt(i) as zombiy_kryg;
						zombie_gnrt.visible = false;
						
						zone_object = new ZoneMapObject(zombie_gnrt, BaseGenerateZone.TYPE_PASSIVE_ZONE);
						_zonesArray.push(zone_object);
					}
					else if (_tiles_movie.getChildAt(i) is CarSensor)
					{
						(_tiles_movie.getChildAt(i) as CarSensor).visible = false;
						var baseCar:CarParsingInfo = new CarParsingInfo(_tiles_movie.getChildAt(i) as CarSensor);
						_carsArray.push(baseCar);
					}
					else if (_tiles_movie.getChildAt(i) is QuestObject)
					{
						CheckIfNeedToAddQuestObject(_tiles_movie.getChildAt(i) as QuestObject);
					}
					else 
					{	
						tmpMovie = _tiles_movie.getChildAt(i) as MovieClip;
						var tmpMovieAngle:Number = tmpMovie.rotation;
						for (var j:int = 0; j < tmpMovie.numChildren; j++)
						{
							if (tmpMovie.getChildAt(j) is box2d_object)
							{
								movieInMovie = tmpMovie.getChildAt(j) as box2d_object;
								movieInMovie.visible = false;
								
								if (!movieInMovie.active)
								{
									map_object = new MapObject(movieInMovie, tmpMovie);
									_staticObjectsArray.push(map_object);
								}
								
							}
							else if (tmpMovie.getChildAt(j) is box2d_circle)
							{
								circleMovie = tmpMovie.getChildAt(j) as box2d_circle;
								circleMovie.visible = false;
								
								map_object = new MapObject(circleMovie, tmpMovie);
								_roundObjectsArray.push(map_object);
							}
						}
					}
				}
			}
			
			for(i = 0; i < _tiles_upper_movie.numChildren; i++)
			{
				if (_tiles_upper_movie.getChildAt(i) is MovieClip)
				{
					if (_tiles_upper_movie.getChildAt(i) is zombie_kryg2)
					{
						zombie_gnrt2 = _tiles_upper_movie.getChildAt(i) as zombie_kryg2;
						zombie_gnrt2.visible = false;
						
						zone_object = new ZoneMapObject(zombie_gnrt2, BaseGenerateZone.TYPE_AGRO_ZONE);
						_zonesArray.push(zone_object);
					}
					else
					{
						tmpMovie = _tiles_upper_movie.getChildAt(i) as MovieClip;
						tmpMovieAngle = tmpMovie.rotation;
						
						for (j = 0; j < tmpMovie.numChildren; j++)
						{
							if (tmpMovie.getChildAt(j) is box2d_object)
							{
								movieInMovie = tmpMovie.getChildAt(j) as box2d_object;
								movieInMovie.visible = false;
								
								if (!movieInMovie.active)
								{
									map_object = new MapObject(movieInMovie, tmpMovie);
									_staticObjectsArray.push(map_object);
								}
								
							}
							else if (tmpMovie.getChildAt(j) is box2d_circle)
							{
								circleMovie = tmpMovie.getChildAt(j) as box2d_circle;
								circleMovie.visible = false;
								
								map_object = new MapObject(circleMovie, tmpMovie);
								_roundObjectsArray.push(map_object);
							}
						}
					}
				}
			}
		}
		
		private function CheckIfNeedToAddQuestObject(arg1:QuestObject):void 
		{
			if (true)
			{
				_questObject = new MapObject(arg1, null);
			}
			else
			{
				_questObject = null;
			}
		}
		
		public function Parse():void 
		{
			if (!parsed)
			{
				addEventListener(Event.ENTER_FRAME, onUpdateParsing, false, 0, true);
			}
		}
		
		private function onUpdateParsing(e:Event):void 
		{
			if (!_staticObjectsParsed)
			{
				var zoneObject:ZoneMapObject;
				var length:int = _staticObjectsArray.length;
				var endIndex:int = (_parsingIndex + PARSE_OBJECTS_IN_ONE_FRAME > length) ? length : (_parsingIndex + PARSE_OBJECTS_IN_ONE_FRAME);
				if (_parsingIndex == endIndex ) { _staticObjectsParsed = true; _parsingIndex = 0; }
				else
				{
					for (var i:int = _parsingIndex; i < endIndex; i++)
					{
						_mapObject = _staticObjectsArray[i];
						_tmpSprite = _mapObject.object;
						_tmpMovie = _mapObject.object_owner;
						_tmpMovieAngle = _tmpMovie.rotation;
						_tmpMovie.rotation = 0;
						_tmpSO = App.pools.getPoolObject(StaticObject.NAME);
						_xc = _tmpMovie.x + this.x;
						_yc = _tmpMovie.y + this.y;
						_angle = _tmpSprite.rotation;
						_tmpSO.Init(new Point(_xc, _yc), _tmpSprite, _tmpMovie, _tmpMovieAngle);
						_tmpMovie.rotation = _tmpMovieAngle;
						_staticRectBodies.push(_tmpSO);
					}
					_parsingIndex = endIndex;
				}
			}
			else if (!_roundObjectsParsed)
			{	
				length = _roundObjectsArray.length;
				endIndex = (_parsingIndex + PARSE_OBJECTS_IN_ONE_FRAME > length) ? length : (_parsingIndex + PARSE_OBJECTS_IN_ONE_FRAME);
				if (_parsingIndex == endIndex ) { _roundObjectsParsed = true; _parsingIndex = 0; }
				else
				{
					for (i = _parsingIndex; i < endIndex; i++)
					{
						_mapObject = _roundObjectsArray[i];
						_tmpSprite = _mapObject.object;
						_tmpMovie = _mapObject.object_owner;
						_tmpMovieAngle = _tmpMovie.rotation;
						_tmpMovie.rotation = 0;
						_tmpRO = App.pools.getPoolObject(StaticRoundObject.NAME);
						_xc = _tmpMovie.x + this.x;
						_yc = _tmpMovie.y + this.y;
						_angle = _tmpSprite.rotation;
						_tmpRO.Init(new Point(_xc, _yc), _tmpSprite, _tmpMovie, _tmpMovieAngle);
						_tmpMovie.rotation = _tmpMovieAngle;
						_staticRoundBodies.push(_tmpRO);
					}
					_parsingIndex = endIndex;
				}
			}
			else if (!_zombieZonesParsed)
			{
				length = _zonesArray.length;
				endIndex = (_parsingIndex + PARSE_OBJECTS_IN_ONE_FRAME > length) ? length : (_parsingIndex + PARSE_OBJECTS_IN_ONE_FRAME);
				if (_parsingIndex == endIndex ) { _zombieZonesParsed = true; _parsingIndex = 0; }
				else
				{
					for (i = _parsingIndex; i < endIndex; i++)
					{
						zoneObject = _zonesArray[i];
						if (zoneObject.type == BaseGenerateZone.TYPE_PASSIVE_ZONE)
						{
							_tmpZO = App.pools.getPoolObject(PassiveGenerateZone.NAME);
						}
						else if (zoneObject.type == BaseGenerateZone.TYPE_AGRO_ZONE)
						{
							_tmpZO = App.pools.getPoolObject(ActiveGenerateZone.NAME);
						}
						_tmpZO.Init(zoneObject.sprite, this);
						_parsedZones.push(_tmpZO);
					}
				}
				_parsingIndex = endIndex;
			}
			else if (!_carsParsed)
			{
				for (i = 0; i < _carsArray.length; i++)
				{
					var a:CarParsingInfo = _carsArray[i];
					var tmpCar:BaseCar = App.pools.getPoolObject(BaseCar.NAME);
					tmpCar.Init(a.sprite, this, App.universe.carSprite);
				}
				_carsParsed = true;
			}
			else
			{
				if (_questObject)
				{
					var person:QuestPerson = App.pools.getPoolObject(QuestPerson.NAME);
					person.Init(_questObject.object, this);
				}
				
				if (Math.random() > 0.85) { App.universe.AddHelicopter(); }
				
				removeEventListener(Event.ENTER_FRAME, onUpdateParsing, false);
				_parsed = true;
			}
		}
		
		public function Unparse():void 
		{
			if (parsed)
			{
				_parsed = false
				while (_staticRectBodies.length != 0)
				{
					_staticRectBodies.shift().Destroy();
				}
				while (_staticRoundBodies.length != 0)
				{
					_staticRoundBodies.shift().Destroy();
				}
				while (_parsedZones.length != 0)
				{
					_parsedZones.shift().Destroy();
				}
				_carsParsed = false;
				_staticObjectsParsed = false;
				_roundObjectsParsed = false;
				_zombieZonesParsed = false;
				_parsingIndex = 0;
			}
		}
		
		public function Destroy(e:Destroying = null):void 
		{
			dispatchEvent(new MapSegmentEvent(MapSegmentEvent.DESTROYING, true, false));
			if (_parsed)
			{
				Unparse();
			}
			_staticObjectsArray.length = 0;
			_roundObjectsArray.length = 0;
			_zonesArray.length = 0;
			_carsArray.length = 0;
			
			_parent_sprite.removeChild(_tiles_movie);
			_upper_parent_sprite.removeChild(_tiles_upper_movie);
			
			App.pools.returnPoolObject(NAME, this);
		}
		
		public function SetType(type:int = -1):void 
		{
			if (type != -1)
			{
				_type = type;
			}
			var length:int = _tiles_movie.totalFrames;
			var fits:Array = [];
			for (var i:int = 1; i <= length; i++)
			{
				_tiles_movie.gotoAndStop(i);
				var tmpString:String = _tiles_movie.currentFrameLabel
				var tmpArray:Array = tmpString.split("_");
				if (tmpArray[0] == "type")
				{
					if (tmpArray[1] == _type.toString())
					{
						fits.push(i);
					}
				}
			}
			
			length = fits.length;
			_currentFrame = fits[App.randomInt(0, length)];
			
			_tiles_movie.x = _tiles_upper_movie.x = x;
			_tiles_movie.y = _tiles_upper_movie.y = y;
			_tiles_movie.gotoAndStop(_currentFrame);
			_tiles_upper_movie.gotoAndStop(_currentFrame);
			
			_testArray.push(_currentFrame);
			
			FillObjectsArrays();
		}
		
		public function get type():int { return _type; }
		
		public function SetIndex(arg:int):void { _index = arg; }
		
		public function get index():int { return _index; }
		
		public function get parsed():Boolean { return _parsed; }
		
		public function get segment_ID():int { return _segment_ID; }
	}

}