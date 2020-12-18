import flash.external.*;
import mx.controls.*;
//import flash.geom.Rectangle;

#include "expiring_checking.as"
#include "password_checking.as"

_trace('--common--');
if(_root.enableExternalInterface)
{
	_trace('ExternalInterface.available: '+ExternalInterface.available);
	if(ExternalInterface.available)
	{
	  _trace(ExternalInterface.addCallback("PlayMovie",null,OnButtonPlayClicked));
	  _trace(ExternalInterface.addCallback("PauseMovie",null,PauseMovie));
	  _trace(ExternalInterface.addCallback("StopMovie",null,StopMovie));
	}
}

// constants
var userPauseCount=0;
var progressBarOffset=10;
var timelineMinWidth=62;//  is min width of timeline
var timerInterval=100;
var scrubLeftOffset=(Controls.progressBar.timeline.timelineLeft._width-Controls.progressBar.scrub._width)/2;
if(scrubLeftOffset<0) scrubLeftOffset=0;
var scrubRightOffset=(Controls.progressBar.timeline.timelineRight._width+Controls.progressBar.scrub._width)/2;
if(scrubRightOffset<Controls.progressBar.scrub._width) scrubRightOffset=Controls.progressBar.scrub._width;
var scrubOffset=scrubLeftOffset+scrubRightOffset;
_trace('scrubLeftOffset='+scrubLeftOffset);
_trace('scrubRightOffset='+scrubRightOffset);

// variables
var passwordChecked=false;
var ffp=false;//first frame pause embedded by FB
var toolbarHeight=_root.showToolbar?Controls._height:0;
var isPlaying=false;
var scrubDragged=false;
var intervalID:Number;
var borderWidth=_root.enableBorder?_root.borderWidth:0;
var videoWidth = _root.vw;
var videoHeight = _root.vh;
var initialWidth = _root.vw + borderWidth*2;
var initialHeight = _root.vh + toolbarHeightForMovieSize + borderWidth*2;
var fullScreenAspectX = initialWidth / (System.capabilities.screenResolutionX);
var fullScreenAspectY = initialHeight / (System.capabilities.screenResolutionY);
var fullScreenAspectHor=fullScreenAspectX>fullScreenAspectY;
var fullScreenAspect=fullScreenAspectHor?fullScreenAspectX:fullScreenAspectY;
var stopTimer=false;
var ignoreClickFrame=0;
var hideMenuClick=false
mc.createEmptyMovieClip("mm", 501);
var mainMenu:MovieClip=mm;

if (_root.scaleMode == "noScale")
	if ((initialWidth > System.capabilities.screenResolutionX) || 
	(initialHeight + toolbarHeight > System.capabilities.screenResolutionY))
	{
		_root.scaleMode = "showAll";
	}

mc.createTextField("ab",502, /*x, y,*/ 0, 0, 200, 60);
var aboutBox:TextField=ab;
		
	
var menuX=0;
var menyY=0;
var menuWidth=0;
var gap=(toolbarHeight/fullScreenAspect)-toolbarHeight;
var hgap=gap/2;

_trace(fullScreenAspect+':'+hgap+':'+toolbarHeight);
_trace('initialWidth='+initialWidth);
_trace('initialHeight='+initialHeight);

// clips
btnClickToStart=attachMovie("ClickToStart","btnClickToStart",603);
mc.volBar=attachMovie("volume_bar","volBar",601);
var volBarX=0;
var volBarY=0;
var initialVolBarHeight=mc.volBar._height;
mc.mcPausedIcon=attachMovie("PausedIconMovieClip","mcPausedIcon",600);
mcOverlayLoading=attachMovie("overlay-loading","mcOverlayLoading",602);
mcOverlayLoading._visible=true;
mcOverlayLoading.stop();
mcJumpLoading=attachMovie("overlay-loading","mcOverlayLoading",604);
mcJumpLoading._visible=false;
mcJumpLoading.stop();
var autoscrollShiftX:Number=0;
var autoscrollShiftY:Number=0;

// visibility
btnClickToStart._visible=false;
mc.volBar._visible=false;
mcPausedIcon._visible=false;

