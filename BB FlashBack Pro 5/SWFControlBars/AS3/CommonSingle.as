import mx.controls.Menu;
isSingleSwf=true;
#include "flashvars.as"
if(!CheckVersion()) return;
#include "common.as"

_trace('--commonSingle--');
mcWhiteRect._visible=false;
var mc:MovieClip=this;

// constants
var startFrame=2;

// variables
var pauseFlagFrame=0;

// initialisation
Controls.chkHide.lblText.text=_root.str3;

// visibility
_root.Controls._visible=_root.showToolbar;
_root.Controls.btnStop._visible=_root.showStopButton;
_root.Controls.btnNext._visible=_root.showNextButton ;
_root.Controls.btnPrev._visible=_root.showPrevButton ;
_root.Controls.btnLast._visible=_root.showLastButton;
_root.Controls.progressBar._visible=_root.showTimeline;
_root.Controls.lblTime._visible=_root.showTimer;
_root.Controls.btnFullScreen._visible=_root.showFullScreen;
_root.Controls.btnSound._visible=_root.showVolumeBar;
_root.Controls.chkHide._visible=_root.showAutoHide;
_root.Controls.btnFBLogo._visible=_root.showFBLogo;
Controls.chkHide.uncheckAutoHide._visible=!_root.autoHide;
with(Controls.progressBar.timeline)
{
	timelineFullLeft._visible=false;	
	timelineFullMiddle._visible=false;
	timelineFullRight._visible=false;
}

// functions

function FBStopMovie()
{
	_trace('FBStopMovie');
//	fbPauseFlag=true;
	pauseFlagFrame=mc._currentframe;
	if(pauseFlagFrame==startFrame) ffp=true;
	StopMovie();
}

function FBPlayMovie()
{
	_trace('FBPlayMovie');
	if(btnClickToStart._visible) OnClickToStart();
	else PlayMovie();	

}

function OnFullScreen(bFull:Boolean) 
{
	if(!bFull || _root.scaleMode=="noScale")
	{
		if(mcWhiteRect._visible) mcWhiteRect._visible=false;
	}
}

