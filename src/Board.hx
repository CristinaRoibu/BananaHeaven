package src;

import openfl.desktop.ClipboardTransferMode;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import src.Card;
import openfl.events.MouseEvent;
import src.Player;
import openfl.Assets;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import haxe.Timer;

/**

 * @author Cristina
 * handles the battle and the display screen
 */
class Board extends Sprite 
{

	public var placedCards:Array<Card> = new Array<Card>(); 
	public var numberOfCards:Int = 35;
	public var numberOfRows:Int = 7;
	public var isTurnPlayer1:Bool = true;
	public var player1Card:Card;
	public var player2Card:Card;
	public var pyramidDeck:Array<Card>;
	public var handDeck:Array<Card>;
	public var player1:Player;
	public var player2:Player;
	public var selectedMonster:Card;
	public var selectedPlayerCard:Card;
	public var monsterImage:Bitmap = null;
	public var screenHeight:Int = 1000;
	public var screenWidth:Int = 1200;
	public var message:String;
	public var winLoseMessage:TextField = null;
	public var loserMessage:TextField = null;
	public var socialCardsObject:SocialCards;
	public var blueArrowData:BitmapData;
	public var blueArrow:Bitmap;
	public var redArrowData:BitmapData;
	public var redArrow:Bitmap;
	public var moveSidewaysData:BitmapData;
	public var moveSideways:Bitmap;
	public var cardOverlayData:BitmapData;
	public var rowOverlay:Bitmap;
	public var rowOverlayData:BitmapData;
	var pickedCard:Card;
	public var currentCard:Card;
	var cardImage:Bitmap = null;
	var cardDimensionAnimation:Float = 0.35;
	var currentPlayer:Player;
	var currentPlayerCard:Card;
	public var isSwapCardON:Bool = false; // if its false you clicked on a swapCard card
	public var cardToSwap1:Card;
	public var cardToSwap2:Card;
	var rowOverlays:Array<Bitmap> = new Array<Bitmap>();
	var combinable:Bool = false;
	var comDamage:Int = 0;
	var usedCards:Array<Card> = new Array<Card>();
	var nukedSocialCardsInFirstRow:Bool = false;
	var overlayArray:Array<Bitmap> = new Array<Bitmap>();
	
