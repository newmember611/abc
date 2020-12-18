package AS3{
import flash.events.*;
import flash.display.*;
import flash.text.*;
import flash.geom.Rectangle;
import flash.events.*;
import flash.external.*;
import flash.media.*;
import flash.ui.*;
import flash.net.*;
import flash.system.*;
import flash.utils.Timer;
import flash.geom.Matrix;
import fl.video.*;
import fl.controls.*; 
import AS3.Flashvars;
import AS3.Element;


//#include "expiring_checking.as"
//#include "password_checking.as"
public class Common extends MovieClip
{
	// constants
	private var progressBarOffset:int=10;
	private var timelineMinWidth:int=62;//  is min width of timeline
	protected var timerInterval:int=50;
	
	// variables
	protected var autoHide=false;
	private var passwordChecked=false;
	protected var ffp=false;//first frame pause embedded by FB
	protected var isPlaying=false;
	private var intervalID:int=0;
//	private var stopTimer=false;
	protected var ignoreClickFrame:int=0;
//	private var hideMenuClick=false;
	private var volBarX:int=0;
	private var volBarY:int=0;
	private var autoscrollShiftX:Number=0;
	private var autoscrollShiftY:Number=0;
	private var prevTime:Number=0;
	protected var showMovieLoadingOverlay=false;
	protected var timerCount:int=0;
	private var debugText="";
	private var timer:Timer = new Timer(timerInterval);
	protected var movieLoaded=false;
	protected var sliderDragging=false;
	protected var scrubDragging=false;
	protected var userPauseCount:int=0;
	protected var pausedByInteractiveElement=0;

	// variables assigned in constructor
	private var isSingleSwf:Boolean;
	protected var flashvars:Flashvars;
	protected var scrubOffset:int;
	protected var toolbarHeight:int;
	protected var toolbarHeightForMovieSize:int;
	public var initialWidth:int;
//	protected var initialStageWidth:int;
	public var initialHeight:int;
	public var borderWidth:int;
	private var fullScreenAspectX:Number;//640/1440
	private var fullScreenAspectY:Number;//480/900
	private var fullScreenAspectHor:Boolean;
	protected var fullScreenAspect:Number;
	protected var scrubLeftOffset:int=0;
	protected var scrubRightOffset:int=0;
	private var initialVolBarHeight:int=0;
	protected var videoHeight:int=0;
	protected var videoWidth:int=0;

	// clips
	private var Controls=null;
	protected var menu:List=null;
	private var aboutBox:TextField=null;
	private var textFieldTest:TextField=null;
	private var lblDebug:TextField=null;
	private var borderSprite:Sprite=null;
	protected var btnClickToStart=new ClickToStart();
	protected var mcOverlayLoading:OverlayLoading=new OverlayLoading();
	protected var mcJumpLoading:OverlayLoading=new OverlayLoading();
	protected var mcBlackRect=new BlackRect();
	protected var previewSymbol=new PreviewSymbol();
	protected var volBar=new VolumeBar();
	protected var mcPausedIcon=new PausedIcon();	
	
	// override 
	function GetLoaderInfo():LoaderInfo{return null;}
	function PlayMovie(){}
	function PauseMovie(){}
	function StopMovie(){}
	function OnResizeControls(fullscreenMode:Boolean){}
	function DoPosUpdate(){}
	function GetCurrentTime(){}
	function OnTimer(){}
	function RemoveDelay(){}
	function SetProgress(){}
	function OnFullScreen(bFull:Boolean){}
	function SetVolume(ratio:Number){}
	function SetProgressByCoord(x:Number){}
	function OnClickToStart(){}
	function GetMovieLoadProgress(){}
	
	function Common()
	{		
		_trace("Common");
	}
	
	function CreateBorderSprite()
	{
		borderSprite = new Sprite();
		//_trace('fullScreenBackgroundColor: ' + flashvars.fullScreenBackgroundColor);
		stage.addChildAt(borderSprite, 0);
	}
	
	function Init(Controls,isSingleSwf:Boolean)
	{		
		_trace("Init");
		this.Controls=Controls;
		this.isSingleSwf=isSingleSwf;
		flashvars=new Flashvars(this);
		_trace("autoHideToolbar="+flashvars.autoHideToolbar);
		_trace("autoHide="+flashvars.autoHide);
		SetSizes();
		if(flashvars.debugMode==2) CreateDebugWindow();
		debugText=null;
		InitClips();
		SetVisibility();
		InitMisc();
		SetHandlers();
		CreateBorderSprite();
		RedrawBorderSprite();
	}

	function CreateDebugWindow()
	{
		if(lblDebug==null)
		{
			lblDebug=new TextField();
			lblDebug.x=0;
			lblDebug.y=30;
			lblDebug.width=Math.min(200,initialWidth/3);
			lblDebug.height=initialHeight-60;
			lblDebug.multiline=true;
			lblDebug.mouseWheelEnabled=true;
			lblDebug.wordWrap=false;
			lblDebug.selectable=true;
			var my_fmt:TextFormat = new TextFormat();
			my_fmt.font='Arial';
			my_fmt.size=10;
			lblDebug.setTextFormat(my_fmt);
			stage.addChild(lblDebug);
			lblDebug.visible=true;
			lblDebug.text=debugText;
		}
	}
	
	
	
	function RedrawBorderSprite()
	{
		borderSprite.graphics.clear();
		borderSprite.graphics.beginFill(flashvars.borderColor);
		var w:int = videoWidth;
		var h:int = videoHeight;
		if (stage.displayState == StageDisplayState.FULL_SCREEN && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
			w /= fullScreenAspect;
			h /= fullScreenAspect;
		}
		h += toolbarHeightForMovieSize + borderWidth * 2;
		w += borderWidth * 2;
		var sx:int = GetCenterShiftX(stage.displayState == StageDisplayState.FULL_SCREEN);
		var sy:int = GetCenterShiftY(stage.displayState == StageDisplayState.FULL_SCREEN);
		if (borderWidth != 0)
		{
			borderSprite.graphics.beginFill(flashvars.borderColor);
			borderSprite.graphics.drawRect(0+sx,0+sy, w, h);
			borderSprite.graphics.drawRect(0+sx+borderWidth, 0+sy+borderWidth, w-borderWidth*2, h-borderWidth*2);
			borderSprite.graphics.endFill();
		}
	}
	
	function SetSizes()
	{
		_trace("SetSizes");
		stage.align = StageAlign.TOP_LEFT;
	    toolbarHeight=flashvars.showToolbar?Controls.height:0;
		toolbarHeightForMovieSize=flashvars.autoHideToolbar?0:toolbarHeight;
		borderWidth=flashvars.enableBorder?flashvars.borderWidth:0;
		videoHeight=flashvars.vh;
		videoWidth=flashvars.vw;
		initialWidth=videoWidth + borderWidth*2;
		initialHeight=videoHeight + toolbarHeightForMovieSize + borderWidth * 2;
		
		if (flashvars.scaleMode == StageScaleMode.NO_SCALE)
			if ((initialWidth > Capabilities.screenResolutionX) || 
			(initialHeight + toolbarHeight > Capabilities.screenResolutionY))
			{
				flashvars.scaleMode = StageScaleMode.SHOW_ALL;
			}
	
//		initialStageWidth=stage.width;

		initialVolBarHeight=volBar.height;
		scrubLeftOffset=(Controls.progressBar.timeline.timelineLeft.width-Controls.progressBar.scrub.width)/2;
		scrubRightOffset=(Controls.progressBar.timeline.timelineRight.width+Controls.progressBar.scrub.width)/2;
		if(scrubLeftOffset<0) scrubLeftOffset=0;	
		if(scrubRightOffset<Controls.progressBar.scrub.width) scrubRightOffset=Controls.progressBar.scrub.width;
		scrubOffset=scrubLeftOffset+scrubRightOffset;
		fullScreenAspectX=(videoWidth)/(Capabilities.screenResolutionX-borderWidth*2);//640/1440
		fullScreenAspectY=(videoHeight)/(Capabilities.screenResolutionY-toolbarHeightForMovieSize-borderWidth*2);//480/900
		fullScreenAspectHor=fullScreenAspectX>fullScreenAspectY;
		fullScreenAspect=fullScreenAspectHor?fullScreenAspectX:fullScreenAspectY;
		//fullScreenAspect = 1/fullScreenAspect;
		_trace('initialWidth='+initialWidth);
		_trace('initialHeight='+initialHeight);	   
		_trace('stage.width='+stage.width);
		_trace('stage.height='+stage.height);	   
		_trace('toolbarHeight='+toolbarHeight);	 
		_trace('fullScreenAspect='+fullScreenAspect);
	}

	function InitClips()
	{
		_trace("InitClips");
		stage.addChild(mcBlackRect);
		stage.addChild(volBar);
		stage.addChild(btnClickToStart);
		stage.addChild(mcPausedIcon);		
		stage.addChild(mcOverlayLoading);
		stage.addChild(mcJumpLoading);
//		stage.addChild(previewSymbol);		
	}

	function SetVisibility()
	{
		_trace("SetVisibility");
		Controls.visible=flashvars.showToolbar;
//		Controls.btnStop.visible=flashvars.showStopButton;
//		Controls.btnLast.visible=flashvars.showLastButton;
		Controls.progressBar.visible=flashvars.showTimeline;
		Controls.lblTime.visible=flashvars.showTimer;
		Controls.btnFullScreen.visible=flashvars.showFullScreen;
		Controls.btnSound.visible=flashvars.showVolumeBar;
		_trace("showAutoHide = " + flashvars.showAutoHide);
		Controls.chkHide.visible=flashvars.showAutoHide;
		Controls.btnFBLogo.visible=flashvars.showFBLogo;
		Controls.chkHide.uncheckAutoHide.visible=!flashvars.autoHide;
		with(Controls.progressBar.timeline)
		{
			timelineFullMiddle.visible=false;
			timelineFullLeft.visible=false;	
			timelineFullRight.visible=false;
		}
		mcOverlayLoading.visible=true;
		mcOverlayLoading.stop();
		mcJumpLoading.visible = false;
		mcJumpLoading.stop();
		btnClickToStart.visible=false;
		volBar.visible=false;
		mcPausedIcon.visible=false;
		ShowVolBar(false);
	}
	
	function InitMisc()
	{
		Controls.chkHide.lblText.text=flashvars.str3;
		stage.scaleMode=flashvars.scaleMode0;
		stage.showDefaultContextMenu=false;
//		_global.style.setStyle("themeColor","darkGray");
		SetVolume(100);
		// actions
		mcBlackRect.x=0;
		mcBlackRect.y=0;
		mcBlackRect.width=initialWidth;
		mcBlackRect.height=initialHeight;	
	}
	
	function SetHandlers()
	{
		_trace("SetHandlers");
		if(flashvars.enableExternalInterface)
		{
			_trace('ExternalInterface.available: '+ExternalInterface.available);
			if(ExternalInterface.available)
			{
			  ExternalInterface.addCallback("PlayMovie",OnButtonPlayClicked);
			  ExternalInterface.addCallback("PauseMovie",PauseMovie);
			  ExternalInterface.addCallback("StopMovie",StopMovie);
			}
		}
				
		with(Controls)
		{
			// add event listeners to remove Delay Timer (Steve Pinter)
			btnPlay.addEventListener(MouseEvent.CLICK, remove_delay);			
			btnPause.addEventListener(MouseEvent.CLICK, remove_delay);
			btnFullScreen.addEventListener(MouseEvent.CLICK, remove_delay);
			chkHide.addEventListener(MouseEvent.CLICK, remove_delay);
			btnSound.addEventListener(MouseEvent.CLICK, remove_delay);
			btnFBLogo.addEventListener(MouseEvent.CLICK, remove_delay);
			progressBar.scrub.addEventListener(MouseEvent.MOUSE_DOWN, remove_delay);
			progressBar.scrub.addEventListener(MouseEvent.MOUSE_UP, remove_delay);
//			progressBar.addEventListener(MouseEvent.MOUSE_OUT, scrub_onMouseUp);
			progressBar.timeline.addEventListener(MouseEvent.MOUSE_DOWN, remove_delay);
			
			// another event handlers
			btnPlay.addEventListener(MouseEvent.CLICK, btnPlay_onMouseUp);			
			btnPause.addEventListener(MouseEvent.CLICK, btnPause_onMouseUp);
			btnFullScreen.addEventListener(MouseEvent.CLICK, btnFullScreen_onMouseUp);
			chkHide.addEventListener(MouseEvent.CLICK, chkHide_onMouseUp);
			btnSound.addEventListener(MouseEvent.CLICK, btnSound_onMouseUp);
			btnFBLogo.addEventListener(MouseEvent.CLICK, btnFBLogo_onMouseUp);
			progressBar.scrub.addEventListener(MouseEvent.MOUSE_DOWN, scrub_onMouseDown);
			progressBar.scrub.addEventListener(MouseEvent.MOUSE_UP, scrub_onMouseUp);
//			progressBar.addEventListener(MouseEvent.MOUSE_OUT, scrub_onMouseUp);
			progressBar.timeline.addEventListener(MouseEvent.MOUSE_DOWN, timeline_onMouseDown);
		}
		with(stage)
		{
			addEventListener(FullScreenEvent.FULL_SCREEN, stage_OnFullScreen);
			addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
//			addEventListener(MouseEvent.MOUSE_OUT, stage_onMouseUp);
		}
		with(volBar)
		{
			slider.addEventListener(MouseEvent.MOUSE_DOWN, slider_onMouseDown);
			slider.addEventListener(MouseEvent.MOUSE_UP, slider_onMouseUp);
//			addEventListener(MouseEvent.MOUSE_OUT, slider_onMouseUp);
		}
		btnClickToStart.addEventListener(MouseEvent.CLICK, btnClickToStart_onMouseUp);	
		timer.addEventListener(TimerEvent.TIMER, OnTimerCommon);
	}
	
	function remove_delay(event:MouseEvent)
	{
		RemoveDelay();
	}

	// Handlers
	function stage_onMouseUp(event:MouseEvent):void
	{
		trace('stage_onMouseUp');
		if(sliderDragging) StopSliderDrag();
		if(scrubDragging) StopScrubDrag();
	}	
	function btnClickToStart_onMouseUp(e:MouseEvent)
	{
	  OnClickToStart();
	}
	function btnPlay_onMouseUp(e:MouseEvent)
	{
		OnButtonPlayClicked();
	}	
	function timeline_onMouseDown(e:MouseEvent) 
	{
		_trace('timeline_onMouseDown');
		if(!scrubDragging)
		{
		  var x:Number=Controls.progressBar.mouseX-Controls.progressBar.scrub.width/2;
		  SetProgressByCoord(x);
		}
	}
	function btnPause_onMouseUp(e:MouseEvent)
	{
		userPauseCount++;
		PauseMovie();
	}
	function btnStop_onMouseUp(e:MouseEvent)
	{
		userPauseCount++;
		StopMovie();
	}	
	function scrub_onMouseDown(e:MouseEvent) 
	{
		_trace('scrub_onMouseDown');
		var y=Controls.progressBar.scrub.y;
		var w=Controls.progressBar.width-scrubOffset;
		var x=scrubLeftOffset;
		var r:Rectangle=new Rectangle(x, y, w, 0);
		Controls.progressBar.scrub.startDrag(true, r);
		Controls.progressBar.scrub.addEventListener(Event.ENTER_FRAME,scrub_EnterFrame);
		scrubDragging=true;
	}

	private function scrub_EnterFrame(event:Event):void 
	{
		SetProgressByCoord(Controls.progressBar.scrub.x);
	}
	
	function scrub_onMouseUp(e:MouseEvent)
	{
		StopScrubDrag();
	}	
	function chkHide_onMouseUp(e:MouseEvent)
	{
		_trace('chkHide_onMouseUp');
		autoHide=!autoHide;
		Controls.chkHide.uncheckAutoHide.visible=!autoHide;
	}
	
	function OnTimerCommon(event:TimerEvent):void 
	{ 
//		if(stopTimer) return;
		try
		{
			timerCount++;
			OnTimer();
		}
		catch(ex)
		{
		  _trace('OnTimer exception: '+ex);
		  timer.stop();
//		  stopTimer=true;
		}
	}
	function btnFullScreen_onMouseUp(e:MouseEvent)
	{
	  _trace('btnFullScreen_onMouseUp');
	  if(stage.displayState == StageDisplayState.NORMAL)
	  {
		stage.displayState =StageDisplayState.FULL_SCREEN;
	  }
	  else if(stage.displayState == StageDisplayState.FULL_SCREEN)
	  {
		stage.displayState = StageDisplayState.NORMAL;
	  }
	  DoPosUpdate();
	}

	function slider_onMouseDown(e:MouseEvent) 
	{
		_trace('slider_onMouseDown');
		var x=volBar.slider.x;
		var y=initialVolBarHeight-volBar.slider.height;
		volBar.slider.startDrag(true, new Rectangle(x, 0, 0, y));
		volBar.slider.addEventListener(Event.ENTER_FRAME,slider_EnterFrame);
		sliderDragging=true;
	}
	
	private function slider_EnterFrame(event:Event):void 
	{
		with(volBar)
		{
			var ratio = 100-Math.round(slider.y*100/(volBar.height-slider.height));
			SetVolume(ratio);
		}
	}	

	function slider_onMouseUp(e:MouseEvent)
	{	
	//	_trace('volBar.slider.onMouseUp');
		StopSliderDrag();	
	}
	
	function btnSound_onMouseUp(e:MouseEvent)
	{	
		_trace('Controls.btnSound.onMouseUp volumeBar.visible: '+volBar.visible);	
		ShowVolBar(!volBar.visible);
	}
	
	function stage_OnFullScreen(event:FullScreenEvent):void 
	{
		var bFull=event.fullScreen;
//		if(flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{	
//			var scale=1.0;
			if(bFull)
			{
				// steve pinter: uncomment
				//stage.scaleMode=flashvars.scaleMode;
/*				scale*=fullScreenAspect;		
				Controls.scaleY=scale;
				Controls.scaleX=scale;
//				scale*=0.99;
				volBar.scaleX=scale;
				volBar.scaleY=scale;*/
				ResizeControls(true);
			}
			else
			{
				// steve pinter: uncomment
				//stage.scaleMode=flashvars.scaleMode0;//StageScaleMode.NO_SCALE;
				Controls.progressBar.scrub.x=scrubLeftOffset;
/*				Controls.scaleY=scale;
				Controls.scaleX=scale;
				volBar.scaleY=scale;
				volBar.scaleX=scale;*/
				ResizeControls(false);
			}
		  	SetLoadProgress();
		  	SetProgress();
		}
		OnFullScreen(bFull);
		var menuVisible=menu!=null && menu.visible;
		if(menuVisible)
		{
			menu.visible=false;
		}
		HideAboutBox();
		RedrawBorderSprite();
	}

	function btnFBLogo_onMouseUp(e:MouseEvent)
	{
		_trace('btnFBLogo_onMouseUp');
//		if(hideMenuClick){ hideMenuClick=false; return;}
		if(menu==null)
		{
			menu=new List();
			menu.setStyle("backgroundColor","lightGray");
			menu.setStyle("color","blue");
			menu.setStyle("fontFamily","Arial");
			menu.setStyle("fontSize","12");
			menu.addItem({label:flashvars.str1,value:"1"});//,enabled:false});
			menu.addItem({label:flashvars.str2,value:"2"});
			menu.width=Math.max(GetStringWidth(flashvars.str1),GetStringWidth(flashvars.str2))+43;
			menu.height=41;
			menu.addEventListener(Event.CHANGE, menu_itemSelected);			
			stage.addChild(menu);		
		}
		else if(menu.visible)
		{
			HideMenu();
			return;
		}
	
		var x=Controls.btnFBLogo.x+Controls.btnFBLogo.width-menu.width+borderWidth;
		if(x<0) x=0;
		var y=flashvars.topToolbar?Controls.y+Controls.height: Controls.y-menu.height;
		if(y<0) y=0;
		x += GetCenterShiftX(stage.displayState == StageDisplayState.FULL_SCREEN);
		//y += GetCenterShiftY(stage.displayState == StageDisplayState.FULL_SCREEN);
	
/*		var matrix:Matrix = new Matrix();
		var scaledFS=stage.displayState == StageDisplayState.FULL_SCREEN && flashvars.scaleMode!=StageScaleMode.NO_SCALE;
		if(scaledFS)
		{
			var scale=fullScreenAspect;
			matrix.scale(scale,scale);
			x=(Controls.btnFBLogo.x+Controls.btnFBLogo.width-menu.width)*fullScreenAspect;
			if(x<0) x=0;
			if(!flashvars.topToolbar) y=Controls.y-menu.height*fullScreenAspect;
			if(y<0) y=0;
		}
		menu.transform.matrix = matrix;*/
		
/*		if(isSingleSwf)
		{
			x+=Controls.x;
			menuX=x+autoscrollShiftX;
			menuY=y+autoscrollShiftY;	
	//  		_trace('x='+x+' y='+y);
		}*/
		menu.x=x;
		menu.y=y;
		menu.visible=true;
	}
	
	function menu_itemSelected(event) 
	{
		var selIndex:int = menu.selectedIndex;
		//	  _trace("Item selected: " + item.attributes.label);
		switch(selIndex)
		{
			case 0:
		  		ShowAboutBox();
			  	break;
		  	case 1:
				GetURL(flashvars.str4,"_blank");				  
		  		break;
		}
		HideMenu();
	}

	// Methods
	function HideMenu()
	{
		_trace('HideMenu');
		menu.clearSelection();
		menu.visible=false;
	}
	function StopScrubDrag():void 
	{
		_trace('StopScrubDrag');
		if(scrubDragging)
		{
			Controls.progressBar.scrub.stopDrag();	
			Controls.progressBar.scrub.removeEventListener(Event.ENTER_FRAME,scrub_EnterFrame);
			scrubDragging=false;
		}
	}	
	function ClearPauseFlag()
	{
		if(pausedByInteractiveElement>0)
		{
			pausedByInteractiveElement=0;
		}
	}
	function StopSliderDrag()
	{
		_trace('StopSliderDrag');
		if(sliderDragging)
		{			
			volBar.slider.stopDrag();
			volBar.slider.removeEventListener(Event.ENTER_FRAME,slider_EnterFrame);
			ShowVolBar(false);	
			ClearPauseFlag();
			sliderDragging=false;
		}
	}	
	function OnButtonPlayClicked()
	{
		_trace('OnButtonPlayClicked');
		if(btnClickToStart.visible) OnClickToStart();
		else PlayMovie();
	}
	function GetWidth(ctl)
	{
		return ctl.visible?ctl.width:0;
	}

	function IsMouseOverControl(ctl,xmouse,ymouse):Boolean
	{
	//	_trace(xmouse+' '+ymouse+' '+ctl.x+' '+ctl.y);
		return ctl!=null && ctl.x<=xmouse && xmouse<=(ctl.x+ctl.width) && ctl.y<=ymouse && ymouse<=(ctl.y+ctl.height);	
	}
	
	function IsMouseOverSoundBtn():Boolean
	{
		var xmouse=stage.mouseX-Controls.x;
		var ymouse=stage.mouseY-Controls.y;
		if(stage.displayState == StageDisplayState.FULL_SCREEN && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
			xmouse/=fullScreenAspect;
			ymouse/=fullScreenAspect;
		}
		var ctl=Controls.btnSound;
		return flashvars.showToolbar && IsMouseOverControl(ctl,xmouse,ymouse);	
	}
	
	function IsMouseOverVolumeBar():Boolean
	{
		return flashvars.showToolbar && IsMouseOverControl(volBar,stage.mouseX,stage.mouseY);
	}
	
	function IsMouseOverToolbar():Boolean
	{
		return flashvars.showToolbar && IsMouseOverControl(Controls,stage.mouseX,stage.mouseY);
	}
	
	function IsMouseOverMenu():Boolean
	{
		return flashvars.showToolbar && IsMouseOverControl(menu,stage.mouseX,stage.mouseY);
	}

	function GetStringWidth(s:String)
	{
		var w:int=0;
		if(	textFieldTest==null)
		{
			textFieldTest=new TextField();//101, 0, 0, 400, 100);
			textFieldTest.visible=false;
			var my_fmt:TextFormat = new TextFormat();
			my_fmt.font = "Arial";
			my_fmt.size = 12;
			textFieldTest.setTextFormat(my_fmt);
			textFieldTest.autoSize = TextFieldAutoSize.LEFT;
			this.addChild(textFieldTest);
		}		
		textFieldTest.text=s;
		w=textFieldTest.textWidth;
//		_trace('w='+w);	
		if(w<1)
		{
			w=s.length*175/25;
		}
		return w;
	}
	
	function GetCenterShiftX(bFull:Boolean):Number
	{
		var targetWidth=initialWidth-borderWidth*2;
		if (bFull && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
			targetWidth /= fullScreenAspect;
		}
		targetWidth += borderWidth*2;
		var shiftX:Number = bFull ? (Capabilities.screenResolutionX - targetWidth)/2 : 0;
		return shiftX;
	}
	
	function GetCenterShiftY(bFull:Boolean):Number
	{
		var targetHeight=initialHeight - toolbarHeightForMovieSize - borderWidth*2;
		if (bFull && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
			targetHeight /= fullScreenAspect;
		}
		targetHeight += toolbarHeightForMovieSize + borderWidth*2;
		var shiftY:Number = bFull ? (Capabilities.screenResolutionY - targetHeight)/2 : 0;
		return shiftY;
	}

	function ResizeControls(fullscreenMode:Boolean)
	{
		_trace("ResizeControls fullscreenMode="+fullscreenMode);
		var targetWidth=initialWidth - borderWidth*2;
		var targetHeight=initialHeight - toolbarHeightForMovieSize - borderWidth*2;
		if(fullscreenMode && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
			targetWidth/=fullScreenAspect;
			targetHeight/=fullScreenAspect;
		}
		
		SetCenter(btnClickToStart);
		SetCenter(mcPausedIcon);
		SetCenter(mcOverlayLoading);
		SetCenter(mcJumpLoading);
		
		if(flashvars.showToolbar)
		{
			_trace('ResizeControls: '+targetWidth);
			Controls.x = 0;
			Controls.y = 0;
			if (!flashvars.topToolbar)
				Controls.y = targetHeight + toolbarHeightForMovieSize - toolbarHeight;
			Controls.x += GetCenterShiftX(fullscreenMode) + borderWidth;
			Controls.y += GetCenterShiftY(fullscreenMode) + borderWidth;
			with(Controls)
			{
				bgClip.width=targetWidth;
				var x:Number=0;
				x=SetPos(x,btnFirst);
				x=SetPos1(x,btnPlay);
				btnPause.x=btnPlay.x;
//				x=SetPos(x,btnPrev);
//				x=SetPos(x,btnStop);
//				x=SetPos(x,btnNext);
//				x=SetPos(x,btnLast);
				x+=progressBarOffset;
				var progressBarX:Number=x;
				progressBar.x=progressBarX;
				x=targetWidth-1;
				x=SetPos2(x,btnFBLogo);
				x=SetPos2(x,chkHide);
				x=SetPos2(x,btnSound);
				x=SetPos2(x,btnFullScreen);
				x=SetPos2(x,lblTime);
				var w=x-progressBar.x-progressBarOffset;
	//			_trace(w);
				with(progressBar.timeline)
				{		
					timelineRight.x=w-timelineRight.width;
					timelineFullRight.x=timelineRight.x;
					timelineMiddle.width=timelineRight.x-timelineMiddle.x;	
					timelineFullMiddle.width=0;
					width=w;	
				}
				progressBar.width=w;
				ShowVolBar(false);
			}
		}
		OnResizeControls(fullscreenMode);
	}
	

	function SetPos(x:Number,ctl):Number
	{
		if(ctl.visible)
		{
			ctl.x=x;
			x+=ctl.width;
		}
		return x;
	}
	function SetPos1(x:Number,ctl):Number
	{
		ctl.x=x;
		x+=ctl.width;
		return x;
	}	
	function SetPos2(x:Number,ctl):Number
	{
		if(ctl.visible)
		{
			x-=ctl.width;
			ctl.x=x;
		}
		return x;
	}	

	function ShowVolBar(val: Boolean)
	{
		_trace('ShowVolBar: '+val);
		volBar.visible=val;
		SetupVolControl();
	}
	
	function SetupVolControl()
	{
		_trace('SetupVolControl');
		var x=Controls.btnSound.x;
		var y=flashvars.topToolbar ? Controls.y+Controls.height : Controls.y-volBar.height;
		/*if(stage.displayState == StageDisplayState.FULL_SCREEN && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
			x *= fullScreenAspect;
		}*/
		//var sx:Number = GetCenterShiftX(stage.displayState == StageDisplayState.FULL_SCREEN);
		//var sy:Number = GetCenterShiftY(stage.displayState == StageDisplayState.FULL_SCREEN);
		volBarX=x + Controls.x;
		volBarY=y;
		volBar.x = x + Controls.x;	
		volBar.y = y;
	}

	function RootOnMouseDown()
	{
		if(volBar.visible)
		{
			var b1=IsMouseOverVolumeBar();
			var b2=IsMouseOverSoundBtn();
	//		_trace('>'+b1+' '+b2);
			if(!b1 && !b2) ShowVolBar(false);
		}
		HideAboutBox();
	}

/*	function FullScreenResizeFix()
	{
		if(stage.displayState == StageDisplayState.FULL_SCREEN && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
			stage.scaleMode=flashvars.scaleMode;
			stage.displayState=StageDisplayState.FULL_SCREEN;
			DoPosUpdate();
		}
	}*/
	
	public function GetURL(url:String, window:String) 
	{
/*          var url:String = "http://www.adobe.com";
		var variables:URLVariables = new URLVariables();
		variables.exampleSessionId = new Date().getTime();
		variables.exampleUserLabel = "Your Name";*/

		if(url.toLowerCase().indexOf("mailto:")<0)
		{
			if(url.toLowerCase().indexOf('http://')<0) url='http://'+url;
		}
		var request:URLRequest = new URLRequest(url);
		//            request.data = variables;
		try 
		{            
			navigateToURL(request,window);
		}
		catch (e:Error) 
		{
			trace(e.toString());
			// handle error here
		}
	}
	
	public function ExecuteJScript(jscript:String) 
	{
		_trace('ExecuteJScript: '+jscript);
		try 
		{
			ExternalInterface.call('function(){ '+jscript+' ;}');
		}
		catch (e:Error) 
		{
			trace(e.toString());
			_trace(e.toString());
			// handle error here
		}
	}
	
	function ShowAboutBox()
	{
		_trace('ShowAboutBox');
		var h=60;
		if(aboutBox==null)
		{
			aboutBox=new TextField();//this.createTextField("aboutBox",501, stage.width-171, 30, 170, 60);
			aboutBox.width=170;
			aboutBox.height=h;			
			aboutBox.multiline=true;
			aboutBox.mouseWheelEnabled=false;
			aboutBox.wordWrap=true;
			aboutBox.selectable=false;
			aboutBox.border=true;
	
	/*		var my_fmt:TextFormat = new TextFormat();
			my_fmt.font='Arial';
			my_fmt.size=10;
			aboutBox.setNewTextFormat(my_fmt);*/
			var txt='FlashBack version: '+flashvars.fbVer;
			txt+='\nSWF Toolbar version: '+flashvars.toolbarVersion;		
			aboutBox.text=txt;
			stage.addChild(aboutBox);
		}
		var y=flashvars.topToolbar?Controls.y+Controls.height: Controls.y-h;
		if(y<0) y=0;
		var targetWidth=initialWidth-borderWidth*2;
		if (stage.displayState == StageDisplayState.FULL_SCREEN && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
			targetWidth /= fullScreenAspect;
		}
		targetWidth += borderWidth*2;
		aboutBox.x=targetWidth - 171 - borderWidth + GetCenterShiftX(stage.displayState == StageDisplayState.FULL_SCREEN);
		aboutBox.y=y;
		aboutBox.visible=true;
	}

	function HideAboutBox()
	{
		_trace('HideAboutBox');
		if(aboutBox!=null)
		{
			aboutBox.visible=false;
		}
	}

	function UpdateLoadingMeter()
	{
	//	_trace('UpdateLoadingMeter');
		if(movieLoaded) showMovieLoadingOverlay=false;
		else
		{
			if(isPlaying)
			{
				if((timerCount%10)==0)
				{
				  var t:Number= GetCurrentTime();
				  showMovieLoadingOverlay=t-prevTime<0.1;
				  prevTime=t;
				}
			}	
			if(flashvars.startFrame>0) showMovieLoadingOverlay=true;
			if(showMovieLoadingOverlay && (btnClickToStart.visible || mcPausedIcon.visible)) showMovieLoadingOverlay=false;
		}
	
		if(mcOverlayLoading.visible!=showMovieLoadingOverlay) mcOverlayLoading.visible=showMovieLoadingOverlay;
		if(showMovieLoadingOverlay)
		{
			var index:int=(timerCount/2)%8;
			mcOverlayLoading.gotoAndStop(index+1);
		}
	}
	function SetLoadProgress()
	{
		_trace('SetLoadProgress');
		if(flashvars.showToolbar && Controls.progressBar.visible)
		{
			with(Controls.progressBar.timeline)
			{
				var w=GetMovieLoadProgress();
	//			_trace('w='+w);
				timelineFullMiddle.width=timelineMiddle.width*w;
			}
		}
	}

	function CheckWidth()
	{
		_trace('CheckWidth');
	//	_trace('CheckWidth width='+width);
	//	_trace(' width='+width);
	//	_trace(' stage.width='+stage.width);
		var mcWidth=initialWidth;//stage.width
		with(Controls)
		{
		  var ar:Array=new Array(chkHide,btnFBLogo,btnSound,btnFullScreen,lblTime/*,btnStop,btnLast,btnPrev,btnNext*/);
		  var w=btnFirst.width+btnPlay.width+timelineMinWidth;
	//	  _trace(' w='+w);
          var i:int=0;
		  var ctl;
		  for(i=0;i<ar.length;i++)
		  {
			  ctl=ar[i];
			  if(ctl.visible)
			  {
				 w+= ctl.width;
			  }
		  }	
	//	  _trace(' w='+w);
		  for(i =0;i<ar.length && w>mcWidth;i++)
		  {
			  ctl=ar[i];
			  if(ctl.visible)
			  {
				 ctl.visible=false;
				 w-= ctl.width;
			  }
		  }	
		}
	}

	function FinalActions()
	{
		_trace('FinalActions');
/*		if(flashvars.expiredDate.length>0)
		{
			Controls.visible=false;
			mcOverlayLoading.visible=false;		
			ifExpiryDateExists();
		}
		else if(flashvars.pwd.length>0)
		{
			Controls.visible=false;
			mcOverlayLoading.visible=false;
			var passwordChecking=new PasswordChecking();
			passwordChecking.ifPasswordExists();
		}
		else*/
		{
			trace('showToolbar='+flashvars.showToolbar);
			passwordChecked=true;
			Controls.visible=flashvars.showToolbar;
			mcOverlayLoading.visible=true;
			if(flashvars.showToolbar) CheckWidth();
			ResizeControls(false);
			if(flashvars.showToolbar) SetLoadProgress();
			timer.start();
		}
	}	
	function SetCenter(ctl)
	{
		var k=0.5;
		var fullscreenMode=stage.displayState == StageDisplayState.FULL_SCREEN;
		if(fullscreenMode && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
			k/=fullScreenAspect;
		}
		var sx:Number = GetCenterShiftX(fullscreenMode);
		var sy:Number = GetCenterShiftY(fullscreenMode);
		ctl.x=initialWidth*k-ctl.width/2 + sx;
		ctl.y=initialHeight*k-ctl.height/2 + sy;	
	}
	function _trace(obj:Object)
	{		
		var msg=obj.toString();
		if(debugText!=null) debugText+=msg+'\n';
		else if(flashvars!=null && flashvars.debugMode==2 && lblDebug!=null)
		{
	    	lblDebug.appendText(msg+'\n');
		}
		trace(msg);
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
	function GetTwoDigits(i)
	{
		return i>9 ? i:"0"+i;
	}	
}
}