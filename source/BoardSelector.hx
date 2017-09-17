package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

/**
 * ...
 * @author ropp
 */
class BoardSelector extends FlxSprite
{
	private var currentLocX:Int;
	private var currentLocY:Int;
	
	private var parent:BoardGrid;
	
	private var selectorSprites:FlxTypedGroup<FlxSprite>;

	public function new(?X:Float = 0, ?Y:Float = 0, selectorColor:FlxColor, parent:BoardGrid, ?currentLocX:Int = 0, ?currentLocY:Int = 0) 
	{
		super(X, Y);
		
		this.currentLocX = currentLocX;
		this.currentLocY = currentLocY;
		
		this.parent = parent;
		
		selectorSprites = new FlxTypedGroup<FlxSprite>();
		
		// top bar
		var tempSprite:FlxSprite = new FlxSprite(x, y);
		tempSprite.makeGraphic(parent.getGridThickness() * 2 + parent.getSquareWidth(), parent.getGridThickness(), selectorColor);
		selectorSprites.add(tempSprite);
		
		// left bar
		tempSprite = new FlxSprite(x, y);
		tempSprite.makeGraphic(parent.getGridThickness(), parent.getGridThickness() * 2 + parent.getSquareHeight(), selectorColor);
		selectorSprites.add(tempSprite);
		
		
		// bottom bar
		tempSprite = new FlxSprite(x, y + parent.getGridThickness() + parent.getSquareHeight());
		tempSprite.makeGraphic(parent.getGridThickness() * 2 + parent.getSquareWidth(), parent.getGridThickness(), selectorColor);
		selectorSprites.add(tempSprite);
		
		
		//right bar
		tempSprite = new FlxSprite(x + parent.getGridThickness() + parent.getSquareWidth(), y);
		tempSprite.makeGraphic(parent.getGridThickness(), parent.getGridThickness() * 2 + parent.getSquareHeight(), selectorColor);
		selectorSprites.add(tempSprite);
	}
	
	public function addSprites():Void {
		for (selectorSprite in selectorSprites) {
			parent.parent.add(selectorSprite);
		}
	}
	
	public function removeSprites():Void {
		for (selectorSprite in selectorSprites) {
			parent.parent.remove(selectorSprite);
		}
	}
	
	public function maybeMoveLeft():Void {
		if (currentLocX > 0) {
			currentLocX--;
			updateNewPosition();
		}
	}
	
	public function maybeMoveRight():Void {
		if (currentLocX < parent.getBoardWidth()-1) {
			currentLocX++;
			updateNewPosition();
		}
	}
	
	public function maybeMoveUp():Void {
		if (currentLocY > 0) {
			currentLocY--;
			updateNewPosition();
		}
	}
	
	public function maybeMoveDown():Void {
		if (currentLocY < parent.getBoardHeight() - 1) {
			currentLocY++;
			updateNewPosition();
		}
	}
	
	private function updateNewPosition():Void {
		var xDifference = this.x;
		var yDifference = this.y;
		
		this.x = currentLocX * (parent.getSquareWidth() + parent.getGridThickness());
		this.y = currentLocY * (parent.getSquareHeight() + parent.getGridThickness());
		
		xDifference = this.x - xDifference;
		yDifference = this.y - yDifference;
		
		for (selectorSprite in selectorSprites) {
			selectorSprite.x += xDifference;
			selectorSprite.y += yDifference;
		}
	}
	
	public function getCurrentLoc():FlxPoint {
		return new FlxPoint(currentLocX, currentLocY);
	}
}