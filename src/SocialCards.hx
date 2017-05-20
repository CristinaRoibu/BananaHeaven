package src;


/**
 * ...
 * @author cristina
 * this class contains the methods that execute social cards actions
 */
class SocialCards 
{
	var boardInstance:Board;

	
	public function new(boardInstance:Board) 
	{
		this.boardInstance = boardInstance;
		
	}
	
	public function socialMethods(card:Card):Void{
		switch (card.cardName){ // based on the name of the card we clicked on it will call the relative method
			case "swapHands":swapHandsMethod();
			case "swapPosition":swapPositionMethod();
			case "swapCard":swapCard();
		}
	}
	
	
	public function swapHandsMethod():Void{ 
		var cards:Array<Card>;
		cards = boardInstance.player1.cards;
		boardInstance.player1.cards = boardInstance.player2.cards;
		boardInstance.player2.cards = cards;
		
		boardInstance.player1.repositionObjects(); 
		boardInstance.player2.repositionObjects();
	
	}
	
	public function swapPositionMethod():Void{
		var indexPlayer1:Int = boardInstance.placedCards.indexOf(boardInstance.player1Card);
		var indexPlayer2:Int = boardInstance.placedCards.indexOf(boardInstance.player2Card);
		
		boardInstance.placedCards[indexPlayer1] = boardInstance.player2Card;
		boardInstance.placedCards[indexPlayer2] = boardInstance.player1Card;
		boardInstance.arrangeCards();
	}
	
	public function swapCard():Void{
		var indexCard1:Int; // contains the index of the selected card in the array cards of the player
		var indexCard2:Int;
		var playerOfCard1:Int; // contains the player of the selected card
		//var playerOfCard2:Int;
		
		
		if (boardInstance.player1.cards.indexOf(boardInstance.cardToSwap1) != -1){ // if the index of the card is -1 means that the card is not in the player 1 array of cards
            indexCard1 = boardInstance.player1.cards.indexOf(boardInstance.cardToSwap1);
			playerOfCard1 = 1;
		}else{
			indexCard1 = boardInstance.player2.cards.indexOf(boardInstance.cardToSwap2);
			playerOfCard1 = 2;
		}
		
		if (boardInstance.player1.cards.indexOf(boardInstance.cardToSwap2) != -1){ // if the index of the card is -1 means that the card is not in the player 1 array of cards
            indexCard2 = boardInstance.player1.cards.indexOf(boardInstance.cardToSwap1);
			//playerOfCard2 = 1;
			
		}else{
			indexCard2 = boardInstance.player2.cards.indexOf(boardInstance.cardToSwap2);
			//playerOfCard2 = 2;
		}
		
		
		if (playerOfCard1 == 1){ //if selected card number one belongs to player number 1
			boardInstance.player2.cards[indexCard2] = boardInstance.cardToSwap1;
			boardInstance.player1.cards[indexCard1] = boardInstance.cardToSwap2;
			
		}else{ // if the first card selected belongs to player 2 
			boardInstance.player1.cards[indexCard1] = boardInstance.cardToSwap1;
			boardInstance.player2.cards[indexCard2] = boardInstance.cardToSwap2;
			
		}
		boardInstance.player1.repositionObjects(); //removes player cards and ripositions them on the board
		boardInstance.player2.repositionObjects();
		boardInstance.isSwapCardON = false;
		boardInstance.cardToSwap1 = null; // put them null so the next time you use the variables they dont contain the cards from before
		boardInstance.cardToSwap2 = null;
	}
}