	public function new() 
	{
	
		super();
		
		addChild(new Bitmap(Assets.getBitmapData("img/Background3.png")));
		
		socialCardsObject = new SocialCards(this);
		player1 = new Player(1, displayLoserMessage); //instantiate player class, pass the int of player (1 or 2) as a parameter to the player class
		player1.y = 820;  // place player
		addChild(player1);  //display the player
		
		player2 = new Player(2, displayLoserMessage);//each instance contains its set of variables
		player2.y = 820;
		player2.x = 750;
		addChild(player2);		
		currentPlayer = player1;
		redArrowData = Assets.getBitmapData("img/redArrow.png");
		blueArrowData = Assets.getBitmapData("img/blueArrow.png");
		moveSidewaysData = Assets.getBitmapData("img/moveSideways.png");
		cardOverlayData = Assets.getBitmapData("img/cardOverlay.png");
		rowOverlayData = Assets.getBitmapData("img/rowOverlay.png");
		/* generate cards from the deck */
		generatePyramidDeck();
		generateHandDeck();
		
		for (i in 0...3 ){
			player1.addCard(handDeck.pop());
			player2.addCard(handDeck.pop());
		}
		
		for (i in 0...numberOfCards) { //adds the 27 cards to the pyramid
			
			placedCards.push(pyramidDeck.pop());
		}
		arrangeCards();
		
		player1Card = new Card(1, null, "player1", false, false); //create the monkey cards that go up the pyramid
		player2Card = new Card(2, null, "player2", false, false);
		currentPlayerCard = player1Card;
		this.addEventListener(MouseEvent.CLICK, onClick); // when you detect a click in this class, call the onClick method
		
		message = "Blue monkey's turn!"; // display the turn message
		winLoseMessage = new TextField(); //players turns message
		winLoseMessage.text = message;
		var textFormat:TextFormat = new TextFormat();
		textFormat.size = 20;
		winLoseMessage.setTextFormat(textFormat);
		winLoseMessage.autoSize = TextFieldAutoSize.LEFT;
		winLoseMessage.x = (screenWidth / 2) - (winLoseMessage.width / 2);
		winLoseMessage.y = 850;
		winLoseMessage.textColor = 0xffffff;
		addChild(winLoseMessage);
		
		
		loserMessage = new TextField(); //players turns message
		loserMessage.text = message;
		var textFormat:TextFormat = new TextFormat();
		textFormat.size = 30;
		loserMessage.setTextFormat(textFormat);
		loserMessage.autoSize = TextFieldAutoSize.LEFT;
		loserMessage.x = (screenWidth / 2) - (loserMessage.width / 2);
		loserMessage.y = (screenHeight / 2) - 180;
		loserMessage.textColor = 0xffffff;
		
		blueArrow = new Bitmap(blueArrowData); // put the blue arrow on the first player
		blueArrow.scaleX = 0.6;
		blueArrow.scaleY = 0.6;
		blueArrow.y = 480;
		blueArrow.x = 5;
		addChild(blueArrow);
		currentPlayer = player1;
		currentPlayerCard = player1Card;
		
		for (theCard in placedCards){ // add the golden overlay on the cards that can be clicked
			if(theCard.row == 1){
				rowOverlay = new Bitmap(rowOverlayData);
				rowOverlay.scaleX = 0.21;
				rowOverlay.scaleY = 0.21;
				rowOverlay.y = theCard.y;
				rowOverlay.x = theCard.x;
				addChild(rowOverlay);
			}
		}
			

		
	}
	
	
	public function arrangeCards(){ // this function arranges the cards on the board in a pyramid shape
		// we remove everything from the board so we can replace all things in their right place
		nukedSocialCardsInFirstRow = false;
		for (card in placedCards) {
			removeChild(card);
		}
		
		var arrayCardIndex:Int = 0;
		
		for (rowIndex in 0...numberOfRows){ // runs from 0 to numberOfRows in the pyramid
			var numberOfCardsOnThisRow = rowIndex + 2; // stores how many cards are in this row
			
			for (cardIndex in 0...numberOfCardsOnThisRow) { // runs as many times as many cards there are on this row
				var card:Card = placedCards[arrayCardIndex]; // takes a card and puts it in the variable card
				card.scaleX = 0.7; // redimensions the card
				card.scaleY = 0.7;
				
				var rowStartX = (screenWidth / 2) - (((numberOfCardsOnThisRow * card.width) + 25 * numberOfCardsOnThisRow) / 2); // takes the width of the screen, divides it by 2 to find the middle
				// then calculates the width of the card row, divides it by two so you can put the middle of the card row in the middle of the screen
				
				card.y = rowIndex * (card.height + 25); // calculates the y coordinate of the card
				card.x = rowStartX + (cardIndex * (card.width + 25)); // calculates the x coordinate of the card
				card.row = numberOfRows - rowIndex; // assigns the row number to the card
				
				addChild(card); // lastly we display the card
				arrayCardIndex++; // increments the arrayCardIndex variable
				if (card.row == 1){nukeSocialCards(card); }
			}
		}
		if (nukedSocialCardsInFirstRow) arrangeCards();
	}
	
	//this function allows the monkeys to move up a row after they won a battle
	public function onClick(event:MouseEvent) {
		if (!isSwapCardON){ // if the swap 1 card was not selected then doeverything as planned //"!isSwapCardON": means if that variable is false do this else do that 
			if (Std.is(event.target, Card)) { // checks if the clicked object is a Card
				currentCard = cast(event.target, Card);
				if (currentCard.isSocialCard == true){
					if (isCardInRightRow(currentCard)){
						monsterImage = new Bitmap(Assets.getBitmapData("img/" + currentCard.cardName + ".png"));
						
						monsterImage.x = (screenWidth / 2) - (monsterImage.width / 2);
						monsterImage.y = (screenHeight / 2) - (monsterImage.height / 2);
						addChild(monsterImage);
						selectedMonster = currentCard;
						Timer.delay(removeSocialCard, 1300);
						return;
					}
				}
				
				if (currentCard.playerNumber == null && currentCard.isHandCard == false){//if the player number of the card is null it is not a player card or social card
					if (isCardInRightRow(currentCard)){
						removeChild(moveSideways);
						selectedMonster = currentCard; //put the card in the selected monster variable 
						removeChild(selectedMonster);
						monsterImage = new Bitmap(Assets.getBitmapData("img/" + selectedMonster.cardName + ".png"));
						
						monsterImage.x = (screenWidth / 2) - (monsterImage.width / 2);
						monsterImage.y = (screenHeight / 2) - (monsterImage.height / 2);
						addChild(monsterImage);
					}
				} else if (selectedMonster != null){
					var player:Player = cast(currentCard.parent,Player);
					if ((isTurnPlayer1 && player.playerNumber == 1) || (!isTurnPlayer1 && player.playerNumber == 2))//if the clicked card belongs to the player whose turn it is
						selectedPlayerCard = currentCard;
				}
				if (selectedMonster != null && selectedPlayerCard != null) {
					addOverlay();
					if (usedCards.indexOf(selectedPlayerCard) == -1){
						
						usedCards.push(selectedPlayerCard);
						if (usedCards[0].cardName == "bananaPeel") {
							
							combinable = true;
							comDamage += selectedPlayerCard.damage;
							//selectedPlayerCard = null;
							if (usedCards.length <= 1) {
								return;
							}
						}
					} else if (usedCards.indexOf(selectedPlayerCard) != -1) {
						return;
					}
					
					Timer.delay(battleResults, 650);
						
				}
			}
		}else{ // if a player selected a swap one card method then the game will execute this else
			if (Std.is(event.target, Card)) { // checks if the clicked object is a Card
				if(cardToSwap1 == null){
					cardToSwap1 = cast(event.target, Card); //get first selected card and put it in the variable
				}else{
					cardToSwap2 = cast(event.target, Card);
					removeSocialCard();
				}
			}
		}
	}
	
