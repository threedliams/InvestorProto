package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxG;

/**
 * ...
 * @author ropp
 */
class BoardGrid extends FlxObject
{
	private var boardWidth:Int;
	private var boardHeight:Int;
	
	private var gridThickness:Int;
	
	private var squareWidth:Int;
	private var squareHeight:Int;
	
	private var gridColor:FlxColor;
	
	private var verticleBars:FlxTypedGroup<FlxSprite>;
	private var horizontalBars:FlxTypedGroup<FlxSprite>;
	
	public var parent:PlayState;
	
	private var selector:BoardSelector;
	
	private var keyDelay:Float;
	private var keyRepeatDelay:Float;
	
	private var currentPressTime:Float = 0;
	private var currentRepeatTime:Float = 0;
	
	private var companies:Array<Array<Company>>;
	private var availableSlots:Array<FlxPoint>;
	
	private var companySpawnChance:Float = 0;

	public function new(?X:Float=0, ?Y:Float=0, boardWidth:Int, boardHeight:Int, parent:PlayState)
	{
		super(X, Y);
		
		
		this.boardWidth = boardWidth;
		this.boardHeight = boardHeight;
		
		gridThickness = 5;
		
		squareWidth = 50;
		squareHeight = 50;
		
		gridColor = FlxColor.GRAY;
		
		verticleBars = new FlxTypedGroup<FlxSprite>();
		horizontalBars = new FlxTypedGroup<FlxSprite>();
		
		this.parent = parent;
		
		drawBoard();
		
		this.selector = new BoardSelector(X, Y, FlxColor.RED, this);
		selector.addSprites();
		
		keyDelay = .5;
		keyRepeatDelay = .03;
		
		
		companies = [for (y in 0...boardHeight) [for (x in 0...boardWidth) null]];
		
		availableSlots = new Array<FlxPoint>();
		for (y in 0...boardHeight) {
			for (x in 0...boardWidth) {
				availableSlots.push(new FlxPoint(x, y));
			}
		}
		
	}
	
	private function randomlySpawnCompany():Bool {
		var generatedSpawnChance:Float = Math.random() * 100;
		if (availableSlots.length == 0 || generatedSpawnChance > companySpawnChance) {
			return false;
		}
		
		companySpawnChance = 0;
		
		var randomPointIndex = Std.random(availableSlots.length);
		
		var spawnPoint:FlxPoint = availableSlots[randomPointIndex];
		
		return addCompany(Std.int(spawnPoint.x), Std.int(spawnPoint.y), getRandomColor());
	}
	
	private function getRandomColor():FlxColor {
		var randomR:Int = Std.random(256);
		var randomG:Int = Std.random(256);
		var randomB:Int = Std.random(256);
		
		return FlxColor.fromRGB(randomR, randomG, randomB);
	}
	
	private function addCompany(x:Int, y:Int, color:FlxColor):Bool {
		if (x > boardWidth || y > boardHeight) {
			return false;
		}
		if (indexOfPoint(availableSlots, new FlxPoint(x, y)) == -1) {
			return false;
		}
		
		var tempCompany = new Company((x + 1) * gridThickness + x * squareWidth, (y + 1) * gridThickness + y * squareHeight, squareWidth, squareHeight, gridThickness, x, y, color, this);
		
		companies[y][x] = tempCompany;
		removePoint(availableSlots, new FlxPoint(x, y));
		
		return true;
	}
	
	public function removeCompany(x:Int, y:Int):Bool {
		if (indexOfPoint(availableSlots, new FlxPoint(x, y)) != -1) {
			return false;
		}
		
		companies[y][x] = null;
		
		availableSlots.push(new FlxPoint(x, y));
		
		return true;
	}
	
	private function buyCompany(x:Int, y:Int):Bool {
		if (companies[y][x] == null || parent.cash < companies[y][x].getValue()) {
			return false;
		}
		
		if (companies[y][x].buy()) {
			parent.cash -= companies[y][x].getValue();
			return true;
		}
		
		return false;
	}
	
	private function sellCompany(x:Int, y:Int):Bool {
		if (companies[y][x] == null) {
			return false;
		}
		
		if (companies[y][x].sell()) {
			parent.cash += companies[y][x].getValue();
			return true;
		}
		
		return false;
	}
	
