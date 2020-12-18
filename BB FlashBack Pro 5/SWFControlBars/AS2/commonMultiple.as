import flash.external.*;
import mx.controls.Menu;
isSingleSwf=false;
//import flash.display.BitmapData;
#include "flashvars.as"
if(!CheckFPVersion())
{
	mcBlackRect._visible=false;
	return;
}
#include "common.as"

// clp is for background
//clp = this;

_trace('--commonMultiple--');
mcWhiteRect._visible=false;
mcWhiteRect2._visible=false;
if(!_root.dimPreview) mcBlackRect._visible=false;

// constants
var durationDeviation=0.1;

// variables
var movieState=0;
//var fbPauseFlag=false;
var pauseFlagFrame=0;
// Video
var nc:NetConnection = new NetConnection();
nc.onStatus = function(info) 
{ 
	if ( info.code == 'NetConnection.Connect.Success') 
	{ 
		_trace('NetConnection.Connect.Success');
//		video_ns = new NetStream(netConn); 
//		my_video.attachVideo(video_ns); 
//		video_ns.play("test.flv") ; 
	} 
	if(info.code == 'NetStream.FileStructureInvalid')
	{
		_trace('NetStream.FileStructureInvalid');
	}	
}
nc.connect(null);
var ns:NetStream = new NetStream(nc);
theVideo.attachVideo(ns);
_trace("theVideo._width: " + theVideo._width);
_trace("theVideo.scale: " + theVideo.scale);
theVideo._width = videoWidth;
theVideo._height = videoHeight;
theVideo._visible=false;
theVideo.smoothing=true;
var duration:Number = 0;

ns.onMetaData = function(infoObject:Object) 
{
	_trace("onMetaData");
//    for (var propName:String in infoObject) { _trace(propName + " = " + infoObject[propName]);}
	duration = infoObject.duration;
	_trace('duration='+duration);
	CheckStartFrame();
};
ns.onStatus = function(info)
{
//	_trace('ns.onStatus: '+info.code);
	if(info.code == "NetStream.Buffer.Full")
	{
//		OnMovieLoaded();
	}
	else
	if(info.code == "NetStream.Buffer.Empty")
	{
		/*if((_level0.movieprebuffer != undefined)&&(_level0.movieprebuffer > 0))
		{
			prebuffer._visible = true;
		}*/
	}
	else
	if(info.code == "NetStream.Play.Start")
	{
//		_trace('NetStream.Play.Start');
	}
	else
	if(info.code == "NetStream.Play.Stop")
	{
//		_trace('NetStream.Play.Stop');
		if(isPlaying)
		{
  		  if(_root.loopPlayback) Seek(0);
		  else
		  {
		    StopMovie();
		    Controls.progressBar.scrub._x=Controls.progressBar._width-scrubRightOffset;
		  }
		}
	}
	else
	if(info.code == "NetStream.Play.StreamNotFound")
	{
//		_trace('NetStream.Play.StreamNotFound');
	}
}

// initialisation
Controls.chkHide.lblText.text=_root.str3;
//_root.showToolbar=false;// test

// visibility
Controls._visible=_root.showToolbar;
Controls.btnStop._visible=_root.showStopButton;
Controls.btnNext._visible=_root.showNextButton && isSwf;
Controls.btnPrev._visible=_root.showPrevButton && isSwf;
Controls.btnLast._visible=_root.showLastButton;
Controls.progressBar._visible=_root.showTimeline;
Controls.lblTime._visible=_root.showTimer;
Controls.btnFullScreen._visible=_root.showFullScreen;
Controls.btnSound._visible=_root.showVolumeBar;
Controls.chkHide._visible=_root.showAutoHide;
Controls.btnFBLogo._visible=_root.showFBLogo;
Controls.chkHide.uncheckAutoHide._visible=!_root.autoHide;
//with(Controls.progressBar.timeline)
{
	Controls.progressBar.timeline.timelineFullMiddle._visible=false;
	Controls.progressBar.timeline.timelineFullLeft._visible=false;	
	Controls.progressBar.timeline.timelineFullRight._visible=false;
}
// functions
function FBStopMovie()
{
	_trace('FBStopMovie');
	if(isSwf)
	{
		pauseFlagFrame=_level1._currentframe;
		if(pauseFlagFrame==1) ffp=true;
	}
	else pauseFlagFrame=1;
	StopMovie();
}
function FBPlayMovie()
{
	_trace('FBPlayMovie');
	PlayMovie();	
}
function FBDelayMovie()
{
	_trace('FBDelayMovie');
	DelayMovie();
}

