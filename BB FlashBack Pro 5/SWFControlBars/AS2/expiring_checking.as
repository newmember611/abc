// Expired date checking module for FB, AS2.0

// variable for getting of expiring date from FB
// var expiryDate:String = "05/11/2009"; // format is day/month/year - 05/12/2009

// turning date in right format
// expiring date from FB

_trace('--expiring_checking--');
var dayFromFB:Number = Number(_root.expiryDate.charAt(0)+_root.expiryDate.charAt(1));
var monthFromFB:Number = Number(_root.expiryDate.charAt(3)+_root.expiryDate.charAt(4));
var yearFromFB:Number = Number(_root.expiryDate.charAt(6)+_root.expiryDate.charAt(7)+_root.expiryDate.charAt(8)+_root.expiryDate.charAt(9));
// today`s date from client-computer
var todayIs:Date = new Date();
var yearNow:Number = todayIs.getFullYear();
var dayNow:Number = todayIs.getDate();
var monthNow:Number = todayIs.getMonth()+1;

//function of checking if user setup expiring date
// ifExpiryDateExists();

/*var customMenu:ContextMenu = new ContextMenu();
customMenu.builtInItems.play = false;
customMenu.builtInItems.forward_back = false;
customMenu.builtInItems.rewind = false;
_root.menu = customMenu;*/

//function of checking if date already expired or not
function checkingIfExpired():Boolean {

	if (yearNow > yearFromFB)
	{
		createExpiredScreen();
		_trace("expired by year"); 
		return false;
	}
	else if (yearNow == yearFromFB) 
	{
		if (monthNow > monthFromFB) 
		{
			createExpiredScreen();
			_trace ("expired by month");
			return false;
		}
		else if (monthNow == monthFromFB ) 
		{
			if (dayNow > dayFromFB) 
			{
				createExpiredScreen();
				_trace ("expired by day");
				return false;
			}
		}
	}

	_trace ("not expired yet, enjoy your movie");
	return true;
	
} // end of function

// function of creating of password screen 
function createExpiredScreen():Void {
	// dark background on whole movie
	this.createEmptyMovieClip("DBackground", 64999); //dont changing 64999!
	DBackground.beginFill(0x000000, 50);
	DBackground.moveTo(0, 0);
	DBackground.lineTo(_root.width, 0);
	DBackground.lineTo(_root.width, _root.height);
	DBackground.lineTo(0, _root.height);
	DBackground.lineTo(0, 0);
//	DBackground.lineTo(0, 0);   // need to debugging
//	DBackground.lineTo(500, 0);
//	DBackground.lineTo(500, 450);
//	DBackground.lineTo(0, 450);
	DBackground.endFill();

	// size of Expired-window
	var PW_width:Number = 217;
	var PW_height:Number = 104;

	// Expired-window creation
	this.createEmptyMovieClip("expriredWindow", DBackground.getDepth()+1);
	expriredWindow._quality = "HIGH";
	expriredWindow.lineStyle(2, 0xFFFFFF);
	expriredWindow.beginFill(0x3c3c3c, 100);
	expriredWindow.moveTo(0, 0);
	expriredWindow.lineTo(PW_width, 0);
	expriredWindow.lineTo(PW_width, PW_height);
	expriredWindow.lineTo(0, PW_height);
	expriredWindow.lineTo(0, 0);
	expriredWindow.endFill();
	expriredWindow._x = DBackground._width/2-108;
	expriredWindow._y = DBackground._height/2-52;
	
	// format of text
	var whiteCentered:TextFormat = new TextFormat();
	whiteCentered.font = "Arial";
	whiteCentered.size = 15;
	whiteCentered.color = 0xFFFFFF;
	whiteCentered.bold = false; whiteCentered.italic = false; whiteCentered.underline = false;
	whiteCentered.align = "center";	

	// text if Expired already
	this.createTextField("expiredLabel",  DBackground.getDepth()+2, 0, 0, 217, 40);
	expiredLabel.text = _root.movieHasExpired;//"This movie has expired\nand will not be displayed.";
	expiredLabel.type = "static";
	expiredLabel.autoSize = false; 
	expiredLabel.selectable = false;
	expiredLabel.multiline = true;
	expiredLabel._x = expriredWindow._x;
	expiredLabel._y = expriredWindow._y + 30;
	expiredLabel.setTextFormat(whiteCentered);
	//expiredLabel._visible = false;
	
	/* temporary commented
	this.createEmptyMovieClip("underButtonBG", this.getNextHighestDepth());
	underButtonBG.beginFill(0x565656, 100);
	underButtonBG.moveTo(0, 0);
	underButtonBG.lineTo(215, 0);
	underButtonBG.lineTo(215, 30);
	underButtonBG.lineTo(0, 30);
	underButtonBG.lineTo(0, 0);
	underButtonBG.endFill();
	underButtonBG._x = PasswordWindow._x + 1;
	underButtonBG._y = PasswordWindow._y + 73;
	*/	
// END OF function createExpiredScreen()
}


function ifExpiryDateExists():Boolean {
	_trace('ifExpiryDateExists');
	if (_root.expiryDate == "") {
		_trace("expiry date is empty");
		return true;
	}
	else 
	{
		if(checkingIfExpired())
		{
			_root.expiryDate="";
			FinalActions();
			return true;
		}
		else return false;
	}
}

_trace('--expiring_checking eof--');