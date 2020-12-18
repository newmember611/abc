// password checking module for FB, AS2.0

// password string from FB
// var pwd:String = "123"; ifPasswordExists();

_trace('--password_checking--');

//// attempt-counter
var firstOrNot:Boolean = false;
//// variable for checking, if password granted
var pwdCatched:Boolean = false;
// delay after checking password
var delayCheck:Number = 2; // in seconds


// customizing Flash-player menu
/*var customMenu:ContextMenu = new ContextMenu();
customMenu.builtInItems.play = false;
customMenu.builtInItems.forward_back = false;
customMenu.builtInItems.rewind = false;
//customMenu.hideBuiltInItems();
//_root.menu = customMenu;
*/
// function of creating of password screen 
function createPasswordScreen():Void {
	// dark background on whole movie
	this.createEmptyMovieClip("DBackground", 64999); //instead of this.getNextHighestDepth());
	DBackground.beginFill(0x000000, 50);
	DBackground.moveTo(0, 0);
	DBackground.lineTo(_root.width, 0);
	DBackground.lineTo(_root.width, _root.height);
	DBackground.lineTo(0, _root.height);
	DBackground.lineTo(0, 0);
	DBackground.endFill();
	
	// size of Password Window
	var PW_width:Number = 217;
	var PW_height:Number = 104;
	
	//text formats
	// format of usual text
	var textFormat:TextFormat = new TextFormat();
	textFormat.font = "Arial"; //"Times New Roman";
	textFormat.size = 15;
	textFormat.color = 0x000000;
	textFormat.bold = false; textFormat.italic = false; textFormat.underline = false;
	textFormat.align = "left";
	//url = ""; target = "";
	
	// format of usual text, but WHITE words
	var textFormatWhite:TextFormat = new TextFormat();
	textFormatWhite.font = "Arial";
	textFormatWhite.size = 15;
	textFormatWhite.color = 0xFFFFFF;
	textFormatWhite.bold = false; textFormatWhite.italic = false; textFormatWhite.underline = false;
	textFormatWhite.align = "left";
	
	// format of usual text, but WHITE words + centered
	var textFormatWhiteCenter:TextFormat = new TextFormat();
	textFormatWhiteCenter.font = "Arial";
	textFormatWhiteCenter.size = 15;
	textFormatWhiteCenter.color = 0xFFFFFF;
	textFormatWhiteCenter.bold = false; textFormatWhiteCenter.italic = false; textFormatWhiteCenter.underline = false;
	textFormatWhiteCenter.align = "center";
	
	// format of button text
	var bttn_textFormat:TextFormat = new TextFormat();
	bttn_textFormat.font = "Arial";
	bttn_textFormat.size = 15;
	bttn_textFormat.color = 0x000000;
	bttn_textFormat.bold = false; bttn_textFormat.italic = false; bttn_textFormat.underline = false;
	bttn_textFormat.align = "center";
	
	// Password Window creation
	this.createEmptyMovieClip("PasswordWindow", DBackground.getDepth()+1);
	PasswordWindow._quality = "HIGH";
	PasswordWindow.lineStyle(2, 0xFFFFFF);
	PasswordWindow.beginFill(0x3c3c3c, 100);
	PasswordWindow.moveTo(0, 0);
	PasswordWindow.lineTo(PW_width, 0);
	PasswordWindow.lineTo(PW_width, PW_height);
	PasswordWindow.lineTo(0, PW_height);
	PasswordWindow.lineTo(0, 0);
	PasswordWindow.endFill();
	PasswordWindow._x = DBackground._width/2-108;
	PasswordWindow._y = DBackground._height/2-52;
	//_trace(PasswordWindow.getDepth());
	
	this.createTextField("inputFieldLabel", DBackground.getDepth()+2, 0, 0, 120, 20);
	inputFieldLabel.text = _root.enterPassword;//"Enter password:";
	inputFieldLabel.type = "static";
	inputFieldLabel.autoSize = false; 
	inputFieldLabel.selectable = false;
	inputFieldLabel.multiline = false;
	inputFieldLabel._x = PasswordWindow._x + 14;
	inputFieldLabel._y = PasswordWindow._y + 15;
	inputFieldLabel.setTextFormat(textFormatWhite);
	
	// text if wrong password
	this.createTextField("incorrectPasswordLabel", DBackground.getDepth()+3, 0, 0, 217, 20);
	incorrectPasswordLabel.text = _root.incorrectPassword;//"Incorrect password";
	incorrectPasswordLabel.type = "static";
	incorrectPasswordLabel.autoSize = false; 
	incorrectPasswordLabel.selectable = false;
	incorrectPasswordLabel.multiline = false;
	incorrectPasswordLabel._x = PasswordWindow._x;
	incorrectPasswordLabel._y = PasswordWindow._y + 30;
	incorrectPasswordLabel.setTextFormat(textFormatWhiteCenter);
	incorrectPasswordLabel._visible = false;
	
	this.createTextField("inputField", DBackground.getDepth()+4, 0, 0, 188, 22);
	inputField.autoSize = false; 
	//inputField.text = "";
	inputField.type = "input";
	inputField.multiline = false;
	inputField.maxChars = 20;
	inputField.border = true;
	inputField.borderColor = 0x000000;
	inputField.background = true;
	inputField.backgroundColor = 0xFFFFFF;
	inputField.selectable = true;
	inputField._x = PasswordWindow._x + 14;
	inputField._y = PasswordWindow._y + 35;
	//inputField.password = true; //for asterix
	inputField.setNewTextFormat(textFormat); //if at firstly field empty (without text)
	//inputField.setTextFormat(textFormat); //if creating with text
	//_trace(Selection.getFocus());
	Selection.setFocus("_level0.inputField");
	//_trace(Selection.getFocus());
	
	this.createEmptyMovieClip("underButtonBG", DBackground.getDepth()+5);
	underButtonBG.beginFill(0x565656, 100);
	underButtonBG.moveTo(0, 0);
	underButtonBG.lineTo(215, 0);
	underButtonBG.lineTo(215, 30);
	underButtonBG.lineTo(0, 30);
	underButtonBG.lineTo(0, 0);
	underButtonBG.endFill();
	underButtonBG._x = PasswordWindow._x + 1;
	underButtonBG._y = PasswordWindow._y + 73;
	
	// BUTTONS
	
	// button "OK"
	this.createEmptyMovieClip("buttonOK_MC", DBackground.getDepth()+6);
	var fillType:String = "linear";
	var colors:Array = [0xFFFFFF, 0xC8C8C8]; //0xF10033
	var alphas:Array = [100, 100];
	var ratios:Array = [0, 255];
	// horizontal

	var bttnWidth:Number = 69;
	var bttnHeight:Number = 23;
	var bttnCornerSmoothing:Number = 5;

	var matrix = {matrixType:"box", x:0, y:0, w:bttnWidth, h:bttnHeight, r:90/180*Math.PI};

	buttonOK_MC.beginGradientFill(fillType, colors, alphas, ratios, matrix);
	buttonOK_MC.moveTo(0,bttnCornerSmoothing);
	buttonOK_MC.curveTo(0,0,bttnCornerSmoothing,0);
	buttonOK_MC.lineTo(bttnWidth-bttnCornerSmoothing,0);
	buttonOK_MC.curveTo(bttnWidth,0,bttnWidth,bttnCornerSmoothing);
	buttonOK_MC.lineTo(bttnWidth, bttnHeight-bttnCornerSmoothing);
	buttonOK_MC.curveTo(bttnWidth,bttnHeight,bttnWidth-bttnCornerSmoothing,bttnHeight);
	buttonOK_MC.lineTo(bttnCornerSmoothing, bttnHeight);
	buttonOK_MC.curveTo(0,bttnHeight,0,bttnHeight-bttnCornerSmoothing);
	buttonOK_MC.endFill();
	buttonOK_MC._x = underButtonBG._x + 132;
	buttonOK_MC._y = underButtonBG._y + 3;
	
	// button "OK" actions
	buttonOK_MC.onRelease = function(){
		checkPassword();
		Key.removeListener(myListener);
	};
	
	// button "Try Again"
	this.createEmptyMovieClip("buttonTryAgain_MC", DBackground.getDepth()+7);
	buttonTryAgain_MC.beginGradientFill(fillType, colors, alphas, ratios, matrix);
	buttonTryAgain_MC.moveTo(0,bttnCornerSmoothing);
	buttonTryAgain_MC.curveTo(0,0,bttnCornerSmoothing,0);
	buttonTryAgain_MC.lineTo(bttnWidth-bttnCornerSmoothing,0);
	buttonTryAgain_MC.curveTo(bttnWidth,0,bttnWidth,bttnCornerSmoothing);
	buttonTryAgain_MC.lineTo(bttnWidth, bttnHeight-bttnCornerSmoothing);
	buttonTryAgain_MC.curveTo(bttnWidth,bttnHeight,bttnWidth-bttnCornerSmoothing,bttnHeight);
	buttonTryAgain_MC.lineTo(bttnCornerSmoothing, bttnHeight);
	buttonTryAgain_MC.curveTo(0,bttnHeight,0,bttnHeight-bttnCornerSmoothing);
	buttonTryAgain_MC.endFill();
	buttonTryAgain_MC._x = underButtonBG._x + 132;
	buttonTryAgain_MC._y = underButtonBG._y + 3;
	buttonTryAgain_MC._visible = false;

	// button "Try Again" actions
	buttonTryAgain_MC.onRelease = function(){
		buttonTryAgain_MC._visible = false;
		buttonTextTryAgain._visible = false;
		buttonOK._visible = true;
		buttonTextOK._visible = true;
		inputFieldLabel._visible = true;
		inputField._visible = true;
		incorrectPasswordLabel._visible = false;
		Key.addListener(myListener);
	};
	
	// buttons text
	
	this.createTextField("buttonTextOK", DBackground.getDepth()+8, 0, 0, 68, 20);
	buttonTextOK.autoSize = false; 
	buttonTextOK.text = _root.oK;//"OK";
	buttonTextOK.type = "dynamic";
	buttonTextOK.multiline = false;
	buttonTextOK.maxChars = 10;
	buttonTextOK.selectable = false;
	buttonTextOK._x = buttonOK_MC._x;
	buttonTextOK._y = buttonOK_MC._y + 1;
	buttonTextOK.setTextFormat(bttn_textFormat);
	

	this.createTextField("buttonTextTryAgain", DBackground.getDepth()+9, 0, 0, 68, 22);
	buttonTextTryAgain.autoSize = false; 
	buttonTextTryAgain.text = _root.tryAgain;//"Try Again";
	buttonTextTryAgain.type = "static";
	buttonTextTryAgain.multiline = false;
	buttonTextTryAgain.maxChars = 10;
	buttonTextTryAgain.selectable = false;
	buttonTextTryAgain._x = buttonOK_MC._x;
	buttonTextTryAgain._y = buttonOK_MC._y + 1;
	buttonTextTryAgain.setTextFormat(bttn_textFormat);
	buttonTextTryAgain._visible = false;
	
	this.createEmptyMovieClip("DarkPasswordField", DBackground.getDepth()+10);
	DarkPasswordField.beginFill(0x000000, 30);
	DarkPasswordField.moveTo(0, 0);
	DarkPasswordField.lineTo(inputField._width+1, 0);
	DarkPasswordField.lineTo(inputField._width+1, inputField._height+1);
	DarkPasswordField.lineTo(0, inputField._height+1);
	DarkPasswordField.endFill();
	DarkPasswordField._visible = false;
	DarkPasswordField._x = inputField._x;
	DarkPasswordField._y = inputField._y;
	
// END OF function createPasswordScreen()
}


