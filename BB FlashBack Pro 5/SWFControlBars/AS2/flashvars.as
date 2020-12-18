//var flashvars="urlParams=true&scaleMode0=noScale&scaleMode=showAll&showToolbar=true&topToolbar=true&showFullScreen=true&fullScreenBackgroundColor=16777215&enableBorder=false&borderWidth=1&borderColor=0&notScaleInFullScreen=false&autoHide=false&autoHideToolbar=false&showAutoHide=true&showTimer=true&showTimeline=true&showNextButton=true&showPrevButton=true&showFBLogo=true&showVolumeBar=false&fps=7&showPausedOverlay=true&pauseByClickingOnMovie=true&startingPlaybackMode=2&preloadPercent=0&str4=http:%2F%2Fwww.bbsoftware.co.uk%2Fbbflashback.aspx%3Fapp=FlashBack2%26did=3024101&str1=\u0042\u0042\u0020\u0046\u006C\u0061\u0073\u0068\u0042\u0061\u0063\u006B\u0020\u306B\u3088\u308B\u4F5C\u6210\u0020\u0042\u0042\u0020\u0046\u006C\u0061\u0073\u0068\u0042\u0061\u0063\u006B\u0020\u0050\u0072\u006F&str2=\u0056\u0069\u0073\u0069\u0074\u0020\u0042\u0042\u0020\u0046\u006C\u0061\u0073\u0068\u0042\u0061\u0063\u006B\u0020\u0050\u0072\u006F\u0020\u0077\u0065\u0062\u0073\u0069\u0074\u0065&str3=\u975E\u8868\u793A";
var flashvars:String="flashvarsStub                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           ";
_root.toolbarVersion='2.2.34';
_root.debugMode=0;// debug
_root.enableExternalInterface=false;
var defaultFileName='Test.flv';
_root.embeddedMode=_parent!=undefined;
var mc:MovieClip=_root.embeddedMode ? this : _root;
CreateDebugWindow(); // displays all the messages from _trace calls
_trace('--flashvars--');
_trace('toolbarVersion='+_root.toolbarVersion);
_trace('sandboxType='+System.security.sandboxType);

