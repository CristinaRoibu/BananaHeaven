package;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;

/**
 * @author Cristina
 */
class Button extends Sprite
{
	
       //Class button represents a button. It will be instantiated for the purpose of creating buttons
	 
	public function new(buttonName:String):Void
	{
		super();
		var buttons:Bitmap = new Bitmap(Assets.getBitmapData("img/" + buttonName+".png"));
		
		buttons.scaleX =2;
		buttons.scaleY =2;
		addChild(buttons);
	}
}