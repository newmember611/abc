import flash.external.*;
import mx.controls.Menu;
import flash.geom.*;
isSingleSwf=true;
#include "flashvars.as"
if(!CheckFPVersion()) return;
#include "common.as"

_trace('--commonSingle--');
mcWhiteRect._visible=false;
//_trace('this.width='+this._width);
//_trace('_root.width='+_root._width);
if(parent!=undefined) _trace('parent._width='+parent._width);

// constants
var startMovieFrame=2;

// variables
var pauseFlagFrame=0;

// initialisation
Controls.chkHide.lblText.text=_root.str3;

// visibility
_trace("Controls._visible = _root.showToolbar = " + _root.showToolbar);
Controls._visible=_root.showToolbar;
Controls.btnStop._visible=_root.showStopButton;
Controls.btnNext._visible=_root.showNextButton;
Controls.btnPrev._visible=_root.showPrevButton;
Controls.btnLast._visible=_root.showLastButton;
Controls.progressBar._visible=_root.showTimeline;
Controls.lblTime._visible=_root.showTimer;
Controls.btnFullScreen._visible=_root.showFullScreen;
Controls.btnSound._visible=_root.showVolumeBar;
Controls.chkHide._visible=_root.showAutoHide;
Controls.btnFBLogo._visible=_root.showFBLogo;
Controls.chkHide.uncheckAutoHide._visible=!_root.autoHide;
with(Controls.progressBar.timeline)
{
	timelineFullLeft._visible=false;	
	timelineFullMiddle._visible=false;
	timelineFullRight._visible=false;
}

// functions

function UpdateToolbarPos()
{
	_trace("UpdateToolbarPos()");
	var pt:Point = GetMCPos();
	pt.x = borderWidth - pt.x;
	pt.y = borderWidth - pt.y;	
	if (_root.topToolbar && _root.showToolbar)
	{
		if (!_root.autoHideToolbar)
			pt.y += toolbarHeight - GetToolbarHeight();
	}
	else
		pt.y += videoHeight - GetToolbarHeight() + GetToolbarHeightForMovieSize();
	Controls._x = pt.x;
	Controls._y = pt.y;
	_trace("Controls._x = " + Controls._x);
	_trace("Controls._y = " + Controls._y);
}

function GetMCPos()
{
	_trace("GetMCPos()");
	_trace("borderWidth: " + borderWidth);
	_trace("autoscrollShiftX = " + autoscrollShiftX);
	_trace("autoscrollShiftY = " + autoscrollShiftY);
	var pt:Point = new Point(autoscrollShiftX + borderWidth, autoscrollShiftY + borderWidth);
	if (_root.topToolbar)
	{
		if (_root.autoHideToolbar)
			pt.y -= (GetToolbarHeightForMovieSize());
		else
			pt.y -= (GetToolbarHeightForMovieSize() - GetToolbarHeight());
	}
		
	_trace("MCPos: " + pt.x + " " + pt.y);
	return pt;
}


function UpdateMCPos()
{
	_trace("UpdateMCPos()");
	var pt:Point = GetMCPos();
	mc._x = pt.x;
	mc._y = pt.y;
}

function UpdateBackground(bFull:Boolean)
{
	_trace("UpdateBackground()");
	
	var pt:Point = GetMCPos();
	pt.x = borderWidth - pt.x;
	pt.y = borderWidth - pt.y;
	var pt2:Point = new Point(pt.x + videoWidth, pt.y + videoHeight);
	if (_root.topToolbar)
	{
		if (!_root.autoHideToolbar)
			pt.y += toolbarHeight - GetToolbarHeight();
			//pt.y -= (GetToolbarHeightForMovieSize() - GetToolbarHeight());
	}
	else
	{
		if (!_root.autoHideToolbar)
			pt2.y += GetToolbarHeight();
	}
	//var pt2:Point = new Point(pt.x + videoWidth, pt.y + videoHeight);
	//if (!_root.topToolbar)
	//{
		//pt2.y += GetToolbarHeightForMovieSize();
	//}
	RedrawBGWithBorder(bFull, pt.x, pt.y, pt2.x, pt2.y);
}

function FBStopMovie()
{
	_trace('FBStopMovie');
//	fbPauseFlag=true;
	pauseFlagFrame=mc._currentframe;
	if(pauseFlagFrame==startMovieFrame) ffp=true;
	StopMovie();
}

function FBPlayMovie()
{
	_trace('FBPlayMovie');
	if(btnClickToStart._visible) OnClickToStart();
	else PlayMovie();	

}