	private function battleResults(){
		removeChild(monsterImage);
		var player:Player = cast(selectedPlayerCard.parent, Player);
		if ((isTurnPlayer1 && player.playerNumber == 1) || (!isTurnPlayer1 && player.playerNumber == 2)) {//if the selected card belongs to the right player
			var didYouWin:Bool = battle();
			if (didYouWin) {
				if (isTurnPlayer1) {
					placeMonkey(player1Card);
				} else { //if its 2 player's turn
					placeMonkey(player2Card);
				}
			} else { // if you ender this else means you lost the battle
				var deadMonkey:Bool = false;
				pickedCard = handDeck.pop();
				if (isTurnPlayer1) {
					player1.replaceCard(currentCard, pickedCard);
					cardImage = new Bitmap(pickedCard.imageData);

					cardImage.scaleX = cardDimensionAnimation;
					cardImage.scaleY = cardDimensionAnimation;
					cardImage.y = (currentCard.y + player1.y) -10;
					cardImage.x = (currentCard.x + player1.x) -10;
					addChild(cardImage);
					Timer.delay(removeHandCard, 800);
						
					deadMonkey = player1.losingLives();
				}
				else {
					player2.replaceCard(currentCard, pickedCard);
					cardImage = new Bitmap(pickedCard.imageData);

					cardImage.scaleX = cardDimensionAnimation;
					cardImage.scaleY = cardDimensionAnimation;
					cardImage.y = (currentCard.y + player2.y) -10;
					cardImage.x = (currentCard.x + player2.x) -10;
					addChild(cardImage);
					Timer.delay(removeHandCard, 800);
					
					deadMonkey = player2.losingLives();
				}
				if (deadMonkey == false){
					arrangeCards();
					changeTurn();
				}
			}
		}
		selectedMonster = null;
		selectedPlayerCard = null;
		if (player1Card.row == 7 || player2Card.row == 7) {
			Timer.delay(displayWinScreen, 1000);
		}
	}
	
	public function displayWinScreen():Void{ // when a player gets to the top of the pyramid he wins the game and goes to banana heaven
		removeChildren();
		//addChild(new Bitmap(Assets.getBitmapData("img/Background3.png")));
		
		var winScreenTextField:TextField = new TextField();
		var message:String = "Congratulations ";
		
		if (player1Card.row == 7) message += "Blue";
		else message += "Red";
		
		message += " Monkey, you won!"; 
		
		winScreenTextField.text = message;
		var textFormat:TextFormat = new TextFormat();
		textFormat.size = 30;
		winScreenTextField.setTextFormat(textFormat);
		winScreenTextField.autoSize = TextFieldAutoSize.LEFT;
		winScreenTextField.x = 350;
		winScreenTextField.y = 450;
		winScreenTextField.textColor = 0xffffff;
		addChild(winScreenTextField);
		
	}
	
	public function removeHandCard():Void{
		removeChild(cardImage);
		cardImage = null;
	}
	
	// makes sure the clicked card is in the right poition, checks if the player still is not on the board and checks if the card is in a movable row
	private function isCardInRightRow(card:Card):Bool
	{
		return ((currentPlayerCard.row == null && card.row == 1) ||
				(currentPlayer.moveableWays == MovableWays.Up && card.row == (currentPlayerCard.row + 1)) ||
				(currentPlayer.moveableWays == MovableWays.Side && card.row == (currentPlayerCard.row)));
	}
	
