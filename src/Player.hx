package src;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import src.Card.MovableWays;

/**
 * ...
 * @author Cristina
 */
class Player extends Sprite 
{

	public var cards:Array<Card> = new Array<Card>();   // array of type card with the player cards
	public var lifeImageData:BitmapData;  //variable that will contain the picture of lives
	public var crossImageData:BitmapData;
	public var livesImages:Array<Bitmap>  = new Array<Bitmap>();   //array of lives, so you can add the cross on top when you lose a life
	public var playerImage:Bitmap;   //variable that will contain player picture
	public var playerNumber:Int;   //variable that will contain nr of player 
	public var lives:Int = 3;   //variable that contains the number of lives the player has
	public var countCrosses:Int = 0;
	public var method:Int->Void;
	
	public var moveableWays:MovableWays;
	
	public function new(playerNumber:Int, method:Int->Void) // get the int from the main class 
	{
		super(); // calls the constructor of the superClass (class that it extends), sprite class in this case 
		this.playerNumber = playerNumber;  // assigns the player number to the playerNumber variable present in this class
		lifeImageData = Assets.getBitmapData("img/monkey.png");  //uploads the monkey picture and puts it in the lifeImageData variable
		crossImageData = Assets.getBitmapData("img/cross.png"); 
		
		this.method = method;
		for (i in 0...lives) {  //for loop that runs 3 times because variable lives is 3
			var lifeImage:Bitmap = new Bitmap(lifeImageData); //create variable that stores lifeImageData(monkey)
			lifeImage.scaleX = 0.03;
			lifeImage.scaleY = 0.03;
			lifeImage.x = 5 + 20*i + (lifeImage.width * i); //position the life pictures, 5 space at the start, 20 is the interval between images
			addChild(lifeImage);
			livesImages.push(lifeImage);  // add the life picture to the life array 
		}
		if (playerNumber == 1){
			playerImage = new Bitmap(Assets.getBitmapData("img/monkey1Blue.png")); //display image monkey player 1 blue
			playerImage.scaleX = 0.4;
			playerImage.scaleY = 0.4;
			playerImage.y = 30;
			addChild(playerImage);
		}else if (playerNumber == 2){
			playerImage = new Bitmap(Assets.getBitmapData("img/monkey2Red.png")); //display image monkey player 2 red
			playerImage.scaleX = 0.4;
			playerImage.scaleY = 0.4;
			playerImage.y = 30;
			addChild(playerImage);
			
		}
		
		if (playerNumber == 2) {  // this method positions the lives images of the second player 
			var lifeIndex = 0;
			for (lifeImage in livesImages) { // for each method
				lifeImage.x = 310+ (50*lifeIndex);
				lifeIndex++;
			}
		}
	}
	
	
	public function addCard(card:Card):Void{  //parameters (card:Card) -> card is the variable name of type Card (Card as in the class Card)
		cards.push(card);    //takes the card that you pass to this method and puts it in the array called cards
		repositionObjects();
	}
	
	public function replaceCard(cardToReplace:Card, cardThatReplaces:Card):Void{ //this method is called when the used card in the player hand is used and needs replacing
		for (card in cards) {
			trace(card.cardName);
			removeChild(card);
		}
		trace(cards.indexOf(cardToReplace));
		trace(cardToReplace.cardName);
		cards[cards.indexOf(cardToReplace)] = cardThatReplaces;
		repositionObjects();
	}
	
	public function repositionObjects():Void{ //every time a player card is dealed this method repositions all 3 cards of the player
		var index:Int = 0; //need this index for calculating the position of the cards
		
		for (card in cards) {  //for each method, this for will loop through all the elements of the cards array (3 times)
			removeChild(card);  //remove the 3 cards that are there at the moment
			if (playerNumber == 1)
				card.x = 160 + 10*index + (index * card.width); //160 is the width of the monkey player picture  
			else {
				playerImage.x = 300;
				card.x = index * 100;
			}
			card.y = 30;
			addChild(card);
			index++;
		}
	}
	
	
	
	public function losingLives():Bool{
		var lastImagelives:Bitmap;
		
		if (playerNumber == 1){
			lastImagelives = livesImages[2 - countCrosses]; //take the coordinates of the last monkey life of the array lives
		}else{
			lastImagelives = livesImages[countCrosses];
		}
		
		var crossImage:Bitmap = new Bitmap(crossImageData);
		crossImage.x = lastImagelives.x;
		crossImage.y = lastImagelives.y;
		crossImage.scaleX = 0.02;
		crossImage.scaleY = 0.02;
		addChild(crossImage);
		countCrosses++; //counts the crosses, which means counts the amount of lives lost per player
		
		if (countCrosses == 3){
			if (playerNumber == 1){
				trace (playerNumber + " is the stinky loser");
				method(playerNumber);
				return true;
			}else{
				 trace ("Red monkey is the stinky loser");
				 method(playerNumber);
				 return true;
			}
			
		}
		return false;
	}
}