function OnFullScreen(bFull:Boolean) 
{
	_trace('OnFullScreen bFull='+bFull);
	if(_root.dimPreview && mcBlackRect._visible)
	{
		if(bFull && _root.scaleMode!="noScale" && _root.showToolbar)
		{
			mcBlackRect._y=hgap*fullScreenAspect;
			mcBlackRect._height=initialHeight-gap*fullScreenAspect;
		}
		else
		{
			mcBlackRect._y=0;
			mcBlackRect._height=initialHeight;
		}		
	}
	if(mcPreview!=undefined)
	{
		if(bFull && _root.scaleMode!="noScale" && _root.showToolbar)
		{
			mcPreview._y=_root.topToolbar? hgap*fullScreenAspect+Controls._height:hgap*fullScreenAspect;
		}
		else
		{
			mcPreview._y=(_root.showToolbar && _root.topToolbar) ? Controls._height : 0;
		}
	}
	if(previewSymbol._visible && mcWhiteRect!=undefined)
	{
		previewSymbol._y=(_root.showToolbar && _root.topToolbar) ? Controls._height : 0;
		if(bFull)
		{
			mcWhiteRect._x=initialWidth;
			mcWhiteRect._y=0;			
			mcWhiteRect2._x=0;
			mcWhiteRect2._y=_root.showToolbar && _root.topToolbar?initialHeight:initialHeight-toolbarHeight;			
			if(_root.scaleMode=="noScale")
			{

			}
			else
			{
				if(_root.showToolbar)
				{
					previewSymbol._y=_root.topToolbar? hgap*fullScreenAspect+Controls._height:hgap*fullScreenAspect;
				    mcWhiteRect2._y=initialHeight-hgap*fullScreenAspect- (_root.topToolbar?0:Controls._height);
				}								
			}
			mcWhiteRect._width=System.capabilities.screenResolutionX;
			mcWhiteRect._height=System.capabilities.screenResolutionY;
			mcWhiteRect._visible=true;
			mcWhiteRect2._width=System.capabilities.screenResolutionX;
			mcWhiteRect2._height=System.capabilities.screenResolutionY;
			mcWhiteRect2._visible=true;
		}
		else
		{
			mcWhiteRect._visible=false;
			mcWhiteRect2._visible=false;
		}
	}		
	UpdateBackground(bFull);
}
function OnToolbarLoaded()
{
	_trace('OnToolbarLoaded');
	if(_root.startingPlaybackMode==0)
	{
		showMovieLoadingOverlay = false;
		btnClickToStart._visible=true;
		mcPausedIcon._visible=false;
	}
	else LoadMovie2();
}
function OnMovieLoaded()
{
	_trace('OnMovieLoaded');
	if(_root.showToolbar)
	{
//		with(Controls.progressBar.timeline)
		{
			Controls.progressBar.timeline.timelineFullRight._visible=true;
		}	
	}
	showMovieLoadingOverlay=false;
	if(_root.startingPlaybackMode==1)
	{
		if(movieState<2) btnClickToStart._visible=true;
		mcPausedIcon._visible=false;
	}
	else if(movieState<2) StartPlay();
	
	CheckStartFrame();
}
function SetTime()
{
	if(_root.showToolbar)
	{
// _trace("SetTime");
		if(isSwf)
		{
		  var sec=Math.floor(_level1._currentframe/_root.fps);
		  var tsec=Math.floor(_level1._totalframes/_root.fps);
		  Controls.lblTime.text=GetTimeString(sec)+"/"+GetTimeString(tsec);
		}
		else
		{
		  var sec=Math.floor(ns.time);
		  var tsec=Math.floor(duration);
		  Controls.lblTime.text=GetTimeString(sec)+"/"+GetTimeString(tsec);
		}
	}
}
function PlayMovie()
{
	_trace("PlayMovie");
	if(movieState<2)
	{
		StartPlay();
		return;
	}
	if(_root.startFrame>0) return;
	//check for security code
	_level1.VerifySecurityCode(_root.specialcode);
	//
	RemoveDelay();
	if(isSwf)
	{
	  _level1.play();
	}
	else
	{
	   ns.pause(false);
	}
	isPlaying=true;
	UpdateControls();
}
function StopMovie()
{
	_trace('StopMovie');
	RemoveDelay();
	if(isSwf)
	{
		_level1.gotoAndStop(_level1._currentframe);
	}
	else
	{
		ns.pause(true);
	}
	isPlaying=false;
	UpdateControls();
}