	// places the given monkey to the new clicked poition
	private function placeMonkey(playerCard:Card):Void
	{
		var pickedCard:Card = handDeck.pop();
		if (isTurnPlayer1) {
			player1.replaceCard(currentCard, pickedCard);
			
			cardImage = new Bitmap(pickedCard.imageData);
			cardImage.scaleX = cardDimensionAnimation;
			cardImage.scaleY = cardDimensionAnimation;
			cardImage.y = (currentCard.y + player1.y) -10;
			cardImage.x = (currentCard.x + player1.x) -10;
			addChild(cardImage);
			Timer.delay(removeHandCard, 800);
		} else {
			player2.replaceCard(currentCard, pickedCard);
			
			cardImage = new Bitmap(pickedCard.imageData);
			cardImage.scaleX = cardDimensionAnimation;
			cardImage.scaleY = cardDimensionAnimation;
			cardImage.y = (currentCard.y + player2.y) -10;
			cardImage.x = (currentCard.x + player2.x) -10;
			addChild(cardImage);
			Timer.delay(removeHandCard, 800);
		}
		if (playerCard.row == null)   // if your monkey is not on the board, you can only go on row 1
		{
			placedCards[placedCards.indexOf(selectedMonster)] = playerCard; // puts the monkey card in the place of the clicked card
			arrangeCards();
			changeTurn(); // it is now player 2 turn
		}
		else if (playerCard.row != null)     // if your monkey is in a row, and the clicked card is in the very next row
		{
			var player1CardIndex:Int = placedCards.indexOf(playerCard); // gets the index of the monkey card in the pyramid card array
			var cardIndex:Int = placedCards.indexOf(selectedMonster); // gets the index of the clicked card in the pyramid card array
			placedCards[player1CardIndex] = pyramidDeck.pop(); // puts the clicked card in place of the monkey card
			placedCards[cardIndex] = playerCard; // puts the monkey card in place of the clicked card
			arrangeCards();
			changeTurn(); // it is now player 2 turn
		}
	}
	
	
	
	
	// shuffles the deck
	public function shuffleDeck(cardsArray:Array<Card>){
		var n:Int = cardsArray.length;
		for (i in 0...n ) {
			var change:Int = i + Math.floor( Math.random() * (n - i) );
			var tempCard:Card = cardsArray[i];
			cardsArray[i] = cardsArray[change];
			cardsArray[change] = tempCard;
		}
	}
		
		
	public function battle():Bool{  // this method is called in the onClick method above
		var extraDamage:Int = 0;
		if (combinable){

			for (card in usedCards) {
				extraDamage += card.damage;
			}
			resetExtraPeelDamage();
			overlayRemoval();
			return selectedMonster.damage <= extraDamage;
			
		}
		resetExtraPeelDamage();
		overlayRemoval();
		return selectedMonster.damage <= selectedPlayerCard.damage;
		
	}
	
	function resetExtraPeelDamage(){
			combinable = false;

			comDamage = 0;
			usedCards = new Array<Card>();
	}
	
