package AS3{
import flash.events.*;
import flash.display.*;
import flash.text.*;
import flash.geom.*;
import flash.events.*;
import flash.external.*;
import flash.media.*;
import flash.ui.*;
import flash.net.*;
import flash.system.*;
import flash.utils.Timer;
import fl.video.*;
import AS3.Flashvars;
import AS3.Common;
import AS3.Element;
import AS3.Elements;
import AS3.ButtonElement;
import AS3.PauseElement;
import flash.utils.Timer;
import flash.events.TimerEvent;

//#include "expiring_checking.as"
//#include "password_checking.as"
public class CommonMultiple extends Common
{
	// constants
	var durationDeviation=0.1;
	const timeDelta:int = 10;//[ms]
	
	// variables
	var movieState=0;
	var pauseFlagFrame=0;	
	var level1PrevFrame;
	var level1Initialised=false;
	var nsTime:Number=0;
	var toolbarLoaded=false;
	var previewLoaded=false;
	var nc:NetConnection = new NetConnection();	
	var isSwf=false;
	var ns:NetStream;
//	var frameRate:int=0;
//	var movieWidth:int=0;
//	var movieHeight:int=0;
	var duration:Number = 0;

	// Clips	
	var mcPreview:MovieClip=null;
	var mcWhiteRect:MovieClip=new WhiteRect();
	var mcWhiteRect2:MovieClip=new WhiteRect();
	var theMovie:MovieClip=null;
	var theVideo:Video=null;
	var Controls:ControlBar=new ControlBar();
	
	// interactive elements
	var elements:Elements=new Elements();
	var sprite:Sprite =new Sprite();
//	var autoscrollZoomPanList:Array=null;
	var timerObject:Timer = new Timer(1000, 1);
	var autohideTimer:Timer = new Timer(3000, 1);
	protected var jumpTimer:Timer = new Timer(timerInterval);
	protected var jumpTimerCount:int=0;
	protected var jumpTime:Number;
	protected var jumpBtn:ButtonElement;
	protected var startJumpTime:Number = 0;
	
	//var default_bg_color:uint = 0xffff00;

	var bgshape:Sprite;
	//stage.align = "CC";
	
	function initBG()
	{
		bgshape = new Sprite();
		_trace('fullScreenBackgroundColor: ' + flashvars.fullScreenBackgroundColor);
		bgshape.width = 1;
		bgshape.height = 1;
		bgshape.graphics.beginFill(flashvars.fullScreenBackgroundColor);
		bgshape.graphics.drawRect(0,0,1,1);
		stage.addChildAt(bgshape, 0);
		stage.addEventListener(Event.RESIZE, resizeBGWithStage);
	}
	function changeBGColor(color:uint) 
	{
		bgshape.graphics.beginFill(color);
		bgshape.graphics.drawRect(0,0,stage.stageWidth, stage.stageHeight);
	}
	function resizeBGWithStage(e:Event)
	{
		try {
			if (stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				bgshape.width = stage.stageWidth;
				bgshape.height = stage.stageHeight;
				//bgshape.graphics.beginFill(flashvars.fullScreenBackgroundColor);
				//bgshape.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			}
			else
			{
				bgshape.width = 1;
				bgshape.height = 1;
			}
		} catch(e){}
	}
		
	public function CommonMultiple()
	{
		trace('CommonMultiple');
		mcCompatibility.visible=false;
		stage.addChild(Controls);
		Init(Controls,false);
/*		if(!CheckVersion())
		{
			mcBlackRect.visible=false;
			return;
		}*/
		
		// clips
//		stage.addChild(mcWhiteRect);
//		stage.addChild(mcWhiteRect2);
//		stage.addChild(sprite);
		
		// visibility
		mcWhiteRect.visible=false;
		mcWhiteRect2.visible=false;
		if(!flashvars.dimPreview) mcBlackRect.visible=false;
/*		Controls.btnNext.visible=flashvars.showNextButton && isSwf;
		Controls.btnPrev.visible=flashvars.showPrevButton && isSwf;*/
			
		// initialisation
		isSwf=flashvars.fileName.toLowerCase().indexOf(".swf")>0;		
		_trace('isSwf='+isSwf);
		if(!isSwf)
		{
			// net stream
			var customClient:Object = new Object();
			customClient.onMetaData = metaDataHandler;
			customClient.onCuePoint=ns_onCuePoint;
			customClient.onStatus=ns_onStatus;
			nc.connect(null);
			ns = new NetStream(nc);
			ns.client = customClient;
			theVideo=new Video();
			stage.addChildAt(theVideo,0);
			stage.addChildAt(sprite,1);
			theVideo.width=videoWidth;
			theVideo.height=videoHeight;
			theVideo.attachNetStream(ns);
//			theVideo.visible=false;
			theVideo.smoothing=true;
		}
		SetPreview();				
		SetHandlersM();		
		FinalActions();
		initBG();
		
		jumpTimer.stop();
		//jumpTimer.addEventListener(TimerEvent.TIMER, OnJumpTimer);
	}
	
	function SetPreview()
	{
		if(flashvars.previewFileName!=null)
		{
		  _trace('previewFileName: '+flashvars.previewFileName);
		  if(flashvars.previewFileName.length>0)
		  {
			var loader:Loader = new Loader();
			var urlReq:URLRequest = new URLRequest(flashvars.previewFileName);
			loader.load(urlReq);
			var v=loader.content;
			mcPreview=v;			  
			stage.addChild(mcPreview);
//  		theMovie.createEmptyMovieClip("mcPreview",-18000);
			mcPreview.x=0 + borderWidth;
			mcPreview.y=flashvars.showToolbar && flashvars.topToolbar ? Controls.height + borderWidth : borderWidth;
			mcPreview.quality = 'best';
		  }
		  else
		  {
			  _trace('embedded preview');
			  previewSymbol.x=0;
			  previewSymbol.y=0;
			  if(flashvars.showToolbar && flashvars.topToolbar) previewSymbol.y=Controls.height;
			  _trace('previewSymbol.y: '+previewSymbol.y);
			  previewSymbol.x += borderWidth;
			  previewSymbol.y += borderWidth;
			  previewSymbol.width=initialWidth-borderWidth*2;
			  previewSymbol.height=initialHeight-previewSymbol.y-borderWidth*2;
			  previewSymbol.scaleX=flashvars.psx/100;
			  previewSymbol.scaleY=flashvars.psy/100;
			  previewSymbol.visible=true;
			  previewLoaded=true;
		  }
		}
	}
	
	// Override	
	override function GetLoaderInfo():LoaderInfo{return loaderInfo;}
	override function GetMovieLoadProgress()
	{
		if(movieState<1) return 0;	
		var d=0;
		if(isSwf)
		{
			d= theMovie.framesLoaded/theMovie.totalFrames;
		}
		else
		{
			d=  ns.bytesTotal>0 ? ns.bytesLoaded/ns.bytesTotal : 0;	
			_trace('ns.time='+ns.time+' bytesLoaded='+ns.bytesLoaded+' bytesTotal='+ns.bytesTotal);
		}
		if(d<0) d=0;
		else if(d>1) d=1;
		return d;
	}
	function SecondsLoaded()
	{
			if (isSwf)
			{
					return theMovie.framesLoaded / flashvars.fps;
			}
			else
			{
					return (ns.bytesLoaded/ns.bytesTotal)*duration;
			}
	}
	override function OnClickToStart()
	{
		_trace('OnClickToStart');
		btnClickToStart.visible=false;
		if(movieLoaded) PlayMovie();
		else LoadMovie2();
	}
	override function SetProgressByCoord(x:Number)
	{
		if(flashvars.showToolbar && Controls.progressBar.visible)
		{
			var pr=(x-scrubLeftOffset)/(Controls.progressBar.width-scrubOffset);
			if(isSwf)
			{
				var frameIndex = Math.round(theMovie.totalFrames*pr);
				if(frameIndex==0) frameIndex=1;
				if(frameIndex>=1&&frameIndex<=theMovie.totalFrames)
				{
					_trace(frameIndex);
					if(isPlaying) theMovie.gotoAndPlay(frameIndex);
					else theMovie.gotoAndStop(frameIndex);
					UpdateControls();
				}
			}
			else
			{
				var time = duration*pr;
				ns.seek(time);			
				UpdateControls();
			}
		}
	}
	override function PlayMovie()
	{
		_trace("PlayMovie");
		ClearPauseFlag();
		if(movieState<2)
		{
			StartPlay();
			return;
		}
		if(flashvars.startFrame>0) return;
//		check for security code
//		theMovie.VerifySecurityCode(flashvars.specialcode);
		if(isSwf)
		{
		  theMovie.play();
		}
		else
		{
		   ns.resume();
		}
		isPlaying=true;
		UpdateControls();
	}
	override function StopMovie()
	{
		_trace('StopMovie');
		if(isSwf)
		{
			theMovie.gotoAndStop(theMovie.currentFrame);
		}
		else
		{
			ns.pause();
		}
		isPlaying=false;
		UpdateControls();
	}
	override function PauseMovie()
	{
		_trace('PauseMovie');
		ClearPauseFlag();
		if(isSwf)
		{
		  theMovie.stop();
		}
		else
		{
		  ns.pause();
		}
		isPlaying=false; 
		UpdateControls();
	}
	
	function DelayMovie(duration:int)
	{
		_trace("DelayMovie: " + duration);
		RemoveDelay();
		//if (duration)
		//{
		//delayId = setInterval(RemoveDelay, pauseduration);
		timerObject.delay = duration;//pauseduration;
		timerObject.addEventListener(TimerEvent.TIMER, RemoveDelayHandler);
		timerObject.start();
		if (isSwf)
		{
			theMovie.stop();
		}
		else
		{
			ns.pause();
		}
		isPlaying=false;
		//}
		_trace("End DelayMovie");
	}
	
	function RemoveDelayHandler(eventObject:TimerEvent)
	{
		_trace("RemoveDelayHandler");
		RemoveDelay();
		_trace("End RemoveDelayHandler");
	}
	
	override function RemoveDelay()
	{
		_trace("RemoveDelay");
		if (timerObject.running)
		{
			timerObject.stop();
			if (!isPlaying)
			{
				_trace("RemoveDelay !isPlaying");
				if (isSwf)
				{
					_trace("theMovie.play");
					theMovie.play();
				}
				else
				{
					_trace("ns.play");
					ns.resume();
				}
				isPlaying=true;
			}
		}
		_trace("End RemoveDelay")
	}
	
	override function DoPosUpdate()
	{
/*		_trace('theVideo.scaleX: '+theVideo.scaleX);

		if(theMovie.autoscrollShiftX==undefined) theMovie.autoscrollShiftX=0;
		if(theMovie.autoscrollShiftY==undefined) theMovie.autoscrollShiftY=0;
		var dy=flashvars.showToolbar && flashvars.topToolbar ? Controls.height : 0;
		if(flashvars.showToolbar && stage.displayState == StageDisplayState.FULL_SCREEN)
		{
			if(flashvars.scaleMode!=StageScaleMode.NO_SCALE)
			{
			  dy=flashvars.topToolbar? hgap*fullScreenAspect+Controls.height:hgap*fullScreenAspect;
			}
		}
		theMovie.x=theMovie.autoscrollShiftX;
		theMovie.y=theMovie.autoscrollShiftY+dy;*/
	}
	
	override function GetCurrentTime()
	{
		if(movieState<1) return 0;
		var t=0;
		if(isSwf)
		{
			if(theMovie.totalFrames>0)
			{
				t=theMovie.currentFrame * duration/theMovie.totalFrames;
			}
		}
		else
		{
			if(ns.time>0)
			{
			  t=ns.time;	
			}
		}
		return t;
	}
	override function OnTimer() 
	{ 
		if(!toolbarLoaded)
		{
			if(stage.loaderInfo.bytesLoaded==stage.loaderInfo.bytesTotal)
			{
				toolbarLoaded=true;
				OnToolbarLoaded();
			}
		}
	
		if(!previewLoaded && mcPreview!=null)
		{
			if(mcPreview.bytesLoaded==mcPreview.bytesTotal)
			{
				previewLoaded=true;
				OnPreviewLoaded();
			}
		}
		if(movieState>0)
		{
			if(isSwf)
			{
				if(theMovie.currentFrame>=0)
				{
					if(!level1Initialised && theMovie.framesLoaded>0) 
					{
						InitLevel1();
						level1Initialised=true;
					}		  
					if(theMovie.currentFrame!=level1PrevFrame)
					{
						level1PrevFrame=theMovie.currentFrame;
						MovieOnEnterFrame();
					}		  
					if(!movieLoaded)
					{
						SetLoadProgress();
						if(theMovie.framesLoaded==theMovie.totalFrames)
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
			if(toolbarLoaded && !movieLoaded && flashvars.startingPlaybackMode!=1 && movieState<2) CheckPreload();
		}
		UpdateLoadingMeter();
	}
	override function OnResizeControls(fullscreenMode:Boolean)
	{
		if(!isSwf)
		{
			theVideo.x=0;
		  	theVideo.y=flashvars.showToolbar && flashvars.topToolbar && !flashvars.autoHideToolbar ? Controls.height:0;
			sprite.x=theVideo.x+flashvars.pw/2;
			sprite.y=theVideo.y+(flashvars.showToolbar && !flashvars.topToolbar? flashvars.ph : 0);
			theVideo.x += GetCenterShiftX(fullscreenMode)+borderWidth;
			theVideo.y += GetCenterShiftY(fullscreenMode)+borderWidth;
			sprite.x += GetCenterShiftX(fullscreenMode)+borderWidth;
			sprite.y += GetCenterShiftY(fullscreenMode)+borderWidth;
//			sprite.x=theVideo.x;
//			sprite.y=theVideo.y;
//		  theVideo.width=initialWidth;
//		  theVideo.height=flashvars.showToolbar?initialHeight-Controls.height:initialHeight;
		}
		
/*		if(flashvars.showToolbar && isSwf)
		{	
			if(fullscreenMode && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
			{
				Controls.y =flashvars.topToolbar ? hgap*fullScreenAspect : initialHeight-Controls.height-hgap*fullScreenAspect;
			}
			DoPosUpdate();
		}*/
	}
	override function SetProgress()
	{
		if(flashvars.showToolbar && !scrubDragging && Controls.progressBar.visible)
		{
			with(Controls.progressBar)
			{
				var pr=0;
				if(isSwf) pr=theMovie.totalFrames>1?(theMovie.currentFrame-1)/(theMovie.totalFrames-1): 0;
				else
				{
					pr=ns.time/duration;
				    if(ns.time > duration-durationDeviation) pr=1.;
				}
				if(!movieLoaded)
				{
					var w=GetMovieLoadProgress();
					if(pr>w) pr=w;
				}
				if(pr<0) pr=0;
				else if(pr>1) pr=1;
//				trace('pr='+pr);
				scrub.x=scrubLeftOffset+(width-scrubOffset)*pr;
			}
		}
	}	
	override function OnFullScreen(bFull:Boolean)
	{
		_trace('stage_OnFullScreen bFull='+bFull);
		if(bFull)
		{
			if(flashvars.scaleMode!=StageScaleMode.NO_SCALE)
			{
				theVideo.width=videoWidth/fullScreenAspect;
				theVideo.height=videoHeight/fullScreenAspect;
//				theVideo.scaleX=scale;//(Number)initialStageWidth/initialWidth;///fullScreenAspect/stage.width;
//				theVideo.scaleY=scale;//initialHeight/fullScreenAspect/stage.height;
			}
			//theVideo.x = theVideo.width
			// steve pinter:
			/*var sx:Number = stage.stageWidth ;
			var sy:Number = stage.stageHeight;
			var mw:Number = theVideo.width;
			var mh:Number = theVideo.height;
			var xpos:Number = sx/2 - mw/2;
			var ypos:Number = sy/2 - mh/2;
			//var xshift:Number = xpos - theVideo.x;
			//var yshift:Number = ypos - theVideo.y;
			theVideo.x = xpos;
			theVideo.y = ypos;*/
		}
		else
		{
			theVideo.width=videoWidth;
			theVideo.height=videoHeight;
//			theVideo.scaleY=1;
//			theVideo.scaleX=1;
		}
		
		if(flashvars.dimPreview && mcBlackRect.visible)
		{
			mcBlackRect.y=0;
			mcBlackRect.height=initialHeight;
		}
		if(mcPreview!=null)
		{
			if(bFull && flashvars.scaleMode!=StageScaleMode.NO_SCALE && flashvars.showToolbar)
			{
				mcPreview.y=flashvars.topToolbar? Controls.height:0;
				mcPreview.y+= borderWidth;
			}
			else
			{
				mcPreview.y=(flashvars.showToolbar && flashvars.topToolbar) ? Controls.height : 0;
				mcPreview.y+= borderWidth;
			}
		}
		if(previewSymbol.visible && mcWhiteRect!=null)
		{
			previewSymbol.y=(flashvars.showToolbar && flashvars.topToolbar) ? Controls.height : 0;
			if(bFull)
			{
				mcWhiteRect.x=initialWidth;
				mcWhiteRect.y=0;			
				mcWhiteRect2.x=0;
				mcWhiteRect2.y=flashvars.showToolbar && flashvars.topToolbar?initialHeight:initialHeight-toolbarHeight;			
				if(flashvars.scaleMode==StageScaleMode.NO_SCALE)
				{
	
				}
				else
				{
					if(flashvars.showToolbar)
					{
						previewSymbol.y=flashvars.topToolbar? Controls.height:0;
						mcWhiteRect2.y=initialHeight- (flashvars.topToolbar?0:Controls.height);
					}								
				}
				mcWhiteRect.width=Capabilities.screenResolutionX;
				mcWhiteRect.height=Capabilities.screenResolutionY;
				mcWhiteRect.visible=true;
				mcWhiteRect2.width=Capabilities.screenResolutionX;
				mcWhiteRect2.height=Capabilities.screenResolutionY;
				mcWhiteRect2.visible=true;
			}
			else
			{
				mcWhiteRect.visible=false;
				mcWhiteRect2.visible=false;
			}
		}
		UpdateInteractiveElements();
	}	
	override function SetVolume(ratio:Number)
	{
		var d=ratio/100;
		if(isSwf)
		{
		}
		else
		{
			if(ns!=null)
			{
//				_trace(d);
				var sf:SoundTransform=new SoundTransform();
				sf.volume=d;
				SoundMixer.soundTransform=sf;//volume=d;//[0-1]
			}
		}
	}
	
	// Handlers
	function SetHandlersM()
	{
//		trace('SetHandlersM');
		with(Controls)
		{
			btnFirst.addEventListener(MouseEvent.CLICK, btnFirst_onMouseUp);
//			btnNext.addEventListener(MouseEvent.CLICK, btnNext_OnRelease);
//			btnLast.addEventListener(MouseEvent.CLICK, btnLast_OnRelease);
//			btnPrev.addEventListener(MouseEvent.CLICK, btnPrev_OnRelease);
//			btnStop.addEventListener(MouseEvent.CLICK, btnStop_OnRelease);
		}
					
			
//		ns.addEventListener(MetadataEvent.METADATA_RECEIVED, flvPlayback_metadataReceived);
//		ns.addEventListener("cuePoint", ns_onCuePoint);	
//		ns.addEventListener(NetStatusEvent.NET_STATUS, ns_onStatus);
 		
		with(stage)
		{
			addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
			addEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
		}
	}
	
	function ns_onCuePoint(infoObject:Object):void 
	{ 
		_trace("onCuePoint");
		try
		{
//			trace(typeof(infoObject.time));
//			trace(infoObject.time);
/*			var key:String;
			for (key in infoObject)
			{
				trace(key + ": " + infoObject[key]);
			}*/
			
			var info=infoObject.name;
/*			if(info.indexOf('fbh')==0)
			{
				OnCuePointHeader(infoObject);
			}
			else*/ if(info.indexOf('fb;')==0)
			{
				// split to several objects (Steve Pinter)
				var lines:Array = info.split(";fb;");
				for (var i:int = 0; i < lines.length; i++)
				{
					if (i>0)
						lines[i] = "fb;" + lines[i];
					OnCuePointElement(infoObject, lines[i]);
				}
				//OnCuePointElement(infoObject);
			}
		}
		catch(ex)
		{
			_trace(ex);
		}
	}	

/*	function OnCuePointHeader(infoObject:Object)
	{
//		trace("OnCuePointHeader");
		if(autoscrollZoomPanList==null)
		{
			autoscrollZoomPanList=new Array();
			var info=infoObject.name;
			var lines:Array = info.split("\n");
			for(var i:int=0;i<lines.length;i++)
			{
				var ss:Array=lines[i].split(' ');
				if(ss.length==7)
				{
					autoscrollZoomPanList.push(new AutoscrollZoomPanInfo(ss));
				}
			}
		}
	}*/
	
	function OnCuePointElement(infoObject:Object, info:String)
	{
		_trace("OnCuePointElement");
		//var info=infoObject.name;
		_trace(info);			
		Element.common = this;
		var id:int = Element.GetId(info);			
		var el:Element=elements.GetElementById(id);
		var firsttime:Boolean = el == null;
		var time:int=infoObject.time*1000;
		if(el==null)
		{
			_trace("el==null");	
			// Steve Pinter : Comment out	
		    if(Element.IsPaused(info))
			{
				StopMovie();
			}
			el=Element.Parse(info);
			_trace("after parse");
			el.time=time/*-500./flashvars.fps*/;
			elements.Add(el);
			_trace("elementTypeID : " + el.type);
			if(el.type==Element.typeButton)
			{
				_trace("button initialization");
				if(flashvars.IsMovieScaled)
				{
					// Steve Pinter: Uncomment?
//					el.Button.ScaleX(flashvars.mw,flashvars.sw);
//					el.Button.ScaleY(flashvars.mh,flashvars.sh);
				}
				el.Button.InitShape(flashvars.debugMode>0);
				// Steve Pinter: Done into InitShape?
				el.Button.shape.visible=false;
//					if(theVideo.y!=0) el.Button.shape.y+=theVideo.y
				sprite.addChild(el.Button.shape);
				el.Button.shape.addEventListener(MouseEvent.MOUSE_DOWN, ShapeClickHandler);
			}
		}
/*			elements.GetItem(index);
		trace(el.toString());
		btn.x=el.x;
		btn.y=el.y+theVideo.y;
		btn.width=el.w;
		btn.height=el.h;
		btn.visible=true;
		curElement=el;*/
		//var afterjump:Boolean = !isSwf && ns.time != time;
		if(el!=null)
		{				
			_trace("el!=null");
			switch(el.type)
			{
				case Element.typeButton:
					if(el.Button.pause)
					{
						if (firsttime)
							PauseAndSeek(time, el.type);
						else
							StopMovie();
					}
				break;
				case Element.typePause:
					PauseOrDelay(time, el.Pause.waitclick, el.Pause.duration, el.type, firsttime);
				break;
				default:
					if (firsttime)
						PauseAndSeek(time, el.type);
					else
						StopMovie();
				break;
			}
		}
		// Steve Pinter: added by me
		UpdateInteractiveElements();
	}
	
	function PauseOrDelay(time:int, waitclick:Boolean, duration:int, elType:int, firsttime:Boolean)
	{
		_trace("PauseOrDelay " + time + " " + waitclick + " " + duration);
		if (waitclick)
		{
			if (firsttime)
				PauseAndSeek(time, elType);
			else
				StopMovie();
		}
		else
		{
			pausedByInteractiveElement = elType;
			DelayMovie(duration);
			if(flashvars.sf!=0)
			{
		  		var timeMS:int=time+flashvars.sf;
		  		ns.seek(timeMS/1000.0);			
			}
			//UpdateControls();
			//UpdateInteractiveElements();
		}
	}
	
	function PauseAndSeek(time:int, elType:int)//ms
	{
		_trace('PauseAndSeek: '+time);
//		time+=timeDelta;
		PauseMovie();
		pausedByInteractiveElement = elType;
		if(flashvars.sf!=0)
		{
		  var timeMS:int=time+flashvars.sf;
		  ns.seek(timeMS/1000.0);			
		}
		UpdateControls();
		UpdateInteractiveElements();
	}
	
	function GetFlvOffset(w:int):int
	{
		var r:int=(w/16)*16;
		if(r<w) r+=16;
		return (r-w)/2;
	}
	
	function metaDataHandler(info:Object):void 
	{
		trace('metaDataHandler');
//		frameRate=info.frameRate;
//		movieWidth= info.width;
//		movieHeight= info.height;
		duration = info.duration;
		_trace('duration=' + duration); // 16.334
//		_trace('framerate=' + frameRate); // 15
//		trace("width:",movieWidth); // 320
//		trace("height:",movieHeight); // 213
		_trace('theVideo.width='+theVideo.width);
//		theVideo.width=movieWidth;
//		theVideo.height=movieHeight;

//		sprite.width=movieWidth;
//		sprite.height=movieHeight;
		sprite.visible=true;
		CheckStartFrame();
	}
	
	function ns_onStatus(info)
	{
//		_trace('ns_onStatus: '+info.code);
		switch(info.code)
		{
			case "NetStream.Buffer.Full":
			break;
			case "NetStream.Buffer.Empty":
			break;
			case "NetStream.Play.Start":
			break;
			case "NetStream.Play.Stop":
				if(flashvars.loopPlayback) ns.seek(0);
				else
				{
				  StopMovie();
				  Controls.progressBar.scrub.x=Controls.progressBar.width-scrubRightOffset;
				}
			break;
			case "NetStream.Play.StreamNotFound":
				_trace(info.code);
			break;
			case "NetStream.FileStructureInvalid":
				_trace(info.code);
			break;
			case "NetStream.Seek.InvalidTime":
				_trace(info.code);
			break;
		}
	}
	
	function stage_onMouseMove(e:MouseEvent)
	{
		_trace("stage_onMouseMove");
//		if(passwordChecked) 
		{
			CheckMousePos();	
		}
		if (flashvars.autoHideToolbar)
		{
			_trace("stage_onMouseMove.autoHideToolbar");
			showToolbar(true);
			//removeAutohideTimer();
			if (autohideTimer.running)
				autohideTimer.stop();
			setAutohideTimer();
		}
	}
	
	function setAutohideTimer()
	{
		autohideTimer.addEventListener(TimerEvent.TIMER, onAutohideTimer);
		autohideTimer.start();
	}
	
	function onAutohideTimer(eventObject:TimerEvent)
	{
		showToolbar(false);
		autohideTimer.stop();
	}
	
	function showToolbar(sh:Boolean)
	{
		Controls.visible = sh;
		if (sh == false)
		{
			HideMenu();
			HideAboutBox();
			ShowVolBar(false);
		}
	}

	function stage_onMouseDown(e:MouseEvent)
	{
		_trace('stage_onMouseDown');
		if(sliderDragging || scrubDragging) return;
		_trace('target='+e.target);
		if(e.target!=stage && e.target!=mcPausedIcon && e.target!=bgshape) return;
/*		if(CheckElementHit(e.stageX, e.stageY))
		{
			return;
		}*/
		var menuVisible=menu!=null && menu.visible;
		if(flashvars.pauseByClickingOnMovie && movieState>=2 && !volBar.visible && !menuVisible)
		{
		  var isMouseOver=IsMouseOverToolbar();
		  if(!isMouseOver)
		  {
			if(isSwf && ignoreClickFrame==theMovie.currentFrame)
			{
				return;
			}
			if(isPlaying)
			{
				userPauseCount++;
				PauseMovie();
			}
			else
			{
				if(pausedByInteractiveElement!=Element.typeButton) PlayMovie();
			}
		  }
		}
		RootOnMouseDown();
	}
	
	function btnFirst_onMouseUp(e:Event)
	{
		if(isSwf)	
		{
			theMovie.gotoAndStop(1);
		}
		else 
		{
			ns.pause();
			ns.seek(0);
		}
		isPlaying=false;
		UpdateControls();
	}
	
/*	function btnNext_onMouseUp(e:MouseEvent)
	{
		if(isSwf)	
		{
			theMovie.gotoAndStop(theMovie.currentFrame+1);
		}
		else
		{
			
		}	
		isPlaying=false;
		UpdateControls();
	}
	
	function btnPrev_onMouseUp(e:MouseEvent)
	{
		if(isSwf)
		{
		  theMovie.gotoAndStop(theMovie.currentFrame-1);
		}
		else
		{
			
		}
		isPlaying=false;
		UpdateControls();
	}
	function btnLast_onMouseUp(e:MouseEvent)
	{
		if(isSwf)
		{
		  theMovie.gotoAndStop(theMovie.totalFrames);
		}
		else
		{
			ns.seek(duration);
		}
		isPlaying=false;
		UpdateControls();
	}*/



	// functions
	function FBStopMovie()
	{
		_trace('FBStopMovie');
		if(isSwf)
		{
			pauseFlagFrame=theMovie.currentFrame;
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
	function OnToolbarLoaded()
	{
		_trace('OnToolbarLoaded');
		if(flashvars.jsEvents)
		{
			if(ExternalInterface.available)
			{
				ExternalInterface.call("OnToolbarLoaded()");
			}
		}
		
		if(flashvars.startingPlaybackMode==0)
		{
			btnClickToStart.visible=true;
			mcPausedIcon.visible=false;
		}
		else LoadMovie2();
		//steve pinter
		if (flashvars.autoHideToolbar)
			setAutohideTimer();
	}
	function OnMovieLoaded()
	{
		_trace('OnMovieLoaded');
		if(flashvars.showToolbar)
		{
			with(Controls.progressBar.timeline)
			{
				timelineFullRight.visible=true;
			}	
		}
		showMovieLoadingOverlay=false;
		if(flashvars.startingPlaybackMode==1)
		{
			if(movieState<2) btnClickToStart.visible=true;
			mcPausedIcon.visible=false;
		}
		else if(movieState<2) StartPlay();
		CheckStartFrame();
	}
	function SetTime()
	{
		if(flashvars.showToolbar)
		{
			// _trace("SetTime");
			var sec,tsec;
			if(isSwf)
			{
			  sec=Math.floor(theMovie.currentFrame/flashvars.fps);
			  tsec=Math.floor(theMovie.totalFrames/flashvars.fps);
			  Controls.lblTime.text=GetTimeString(sec)+"/"+GetTimeString(tsec);
			}
			else
			{
			  sec=Math.floor(ns.time);
			  tsec=Math.floor(duration);
			  Controls.lblTime.text=GetTimeString(sec)+"/"+GetTimeString(tsec);
			}
		}
	}

	function IsMovieEnd():Boolean
	{
		if(!movieLoaded) return false;
		return isSwf?theMovie.currentFrame==theMovie.totalFrames: ns.time>=duration-durationDeviation;
	}
	function UpdateControls()
	{
		_trace('UpdateControls isPlaying='+isPlaying);
		if(isSwf && pauseFlagFrame!=theMovie.currentFrame) pauseFlagFrame=0;
		mcPausedIcon.visible=!isPlaying && movieState>0 && flashvars.showPausedOverlay && !IsMovieEnd() && !btnClickToStart.visible && pauseFlagFrame==0 && userPauseCount>0 && pausedByInteractiveElement==0;
		_trace('mcPausedIcon.visible = ' + mcPausedIcon.visible);
		if(!isSwf && pauseFlagFrame>0) pauseFlagFrame=0;
		if(!flashvars.showToolbar) return;
	
		Controls.btnPlay.enabled=!IsMovieEnd();
		if(isSwf)
		{
		  if(theMovie.currentFrame==theMovie.totalFrames)
		  {
			  if(isPlaying)
			  {
				  if(flashvars.loopPlayback)
				  {
					theMovie.gotoAndPlay(1);
				  }
				  else
				  {
					theMovie.gotoAndStop(theMovie.currentFrame);
					isPlaying=false;
				  }
			  }
		  }
	
		  Controls.btnFirst.enabled=theMovie.currentFrame>1;
//		  Controls.btnLast.enabled=theMovie.currentFrame<theMovie.totalFrames;
		  Controls.btnPrev.enabled=theMovie.currentFrame>1;
		  Controls.btnNext.enabled=theMovie.currentFrame<theMovie.totalFrames;
		}
		else
		{
		  if(ns.time>=duration && duration>0)
		  {
			  if(isPlaying) ns.pause();
			  isPlaying=false;
		  }
		  Controls.btnFirst.enabled=ns.time>0;
//		  Controls.btnLast.enabled=ns.time<duration;
		}
	  Controls.btnPlay.visible = !isPlaying;
	  Controls.btnPause.visible = isPlaying;
	  SetProgress();
	}
		
	function ClearPreview()
	{
		if(mcPreview!=null)
		{
			stage.removeChild(mcPreview);
			mcPreview=null;
		}	
		if(previewSymbol!=null)
		{
			previewSymbol.visible=false;
			mcWhiteRect.visible=false;
			mcWhiteRect2.visible=false;
			mcWhiteRect.height=0;
			mcWhiteRect2.height=0;
		}
		if(mcBlackRect!=null) mcBlackRect.visible=false;
//		if(theMovie.fb_preview!=undefined) theMovie.fb_preview.visible=false;
	}
	
	function LoadMovie2()
	{	
		_trace('LoadMovie2 fileName='+flashvars.fileName);
		ClearPreview();
		showMovieLoadingOverlay=true;
		if(flashvars.showToolbar)
		{
			with(Controls.progressBar.timeline)
			{
				timelineFullMiddle.visible=true;
				timelineFullLeft.visible=true;	
			}
		}
		if(isSwf)
		{
			var loader:Loader = new Loader();
			var urlReq:URLRequest = new URLRequest(flashvars.fileName);
			loader.load(urlReq);
			var v=loader.content;
			theMovie=v;
			theMovie=new MovieClip();
			theMovie.quality = 'best';
			theMovie.visible=true;
			stage.addChild(theMovie);
		}
		else
		{
			theVideo.visible=true;
			_trace('ns.play: '+flashvars.fileName);
			try
			{
				ns.checkPolicyFile=false;
				ns.play(flashvars.fileName);
				ns.pause();
				ns.seek(0);
			}
			catch(ex)
			{
				_trace('LoadMovie2 ns exception: '+ex.toString());
			}
	
		}
	
		movieState=1;
		timerCount=0;
		_trace('endof LoadMovie2');
	}
		
	function CheckMousePos()
	{
		if(flashvars.showToolbar)
		{
			var isMouseOver=IsMouseOverToolbar();
			//_trace(isMouseOver+" "+flashvars.autoHide);
			// steve pinter
			//if(autoHide && Controls.visible && !isMouseOver) Controls.visible=false;
			//if(!Controls.visible && isMouseOver) Controls.visible=true;
		}			
	}

	function InitLevel1()
	{
		_trace('InitLevel1');
/*		theMovie.DoPosUpdate=function()
		{
			DoPosUpdate();
		}*/
		duration=theMovie.totalFrames/flashvars.fps;
		_trace('duration='+duration);	
		theMovie.gotoAndStop(1);
		if(flashvars.showToolbar && stage.displayState == StageDisplayState.FULL_SCREEN && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		{
	//    	FullScreenResizeFix();
			ResizeControls(true);
		}
//		else DoPosUpdate();
		theMovie.FBStopMovie=function()
		{
			FBStopMovie();
		}
		theMovie.FBPlayMovie=function()
		{
			FBPlayMovie();
		}
	/*
	theMovie.mc2.onMouseUp = function()
	{
		_trace('theMovie.mc2.onMouseUp');
	}*/
	
	}
	
	function OnPreviewLoaded()
	{
		_trace('OnPreviewLoaded');
	//  	FillRect(mcPreview,0x000000,30);	
	}
		
	function MovieOnEnterFrame()
	{	
/*		_trace("onenterframe");
		// find nearest cuepoint
		var rtn_obj:Object = null;
		if (ns)
			_trace("ns present");
		if (ns.client)
			_trace("ns.client present");
		if (ns.client.findNearestCuePoint)
			_trace("ns.client.findNearestCuePoint present");
		rtn_obj = ns.client.findNearestCuePoint(ns.time, CuePointType.EVENT);
		_trace("cuepoint founded:" + rtn_obj);
		// if this cuepoint is enough near - process it
		if ((rtn_obj != null) && (Math.abs(ns.time - rtn_obj.time) < (1.0/flashvars.fps)))
		{
			_trace("inside cuepoint");
			ns_onCuePoint(rtn_obj);
		}
*/
		
		if(isSwf && theMovie.fb_pausebutton!=undefined)
		{
		  theMovie.fb_pausebutton.x= - theMovie.x;
		  theMovie.fb_pausebutton.y=(flashvars.topToolbar?(Controls.height):0)- theMovie.y;
		  if(flashvars.showToolbar && stage.displayState == StageDisplayState.FULL_SCREEN && flashvars.scaleMode!=StageScaleMode.NO_SCALE)
		  {
			  var y=0;
			  if(flashvars.topToolbar) y+=Controls.height;
			  theMovie.fb_pausebutton.y=y- theMovie.y;
		  }
		}
		if(isSwf && flashvars.pauseByClickingOnMovie)
		{
		  if(theMovie.fb_pobutton!=undefined)
		  {
			  ignoreClickFrame=theMovie.currentFrame;
		  }
		  if(theMovie.fb_pausebutton2!=undefined)
		  {
			  ignoreClickFrame=theMovie.currentFrame;
		  }
		  if(theMovie.fb_pobutton_jump!=undefined)
		  {
			  ignoreClickFrame=theMovie.currentFrame;
/*			 theMovie.fb_pobutton_jump.onMouseUp = theMovie.fb_pobutton_jump.onPress=function()
			 {
				 StopMovie();
			 }*/
		  }
		}
	
		if(flashvars.showToolbar)
		{
			UpdateControls();
			if(flashvars.showTimer) SetTime();
			CheckMousePos();
			if(isSwf)
			{	  
				if(stage.displayState == StageDisplayState.FULL_SCREEN) 
				{
					if(flashvars.scaleMode!=StageScaleMode.NO_SCALE && stage.scaleMode==StageScaleMode.NO_SCALE) 
						stage.scaleMode=flashvars.scaleMode;
				}
				else if(stage.scaleMode!=flashvars.scaleMode) stage.scaleMode=flashvars.scaleMode;
			}
		}
		if(!isSwf) UpdateInteractiveElements();
		CheckStartFrame();
	}

	function CheckStartFrame()
	{
		if(flashvars.startFrame>0)
		{
			if(isSwf)
			{
				if(theMovie.totalFrames>0) 
				{
					if(flashvars.startFrame < theMovie.framesLoaded || theMovie.framesLoaded==theMovie.totalFrames)
					_trace('startFrame');	
					theMovie.gotoAndStop(flashvars.startFrame<theMovie.totalFrames ? flashvars.startFrame : theMovie.totalFrames);
					flashvars.startFrame=0;
				}
					
			}
			else 
			{
				if(duration>0 && ns.bytesTotal>0)
				{
					var time=flashvars.startFrame/flashvars.fps;
					var estTime=duration*ns.bytesLoaded/ns.bytesTotal;
					if(time<estTime||ns.bytesLoaded==ns.bytesTotal)
					{
						_trace('startFrame time='+time);
						flashvars.startFrame=0;
//						PauseAndSeek(time*1000);
						ns.seek(time);	
//						_trace('ns.time='+ns.time);
						UpdateControls();
						UpdateInteractiveElements();
					}
				}
			}
			if(flashvars.startFrame==0)
			{
				if(flashvars.startingPlaybackMode==2) PlayMovie();
				else PauseMovie();
			}
		}
	}
		
	function StartPlay()
	{
		_trace('StartPlay');		
		if(isSwf) theMovie.visible=true;
		else
		{
			theVideo.visible=true;
		}
		movieState=2;
		if(ffp) PauseMovie();
		else PlayMovie();
	}
	
	function GetBufferTime()
	{
		if(movieState<1) return 0;
		var t=0;
		if(isSwf)
		{
			if(theMovie.totalFrames>0)
			{
				t=(theMovie.framesLoaded-theMovie.currentFrame) * duration/theMovie.totalFrames;
			}
		}
		else
		{
			if(ns.bufferLength>=0)
			{
			  t=ns.bufferLength;	
			}
		}
		return t;
	}
	
	function CheckPreload()
	{
		_trace('CheckPreload duration='+duration);
		if(!movieLoaded && duration>0)
		{
			var curTime=timerCount*timerInterval/1000;
			_trace('curTime='+curTime);
			var d=GetMovieLoadProgress();
			_trace('d='+d);
			if(d>0)
			{
				if(flashvars.preloadPercent>0)
				{
					if(flashvars.preloadPercent<=d*100) PlayMovie();//StartPlay();
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
	
	function ShapeClickHandler(ev:MouseEvent):void
	{
		_trace('ShapeClickHandler');
		var shape=ev.currentTarget;
		for each(var el in elements.items)
		{
			var btn:ButtonElement=el.Button;
			if(btn!=null)
			{
				if(btn.shape==shape)
				{
					DoAction(btn);
					break;
				}
			}
		}
	}
	
/*	function CheckElementHit(x:int,y:int):Boolean
	{
		_trace('CheckElementHit');
		for each(var el in elements.items)
		{
			var btn:ButtonElement=el.Button;
			if(btn!=null)
			{
				var time:int=ns.time*1000;
				if(btn.IsVisible(time))
				{
					if(btn.Contains(x,y))
					{
						DoAction(btn);
						return true;
					}										
				}
			}
		}
		return false;
	}*/
	function DoAction(btn:ButtonElement)
	{
		_trace('DoAction '+btn.action);
		switch (btn.action)
		{
			case Element.actionPause:
				PauseMovie();
				break;
			case Element.actionPlay:
				PlayMovie();
				break;
			case Element.actionUrl:
//						if (HtmlPage.IsPopupWindowAllowed)
				{
					var url:String = btn.url;
					_trace(url);
//					if (!url.Trim().StartsWith("http")) url = "http://" + url;
//					HtmlPage.PopupWindow(new Uri(url), "_blank", options);
					GetURL(url,'_blank');
				}				
				break;
			case Element.actionJScript:
				{
					var jscript:String = btn.jscript;
					ExecuteJScript(jscript);
				}				
				break;								
			case Element.actionNone:
				break;
			default:
				var time:Number=0.001*(btn.jumpto) - 0.01;
				_trace("Time to jump:" + time);
				_trace("Before seek");
				if (time == -0.01)
					time = 0;
				
				if (SecondsLoaded() < time)
				//if (true)
				{
					JumpToNotLoaded(time, btn);
				}
				else
				{
					ns.seek(time);
					_trace("After seek");
					//UpdateControls();
					//UpdateInteractiveElements();
					//if (!btn.playafter)
						//PauseMovie();
					if (btn.playafter)
						_trace("playafter true");
					if (btn.playafter) PlayMovie();
					else PauseMovie();
				}
				break;
		}
	}
	
	function OnJumpTimer(eventObject:TimerEvent)
	{
		_trace("OnJumpTimer");
		jumpTimerCount++;
		var escaped = ns.time != startJumpTime;
		//if (jumpTimerCount < 100 && !escaped)
		if (SecondsLoaded() < jumpTime)
		{
			_trace("SecondsLoaded():" + SecondsLoaded() + "jumpTime: " + jumpTime);
			var index:int=(jumpTimerCount/2)%8;
			mcJumpLoading.gotoAndStop(index+1);
		}
		else
		{
			_trace("exit SecondsLoaded():" + SecondsLoaded() + "jumpTime: " + jumpTime);
			_trace("jumptimerend");
			jumpTimer.stop();
			mcJumpLoading.visible = false;
			if (!escaped)
			{
				ns.seek(jumpTime);
				if (jumpBtn.playafter)
					_trace("playafter true");
				if (jumpBtn.playafter) PlayMovie();
					else PauseMovie();
			}
		}
		
	}
	
	function JumpToNotLoaded(time:Number, btn:ButtonElement)
	{
			_trace("JumpToNotLoaded");
			//pause movie
			PauseMovie();
			startJumpTime = ns.time;
			jumpTime = time;
			jumpBtn = btn;
			mcJumpLoading.visible = true;
			jumpTimer.addEventListener(TimerEvent.TIMER, OnJumpTimer);
			jumpTimer.start();
			//show "loading" thumbnail
	}
	
	function UpdateInteractiveElements()
	{
		_trace("UpdateInteractiveElements");
		for each(var el in elements.items)
		{
			var btn:ButtonElement=el.Button;
			if(btn!=null)
			{
				var time:int=ns.time*1000;
				_trace("time: " + time);
				btn.shape.visible=btn.IsVisible(time);
				if(btn.shape.visible)
				{
					// Steve Pinter: mine version
//					btn.UpdateCoords((int)playerPosition);
					btn.UpdateCoords(time, flashvars.debugMode>0);		
				}
			}
		}	

/*		if(poVisible)
		{
			var info:AutoscrollZoomPanInfo=GetAutoscrollZoomPanInfo(ns.time);
			var m:Matrix =new Matrix();
			if (info != null)
			{
				if (info.HasZoomPan && info.Size != flashvars.OrigMovieSize)
				{
					var x:Number=-info.x;
					if (flashvars.HasScaleX) x *= flashvars.ScaleX;
					var y:Number=-info.y;
					if (flashvars.HasScaleY) y *= flashvars.ScaleY;
					m.translate(x,y);
			
					if (info.width != 0 && info.height!=0)
					{
						trace('info.width='+info.width+ ' info.height='+info.height);
						m.scale(flashvars.mw / info.width, flashvars.mh / info.height);
					}
				}

				if (info.HasAutoscroll)
				{
					var sx:Number=info.sx;
					if (flashvars.HasScaleX) sx *= flashvars.ScaleX;
					var sy:Number=info.sy;
					if (flashvars.HasScaleY) sy *= flashvars.ScaleY;
//					trace('sx='+sx+ ' sy='+sy);
					m.translate(sx, sy);
				}				
			}			
			
			var dx:Number=flashvars.pw/2;
			var dy:Number=flashvars.showToolbar && !flashvars.topToolbar? flashvars.ph : 0;
			m.translate(dx, dy);				
			
			if(stage.displayState == StageDisplayState.FULL_SCREEN)
			{					
				var scale: Number = 1/fullScreenAspect;
				m.scale(scale, scale);
			}


			m.translate(theVideo.x,theVideo.y);
			sprite.transform.matrix=m;
		}*/
	}
/*	function GetAutoscrollZoomPanInfo(time:Number):AutoscrollZoomPanInfo //sec
	{
		if (autoscrollZoomPanList.length > 0)
		{
			var frame:int = (int)(time * flashvars.fps);
			var prevInfo: AutoscrollZoomPanInfo = null;
			for each (var info:AutoscrollZoomPanInfo in autoscrollZoomPanList)
			{
				if (frame < info.frame) return prevInfo==null?info:prevInfo;
				prevInfo = info;
			}
			return prevInfo;//autoscrollZoomPanList[autoscrollZoomPanList.length-1];
		}
		return null;
	}*/

}
}