function FBDelayMovie()
{
	_trace('FBDelayMovie');
	DelayMovie();
}



function OnFullScreen(bFull:Boolean) 
{
	if(!bFull || _root.scaleMode=="noScale")
	{
		if(mcWhiteRect._visible) mcWhiteRect._visible=false;
	}	
	UpdateBackground(bFull);
}


function drawRect(clp:MovieClip, left:Number, top:Number, w:Number, h:Number)
{
	clp.lineStyle(5,0x00FF00,100);
	clp.moveTo(left,top);
	clp.lineTo(left+w, top);
	clp.lineTo(left+w, top+h);
	clp.lineTo(left, top+h);
	clp.lineTo(left, top);
}



function DoPosUpdate()
{
	_trace('DoPosUpdate');
	var hgapScaled=hgap*fullScreenAspect;
	var dx=- autoscrollShiftX;
	var dy=- autoscrollShiftY;

	UpdateMCPos();
	UpdateToolbarPos();
	var showWhiteRect:Boolean=false;
	// steve pinter
	if(Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale")
	{
		if(_root.topToolbar)
		{
			showWhiteRect=true;
		}
	}
	if(showWhiteRect)
	{
		mcWhiteRect._x=Controls._x;
		mcWhiteRect._width=Controls._width;
		mcWhiteRect._y=0;
		mcWhiteRect._height=Controls._y;
		mcWhiteRect._visible=true;
	}
	else if(mcWhiteRect._visible) mcWhiteRect._visible=false;	
	
	if(btnClickToStart._visible) SetCenter(btnClickToStart);
	if(mcPausedIcon._visible) SetCenter(mcPausedIcon);
	if(mcOverlayLoading._visible) SetCenter(mcOverlayLoading);
	
	var menuVisible=mainMenu!=null && mainMenu!=undefined && mainMenu._visible;
	if (menuVisible)
		UpdateMenuPos();
	
	var volBarVisible=mc.volBar!=null && mc.volBar!=undefined;// && mc.volBar._visible;
	if (volBarVisible)
		SetupVolControl();
	
	var aboutBoxVisible = aboutBox != undefined && aboutBox != null && aboutBox._visible;
	if (aboutBoxVisible)
		UpdateAboutPos();
	if(_root.debugMode>0)
	{
		mc.lblDebug._x=dx;
		mc.lblDebug._y=toolbarHeight+dy;
	}	
	UpdateBackground(Stage["displayState"] == "fullScreen");
}

function GetLoadProgress()
{
	var tot=mc.getBytesTotal();
	if(tot==undefined || tot<=0) return 0;
	var d=mc.getBytesLoaded()/tot;	
	if(d<0) d=0;
	else if(d>1) d=1;
	return d;
}		

function GetBufferTime()
{
	var t=0;
	if(mc._totalframes!=undefined && mc._totalframes>0)
	{
		t=(mc._framesloaded-mc._currentframe) * duration/mc._totalframes;
	}
	return t;
}

function GetCurrentTime()
{
	var t=0;
	if(mc._totalframes!=undefined && mc._totalframes>0)
	{
		t=mc._currentframe * duration/mc._totalframes;
	}
	return t;
}

function OnMovieLoaded()
{
	_trace('OnMovieLoaded');
	showMovieLoadingOverlay=false;
	if(_root.showToolbar)
	{
		with(Controls.progressBar.timeline)
		{
			timelineFullRight._visible=true;
		}	
	}
	if(_root.startingPlaybackMode==1)
	{
		if(!playStarted) btnClickToStart._visible=true;
		mcPausedIcon._visible=false;
	}
	if(_root.startingPlaybackMode!=1 && !playStarted) StartPlay();
	
	CheckStartFrame();
}
function SetTime()
{
	if(_root.showToolbar)
	{
// _trace("SetTime");
		  var sec=Math.floor(mc._currentframe/_root.fps);
		  var tsec=Math.floor(mc._totalframes/_root.fps);
		  Controls.lblTime.text=GetTimeString(sec)+"/"+GetTimeString(tsec);
	}
}

function StartPlay()
{
	_trace('StartPlay');
/*	mc.VerifySecurityCode(_root.specialcode);
	mc.gotoAndPlay(startMovieFrame);
	isPlaying=true;
	UpdateControls();*/
	RemoveDelay();
	playStarted=true;
	if(ffp) PauseMovie();
	else PlayMovie();
}

function PlayMovie()
{
	_trace("PlayMovie");	
	if(_root.startFrame>0) return;
	//check for security code
	RemoveDelay();
	mc.VerifySecurityCode(_root.specialcode);
	mc.play();
	isPlaying=true;
	UpdateControls();
}
function StopMovie()
{
	RemoveDelay();
	mc.gotoAndStop(mc._currentframe);
	isPlaying=false;
	UpdateControls();
}

function PauseMovie()
{
	RemoveDelay();
	mc.stop();
    isPlaying=false; 
	UpdateControls();
}

var delayId = 0;

function DelayMovie()
{
	_trace("pauseduration: " + pauseduration);
	RemoveDelay();
	if (pauseduration)
	{
		delayId = setInterval(RemoveDelay, pauseduration);
		mc.stop();
		isPlaying=false;
	}
}

function RemoveDelay()
{
	if (delayId)
	{
		clearInterval(delayId);
		delayId = 0;
		mc.play();
		isPlaying=true;
	}
}

function IsMovieEnd():Boolean
{
	if(!movieLoaded) return false;
	return mc._currentframe==mc._totalframes;
}
function UpdateControls()
{	
	var curFrame=mc._currentframe;
	if(curFrame!=undefined && curFrame==mc._totalframes)
	{
	  if(isPlaying)
	  {
		    if(_root.loopPlayback)
			{
				mc.gotoAndPlay(startMovieFrame);
			}
			else
			{
    		  mc.gotoAndStop(curFrame);
    	      isPlaying=false;
			}
	  }
	}    

	if(pauseFlagFrame!=curFrame) pauseFlagFrame=0;
	mcPausedIcon._visible=!btnClickToStart._visible && !isPlaying && toolbarLoaded && _root.showPausedOverlay && !IsMovieEnd() && pauseFlagFrame==0;

	if(mcPausedIcon._visible) SetCenter(mcPausedIcon);

	if(!_root.showToolbar) return;
	Controls.btnPlay.enabled=!IsMovieEnd();
	
	Controls.btnFirst.enabled=curFrame>startMovieFrame;
	Controls.btnLast.enabled=curFrame<mc._totalframes;
	Controls.btnPrev.enabled=curFrame>startMovieFrame;
	Controls.btnNext.enabled=curFrame<mc._totalframes;
	Controls.btnPlay._visible = !isPlaying;
	Controls.btnPause._visible = isPlaying;
	SetProgress();
}
function SetProgress()
{
	if(_root.showToolbar && !scrubDragged && Controls.progressBar._visible)
	{
		with(Controls.progressBar)
		{
			var pr=0;
			pr=mc._totalframes>1?(mc._currentframe-1)/(mc._totalframes-1): 0;
			
			if(pr>=0 && pr<=1)
			{
			  scrub._x=scrubLeftOffset+(_width-scrubOffset)*pr;
			}
		}
	}
}

function ProcessAdditionalParamsForButtonsJScript()
{
	_trace("ProcessAdditionalParamsForButtonsJScript");
	_trace("jsCode: " + jsCode);
	this["JSCall" + buttonId] = function()
	{
		JSCall(arguments.callee.jsCode);
	}
	this["JSCall" + buttonId].jsCode = jsCode;
}

function ProcessAdditionalParamsForButtons()
{	
	_trace("ProcessAdditionalParamsForButtons");
	_trace("jumpFrameNum: " + jumpFrameNum);
	_trace("jumpPlayAfter: " + jumpPlayAfter);
	// create function with name ButtonJump(buttonId)
	this["ButtonJump" + buttonId] = function()
	{
		ButtonJump(arguments.callee.jumpFrameNum, arguments.callee.jumpPlayAfter);
	}
	this["ButtonJump" + buttonId].jumpFrameNum = jumpFrameNum;
	this["ButtonJump" + buttonId].jumpPlayAfter = jumpPlayAfter;
}

function GetMovieLoadProgress()
{
  return mc._framesloaded==undefined? 0 : mc._framesloaded/mc._totalframes;
}

function GetSecondsLoaded()
{
	if (movieState<1) return 0;
	var secs = 0;
	secs = mc._framesloaded==undefinde ? 0 : mc._framesloaded / _root.fps;
	if (secs < 0)
		secs = 0;
	return secs;
}

function ButtonRealJump(jumpFrameNum, jumpPlayAfter)
{
	// +2 because single swf also has additional frames at the beginning
	if (jumpPlayAfter)
	{
		gotoAndPlay(jumpFrameNum + 2);
	}
	else
	{
		gotoAndStop(jumpFrameNum + 2);
	}
}


function SetProgressByCoord(x)// scrub._x 
{
	_trace('SetProgressByCoord x='+x);
	if(_root.showToolbar && Controls.progressBar._visible)
	{
		var pr=(x-scrubLeftOffset)/(Controls.progressBar._width-scrubOffset);

		var frameIndex = Math.round(mc._totalframes*pr);
		if(frameIndex<1) frameIndex=1;
		if(frameIndex>=startMovieFrame && frameIndex<=mc._totalframes)
		{
			RemoveDelay();
			_trace(frameIndex);
			if(isPlaying) mc.gotoAndPlay(frameIndex);
			else mc.gotoAndStop(frameIndex);
			UpdateControls();
		}
	}
}
function SetPos1(x,ctl)
{
	ctl._x=x;
	x+=ctl._width;
	return x;
}
function SetPos(x,ctl)
{
	if(ctl._visible)
	{
		ctl._x=x;
		x+=ctl._width;
	}
	return x;
}
function SetPos2(x,ctl)
{
	if(ctl._visible)
	{
		x-=ctl._width;
		ctl._x=x;
	}
	return x;
}

function SetCenter(ctl)
{	
	ctl._x=((initialWidth-ctl._width)/2)-mc._x;
	ctl._y=((initialHeight-ctl._height)/2)-mc._y;	
}

function OnResizeControls(fullscreenMode:Boolean)
{
	if(_root.scaleMode!="noScale")
	{
		DoPosUpdate();
	}
}

function OnClickToStart()
{
	btnClickToStart._visible=false;
	StartPlay();
}

// Handlers
mc.onMouseDown=function()
{
    _trace('mc.onMouseDown');
	//if(hideMenuClick){ hideMenuClick=false;}
	var menuVisible=mainMenu!=null && mainMenu!=undefined && mainMenu._visible;
	_trace('pauseByClickingOnMovie: '+_root.pauseByClickingOnMovie);
	_trace('playStarted: '+playStarted);
/*	if (menuVisible)
	{
		menuClick();
	}
	else
	{*/
		if(_root.pauseByClickingOnMovie && playStarted && !mc.volBar._visible && !menuVisible)
		{
		  var isMouseOver=IsMouseOverToolbar();
		  if(!isMouseOver)
		  {
			if(ignoreClickFrame==mc._currentframe)
			{
				return;
			}
			RemoveDelay();
			if(isPlaying)
			{
				PauseMovie();
			}
			else
			{
				PlayMovie();
			}
		  }
		}
		RootOnMouseDown();
//	}
}


Controls.progressBar.scrub.onPress = function() 
{
	_trace('Controls.progressBar.scrub.onPress');
	var y=Controls.progressBar.scrub._y;
	var w=Controls.progressBar._width-scrubOffset;
	var x=Controls.progressBar._x;
	
	this.startDrag(false, scrubLeftOffset, y, scrubLeftOffset+w, y);
	scrubDragged=true;
	Controls.progressBar.scrub.onEnterFrame=function()
	{
      SetProgressByCoord(Controls.progressBar.scrub._x);
	}
}

Controls.progressBar.timeline.onPress= function() 
{
	_trace('Controls.progressBar.timeline.onPress');
	RemoveDelay();
	if(!scrubDragged)
	{
	  var xpos=Controls.progressBar._xmouse-Controls.progressBar.scrub._width/2;
	  SetProgressByCoord(xpos);
	}
}

Controls.progressBar.scrub.onRelease=Controls.progressBar.scrub.onReleaseOutside= function()
{
	this.stopDrag();	
	scrubDragged=false;
	Controls.progressBar.scrub.onEnterFrame=null;
}

Controls.chkHide.onRelease = function()
{
	_root.autoHide=!_root.autoHide;
	Controls.chkHide.uncheckAutoHide._visible=!_root.autoHide;
}

Controls.btnFirst.onRelease = function()
{
	RemoveDelay();
  	mc.gotoAndStop(startMovieFrame);
	isPlaying=false;
	UpdateControls();
}
Controls.btnNext.onRelease = function()
{
	RemoveDelay();
	mc.gotoAndStop(mc._currentframe+1);
	isPlaying=false;
	UpdateControls();
}
Controls.btnPrev.onRelease = function()
{
	RemoveDelay();
	mc.gotoAndStop(mc._currentframe-1);
	isPlaying=false;
	UpdateControls();
}
Controls.btnLast.onRelease = function()
{
	RemoveDelay();
	mc.gotoAndStop(mc._totalframes);
	isPlaying=false;
	UpdateControls();
}
Controls.btnPlay.onRelease = function()
{
	RemoveDelay();
	OnButtonPlayClicked();
}

function OnButtonPlayClicked()
{
	if(btnClickToStart._visible) OnClickToStart();
	else
	{
		if(playStarted) PlayMovie();
		else StartPlay();
	}
}
Controls.btnPause.onRelease = function()
{
	RemoveDelay();
	PauseMovie();
}

Controls.btnStop.onRelease = function()
{
	RemoveDelay();
  StopMovie();
}

function IsMouseOverSoundBtn():Boolean
{
	var xmouse=_xmouse-Controls._x;
	var ymouse=_ymouse-Controls._y;
	if(Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale")
	{
		xmouse/=fullScreenAspect;
		ymouse/=fullScreenAspect;
	}
	var ctl=Controls.btnSound;
//	_trace('>>'+_xmouse+' '+_ymouse+' '+Controls._x+' '+Controls._y);
	return _root.showToolbar && IsMouseOverControl(ctl,xmouse,ymouse);	
}

function IsMouseOverVolumeBar():Boolean
{
	return _root.showToolbar && IsMouseOverControl(mc.volBar,_xmouse,_ymouse);
}

function IsMouseOverToolbar():Boolean
{
	return _root.showToolbar && IsMouseOverControl(Controls,_xmouse,_ymouse);
}

function IsMouseOverMenu():Boolean
{
	return _root.showToolbar && IsMouseOverControl(mainMenu,_xmouse,_ymouse);
}

function checkMousePos()
{
	if(_root.showToolbar)
	{
			var isMouseOver=IsMouseOverToolbar();
			//_trace(isMouseOver+" "+_root.autoHide);
			// steve pinter
			//if(_root.autoHide && Controls._visible && !isMouseOver) Controls._visible=false;
		    //if(!Controls._visible && isMouseOver) Controls._visible=true;
	}
			
}
	
/*onMouseMove=function()
{
  if(passwordChecked)
  {
    checkMousePos();
  }
}*/

onMouseMove=function()
{
	if(passwordChecked)
	{
	 	checkMousePos();
		CreateToolbarTimer();
	}
}

btnClickToStart.onRelease = function()
{	
  OnClickToStart();
}

// timer
var mcPrevFrame;
var mcInitialised=false;
var toolbarLoaded=false;
var movieLoaded=false;
var playStarted=false;
var timerCount=0;
var showMovieLoadingOverlay=true;
var startMovieFrameLoaded=false;

function OnTimer():Void 
{ 
    if(stopTimer) return;
    timerCount++;
	
	if(mc._currentframe!=undefined)
	{
		if(!toolbarLoaded && mc._framesloaded>=startMovieFrame-1) 
		{
			toolbarLoaded=true;
			OnToolbarLoaded();
		}
		if(!startMovieFrameLoaded && mc._framesloaded>=startMovieFrame)
		{
			startMovieFrameLoaded=true;
			_trace('startMovieFrameLoaded');
			if(_root.startingPlaybackMode!=2) mc.gotoAndStop(startMovieFrame);// first frame pause fix
			if(_root.startingPlaybackMode==1) snd.setVolume(100);
		}
		if(startMovieFrameLoaded && mc._currentframe!=mcPrevFrame)
		{
			mcPrevFrame=mc._currentframe;
			MovieOnEnterFrame();
		}		  
		if(!movieLoaded)
		{
			SetLoadProgress();
			if(mc._framesloaded==mc._totalframes)
			{
			  movieLoaded=true;
			  OnMovieLoaded();
			  //clearInterval(intervalID);
			}
		}
	}

//	_trace('--- startMovieFrameLoaded='+startMovieFrameLoaded+' firstMovieFrameLoaded='+firstMovieFrameLoaded);
	if(startMovieFrameLoaded && !movieLoaded && _root.startingPlaybackMode!=1 && !playStarted) CheckPreload();

	UpdateLoadingMeter();
}

function OnToolbarLoaded()
{
	_trace('OnToolbarLoaded');

	with(Controls.progressBar.timeline)
	{
		timelineFullLeft._visible=true;	
		timelineFullMiddle._visible=true;
	}

	duration=mc._totalframes/_root.fps;
	_trace('duration='+duration);

	if(_root.showToolbar && Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale")
	{
		ResizeControls(true);
	}
	UpdateControls();
}

function MovieOnEnterFrame()
{
	_trace('MovieOnEnterFrame');
//_trace('MovieOnEnterFrame: '+mc._currentframe);
  if(_root.pauseByClickingOnMovie)
  {
	  if(mc.fb_pobutton!=undefined)
	  {
		  //mc.fb_pobutton.onRelease = function(){};//_trace('fb_pobutton.onRelease');}
		  ignoreClickFrame=mc._currentframe;
	  }
	  if(mc.fb_pausebutton2!=undefined)
	  {
//		 mc.fb_pausebutton.onRelease = function(){}//_trace('fb_pausebutton.onRelease');}
		  ignoreClickFrame=mc._currentframe;
	  }
	  if(mc.fb_pobutton_jump!=undefined)
	  {
//		   _trace('fb_pobutton_jump='+mc.fb_pobutton_jump);
		  ignoreClickFrame=mc._currentframe;
/*		  var origHandler=mc.fb_pobutton_jump.onPress;
		   _trace('origHandler='+mc.fb_pobutton_jump.onRelease);
		   _trace('origHandler2='+mc.fb_pobutton_jump.onPress);*/
		 mc.fb_pobutton_jump.onRelease = mc.fb_pobutton_jump.onPress=function()
		 {
//			 _trace('fb_pobutton_jump.onPress');
//			 origHandler();
			 StopMovie();
		 }
	  }
  }

	if(_root.showToolbar)
	{
		UpdateControls();
		if(_root.showTimer) SetTime();
		checkMousePos();
	
		if(Stage["displayState"] == "fullScreen" )
		{
			if(_root.scaleMode!="noScale" && Stage.scaleMode=="noScale")
			  Stage.scaleMode=_root.scaleMode;
		}
		else if(Stage.scaleMode!=_root.scaleMode) Stage.scaleMode=_root.scaleMode;
	}
	
	UpdatePauseButtonPos();
	
	CheckStartFrame();
	//RedrawBG(true, 0,0,0,0);
}

function CheckStartFrame()
{
	if(_root.startFrame>0)
	{
		if(mc._framesloaded!=undefined) 
		{
			var targetFrame=startMovieFrame+_root.startFrame-1;
			if(targetFrame > mc._totalframes) targetFrame=mc._totalframes;
			if(targetFrame < mc._framesloaded || mc._framesloaded==mc._totalframes)
			{
				_trace('startFrame '+_root.startFrame);
				_root.startFrame=0;	
				mc.gotoAndStop(targetFrame);
				if(_root.startingPlaybackMode==2) PlayMovie();
				else PauseMovie();
			}
		}
	}
}

function UpdatePauseButtonPos()
{
	if(fb_pausebutton!=undefined && mc.fb_pausebutton._visible)
	{
		fb_pausebutton._x = -autoscrollShiftX;
		fb_pausebutton._y =  - autoscrollShiftY;//(showToolbar && _root.topToolbar ? toolbarHeight : 0)
/*		_trace('autoscrollShiftY='+autoscrollShiftY+' l0.y='+mc._y+' fb_p._h='+fb_pausebutton._height);
		if(showToolbar && Stage["displayState"] == "fullScreen" && scaleMode!="noScale")
		{
		//		  var y=0;//hgap*fullScreenAspect;
		//		  if(_root.topToolbar) y+=Controls._height;
		//		  mc.fb_pausebutton._y=y- mc._y;
		}*/
	}	
}

function CheckPreload()
{
	_trace('CheckPreload duration='+duration);
	if(showMovieLoadingOverlay && duration!=undefined && duration>0)
	{
		var curTime=timerCount*timerInterval/1000;
		_trace('curTime='+curTime);
		var d=GetLoadProgress();	
		_trace('d='+d);
		if(d>0)
		{
			if(_root.preloadPercent>0)
			{
				if(_root.preloadPercent<=d*100) StartPlay();
			}
			else
			{
				var est=curTime*(1-d)/d;
				_trace('d='+d+' est='+est+' tot='+duration);
				if(est<duration)
				{
					StartPlay();
				}
			}
		}
	}
}

// actions
if(_root.startingPlaybackMode==1)
{
	snd.setVolume(0);
	mc.stop();
}
if(_root.startingPlaybackMode==2)
{
	mc.stop(); // first frame pause fix
}
mc._quality = 'best';
FinalActions();

_trace('--commonSingle eof--');