	public function changeTurn():Void{ //change player turns and display turns message	
		if (rowOverlays != null){// if the array of overlays is not empty
			for (overlay in rowOverlays) {//remove all the overlays that belonget to the player one
				removeChild(overlay); 
			 }
		}
		currentPlayer.moveableWays = selectedMonster.movableWays;
		if (isTurnPlayer1 == true){
			isTurnPlayer1 = false;
			message = "Red monkey's turn!";
			redArrow = new Bitmap(redArrowData);
			redArrow.scaleX = 0.6;
			redArrow.scaleY = 0.6;//position the life pictures, 5 space at the start, 20 is the interval between images
			redArrow.y = 480;
			redArrow.x = 1023;
			removeChild(blueArrow);
			addChild(redArrow);
			currentPlayer = player2;
			currentPlayerCard = player2Card;
			
		
			for (card in placedCards){ //for each card in the array cards(pyramid cards)
				if ((player2Card.row != null) && (card.row == player2Card.row + 1)){
					rowOverlay = new Bitmap(rowOverlayData);
					rowOverlay.scaleX = 0.21;
					rowOverlay.scaleY = 0.21;
					rowOverlay.y = card.y;
					rowOverlay.x = card.x;
					rowOverlays.push(rowOverlay);
					addChild(rowOverlay);
				} else if (player2Card.row == null) { // if the player2 is not on board add overlays to the first row
					if (card.row == 1) {
						rowOverlay = new Bitmap(rowOverlayData);
						rowOverlay.scaleX = 0.21;
						rowOverlay.scaleY = 0.21;
						rowOverlay.y = card.y;
						rowOverlay.x = card.x;
						rowOverlays.push(rowOverlay);
						addChild(rowOverlay);
					}
				}
			}
			
		}else {
			isTurnPlayer1 = true;
			message = "Blue monkey's turn!";
			
			blueArrow = new Bitmap(blueArrowData);
			blueArrow.scaleX = 0.6;
			blueArrow.scaleY = 0.6;//position the life pictures, 5 space at the start, 20 is the interval between images
			blueArrow.y = 480;
			blueArrow.x = 5;
			removeChild(redArrow);
			addChild(blueArrow);
			currentPlayer = player1;
			currentPlayerCard = player1Card;
			
			for (card in placedCards){ //for each card in the array cards(pyramid cards)
				if ((player1Card.row != null) && (card.row == player1Card.row + 1)){
					rowOverlay = new Bitmap(rowOverlayData);
					rowOverlay.scaleX = 0.21;
					rowOverlay.scaleY = 0.21;
					rowOverlay.y = card.y;
					rowOverlay.x = card.x;
					rowOverlays.push(rowOverlay);
					addChild(rowOverlay);
				} else if (player1Card.row == null) {
					if (card.row == 1) {
						rowOverlay = new Bitmap(rowOverlayData);
						rowOverlay.scaleX = 0.21;
						rowOverlay.scaleY = 0.21;
						rowOverlay.y = card.y;
						rowOverlay.x = card.x;
						rowOverlays.push(rowOverlay);
						addChild(rowOverlay);
					}
				}
			}
			
				
		}
		trace(message);
		winLoseMessage.text = message;
		
		if (currentPlayer.moveableWays == MovableWays.Side){//if gets called only when you can move only sideways
			moveSideways = new Bitmap(moveSidewaysData); // put the blue arrow on the first player
			moveSideways.scaleX = 0.6;
			moveSideways.scaleY = 0.6;
			moveSideways.y = 16;
			moveSideways.x = 16;
			addChild(moveSideways);
			
			if (rowOverlays != null){// if the array of overlays is not empty
				for (overlay in rowOverlays) {//remove all the overlays that belonget to the player one
					removeChild(overlay); 
				 }
			}
			for (card in placedCards){ 
				var row:Int = 0;
				if (isTurnPlayer1) {
					row = player1Card.row; // the monkey card that goes up
				} else {
					row = player2Card.row;
				}
					
				if (row != null && card.row == row){ //if player 1 or player 2
					rowOverlay = new Bitmap(rowOverlayData);
					rowOverlay.scaleX = 0.21;
					rowOverlay.scaleY = 0.21;
					rowOverlay.y = card.y;
					rowOverlay.x = card.x;
					rowOverlays.push(rowOverlay);
					addChild(rowOverlay);
				}
			}
		}
	}	
	
	
	
	public function removeSocialCard():Void{ //after you chose a social card this method will remove it from the screen when its called
		removeChild(monsterImage);
		if (currentCard.cardName == "swapCard"){
			isSwapCardON = true;
			if (cardToSwap1 != null && cardToSwap2 != null) {
				socialCardsObject.socialMethods(currentCard);
				changeTurn();
				return;
			} else {
				return; //wait for the player to click two cards
			}
		}
		socialCardsObject.socialMethods(currentCard);//here you call the socialMethods switch that will execute the action of the selected social card
		if (currentCard.cardName != "swapPosition"){
			if (isTurnPlayer1) {
				placeMonkey(player1Card);
			} else { //if its 2 player's turn
				placeMonkey(player2Card);
			}
		} else {
			changeTurn();
		}
	}
	
	public function displayLoserMessage(playerNumber:Int):Void{ // display the loser message when somebody loses all 3 lives
		removeChildren();
		if (playerNumber == 1){
			loserMessage.text = "Blue monkey is the stinky loser!";
		}else{
			loserMessage.text = "Red monkey is the stinky loser!";
		}
		loserMessage.x = (screenWidth / 2) - (loserMessage.width / 2);
		loserMessage.y = (screenHeight / 2) - 180;
		addChild(loserMessage);
	
	}
	
