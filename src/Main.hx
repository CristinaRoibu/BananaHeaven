package;

import openfl.display.Sprite;
import openfl.Lib;
import openfl.media.Sound;
import src.Card;
import src.Player;
import src.Board;
import openfl.events.MouseEvent;
import openfl.Assets;
import openfl.media.SoundChannel;


/**
 * ...
 * @author Cristina
 */
class Main extends Sprite 
{
	
	public var startGame:Button;
	var musicChannel:SoundChannel;
	
	public function new() 
	{
		super();
		startGame= new Button("startGame"); // position the start game button
		startGame.x = (1200 / 2) - (startGame.width / 2);
		startGame.y = (900 / 2) - (startGame.height / 2);
		addChild(startGame);

		var epicMusic : Sound = Assets.getMusic("music/menuSound.wav");
		musicChannel = epicMusic.play();
		

		this.addEventListener(MouseEvent.CLICK, onClickMethod);
		
	}

	
	public function onClickMethod(click:MouseEvent){
		if (click.target == startGame){
			removeChild(startGame); //when you click the start game button it removes the button and stops the music
			musicChannel.stop();
			
			var board:Board = new Board(); // istantiate the board
			board.y = 10;
			addChild(board);
		}		
	}
}