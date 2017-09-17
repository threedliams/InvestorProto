package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

/**
 * ...
 * @author ropp
 */
class Company extends FlxSprite
{
	private var squareWidth:Int;
	private var squareHeight:Int;
	
	private var gridThickness:Int;
	
	private var gridX:Int;
	private var gridY:Int;
	
	private var parent:BoardGrid;
	
	public var owned:Bool;
	
	private var value:Float;
	
	private var highlight:BoardSelector;
	
	private var accrueChance:Float;
	
	private var maxAccrueRate:Float;

	public function new(?X:Float=0, ?Y:Float=0, squareWidth:Int, squareHeight:Int, gridThickness:Int, gridX:Int, gridY:Int, color:FlxColor, parent:BoardGrid) 
	{
		super(X, Y);
		
		this.squareWidth = squareWidth;
		this.squareHeight = squareHeight;
		
		this.gridThickness = gridThickness;
		
		this.gridX = gridX;
		this.gridY = gridY;
		
		this.parent = parent;
		
		makeGraphic(squareWidth, squareHeight, color);
		
		parent.parent.add(this);
		
		this.highlight = new BoardSelector(x - gridThickness, y - gridThickness, FlxColor.GREEN, parent);
		
		accrueChance = .1;
		maxAccrueRate = 100;
		
		value = 100;
	}
	
	override public function destroy():Void 
	{
		this.parent.parent.remove(this);
		this.parent.removeCompany(gridX, gridY);
		super.destroy();
	}
	
	override public function update(elapsed:Float):Void 
	{
		maybeAccrueValue();
		super.update(elapsed);
	}
	
	public function getValue():Float {
		return value;
	}
	
	public function buy():Bool {
		if (owned) {
			return false;
		}
		highlight.addSprites();
		owned = true;
		return true;
	}
	
	public function sell():Bool {
		if (!owned) {
			return false;
		}
		highlight.removeSprites();
		owned = false;
		return true;
	}
	
	private function maybeAccrueValue():Void {
		if (Math.random() > accrueChance) {
			return;
		}
		
		value += Math.random() * maxAccrueRate;
	}
}