function PauseMovie()
{
	_trace('PauseMovie');
	RemoveDelay();
	if(isSwf)
	{
	  _level1.stop();
	}
	else
	{
	  ns.pause(true);
	}
    isPlaying=false; 
	UpdateControls();
}

var delayId = 0;

function DelayMovie()
{
	_trace("DelayMovie()");
	_trace("_level1.pauseduration: " + _level1.pauseduration);
	RemoveDelay();
	if (_level1.pauseduration)
	{
		delayId = setInterval(RemoveDelay, _level1.pauseduration);
		if (isSwf)
		{
			_level1.stop();
		}
		else
		{
			ns.pause(true);
		}
		isPlaying=false;		
	}
}

function RemoveDelay()
{
	if (delayId)
	{
		clearInterval(_root.delayId);
		delayId = 0;
		if(isSwf)
		{
	  		_level1.play();
		}
		else
		{
	   		ns.pause(false);
		}
		isPlaying=true;
	}
}

function IsMovieEnd():Boolean
{
	if(!movieLoaded) return false;
	return isSwf?_level1._currentframe==_level1._totalframes: ns.time>=duration-durationDeviation;
}
function UpdateControls()
{
//	_trace('UpdateControls isPlaying='+isPlaying);
    if(isSwf && pauseFlagFrame!=_level1._currentframe) pauseFlagFrame=0;
	mcPausedIcon._visible=!isPlaying && movieState>0 && _root.showPausedOverlay && !IsMovieEnd() && !btnClickToStart._visible && pauseFlagFrame==0 && userPauseCount>0;
    if(!isSwf && pauseFlagFrame>0) pauseFlagFrame=0;
	if(!_root.showToolbar) return;

	Controls.btnPlay.enabled=!IsMovieEnd();
	if(isSwf)
	{
	  if(_level1._currentframe!=undefined && _level1._currentframe==_level1._totalframes)
	  {
		  if(isPlaying)
		  {
			  if(_root.loopPlayback)
			  {
				_level1.gotoAndPlay(1);
			  }
			  else
			  {
			    _level1.gotoAndStop(_level1._currentframe);
			    isPlaying=false;
			  }
		  }
	  }

	  Controls.btnFirst.enabled=_level1._currentframe>1;
	  Controls.btnLast.enabled=_level1._currentframe<_level1._totalframes;
	  Controls.btnPrev.enabled=_level1._currentframe>1;
	  Controls.btnNext.enabled=_level1._currentframe<_level1._totalframes;
	}
	else
	{
	  if(ns.time>=duration && duration>0)
	  {
		  if(isPlaying) ns.pause(true);
		  isPlaying=false;
	  }
	  Controls.btnFirst.enabled=ns.time>0;
	  Controls.btnLast.enabled=ns.time<duration;
	}
  Controls.btnPlay._visible = !isPlaying;
  Controls.btnPause._visible = isPlaying;
  SetProgress();
}
function SetProgress()
{
	if(_root.showToolbar && !scrubDragged && Controls.progressBar._visible)
	{
//		with(Controls.progressBar)
		{
			var pr=0;
			if(isSwf) pr=_level1._totalframes>1?(_level1._currentframe-1)/(_level1._totalframes-1): 0;
			else pr=ns.time/duration;
			if(pr>=0 && pr<=1)
			{
				if(!movieLoaded)
				{
					var w=GetMovieLoadProgress();
					if(pr>w) pr=w;
				}
    		  	Controls.progressBar.scrub._x=scrubLeftOffset+(Controls.progressBar.timeline._width-scrubOffset)*pr;
			}
		}
	}
}

function ProcessAdditionalParamsForButtonsJScript()
{	
	_level1["JSCall" + buttonId] = function()
	{
		JSCall(arguments.callee.jsCode);
	}
	_level1["JSCall" + buttonId].jsCode = jsCode;
}


