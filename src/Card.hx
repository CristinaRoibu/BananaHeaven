package src;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

/**
 * ...
 * @author Cristina
 */

 enum MovableWays
{
	All;
	Up;
	Side;
}

class Card extends Sprite 
{
	public var image:Bitmap;
	public var imageData:BitmapData;
	public var playerNumber:Int;
	public var row:Int;
	public var damage:Int;
	public var cardName:String;
	public var isHandCard:Bool;
	public var isSocialCard:Bool;
	public var movableWays:MovableWays;
	
	public function new(playerNumber:Int, damage:Int, cardName:String, isHandCard:Bool, isSocialCard:Bool) 
	{
		super();
		this.damage = damage; // take the input you pass this method and put it in the var damage
		this.cardName = cardName;
		this.playerNumber = playerNumber; //puts the parameter you pass it into the playerNumber variable in this class
		this.isHandCard = isHandCard;
		this.isSocialCard = isSocialCard;
		//if the card you want to add has a player number then upload the monkey player card, else upload the card card
		if (playerNumber != null) {
			imageData = Assets.getBitmapData("img/monkeyp" + playerNumber + ".png");
			image = new Bitmap(imageData);
		} else {
			if (isHandCard){
				imageData = Assets.getBitmapData("img/" + cardName + ".png");
				image = new Bitmap(imageData);
			} else {
				if (isSocialCard == true){
					imageData = Assets.getBitmapData("img/backSocialEvent.png");
					image = new Bitmap(imageData);
					movableWays = MovableWays.Side;
				}else {
					imageData = Assets.getBitmapData("img/backMonsterCard.png");
					image = new Bitmap(imageData);
					movableWays = MovableWays.Up;
				}
				
			}
		}
		
		image.scaleX = 0.3;
		image.scaleY = 0.3;
		addChild(image);
	}
}