	public function nukeSocialCards(card:Card):Void{ // delete social cards from the first row
		if (card.isSocialCard == true){
			placedCards[placedCards.indexOf(card)] = pyramidDeck.pop(); 
			nukedSocialCardsInFirstRow = true;
			
		}
		
	}
	
	public function generatePyramidDeck():Void{ //Creates the deck
		pyramidDeck = new Array<Card>(); // a variable has a RAM aaddress only after you initialize it (before that its null)
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 5, "gorilla", false, false));
		pyramidDeck.push(new Card(null, 5, "gorilla", false, false));
		pyramidDeck.push(new Card(null, 6, "hunter", false, false));
		pyramidDeck.push(new Card(null, 6, "hunter", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		
		

		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 5, "gorilla", false, false));
		pyramidDeck.push(new Card(null, 5, "gorilla", false, false));
		pyramidDeck.push(new Card(null, 6, "hunter", false, false));
		pyramidDeck.push(new Card(null, 6, "hunter", false, false));
		
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 2, "snake", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 3, "crocodile", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 4, "tiger", false, false));
		pyramidDeck.push(new Card(null, 5, "gorilla", false, false));
		pyramidDeck.push(new Card(null, 5, "gorilla", false, false));

		pyramidDeck.push(new Card(null, 0, "swapHands", false, true));
		pyramidDeck.push(new Card(null, 0, "swapPosition", false, true));
		pyramidDeck.push(new Card(null, 0, "swapHands", false, true));
		pyramidDeck.push(new Card(null, 0, "swapHands", false, true));
		pyramidDeck.push(new Card(null, 0, "swapHands", false, true));
		pyramidDeck.push(new Card(null, 0, "swapHands", false, true));
		pyramidDeck.push(new Card(null, 0, "swapHands", false, true));
		pyramidDeck.push(new Card(null, 0, "swapHands", false, true));
		pyramidDeck.push(new Card(null, 0, "swapHands", false, true));
		pyramidDeck.push(new Card(null, 0, "swapCard", false, true));
		pyramidDeck.push(new Card(null, 0, "swapCard", false, true));
		pyramidDeck.push(new Card(null, 0, "swapCard", false, true));
		pyramidDeck.push(new Card(null, 0, "swapCard", false, true));
		pyramidDeck.push(new Card(null, 0, "swapCard", false, true));
		pyramidDeck.push(new Card(null, 0, "swapCard", false, true));
		pyramidDeck.push(new Card(null, 0, "swapCard", false, true));
		pyramidDeck.push(new Card(null, 0, "swapCard", false, true));
		pyramidDeck.push(new Card(null, 0, "swapCard", false, true));
		pyramidDeck.push(new Card(null, 0, "swapPosition", false, true));
		pyramidDeck.push(new Card(null, 0, "swapPosition", false, true));
		pyramidDeck.push(new Card(null, 0, "swapPosition", false, true));
		pyramidDeck.push(new Card(null, 0, "swapPosition", false, true));
		pyramidDeck.push(new Card(null, 0, "swapPosition", false, true));
		pyramidDeck.push(new Card(null, 0, "swapPosition", false, true));
		pyramidDeck.push(new Card(null, 0, "swapPosition", false, true));
	
	
		
		
		
		shuffleDeck(pyramidDeck);
	}
	 // create the weapon deck
	public function generateHandDeck():Void{
		handDeck = new Array<Card>();
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		
			
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 1, "bananaPeel", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 2, "bananaBow", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 3, "bananaSpear", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 4, "bananaBomb", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		handDeck.push(new Card (null, 5, "bananaRifle", true, false));
		
		
		shuffleDeck(handDeck);
		
	}
	public function addOverlay():Void{
			var cardOverlay:Bitmap = new Bitmap(cardOverlayData); // put the overlay on the selected bananaPeel
			cardOverlay.scaleX = 0.3;
			cardOverlay.scaleY = 0.3;
			//trace(selectedPlayerCard.x + " " + selectedPlayerCard.y);
			
			if (isTurnPlayer1){
				cardOverlay.y = selectedPlayerCard.y + player1.y;
				cardOverlay.x = selectedPlayerCard.x + player1.x;
			}else{
				cardOverlay.y = selectedPlayerCard.y + player2.y;
				cardOverlay.x = selectedPlayerCard.x + player2.x;
			}
			overlayArray.push(cardOverlay);
			addChild(cardOverlay);
			//Timer.delay(overlayRemoval, 1000);
	}
	public function overlayRemoval():Void{// this method is called by the timer and removes the overlay
		for (overlay in overlayArray) {
			removeChild(overlay);
		}
	}
}