function ProcessAdditionalParamsForButtons()
{	
	// create function with name ButtonJump+buttonId
	_trace("jumpFrameNum: " + jumpFrameNum);
	_trace("jumpPlayAfter: " + jumpPlayAfter);
	_level1["ButtonJump" + buttonId] = function()
	{
		ButtonJump(arguments.callee.jumpFrameNum, arguments.callee.jumpPlayAfter);
	}
	_level1["ButtonJump" + buttonId].jumpFrameNum = jumpFrameNum;
	_level1["ButtonJump" + buttonId].jumpPlayAfter = jumpPlayAfter;
}

function SetProgressByCoord(x)// scrub._x 
{
	if(_root.showToolbar && Controls.progressBar._visible)
	{
		var pr=(x-scrubLeftOffset)/(Controls.progressBar._width-scrubOffset);
		if(pr<0) pr=0;
		else if(pr>1) pr=1;
//		_trace('pr='+pr);
		if(isSwf)
		{
			var frameIndex = Math.round(_level1._totalframes*pr);
			if(frameIndex==0) frameIndex=1;
			if(frameIndex>=1&&frameIndex<=_level1._totalframes)
			{
//				_trace(frameIndex);
				RemoveDelay();
				if(isPlaying) _level1.gotoAndPlay(frameIndex);
				else _level1.gotoAndStop(frameIndex);
				UpdateControls();
			}
		}
		else
		{
			var time = duration*pr;
			Seek(time);
			UpdateControls();
		}
	}
}
function Seek(time)
{
	if(time>0 && time>duration-durationDeviation) time=duration-durationDeviation;
	if(time<0) time=0;
	ns.seek(time);	
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
	ctl._x=(initialWidth-ctl._width)/2;
	ctl._y=(initialHeight-ctl._height)/2;	
}

function UpdateTheVideoPos()
{
	_trace("UpdateTheVideoPos");
	_trace("isSwf: " + isSwf);
	if (!isSwf)
	{
		theVideo._x = borderWidth;
		theVideo._y = borderWidth;
		if (_root.topToolbar && _root.showToolbar && !_root.autoHideToolbar)
			theVideo._y += GetToolbarHeight();
	}
}

function UpdateToolbarPos()
{
	Controls._visible = _root.showToolbar;
	Controls._x = borderWidth;
	Controls._y = borderWidth;
	if (!_root.topToolbar)
	{
		Controls._y = borderWidth + videoHeight;
		_trace("_root.autoHideToolbar: " + _root.autoHideToolbar);
		if (_root.autoHideToolbar)
			Controls._y -= GetToolbarHeight();
	}
}

function OnResizeControls(fullscreenMode:Boolean)
{
	if(!isSwf)
	{
		UpdateTheVideoPos();
	}
	
	//if(_root.showToolbar && isSwf)
	//{	
		UpdateToolbarPos();
		DoPosUpdate();
	//}
}

function ClearPreview()
{
	if(mcPreview!=undefined)
	{
		mcPreview.unloadMovie();
	}	
	if(previewSymbol!=undefined)
	{
		previewSymbol._visible=false;
		mcWhiteRect._visible=false;
		mcWhiteRect2._visible=false;
		mcWhiteRect._height=0;
		mcWhiteRect2._height=0;
	}
	mcBlackRect._visible=false;
    if(_level0.fb_preview!=undefined) _level0.fb_preview._visible=false;
}
function LoadMovie2()
{	
	_trace('LoadMovie2 fileName='+_root.fileName);
//    _root.clear();
	ClearPreview();
    _level0.swapDepths(0);
	showMovieLoadingOverlay=true;
	if(_root.showToolbar)
	{
//		with(Controls.progressBar.timeline)
		{
			Controls.progressBar.timeline.timelineFullMiddle._visible=true;
			Controls.progressBar.timeline.timelineFullLeft._visible=true;	
		}
	}
	if(isSwf)
	{
		loadMovieNum(_root.fileName,1);
		_level1._quality = 'best';
	}
	else
	{
		theVideo._visible=true;
		_trace('ns.play: '+_root.fileName);
//		try
		{
			ns.checkPolicyFile=false;
			ns.play(_root.fileName);
			ns.pause(true);
			Seek(0);
		}
		/*catch(ex)
		{
			_trace('LoadMovie2 ns exception: '+ex.toString());
		}*/

	}

    movieState=1;
	timerCount=0;
	_trace('endof LoadMovie2');
}	

