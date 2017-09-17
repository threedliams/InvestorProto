package;

import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	private var board:BoardGrid;
	
	public var cash:Float;
	public var investments:Float;
	
	private var cashText:FlxText;
	private var investmentText:FlxText;
	
	override public function create():Void
	{
		board = new BoardGrid(0, 0, 15, 15, this);
		add(board);
		
		cash = 100000;
		investments = 0;
		
		cashText = new FlxText(Std.int(board.x) + board.getBoardPixelWidth() + 20, 20, 500, "Cash: $" + cash, 30);
		add(cashText);
		
		investmentText = new FlxText(Std.int(board.x) + board.getBoardPixelWidth() + 20, 80, 500, "Investment value: $" + investments, 30);
		add(investmentText);
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		cashText.text = "Cash: $" + cash;
		investmentText.text = "Investment value: $" + investments;
		super.update(elapsed);
	}
}