mc.createEmptyMovieClip("mc_clip",400);
var clp:MovieClip = mc_clip;
var autoHideTimer:Number = 0;

var jumpTimer:Number = 0;
//var jumpTimerCount:int=0;
//var jumpTime:Number;
//var jumpBtn:ButtonElement;
//var jumpTimerEnabled = false;
var jumpTimerCount:Number = 0;
	
CreateMenu();
CreateAboutBox();

function CreateToolbarTimer()
{
	if (_root.autoHideToolbar && _root.showToolbar)
	{
		clearTimeout(autoHideTimer);
		Controls._visible = true;
		autoHideTimer = setTimeout(HideToolbar, 3000, "autoHideTimer");
	}
}

function HideToolbar(param)
{
	_trace("hideToolbar()");
	clearTimeout(autoHideTimer);
	Controls._visible = false;
	ShowVolBar(false);
	var menuVisible=mainMenu!=null && mainMenu!=undefined && mainMenu._visible;
	if(menuVisible)
	{
		mainMenu._visible=false;
	}
	HideAboutBox();
	autoHideTimer = 0;
}

function fillRect(clp:MovieClip, color:Number, left:Number, top:Number, w:Number, h:Number)
{
	clp.moveTo(left,top);
	clp.beginFill(color, 100);
	clp.lineTo(left+w, top);
	clp.lineTo(left+w, top+h);	
	clp.lineTo(left, top+h);
	clp.lineTo(left, top);
	clp.endFill();
}