// FUNCTIONS 

function ifPasswordExists():Boolean 
{
	_trace('ifPasswordExists');
	firstOrNot = false;		
	if (_root.pwd == "") {
		_trace ("password is empty");
		return true;
		}
	else if (pwdCatched == true) {
		_trace ("password is correct");
		_root.pwd="";
		FinalActions();
		return true;
		}
	else {
			if (firstOrNot == false) {
			createPasswordScreen();
			}
			else {
			checkPassword();
			}
		}
}

// erase all if access granted
function eraseAll():Void {
// movie clips to remove
	this.DBackground.removeMovieClip();
	this.PasswordWindow.removeMovieClip();
	this.DarkPasswordField.removeMovieClip();
	this.underButtonBG.removeMovieClip();
	this.buttonOK_MC.removeMovieClip();
	this.buttonTryAgain_MC.removeMovieClip();
// text fields to remove
	this.inputFieldLabel.removeTextField();
	this.incorrectPasswordLabel.removeTextField();
	this.inputField.removeTextField();
	this.buttonTextOK.removeTextField();
	this.buttonTextTryAgain.removeTextField();
}

// function of password checking
function checkPassword():Boolean {
	firstOrNot = true;
	if (inputField.text == _root.pwd) {
		eraseAll();
		pwdCatched = true;
		ifPasswordExists();
	}
	else {
		DarkPasswordField._visible = true;
		timeDelayIfWronglyPassword();
		return false;
		}
}

var intervalCall:Number;
function justWaiting():Void {
	DarkPasswordField._visible = false;
	clearInterval(intervalCall);
	buttonOK._visible = false;
	buttonTextOK._visible = false;
	buttonTryAgain_MC._visible = true;
	buttonTextTryAgain._visible = true;
	inputFieldLabel._visible = false;
	inputField._visible = false;
	incorrectPasswordLabel._visible = true;
	}
	
function timeDelayIfWronglyPassword():Void {
	intervalCall = setInterval(this, "justWaiting", delayCheck * 1000);
}


// action on "Enter", need to remake
var myListener:Object = new Object();
myListener.onKeyUp = function() {
	if (Key.getCode() == Key.ENTER) {
		//_trace ("Enter is pressed");
		checkPassword();
		//_root.createDelayRect();
		}
	}
Key.addListener(myListener);

_trace('--password_checking eof--');