// functions
function CreateDebugWindow()
{
	if(mc.lblDebug==undefined)
	{
		mc.createTextField("lblDebug",500, 0, 30, Stage.width/2, Stage.height-60);
		mc.lblDebug=lblDebug;
		mc.lblDebug.multiline=true;
		mc.lblDebug.mouseWheelEnabled=true;
		mc.lblDebug.wordWrap=true;
		mc.lblDebug.selectable=true;
		var my_fmt:TextFormat = new TextFormat();
		my_fmt.font='Arial';
		my_fmt.size=10;
		mc.lblDebug.setNewTextFormat(my_fmt);
//		_trace('Debug lblDebug='+_root.lblDebug);
	}
}
function _trace(obj)
{
	if(mc.lblDebug!=undefined && mc.lblDebug!=null)
	{
	  mc.lblDebug.text+=obj.toString()+'\n';
	}
	trace(obj);
}
// parse flashvars
function ReadInternalFlashvars()
{
	_trace('ReadInternalFlashvars');
	if(flashvars.substring(0,12)!="flashvarsStub")
	{
		ReadParams(flashvars, false);
	}
}
function ReadParams(paramsStr:String, overwrite:Boolean)
{
	_trace('ReadParams');
	if(paramsStr!=undefined && paramsStr!=null && paramsStr.length>0)
	{
		var ar:Array = paramsStr.split("&");
		_trace('ar.length='+ar.length);
		for (var i = 0; i<ar.length; i++) 
		{
			var s:String=ar[i];
			if(s.length>0)
			{
				var pos=s.indexOf("=");
				if(pos>0)
				{
					AddParam(s.substr(0,pos),s.substr(pos+1,s.length-pos), overwrite);
				}
				else AddParam(s,'true', overwrite);
			}
		}
	}
}
function AddParam(key:String,val:String,overwrite:Boolean)
{
//	_trace(key+'='+val);
	switch(key)
	{
		case "showStopButton": if(CanWrite(overwrite,_root.showStopButton)) _root.showStopButton=val; break;		
		case "showLastButton": if(CanWrite(overwrite,_root.showLastButton))  _root.showLastButton=val; break;		
        case "showTimeline": if(CanWrite(overwrite,_root.showTimeline)) _root.showTimeline=val; break;
        case "showNextButton": if(CanWrite(overwrite,_root.showNextButton)) _root.showNextButton=val; break;
        case "showPrevButton": if(CanWrite(overwrite,_root.showPrevButton)) _root.showPrevButton=val; break;
        case "showTimer": if(CanWrite(overwrite,_root.showTimer)) _root.showTimer=val; break;
        case "showFullScreen": if(CanWrite(overwrite,_root.showFullScreen)) _root.showFullScreen=val; break;
		case "fullScreenBackgroundColor": if(CanWrite(overwrite,_root.fsBackgroundColor)) _root.fsBackgroundColor=val; break;
		case "enableBorder": if(CanWrite(overwrite,_root.enableBorder)) _root.enableBorder=val; break;
		case "borderWidth": if(CanWrite(overwrite,_root.borderWidth)) _root.borderWidth=val; break;
		case "borderColor": if(CanWrite(overwrite,_root.borderColor)) _root.borderColor=val; break;
        case "showVolumeBar": if(CanWrite(overwrite,_root.showVolumeBar)) _root.showVolumeBar=val; break;
        case "showAutoHide": if(CanWrite(overwrite,_root.showAutoHide)) _root.showAutoHide=val; break;
        case "showFBLogo": if(CanWrite(overwrite,_root.showFBLogo)) _root.showFBLogo=val; break;
        case "fps": if(CanWrite(overwrite,_root.fps)) _root.fps=val; break;
        case "autoHide": if(CanWrite(overwrite,_root.autoHide)) _root.autoHide=val; break;
		case "autoHideToolbar": if(CanWrite(overwrite, _root.autoHideToolbar)) _root.autoHideToolbar=val; break;
        case "fileName": if(CanWrite(overwrite,_root.fileName)) _root.fileName=val; break;
        case "showToolbar": if(CanWrite(overwrite,_root.showToolbar)) _root.showToolbar=val; break;
        case "topToolbar": if(CanWrite(overwrite,_root.topToolbar)) _root.topToolbar=val; break;
        case "str1": if(CanWrite(overwrite,_root.str1)) _root.str1=val; break;
        case "str2": if(CanWrite(overwrite,_root.str2)) _root.str2=val; break;
        case "str3": if(CanWrite(overwrite,_root.str3)) _root.str3=val; break;
        case "str4": if(CanWrite(overwrite,_root.str4)) _root.str4=val; break;
        case "str5": if(CanWrite(overwrite,_root.str5)) _root.str5=val; break;

		case "movieHasExpired": if(CanWrite(overwrite,_root.movieHasExpired)) _root.movieHasExpired=val; break;
		case "incorrectPassword": if(CanWrite(overwrite,_root.incorrectPassword)) _root.incorrectPassword=val; break;
		case "oK": if(CanWrite(overwrite,_root.oK)) _root.oK=val; break;
		case "tryAgain": if(CanWrite(overwrite,_root.tryAgain)) _root.tryAgain=val; break;
		case "enterPassword": if(CanWrite(overwrite,_root.enterPassword)) _root.enterPassword=val; break;
		
        case "showPausedOverlay": if(CanWrite(overwrite,_root.showPausedOverlay)) _root.showPausedOverlay=val; break;
        case "pauseByClickingOnMovie": if(CanWrite(overwrite,_root.pauseByClickingOnMovie)) _root.pauseByClickingOnMovie=val; break;
        case "startingPlaybackMode": if(CanWrite(overwrite,_root.startingPlaybackMode)) _root.startingPlaybackMode=val; break;
        case "preloadPercent": if(CanWrite(overwrite,_root.preloadPercent)) _root.preloadPercent=val; break;
        case "debugMode": if(CanWrite(overwrite,_root.debugMode)) _root.debugMode=val; break;
        case "previewFileName": if(CanWrite(overwrite,_root.previewFileName)) _root.previewFileName=val; break;
        case "loopPlayback": if(CanWrite(overwrite,_root.loopPlayback)) _root.loopPlayback=val; break;
        case "psx": if(CanWrite(overwrite,_root.psx)) _root.psx=val; break;
        case "psy": if(CanWrite(overwrite,_root.psy)) _root.psy=val; break;
        case "scaleMode": if(CanWrite(overwrite,_root.scaleMode)) _root.scaleMode=val; break;
        case "scaleMode0": if(CanWrite(overwrite,_root.scaleMode0)) _root.scaleMode0=val; break;
        case "dimPreview": if(CanWrite(overwrite,_root.dimPreview)) _root.dimPreview=val; break;
        case "pwd": if(CanWrite(overwrite,_root.pwd)) _root.pwd=val; break;
        case "expiryDate": if(CanWrite(overwrite,_root.expiryDate)) _root.expiryDate=val; break;
        case "fbVer": if(CanWrite(overwrite,_root.fbVer)) _root.fbVer=val; break;
        case "enableExternalInterface": if(CanWrite(overwrite,_root.enableExternalInterface)) _root.enableExternalInterface=val; break;				
        case "mw": if(CanWrite(overwrite,_root.mw)) _root.mw=val; break;
        case "mh": if(CanWrite(overwrite,_root.mh)) _root.mh=val; break;
        case "sw": if(CanWrite(overwrite,_root.sw)) _root.sw=val; break;
        case "sh": if(CanWrite(overwrite,_root.sh)) _root.sh=val; break;
        case "vw": if(CanWrite(overwrite,_root.vw)) _root.vw=val; break;
        case "vh": if(CanWrite(overwrite,_root.vh)) _root.vh=val; break;
        case "checkVersion": if(CanWrite(overwrite,_root.checkVersion)) _root.checkVersion=val; break;
        case "startFrame": if(CanWrite(overwrite,_root.startFrame)) _root.startFrame=val; break;
        case "urlParams": if(CanWrite(overwrite,_root.urlParams)) _root.urlParams=val; break;
	}	
}
function CanWrite(overwrite:Boolean,val:String)
{
	return overwrite || val==null || val==undefined;
}
function GetUnescaped(v:String,defaultValue:String): String
{
	if(v==undefined || v==null) return defaultValue;
	return unescape(v);
}
function GetString(v:String,defaultValue:String): String
{
	return v==undefined || v==null ? defaultValue : v;
}
function GetBool(v:Object,defaultValue:Boolean): Boolean
{
  if(v==true) return true;
  else if(v==false) return false;
  if(v=="true") return true;
  else if(v=="false") return false;
  return defaultValue;
}
function GetNumber(v:Object,nDefault:Number): Number
{
  return v==undefined?nDefault:Number(v);
}
function ReplaceString(s:String, searchStr:String, replaceStr:String):String 
{	
    var arr:Array = s.split(searchStr);
    return arr.join(replaceStr);
}
function CheckFPVersion():Boolean
{
	_trace('CheckFPVersion fullScreenSupported='+_root.fullScreenSupported);
	if(!_root.checkVersion) return true;
	if(_root.fullScreenSupported) return true;
	if(isSwf)
	{
	  if(_root.ver0>=6) return true;
	}
	else
	{
	  if(_root.ver0>=7) return true;
	}
	mc.createTextField("tf",0, 0, 0, Stage.width, 36);
	mc.tf=tf;
	tf.backgroundColor=0xf35955;//0xFF0600;
	tf.background=true;
	tf.multiline=true;
	tf.html=true;
	var s:String=str5;
//	_trace('str5='+str5);
	var curVer=ver[0]+'.'+ver[1]+'.'+ver[2];
	s=ReplaceString(s,'%s',curVer);
//	_trace('s='+s);

	tf.htmlText=s+" <a href='http://get.adobe.com/flashplayer'>http://get.adobe.com/flashplayer</a>";//+"<br/>Your current version: "+getVersion();
	var my_fmt:TextFormat = new TextFormat();
	my_fmt.align='center';
	my_fmt.color = 0xFFFFFF;
	my_fmt.bold = true;
	my_fmt.font='Arial';
	my_fmt.size=12;
	tf.setTextFormat(my_fmt);
	Controls._visible=false;
//	mc.lblDebug._visible=false;
//	if(lblDebug!=undefined) lblDebug._visible=false;

	return false;
}