function GetFullScaled()
{
	return (Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale");
}


function GetToolbarHeight()
{
	var res = toolbarHeight;
	if (GetFullScaled())
		res = toolbarHeight * fullScreenAspect;
	return res;
}

function GetToolbarHeightForMovieSize()
{
	return  (!_root.autoHideToolbar && _root.showToolbar) ? GetToolbarHeight() : 0;
}

function RedrawBGWithBorder(fullScreen:Boolean, left:Number, top:Number, right:Number, bottom:Number)
{
	clp.clear();
	if (fullScreen)
	{
		clp.lineStyle(0,0x000000,100);
		var sx = 2* System.capabilities.screenResolutionX;
		var sy = 2* System.capabilities.screenResolutionY;
		clp.lineStyle(0,0,0);
		
		_trace("_root.fsBackgroundColor : " + _root.fsBackgroundColor);
		
		fillRect(clp, _root.fsBackgroundColor, -sx, -sy, sx*2, sy + top);
		fillRect(clp, _root.fsBackgroundColor, -sx, -sy, left + sx, sy*2);
		fillRect(clp, _root.fsBackgroundColor, right, -sy, sx - right, sy*2);
		fillRect(clp, _root.fsBackgroundColor, -sx, bottom, sx*2, sy-bottom);
				
	}
	// draw border
	var borderWidth = _root.enableBorder?_root.borderWidth:0;
	if (Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale")
		borderWidth = borderWidth * fullScreenAspect;
	if (borderWidth != 0)
	{
		var w:Number = right-left;
		var h:Number = bottom-top;
		fillRect(clp, _root.borderColor, left-borderWidth, top-borderWidth, w + borderWidth*2, borderWidth);
		fillRect(clp, _root.borderColor, left-borderWidth, top-borderWidth, borderWidth, h + borderWidth*2);
		fillRect(clp, _root.borderColor, left-borderWidth, bottom, w + borderWidth*2, borderWidth);
		fillRect(clp, _root.borderColor, right, top-borderWidth, borderWidth, h + borderWidth*2);
	}
}

// functions
function JSCall(jsCode)
{
	_trace('JSCall ExternalInterface.available: '+ExternalInterface.available);	
	if(ExternalInterface.available)
	{
		_trace('jsCode: '+jsCode);
		if(jsCode!=undefined)
		{
			ExternalInterface.call('function(){'+jsCode+'}');
		}
	}	
}

function OnJumpTimer():Void
{
	if (arguments.callee.jumpFrameNum/_root.fps < GetSecondsLoaded())
	//if (jumpTimerCount > 100)
	{
		_trace("jumpFrameNum = " + jumpFrameNum);
		clearInterval(jumpTimer);
		mcJumpLoading._visible = false;
		jumpTimer = 0;
		ButtonRealJump(arguments.callee.jumpFrameNum, arguments.callee.jumpPlayAfter);
	}
	else
	{
		jumpTimerCount++;
		var index=(jumpTimerCount/2)%8;
		mcJumpLoading.gotoAndStop(index+1);
	}
}

function ButtonJump(jumpFrameNum, jumpPlayAfter)
{
	_trace("this: " + this);
	if (jumpFrameNum != undefined && jumpPlayAfter != undefined)
	{
		if (jumpFrameNum/_root.fps < GetSecondsLoaded())
		//if (false)
		{
			_trace("realJump");
			ButtonRealJump(jumpFrameNum, jumpPlayAfter);
		}
		else
		{
			_trace("jumptimer");
			OnJumpTimer.jumpFrameNum = jumpFrameNum;
			OnJumpTimer.jumpPlayAfter = jumpPlayAfter;
			jumpTimer = setInterval(OnJumpTimer, 50);
			jumpTimerCount = 0;
			mcJumpLoading._visible = true;
		}
	}
}

function GetTwoDigits(i)
{
	return i>9 ? i:"0"+i;
}
function GetTimeString(seconds)
{
	var sec=seconds%60;
	var minutes=Math.floor(seconds/60);
	var min=minutes%60;
	var hours=Math.floor(minutes/60);
	var minStr=(min >= 10) ? min : "0" + min;
    var str:String =  GetTwoDigits(min)+ ":" +GetTwoDigits(sec);
	if(hours>0) str=hours+":"+str;
	return str;
}
function GetWidth(ctl)
{
	return ctl._visible?ctl._width:0;
}
function IsMouseOverControl(ctl,xmouse,ymouse):Boolean
{
	return ctl!=undefined && ctl!=null && ctl._x<=xmouse && xmouse<=(ctl._x+ctl._width) && ctl._y<=ymouse && ymouse<=(ctl._y+ctl._height);	
}
function GetStringWidth(s:String)
{
	var w:Number=0;
	if(	textField1==undefined)
	{
		createTextField("textField1", 101, 0, 0, 400, 100);
		textField1._visible=false;
		var my_fmt:TextFormat = new TextFormat();
		my_fmt.font = "Arial";
		my_fmt.size = 12;
		textField1.setNewTextFormat(my_fmt);
		textField1.autoSize = true;
//		var t:TextField;
	}

	if(textField1!=undefined)
	{
		textField1.text=s;
		w=textField1.textWidth;
//		_trace('w='+w);
	}	
	
	if(w<1)
	{
	    w=s.length*175/25;
	}
	return w;
}

function ResizeControls(fullscreenMode:Boolean)
{
	// steve pinter
	var targetWidth=initialWidth - borderWidth*2;
	//var targetWidth = movieWidth;
	if(fullscreenMode && _root.scaleMode!="noScale") targetWidth/=fullScreenAspect;
	//targetWidth += borderWidth*2;
	SetCenter(btnClickToStart);
	SetCenter(mcPausedIcon);
	SetCenter(mcOverlayLoading);
	SetCenter(mcJumpLoading);
	
	//RedrawBG(
	
	if(_root.showToolbar)
	{
		_trace('ResizeControls: '+targetWidth);
		//._y=_root.topToolbar?0:initialHeight-Controls._height;
		with(Controls)
		{
			//bgClip._width=targetWidth;
			bgClip._width = targetWidth;
			var x=0;
			x=SetPos(x,btnFirst);
			x=SetPos1(x,btnPlay);
			x=SetPos(x,btnPrev);
			btnPause._x=btnPlay._x;
			x=SetPos(x,btnStop);
			x=SetPos(x,btnNext);
			x=SetPos(x,btnLast);
			progressBar._x=x+progressBarOffset;
			x=targetWidth-1;
			x=SetPos2(x,btnFBLogo);
			x=SetPos2(x,chkHide);
			x=SetPos2(x,btnSound);
			x=SetPos2(x,btnFullScreen);
			x=SetPos2(x,lblTime);
			var w=x-progressBar._x-progressBarOffset;
//			_trace(w);
			with(progressBar.timeline)
			{		
				timelineRight._x=w-timelineRight._width;
				timelineFullRight._x=timelineRight._x;
				timelineMiddle._width=timelineRight._x-timelineMiddle._x;	
				timelineFullMiddle._width=0;
				_width=w;	
			}
			progressBar._width=w;
			ShowVolBar(false);
		}
	}
	OnResizeControls(fullscreenMode);
}

function ShowVolBar(val: Boolean)
{
	_trace('ShowVolBar: '+val);
	mc.volBar._visible=val;
	SetupVolControl();
}

function SetupVolControl()
{
	_trace('SetupVolControl');
	var x = Controls.btnSound._x;
	if (GetFullScaled())
		x *= fullScreenAspect;
	x += Controls._x;
	var y = _root.topToolbar ? Controls._y + GetToolbarHeight() : Controls._y - mc.volBar._height;
	mc.volBar._x = x;
	mc.volBar._y = y;
}

function RootOnMouseDown()
{
	_trace("RootOnMouseDown");
    if(mc.volBar._visible)
	{
		var b1=IsMouseOverVolumeBar();
		var b2=IsMouseOverSoundBtn();
//		_trace('>'+b1+' '+b2);
		if(!b1 && !b2) ShowVolBar(false);
	}
	if (movieState == 0 && _root.startingPlaybackMode==0)
	{
		_trace("btnClickToStart");
		OnClickToStart();
	}
	HideAboutBox();
}

// full screen

Controls.btnFullScreen.onRelease = function()
{
  if(Stage["displayState"] == "normal")
  {
	Stage["displayState"] ="fullScreen";
  }
  else if(Stage["displayState"] == "fullScreen")
  {
  	Stage["displayState"] = "normal";
  }
  DoPosUpdate();
}

// handlers
/*var myListener:Object = new Object();
myListener.onResize = function () {
    trace("Stage size is now " + Stage.width + " by " + Stage.height);
}
Stage.addListener(myListener);
// later, call Stage.removeListener(myListener)*/

mc.volBar.slider.onPress = function() 
{
	_trace('mc.volBar.slider.onPress');
	var x=mc.volBar.slider._x;
	var y=initialVolBarHeight-mc.volBar.slider._height;
	mc.volBar.slider.startDrag(true, x, 0, x, y);

	mc.volBar.slider.onEnterFrame=function()
	{
		with(mc.volBar)
		{
			var ratio = 100-Math.round(slider._y*100/(_height-slider._height));
			snd.setVolume(ratio);
			_trace(ratio);
		}
	}
}
mc.volBar.slider.onRelease=mc.volBar.slider.onReleaseOutside= function()
{	
//	_trace('mc.volBar.slider.onRelease');
	mc.volBar.slider.stopDrag();	
	mc.volBar.slider.onEnterFrame=null;
	ShowVolBar(false);	
}
Controls.btnSound.onRelease = function()
{	
	_trace('Controls.btnSound.onRelease volumeBar._visible: '+mc.volBar._visible);	
	ShowVolBar(!mc.volBar._visible);
}

var myListener:Object = new Object();
myListener.onFullScreen  = function (bFull:Boolean) 
{
	if(_root.showToolbar && _root.scaleMode!="noScale")
	{	
	  Stage.scaleMode=_root.scaleMode;
	  if(bFull)
	  {
		  var scale=100.0*fullScreenAspect;
		  Controls._yscale=scale;
		  Controls._xscale=scale;
		  scale*=0.99;
		  mc.volBar._yscale=scale;
		  mc.volBar._xscale=scale;
		  ResizeControls(true);
	  }
	  else
	  {
		  Controls.progressBar.scrub._x=scrubLeftOffset;
		  var scale=100.0;
		  Controls._yscale=scale;
		  Controls._xscale=scale;
		  mc.volBar._yscale=scale;
		  mc.volBar._xscale=scale;
		  ResizeControls(false);
	  }
	  SetLoadProgress();
	  SetProgress();
	  if(!bFull) Stage.scaleMode=_root.scaleMode;
	}
	OnFullScreen(bFull);
	
	var menuVisible=mainMenu!=null && mainMenu!=undefined && mainMenu._visible;
	if(menuVisible)
	{
		mainMenu._visible=false;
	}	
	HideAboutBox();
}
Stage.addListener(myListener);


// An alternate full screen function that uses hardware scaling to display the upper left corner of the stage in full screen.
/*function goScaledFullScreen()
{
   import flash.geom.Rectangle;
   var screenRectangle:Rectangle = new Rectangle();
   screenRectangle.x = 0;
   screenRectangle.y = 0;
   screenRectangle.width=Stage.width/2;
   screenRectangle.height=Stage.height/2; 
   Stage["fullScreenSourceRect"] = screenRectangle;
   Stage["displayState"] = "fullScreen";
}*/

function FullScreenResizeFix()
{
	if(Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale")
	{
		Stage.scaleMode=_root.scaleMode;
		Stage["displayState"] ="fullScreen";
		DoPosUpdate();
	}
}

function UpdateAboutPos()
{
	_trace("UpdateAboutPos");
	if (aboutBox==undefined || aboutBox==null)
		return;
	var w=200;
	var h=60;
	var w1 = GetFullScaled() ? w * fullScreenAspect : w;
	var h1 = GetFullScaled() ? h * fullScreenAspect : h;
	
	var x = Controls.btnFBLogo._x + Controls.btnFBLogo._width;
	if (GetFullScaled())
		x *= fullScreenAspect;
	x += Controls._x - w1 - 1;
	var y = _root.topToolbar ? Controls._y + GetToolbarHeight() : Controls._y - h1 - 1;
	
	var scale = GetFullScaled() ? fullScreenAspect * 100.0 : 100.0;
	_trace("UpdateAboutPos: x y scale" + x + " " + y + " " + scale);
	aboutBox._y=y;
	aboutBox._x=x;		
	aboutBox._yscale=scale;
	aboutBox._xscale=scale;
	aboutBox._visible=true;
}

// menu routines
// Steve Pinter:
// I have rewrited menu code using TextFiels because 
// Menu class has some problems with events.

function UpdateMenuPos()
{
	_trace("UpdateMenuPos()");
	if (mainMenu == undefined || mainMenu == null)
	{
		_trace("mainMenu undefined");
		return;
	}
	var menuHeight=42;
	var menuWidth1 = GetFullScaled() ? menuWidth * fullScreenAspect : menuWidth;
	var menuHeight1 = GetFullScaled() ? menuHeight * fullScreenAspect : menuHeight;
	
	var x=Controls.btnFBLogo._x+Controls.btnFBLogo._width;
	//if(x<0) x=0;
	if (GetFullScaled())
		x *= fullScreenAspect;
	x += Controls._x -menuWidth1 - 1;
	var y = _root.topToolbar ? Controls._y + GetToolbarHeight() : Controls._y - menuHeight1 - 1;
	
	var scale = GetFullScaled() ? fullScreenAspect * 100.0 : 100.0;
	mainMenu._xscale = scale;
	mainMenu._yscale = scale;
	mainMenu._x = x;
	mainMenu._y = y;
	//mainMenu._visible = true;
}

function getMenuItemByPos(xx, yy)
{
	var x1 = mainMenu.firstItem._x;
	var w1 = mainMenu.firstItem._width;
	var y1 = mainMenu.firstItem._y;
	var h1 = mainMenu.firstItem._height;
	
	var x2 = mainMenu.secondItem._x;
	var w2 = mainMenu.secondItem._width;
	var y2 = mainMenu.secondItem._y;
	var h2 = mainMenu.secondItem._height;
	
	if ((xx>=x1) && (xx<x1+w1) && (yy >=y1) && (yy<y1+h1))
		return 1;
	if ((xx>=x2) && (xx<x2+w2) && (yy >=y2) && (yy<y2+h2))
		return 2;
	return 0;
}

function menuClick()
{
	var menuItem = getMenuItemByPos(mainMenu._xmouse, mainMenu._ymouse);
	if (!mainMenu._visible)
		return;
	if (menuItem == 1)
	{
		_trace("menuClick-showaboutBox");
		ShowAboutBox();
	}
	else if (menuItem == 2)
	{
		getURL(_root.str4,"_blank");
	}
	_trace("menuItem = " + menuItem);
	mainMenu._visible = false;
}

function redrawMenuItem(item, sel)
{
	var bgColor = 0xFFFFFF;
	var bgColor1 = 0xE3FFD6;
	var txtColor = 0x4800FF;
	var txtColor1 = 0x555555;
	item.backgroundColor = (sel) ? bgColor1 : bgColor;
	item.textColor = (sel) ? txtColor1 : txtColor;
}

function menuOver()
{	
	var menuItem = getMenuItemByPos(mainMenu._xmouse, mainMenu._ymouse);
	redrawMenuItem(mainMenu.firstItem, menuItem == 1);
	redrawMenuItem(mainMenu.secondItem, menuItem == 2);
}

function CreateMenu()
{
	mainMenu._visible = false;
	_trace("Create a Menu instance and add some items");
	// Create a Menu instance and add some items
	menuWidth=Math.max(GetStringWidth(_root.str1),GetStringWidth(_root.str2))+43;
	menuHeight = 45;
	
	// create clip
	mainMenu._width = menuWidth;
	mainMenu._height = menuHeight;
	mainMenu.onRelease = menuClick;
	mainMenu.onMouseMove = menuOver;
	fillRect(mainMenu, 0x999999, 0, 0, menuWidth, menuHeight);
	fillRect(mainMenu, 0xffffff, 2, 2, menuWidth-4, menuHeight-4);
		
	mainMenu.createTextField("firstItem",501, /*x, y,*/ 2, 2, menuWidth-4, menuHeight/2-2);
	mainMenu.firstItem.multiline=true;
	mainMenu.firstItem.mouseWheelEnabled=false;
	mainMenu.firstItem.wordWrap=true;
	mainMenu.firstItem.selectable=false;
	mainMenu.firstItem.border=false;
	mainMenu.firstItem.background = true;
	redrawMenuItem(mainMenu.firstItem, false);
	mainMenu.firstItem.text= _root.str1;
	
	mainMenu.createTextField("secondItem", 502, 2, menuHeight/2+1, menuWidth-4, menuHeight/2-2);
	mainMenu.secondItem.multiline=true;
	mainMenu.secondItem.mouseWheelEnabled=false;
	mainMenu.secondItem.wordWrap=true;
	mainMenu.secondItem.selectable=false;
	mainMenu.secondItem.border=false;
	mainMenu.secondItem.background = true;
	redrawMenuItem(mainMenu.secondItem, false);
	mainMenu.secondItem.text = _root.str2;
}

// handlers
Controls.btnFBLogo.onRelease = function()
{
	_trace('btnFBLogo.onRelease');
	_trace("mainMenu._visible = " + mainMenu._visible);
	if (mainMenu._visible)
	{
		mainMenu._visible = false;
	}
	else
	{
		mainMenu._visible = true;
		UpdateMenuPos();
	}
}

function CreateAboutBox()
{
	_trace("CreateAboutBox " + aboutBox);
	// create about box
	aboutBox.multiline=true;
	aboutBox.mouseWheelEnabled=false;
	aboutBox.wordWrap=true;
	aboutBox.selectable=false;
	aboutBox.border=true;
	
	/*	var my_fmt:TextFormat = new TextFormat();
	my_fmt.font='Arial';
	my_fmt.size=10;
	mc.aboutBox.setNewTextFormat(my_fmt);*/
	var txt='FlashBack version: '+_root.fbVer;
	txt+='\nSWF Toolbar version: '+_root.toolbarVersion;			
	var fpVer=getVersion();// getVersion returns string like 'WIN 8,0,1,0'
	txt+='\nFlash Player version: '+fpVer;					
//		aboutBox.appendText(txt);
	aboutBox.text=txt;
	aboutBox._visible = false;
}

function ShowAboutBox()
{
	_trace('ShowAboutBox');
	aboutBox._visible=true;
	UpdateAboutPos();
}

function HideAboutBox()
{
	_trace('HideAboutBox');
	aboutBox._visible=false;
}

var prevTime=0;

function UpdateLoadingMeter()
{
	if(movieLoaded) showMovieLoadingOverlay=false;
	else
	{
		if(isPlaying)
		{
			if((timerCount%10)==0)
			{
			  var t=GetCurrentTime();
			  showMovieLoadingOverlay=t-prevTime<0.1;
			  prevTime=t;
			}
		}	
		if(_root.startFrame>0) showMovieLoadingOverlay=true;
		if(showMovieLoadingOverlay && (btnClickToStart._visible || mcPausedIcon._visible)) showMovieLoadingOverlay=false;
	}

	if(mcOverlayLoading._visible!=showMovieLoadingOverlay) mcOverlayLoading._visible=showMovieLoadingOverlay;
	if(showMovieLoadingOverlay)
	{
		var index=(timerCount/2)%8;
		mcOverlayLoading.gotoAndStop(index+1);
	}
}
function SetLoadProgress()
{
	_trace('SetLoadProgress');
	if(_root.showToolbar && Controls.progressBar._visible)
	{
		var w=GetMovieLoadProgress();
//		with(Controls.progressBar.timeline)
		{
			Controls.progressBar.timeline.timelineFullMiddle._width=Controls.progressBar.timeline.timelineMiddle._width*w;
		}
	}
}
function CheckWidth()
{
	_trace('CheckWidth');
//	_trace('CheckWidth width='+width);
//	_trace(' _width='+_width);
//	_trace(' Stage.width='+Stage.width);
	var mcWidth=initialWidth;//Stage.width
	with(Controls)
	{
	  var ar:Array=Array(chkHide,btnFBLogo,btnSound,btnFullScreen,lblTime,btnStop,btnLast,btnPrev,btnNext);
	  var w=btnFirst._width+btnPlay._width+timelineMinWidth;
//	  _trace(' w='+w);
	  for(var i=0;i<ar.length;i++)
	  {
		  var ctl=ar[i];
		  if(ctl._visible)
		  {
			 w+= ctl._width;
		  }
	  }	
//	  _trace(' w='+w);
	  for(i:Number =0;i<ar.length && w>mcWidth;i++)
	  {
		  var ctl=ar[i];
		  if(ctl._visible)
		  {
			 ctl._visible=false;
			 w-= ctl._width;
		  }
	  }	
	}
}

function FinalActions()
{
	_trace('FinalActions');
//	_trace('expiryDate='+_root.expiryDate);
//	_trace('pwd='+_root.pwd);
	UpdateBackground(Stage["displayState"] == "fullScreen");
	if(_root.expiryDate.length>0)
	{
		//_trace("expirityDate != 0");
		Controls._visible=false;
		mcOverlayLoading._visible=false;		
		ifExpiryDateExists();
	}
	else if(_root.pwd.length>0)
	{
		//_trace("pwd != 0");
		Controls._visible=false;
		mcOverlayLoading._visible=false;		
		ifPasswordExists();
	}
	else
	{
		trace('showToolbar='+_root.showToolbar);
//		trace('Controls='+Controls);
//		trace('mcOverlayLoading='+mcOverlayLoading);
		passwordChecked=true;
		Controls._visible=_root.showToolbar;
		mcOverlayLoading._visible=true;
		if(_root.showToolbar) CheckWidth();
		ResizeControls(false);
		if(_root.showToolbar) SetLoadProgress();
		intervalID = setInterval(OnTimer, timerInterval);
	}
}

// actions
Stage.scaleMode=_root.scaleMode;
/*_root._xscale = 100;
_root._yscale = 100;*/

Stage.showMenu=false;
_global.style.setStyle("themeColor","darkGray");
var snd: Sound=new Sound();
snd.setVolume(100);
ShowVolBar(false);
DoPosUpdate();

_trace('--common eof--');