	private function indexOfPoint(array:Array<FlxPoint>, point:FlxPoint):Int {
		for (i in 0...array.length) {
			if (array[i].equals(point)) {
				return i;
			}
		}
		
		return -1;
	}
	
	private function removePoint(array:Array<FlxPoint>, point:FlxPoint):Bool {
		var index:Int = indexOfPoint(array, point);
		if (index == -1) {
			return false;
		}
		array.remove(array[index]);
		return true;
	}
	
	private function drawBoard():Void {
		var currentXLoc:Int = Std.int(this.x);
		
		for (i in 0...boardWidth + 1) {
			var tempSprite:FlxSprite = new FlxSprite(currentXLoc, this.y);
			//trace(currentXLoc);
			//trace(this.y);
			tempSprite.makeGraphic(gridThickness, getBoardPixelHeight(), gridColor);
			verticleBars.add(tempSprite);
			parent.add(tempSprite);
			currentXLoc += gridThickness + squareWidth;
		}
		
		var currentYLoc:Int = Std.int(this.y);
		
		for (i in 0...boardHeight + 1) {
			var tempSprite:FlxSprite = new FlxSprite(this.x, currentYLoc);
			tempSprite.makeGraphic(getBoardPixelWidth(), gridThickness, gridColor);
			horizontalBars.add(tempSprite);
			parent.add(tempSprite);
			currentYLoc += gridThickness + squareHeight;
		}
	}
	
	public function getBoardWidth():Int {
		return boardWidth;
	}
	
	public function getBoardHeight():Int {
		return boardHeight;
	}
	
	public function getSquareWidth():Int {
		return squareWidth;
	}
	
	public function getSquareHeight():Int {
		return squareHeight;
	}
	
	public function getGridThickness():Int {
		return gridThickness;
	}
	
	public function getBoardPixelWidth():Int {
		return boardWidth * squareWidth + (boardWidth + 1) * gridThickness;
	}
	
	public function getBoardPixelHeight():Int {
		return boardHeight * squareHeight + (boardHeight + 1) * gridThickness;
	}
	
	private function movement(elapsed:Float):Void {
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;
		var enter:Bool = false;
		
		
		up = FlxG.keys.justPressed.UP;
		down = FlxG.keys.justPressed.DOWN;
		left = FlxG.keys.justPressed.LEFT;
		right = FlxG.keys.justPressed.RIGHT;
		enter = FlxG.keys.justPressed.ENTER;
		
		
		if (up || down || left || right || enter) {
			if (up) {
				this.selector.maybeMoveUp();
			}
			if (down) {
				this.selector.maybeMoveDown();
			}
			if (left) {
				this.selector.maybeMoveLeft();
			}
			if (right) {
				this.selector.maybeMoveRight();
			}
			if (enter) {
				var currentLoc = selector.getCurrentLoc();
				var selectedCompany = companies[Std.int(currentLoc.y)][Std.int(currentLoc.x)];
				if (selectedCompany != null) {
					if (selectedCompany.owned) {
						sellCompany(Std.int(currentLoc.x), Std.int(currentLoc.y));
					}
					else {
						buyCompany(Std.int(currentLoc.x), Std.int(currentLoc.y));
					}
				}
			}
		}
		
		up = FlxG.keys.pressed.UP;
		down = FlxG.keys.pressed.DOWN;
		left = FlxG.keys.pressed.LEFT;
		right = FlxG.keys.pressed.RIGHT;
		
		if (up || down || left || right) {
			currentPressTime += elapsed;
			if (currentPressTime > keyDelay) {
				if (currentRepeatTime > keyRepeatDelay) {
					if (up) {
						this.selector.maybeMoveUp();
					}
					if (down) {
						this.selector.maybeMoveDown();
					}
					if (left) {
						this.selector.maybeMoveLeft();
					}
					if (right) {
						this.selector.maybeMoveRight();
					}
					currentRepeatTime = 0;
				}
				else {
					currentRepeatTime += elapsed;
				}
			}
		}
		else {
			currentPressTime = 0;
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		companySpawnChance += elapsed;
		movement(elapsed);
		randomlySpawnCompany();
		
		var investmentValue:Float = 0;
		for (y in 0...companies.length) {
			for (x in 0...companies[y].length) {
				if (companies[y][x] != null) {
					if(companies[y][x].owned) {
						investmentValue += companies[y][x].getValue();
					}
				}
			}
		}
		this.parent.investments = investmentValue;
		
		super.update(elapsed);
	}
}