//_trace('urlParams='+_root.urlParams);

// internal params
ReadInternalFlashvars();
_root.urlParams=GetBool(_root.urlParams,false);

_trace('urlParams='+_root.urlParams);

// url params
if(_root.urlParams)
{
	_trace('urlParams ExternalInterface.available: '+ExternalInterface.available);
	if(ExternalInterface.available)
	{
		var queryString = ExternalInterface.call("function () { return window.location.search.toString(); }");
		if(queryString!=undefined && queryString!=null) 
		{
			_trace('queryString='+queryString);
			queryString=queryString.substring(1);
			ReadParams(queryString, true);
		}
	}
}

_root.fileName=GetString(_root.fileName,defaultFileName);
_root.showStopButton=GetBool(_root.showStopButton,false);
_root.showLastButton=GetBool(_root.showLastButton,false);
_root.showTimeline=GetBool(_root.showTimeline,true);
_root.showNextButton=GetBool(_root.showNextButton,true);
_root.showPrevButton=GetBool(_root.showPrevButton,true);
_root.showTimer=GetBool(_root.showTimer,true);
_root.showFullScreen=GetBool(_root.showFullScreen,true);
_root.fsBackgroundColor=GetNumber(_root.fsBackgroundColor,0);
_root.enableBorder=GetBool(_root.enableBorder, false);
_root.borderWidth=GetNumber(_root.borderWidth, 1);
_root.borderColor=GetNumber(_root.borderColor, 0);
_root.showVolumeBar=GetBool(_root.showVolumeBar,true);
_root.showAutoHide=GetBool(_root.showAutoHide,true);
_root.showFBLogo=GetBool(_root.showFBLogo,true);
_root.fps=GetNumber(_root.fps,12);
_root.autoHide=GetBool(_root.autoHide,false);
_root.autoHideToolbar=GetBool(_root.autoHideToolbar,false);
//_root.notScaleInFullScreen=GetBool(_root.notScaleInFullScreen,true);
_root.showToolbar=GetBool(_root.showToolbar,true);
_root.topToolbar=GetBool(_root.topToolbar,Controls._y==0);//
_root.str1=GetString(_root.str1,"Created with BB FlashBack");
_root.str2=GetString(_root.str2,"Visit www.bbflashback.com");
_root.str3=GetString(_root.str3,"Hide");//// "\u975E\u8868\u793A";//"&#38750;&#34920;&#31034;"//"&#x975E;&#x8868;&#x793A;"
_root.str4=GetUnescaped(_root.str4,"http://www.bbflashback.com");
_root.str5=GetString(_root.str5,"Flash Player %s detected. v9,0,28 or later required.<br/>Update your player here: ");