function DoPosUpdate()
{
	var hgapScaled=hgap*fullScreenAspect;
	//_trace(autoscrollShiftX);
	mc._x=autoscrollShiftX;
	mc._y=autoscrollShiftY;
	var dx=- autoscrollShiftX;
	var dy=- autoscrollShiftY;
	Controls._x= dx;
	Controls._y=(_root.topToolbar?0:(initialHeight-Controls._height))+dy;

	var showWhiteRect:Boolean=false;
	if(Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale")
	{
		mc._y = autoscrollShiftY+(_root.topToolbar?-hgapScaled:hgapScaled);
		Controls._y =(_root.topToolbar ? hgapScaled+hgapScaled : initialHeight-Controls._height-hgapScaled-hgapScaled)+dy;
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
	
	var menuVisible=menu!=null && menu!=undefined && menu._visible;
	if(menuVisible)
	{
		menu._x=menuX+dx;
		menu._y=menuY+dy;
	}
	
	var volBarVisible=_root.volBar!=null && _root.volBar!=undefined && _root.volBar._visible;
	if(volBarVisible)
	{
		_root.volBar._x=volBarX+dx;
		_root.volBar._y=volBarY+dy;
	}
	if(_root.debugMode)
	{
		_root.lblDebug._x=dx;
		_root.lblDebug._y=toolbarHeight+dy;
	}	
/*	_trace(Controls._x+':'+Controls._y+' ');
	this._x = InitialX - mc._x;
	this._y = InitialY - mc._y;
	cy = this._y;*/
}

function GetLoadProgress()
{
	var tot=_root.getBytesTotal();
	if(tot==undefined || tot<=0) return 0;
	var d=_root.getBytesLoaded()/tot;	
	if(d<0) d=0;
	else if(d>1) d=1;
	return d;
}		

function GetBufferTime()
{
	var t=0;
	if(_root._totalframes!=undefined && _root._totalframes>0)
	{
		t=(_root._framesloaded-_root._currentframe) * duration/_root._totalframes;
	}
	return t;
}

function GetCurrentTime()
{
	var t=0;
	if(_root._totalframes!=undefined && _root._totalframes>0)
	{
		t=_root._currentframe * duration/_root._totalframes;
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
	mc.gotoAndPlay(startFrame);
	isPlaying=true;
	UpdateControls();*/
	playStarted=true;
	if(ffp) PauseMovie();
	else PlayMovie();
}
function PlayMovie()
{
	_trace("PlayMovie");	
	//check for security code
	mc.VerifySecurityCode(_root.specialcode);
	mc.play();
	isPlaying=true;
	UpdateControls();
}
function StopMovie()
{
	mc.gotoAndStop(mc._currentframe);
	isPlaying=false;
	UpdateControls();
}
function PauseMovie()
{
	mc.stop();
    isPlaying=false; 
	UpdateControls();
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
				mc.gotoAndPlay(startFrame);
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
	
	Controls.btnFirst.enabled=curFrame>startFrame;
	Controls.btnLast.enabled=curFrame<mc._totalframes;
	Controls.btnPrev.enabled=curFrame>startFrame;
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

function GetMovieLoadProgress()
{
  return mc._framesloaded==undefined? 0 : mc._framesloaded/mc._totalframes;
}

function SetProgressByCoord(x)// scrub._x 
{
	_trace('SetProgressByCoord x='+x);
	if(_root.showToolbar && Controls.progressBar._visible)
	{
		var pr=(x-scrubLeftOffset)/(Controls.progressBar._width-scrubOffset);

		var frameIndex = Math.round(mc._totalframes*pr);
		if(frameIndex<1) frameIndex=1;
		if(frameIndex>=startFrame && frameIndex<=mc._totalframes)
		{
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

/*function SetupVolControl()
{
	if(Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale")
	{
		volBarX = _root.Controls.btnSound._x * fullScreenAspect;
	}
	else
	{
		volBarX = _root.Controls.btnSound._x;
	}
	volBarY = _root.topToolbar ? Controls._height : height-Controls._height-_root.volBar._height;
	_root.volBar._x=volBarX-mc._x;
	_root.volBar._y=volBarY-mc._y;
}*/

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
_root.onMouseDown=function()
{
    _trace('_root.onMouseDown');
	if(hideMenuClick){ hideMenuClick=false;}
	var menuVisible=menu!=null && menu!=undefined && menu._visible;
	_trace('pauseByClickingOnMovie: '+_root.pauseByClickingOnMovie);
	_trace('playStarted: '+playStarted);
	if(_root.pauseByClickingOnMovie && playStarted && !_root.volBar._visible && !menuVisible)
	{
	  var isMouseOver=IsMouseOverToolbar();
	  if(!isMouseOver)
	  {
		if(ignoreClickFrame==mc._currentframe)
		{
			return;
		}
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
  	mc.gotoAndStop(startFrame);
	isPlaying=false;
	UpdateControls();
}
Controls.btnNext.onRelease = function()
{

	mc.gotoAndStop(mc._currentframe+1);
	isPlaying=false;
	UpdateControls();
}
Controls.btnPrev.onRelease = function()
{
	mc.gotoAndStop(mc._currentframe-1);
	isPlaying=false;
	UpdateControls();
}
Controls.btnLast.onRelease = function()
{

	mc.gotoAndStop(mc._totalframes);
	isPlaying=false;
	UpdateControls();
}
Controls.btnPlay.onRelease = function()
{
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
	PauseMovie();
}

Controls.btnStop.onRelease = function()
{
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
	return _root.showToolbar && IsMouseOverControl(_root.volBar,_xmouse,_ymouse);
}

function IsMouseOverToolbar():Boolean
{
	return _root.showToolbar && IsMouseOverControl(Controls,_xmouse,_ymouse);
}

function IsMouseOverMenu():Boolean
{
	return _root.showToolbar && IsMouseOverControl(menu,_xmouse,_ymouse);
}

function checkMousePos()
{
	if(_root.showToolbar)
	{
			var isMouseOver=IsMouseOverToolbar();
			//_trace(isMouseOver+" "+_root.autoHide);
			if(_root.autoHide && Controls._visible && !isMouseOver) Controls._visible=false;
		    if(!Controls._visible && isMouseOver) Controls._visible=true;
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
	  checkMousePos();	
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
var startFrameLoaded=false;

function OnTimer():Void 
{ 
    if(stopTimer) return;
    timerCount++;
	
	if(mc._currentframe!=undefined)
	{
		if(!toolbarLoaded && mc._framesloaded>=startFrame-1) 
		{
			toolbarLoaded=true;
			OnToolbarLoaded();
		}
		if(!startFrameLoaded && mc._framesloaded>=startFrame)
		{
			startFrameLoaded=true;
			_trace('startFrameLoaded');
			if(_root.startingPlaybackMode!=2) mc.gotoAndStop(startFrame);// first frame pause fix
			if(_root.startingPlaybackMode==1) snd.setVolume(100);
		}
		if(startFrameLoaded && mc._currentframe!=mcPrevFrame)
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

//	_trace('--- startFrameLoaded='+startFrameLoaded+' firstMovieFrameLoaded='+firstMovieFrameLoaded);
	if(startFrameLoaded && !movieLoaded && _root.startingPlaybackMode!=1 && !playStarted) CheckPreload();

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
if(_root.startingPlaybackMode==2) mc.stop(); // first frame pause fix
mc._quality = 'best';
FinalActions();

_trace('--commonSingle eof--');