// Handlers
function OnClickToStart()
{
	_trace('OnClickToStart');
	_trace("btnClickToStart:=false");
	btnClickToStart._visible=false;
	if(movieLoaded) PlayMovie();
	else LoadMovie2();
}
_root.onMouseDown=function()
{
    _trace('_root.onMouseDown');
	if(hideMenuClick){ hideMenuClick=false;}
	var menuVisible=mainMenu!=null && mainMenu!=undefined && mainMenu._visible;
/*	if (menuVisible)
		menuClick();
	else
	{*/
		if(_root.pauseByClickingOnMovie && movieState>=2 && !volBar._visible && !menuVisible)
		{
		  var isMouseOver=IsMouseOverToolbar();
		  if(!isMouseOver)
		  {
			if(isSwf && ignoreClickFrame==_level1._currentframe)
			{
				return;
			}
			RemoveDelay();
			if(isPlaying)
			{
				userPauseCount++;
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
	if(isPlaying) PauseMovie();
	
	var y=Controls.progressBar.scrub._y;
	var w=Controls.progressBar._width-scrubOffset;
	var x=Controls.progressBar._x;
	
	Controls.progressBar.scrub.startDrag(true, scrubLeftOffset, y, scrubLeftOffset+w, y);
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
	  var x=Controls.progressBar._xmouse-(Controls.progressBar.scrub._width/2);
	  SetProgressByCoord(x);
	}
}

Controls.progressBar.scrub.onRelease=Controls.progressBar.scrub.onReleaseOutside= function()
{
	_trace('Controls.progressBar.scrub.onRelease');
	Controls.progressBar.scrub.stopDrag();	
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
	if(isSwf)	
	{
	  	_level1.gotoAndStop(1);
	}
	else 
	{
		ns.pause(true);
		Seek(0);
	}
	isPlaying=false;
	UpdateControls();
}
Controls.btnNext.onRelease = function()
{
	RemoveDelay();
	if(isSwf)	
	{
		_level1.gotoAndStop(_level1._currentframe+1);
	}
	else
	{
		
	}	
	isPlaying=false;
	UpdateControls();
}
Controls.btnPrev.onRelease = function()
{
	RemoveDelay();
	if(isSwf)	
	{
	  _level1.gotoAndStop(_level1._currentframe-1);
	}
	else
	{
		
	}
	isPlaying=false;
	UpdateControls();
}
Controls.btnLast.onRelease = function()
{
	RemoveDelay();
	if(isSwf)
	{
	  _level1.gotoAndStop(_level1._totalframes);
	}
	else
	{
		Seek(duration);
	}
	isPlaying=false;
	UpdateControls();
}
Controls.btnPlay.onRelease = function()
{
	RemoveDelay();
	OnButtonPlayClicked();
}
function OnButtonPlayClicked():Void
{
	_trace('OnButtonPlayClicked');
	if(btnClickToStart._visible) OnClickToStart();
	else PlayMovie();
}
Controls.btnPause.onRelease = function()
{
	RemoveDelay();
	userPauseCount++;
	PauseMovie();
}
Controls.btnStop.onRelease = function()
{
	RemoveDelay();
	userPauseCount++;
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
	return _root.showToolbar && IsMouseOverControl(volBar,_xmouse,_ymouse);
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
	
onMouseMove=function()
{
	_trace("mousemove1");
	if(passwordChecked)
	{
  		checkMousePos();
		CreateToolbarTimer();
	}
}

_level1.onMouseMove=function()
{
	_trace("mousemove2");
	if(passwordChecked)
	  checkMousePos();	
	CreateToolbarTimer();
}
btnClickToStart.onRelease = function()
{	
  OnClickToStart();
}

// timer
var level1PrevFrame;
var movieLoaded=false;
var level1Initialised=false;
var nsTime;
var toolbarLoaded=false;
var timerCount=0;
var showMovieLoadingOverlay=true;
var previewLoaded=false;

function OnTimer():Void 
{ 	
//  try
  {
    if(stopTimer) return;
    timerCount++;
	if(!toolbarLoaded)
	{
		if(_root.getBytesLoaded()==_root.getBytesTotal())
		{
			toolbarLoaded=true;
			OnToolbarLoaded();
		}
	}

	if(!previewLoaded && mcPreview!=undefined)
	{
		if(mcPreview.getBytesLoaded()==mcPreview.getBytesTotal())
		{
			previewLoaded=true;
			OnPreviewLoaded();
		}
	}
	if(movieState>0)
	{
		if(isSwf)
		{
			if(_level1._currentframe!=undefined)
			{
				if(!level1Initialised && _level1._framesloaded>0) 
				{
					InitLevel1();
					level1Initialised=true;
				}		  
				if(_level1._currentframe!=level1PrevFrame)
				{
				  	level1PrevFrame=_level1._currentframe;
				  	MovieOnEnterFrame();
				}		  
				if(!movieLoaded)
				{
				  	SetLoadProgress();
				  	if(_level1._framesloaded==_level1._totalframes)
				  	{
						movieLoaded=true;
					  	OnMovieLoaded();
					  	//clearInterval(intervalID);
				  	}
				}
			}
		}
		else// flv
		{
			if(nsTime!=ns.time)
			{
	//			_trace("ns.time="+ns.time+" duration="+duration);
				nsTime=ns.time;
				MovieOnEnterFrame();
			}
			  if(!movieLoaded)
			  {
				  SetLoadProgress();
				  if(ns.bytesLoaded==ns.bytesTotal && ns.bytesTotal>0)
				  {
					  movieLoaded=true;
					  OnMovieLoaded();
				  }
			  }
		}
		if(toolbarLoaded && !movieLoaded && _root.startingPlaybackMode!=1 && movieState<2) CheckPreload();
	}
	UpdateLoadingMeter();
  }
/*  catch(ex)
  {
	  _trace('OnTimer exception: '+ex.ToString());
	  stopTimer=true;
  }*/
}

function InitLevel1()
{
	_trace('InitLevel1');
	_level1.DoPosUpdate=function()
	{
		DoPosUpdate();
	}
 	duration=_level1._totalframes/_root.fps;
	_trace('duration='+duration);	
	_level1.gotoAndStop(1);
	if(_root.showToolbar && Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale")
	{
//    	FullScreenResizeFix();
		ResizeControls(true);
	}
	else DoPosUpdate();
	_level1.ProcessAdditionalParamsForButtons=function()
	{
		_trace("ProcessAdditionalParamsForButtons");
		buttonId = _level1.buttonId;
		jumpFrameNum = _level1.jumpFrameNum;
		jumpPlayAfter = _level1.jumpPlayAfter;
		ProcessAdditionalParamsForButtons();
	}
	
	_level1.ProcessAdditionalParamsForButtonsJScript=function()
	{
		_trace("ProcessAdditionalParamsForButtonsJScript");
		buttonId = _level1.buttonId;
		jsCode = _level1.jsCode;
		ProcessAdditionalParamsForButtonsJScript();
	}
	
	_level1.FBStopMovie=function()
	{
		FBStopMovie();
	}
	_level1.FBPlayMovie=function()
	{
		FBPlayMovie();
	}
	_level1.FBDelayMovie=function()
	{
		FBDelayMovie();
	}
	/*_level1.JSCall=function()
	{
		jsCode = _level1.jsCode;
		JSCall();
	}*/
	/*_level1.ButtonJump=function()
	{
		jumpFrameNum = _level1.jumpFrameNum;
		jumpPlayAfter = _level1.jumpPlayAfter;
		ButtonJump();
	}*/
/*
_level1.mc2.onRelease = function()
{
	_trace('_level1.mc2.onRelease');
}*/
}
function ButtonRealJump(jumpFrameNum, jumpPlayAfter)
{
	// +1 because file has additional frames at start
	if (jumpPlayAfter)
		_level1.gotoAndPlay(jumpFrameNum+1);
	else
		_level1.gotoAndStop(jumpFrameNum+1);
}

function OnPreviewLoaded()
{
	_trace('OnPreviewLoaded');
//  	FillRect(mcPreview,0x000000,30);	
}

function UpdateBackground(bFull:Boolean)
{		
	var left = 0;
	var top = 0;
	var right = videoWidth + 0;
	var bottom = videoHeight + GetToolbarHeightForMovieSize() + 0;
	
	var shiftX = borderWidth;
	var shiftY = borderWidth;
	
	RedrawBGWithBorder(bFull, left + shiftX, top + shiftY, right +shiftX, bottom + shiftY);
}

function DoPosUpdate()
{
	UpdateTheVideoPos();
	if(_level1.autoscrollShiftX==undefined) _level1.autoscrollShiftX=0;
	if(_level1.autoscrollShiftY==undefined) _level1.autoscrollShiftY=0;
	_trace("DoPosUpdate: " + _level1.autoscrollShiftX + " " + _level1.autoscrollShiftY);

	var dx = borderWidth;
	var dy = borderWidth;
	dy += (_root.showToolbar && _root.topToolbar && !_root.autoHideToolbar) ? GetToolbarHeight() : 0;
	
	_level1._x=_level1.autoscrollShiftX + dx;
	_level1._y=_level1.autoscrollShiftY + dy;
}

function MovieOnEnterFrame()
{	
//    if(isSwf && mcPausedIcon._visible) mcPausedIcon._visible=false;
//_trace('MovieOnEnterFrame: '+_level1._currentframe);
	if(isSwf && _level1.fb_pausebutton!=undefined)
	{
	  _level1.fb_pausebutton._x= - _level1._x;
	  _level1.fb_pausebutton._y=(_root.topToolbar?(Controls._height):0)- _level1._y;
	  if(_root.showToolbar && Stage["displayState"] == "fullScreen" && _root.scaleMode!="noScale")
	  {
		  var y=hgap*fullScreenAspect;
		  if(_root.topToolbar) y+=Controls._height;
		  _level1.fb_pausebutton._y=y- _level1._y;
	  }
	}
	if(isSwf && _root.pauseByClickingOnMovie)
	{
	  if(_level1.fb_pobutton!=undefined)
	  {
		  //_level1.fb_pobutton.onRelease = function(){};//_trace('fb_pobutton.onRelease');}
		  ignoreClickFrame=_level1._currentframe;
	  }
	  if(_level1.fb_pausebutton2!=undefined)
	  {
	//		 _level1.fb_pausebutton.onRelease = function(){}//_trace('fb_pausebutton.onRelease');}
		  ignoreClickFrame=_level1._currentframe;
	  }
	  if(_level1.fb_pobutton_jump!=undefined)
	  {
	//		   _trace('fb_pobutton_jump='+_level1.fb_pobutton_jump);
		  ignoreClickFrame=_level1._currentframe;
	/*		  var origHandler=_level1.fb_pobutton_jump.onPress;
		   _trace('origHandler='+_level1.fb_pobutton_jump.onRelease);
		   _trace('origHandler2='+_level1.fb_pobutton_jump.onPress);*/
		 _level1.fb_pobutton_jump.onRelease = _level1.fb_pobutton_jump.onPress=function()
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
		if(isSwf)
		{	  
			if(Stage["displayState"] == "fullScreen") 
			{
				if(_root.scaleMode!="noScale" && Stage.scaleMode=="noScale") 
					Stage.scaleMode=_root.scaleMode;
			}
			else if(Stage.scaleMode!=_root.scaleMode) Stage.scaleMode=_root.scaleMode;
		}
	}
	
	CheckStartFrame();
}

function StartPlay()
{
	_trace('StartPlay');
	_root.Clear();
/*    if(_root.showToolbar && _root.scaleMode=="noScale" && Stage["displayState"] == "fullScreen")
	{
		ResizeControls(true);
	}*/
	
	if(isSwf) _level1._visible=true;
	else
	{
		theVideo._visible=true;
//		ns.play(_root.fileName);
	}
//	showMovieLoadingOverlay=false;
	movieState=2;
    if(ffp) PauseMovie();
	else PlayMovie();
}

function GetMovieLoadProgress()
{
//	_trace('GetMovieLoadProgress');
	if(movieState<1) return 0;	
	var d=0;
	if(isSwf)
	{
		d=_level1._framesloaded==undefined? 0 : _level1._framesloaded/_level1._totalframes;
	}
	else
	{
		d= ns.bytesLoaded!=undefined && ns.bytesTotal!=undefined && ns.bytesTotal>0 ? ns.bytesLoaded/ns.bytesTotal : 0;	
		_trace('ns.time='+ns.time+' bytesLoaded='+ns.bytesLoaded+' bytesTotal='+ns.bytesTotal);
	}
	if(d<0) d=0;
	else if(d>1) d=1;
//	_trace(d);
	return d;
}

function GetSecondsLoaded()
{
	if (movieState<1) return 0;
	var secs = 0;
	if (isSwf)
	{
		secs = _level1._framesloaded==undefinde ? 0 : _level1._framesloaded / _root.fps;
	}
	else
	{
		secs = ns.bufferLength==undefined ? 0 : ns.bufferLength;
	}
	if (secs < 0)
		secs = 0;
	return secs;
}

function CheckStartFrame()
{
//	_trace('CheckStartFrame');
	if(_root.startFrame>0)
	{
		if(isSwf)
		{
			if(_level1._framesloaded!=undefined) 
			{
				if(_root.startFrame < _level1._framesloaded || _level1._framesloaded==_level1._totalframes)
				_trace('startFrame');	
				_level1.gotoAndStop(_root.startFrame<_level1._totalframes ? _root.startFrame : _level1._totalframes);
				_root.startFrame=0;
			}
				
		}
		else 
		{
//			_trace('CheckStartFrame duration='+duration);
			if(duration!=undefined && duration>0 && ns.bytesLoaded!=undefined && ns.bytesTotal!=undefined)
			{
				var time=_root.startFrame/_root.fps;
				var estTime=duration*ns.bytesLoaded/ns.bytesTotal;
//				_trace('time='+time+' estTime='+estTime);
				if(time<estTime||ns.bytesLoaded==ns.bytesTotal)
				{
					_trace('startFrame');
					_root.startFrame=0;
					Seek(time);
				}
			}
		}
		if(_root.startFrame==0)
		{
			if(_root.startingPlaybackMode==2) PlayMovie();
			else PauseMovie();
		}
	}
}

function GetBufferTime()
{
	if(movieState<1) return 0;
	var t=0;
	if(isSwf)
	{
		if(_level1._totalframes!=undefined && _level1._totalframes>0)
		{
			t=(_level1._framesloaded-_level1._currentframe) * duration/_level1._totalframes;
		}
	}
	else
	{
		if(ns.bufferLength!=undefined)
		{
     	  t=ns.bufferLength;	
		}
	}
	return t;
}

function GetCurrentTime()
{
	if(movieState<1) return 0;
	var t=0;
	if(isSwf)
	{
		if(_level1._totalframes!=undefined && _level1._totalframes>0)
		{
			t=_level1._currentframe * duration/_level1._totalframes;
		}
	}
	else
	{
		if(ns.time!=undefined)
		{
     	  t=ns.time;	
		}
	}
	return t;
}

function CheckPreload()
{
	_trace('CheckPreload duration='+duration);
	if(!movieLoaded && duration!=undefined && duration>0)
	{
		var curTime=timerCount*timerInterval/1000;
		_trace('curTime='+curTime);
		var d=GetMovieLoadProgress();
		_trace('d='+d);
		if(d>0)
		{
			if(_root.preloadPercent>0)
			{
				if(_root.preloadPercent<=d*100) PlayMovie();//StartPlay();
			}
			else
			{
				var est=curTime*(1-d)/d;
				_trace('d='+d+' est='+est+' tot='+duration);
				if(est<duration)
				{
					PlayMovie();//StartPlay();
				}
			}
		}
	}
}
// actions
mcBlackRect._x=0;
mcBlackRect._y=0;
mcBlackRect._width=initialWidth;
mcBlackRect._height=initialHeight;
//FillRect(_root,0x000000,30);
_level1._visible=false;
if(previewFileName!=undefined)
{
  _trace('previewFileName: '+_root.previewFileName);
  if(previewFileName.length>0)
  {
    _level0.createEmptyMovieClip("mcPreview",-18000);
    mcPreview._x=0;
    mcPreview._y=_root.showToolbar && _root.topToolbar ? Controls._height : 0;
	mcPreview._quality = 'best';
    mcPreview.loadMovie(_root.previewFileName);
  }
  else
  {
	  _trace('embedded preview');
	  previewSymbol._x=0;
	  previewSymbol._y=0;
	  if(_root.showToolbar && _root.topToolbar) previewSymbol._y=Controls._height;
	  _trace('previewSymbol._y: '+previewSymbol._y);
	  previewSymbol._width=initialWidth;
	  previewSymbol._height=initialHeight-previewSymbol._y;
	  previewSymbol._xscale=_root.psx;
	  previewSymbol._yscale=_root.psy;
	  previewSymbol._visible=true;
      previewLoaded=true;
//	  _trace('scales: '+previewSymbol._xscale+' ' + previewSymbol._yscale);
//    var bitmapData:BitmapData = BitmapData.loadBitmap("preview");
//	  mcPreview.play();
/*		mcWhiteRect=attachMovie("WhiteRect","mcWhiteRect",701);
		mcWhiteRect2=attachMovie("WhiteRect","mcWhiteRect2",702);
		mcWhiteRect._visible=false;
		mcWhiteRect2._visible=false;*/
  }
}
FinalActions();
_trace('--commonMultiple eof--');