_root.movieHasExpired=GetString(_root.movieHasExpired, "This movie has expired\nand will not be displayed.");
_root.incorrectPassword=GetString(_root.incorrectPassword, "Incorrect password");
_root.oK=GetString(_root.oK, "OK");
_root.tryAgain=GetString(_root.tryAgain, "Try Again");
_root.enterPassword=GetString(_root.enterPassword, "Enter password:");

_root.sw=GetNumber(_root.sw,0); // swf width
_root.sh=GetNumber(_root.sh,0);
_root.mw=GetNumber(_root.mw,0); // source movie size
_root.mh=GetNumber(_root.mh,0);
_root.vw=GetNumber(_root.vw,Controls._width); // video size
var toolbarHeight=_root.showToolbar?Controls._height:0;
var toolbarHeightForMovieSize=_root.autoHideToolbar?0:toolbarHeight;
_root.vh=GetNumber(_root.vh,Stage.height-toolbarHeightForMovieSize-_root.borderWidth*2);

_trace("sw: " + _root.sw);
_trace("sh: " + _root.sh);
_trace("mw: " + _root.mw);
_trace("mh: " + _root.mh);
_trace("vw: " + _root.vw);
_trace("vh: " + _root.vh);
_trace("Stage.width: " + Stage.width);
_trace("Stage.height: " + Stage.height);
_trace("mc.width: " + mc.width);
_trace("mc.height: " + mc.height);
_trace("borderWidth: " + _root.borderWidth);

//_root._width = Stage.width - _root.borderWidth*2;
//_root._height = Stage.height - toolbarHeightForMovieSize - _root.borderWidth*2;

_root.showPausedOverlay=GetBool(_root.showPausedOverlay,true);
_root.pauseByClickingOnMovie=GetBool(_root.pauseByClickingOnMovie,true);
_root.startingPlaybackMode=GetNumber(_root.startingPlaybackMode,2);//enum StartingPlaybackMode{spmDownloadOnClick=0,spmDownload=1,spmDownloadAndPlay=2};
_root.preloadPercent=GetNumber(_root.preloadPercent,0);
_root.previewFileName=GetString(_root.previewFileName,undefined);//'Logo1frame.swf'//undefined//
_root.loopPlayback=GetBool(_root.loopPlayback,false);
_root.psx=GetNumber(_root.psx,100);
_root.psy=GetNumber(_root.psy,100);
_root.scaleMode=GetString(_root.scaleMode,'showAll');//"exactFit", "showAll", "noBorder", "noScale".
_root.scaleMode0=GetString(_root.scaleMode0,'showAll');
_root.debugMode=GetNumber(_root.debugMode,0);
_root.dimPreview=GetBool(_root.dimPreview,false);
_root.checkVersion=GetBool(_root.checkVersion,true);
_root.pwd=GetString(_root.pwd,"");
//_root.ffp=GetBool(_root.ffp,false);// first frame pause
_root.expiryDate=GetString(_root.expiryDate,"");// format is day/month/year - 05/12/2009
_root.fbVer=GetString(_root.fbVer,"");
_root.enableExternalInterface=GetBool(_root.enableExternalInterface,false);

_root.startFrame=GetNumber(_root.startFrame,0);

// debug info
//_root.debugMode = 2;

_root.showAutoHide = false;

if(_root.debugMode>0) mc.lblDebug._visible=true;
else
{
	mc.lblDebug._visible=false;
	mc.lblDebug=undefined;
}

// isSwf
_root.isSwf=_root.fileName.toLowerCase().indexOf(".swf")>0;
_trace('isSwf='+isSwf);

// flash player version
var fpVer=getVersion();// getVersion returns string like 'WIN 8,0,1,0'
_trace('FPVersion='+fpVer);
var ver = fpVer.split(" ");
ver = ver[1].split(",");
_root.fullScreenSupported=ver[0] > 9 || (ver[0] == 9 && (ver[1] >0 || ver[2]>=28));
if(!_root.fullScreenSupported) _root.showFullScreen=false;
_root.ver0=ver[0];
_trace('ver0='+_root.ver0);


// pwd="123";
//_trace(pwd);
//_trace(expiryDate);
//expiryDate = "05/12/2009";// format is day/month/year - 05/12/2009
//fileName='test.swf';
//previewFileName='Logo1frame.swf';
//_root.topToolbar=false;
//str1=str2='012345';
//dimPreview=true;
//_root.pauseByClickingOnMovie=false;
//_root.startingPlaybackMode=1;//enum StartingPlaybackMode{spmDownloadOnClick=0,spmDownload(butDontPlay)=1,spmDownloadAndPlay=2};
//_trace(_parent);
//if(_root.embeddedMode)
//_root.urlParams=true;
//_root.startFrame=50;
//_root.startingPlaybackMode=2;

//_root.border =10;

if(_root.embeddedMode) _root.scaleMode='noScale';
_trace('embeddedMode='+_root.embeddedMode);
_trace('startFrame='+_root.startFrame);
_trace('--flashvars eof--');