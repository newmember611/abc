package AS3{
import flash.text.*;
import flash.geom.*;
import flash.events.*;
import flash.system.*;
import flash.display.*;
import flash.external.*;
import AS3.Common;

public class Flashvars 
{
	var toolbarVersion='3.3.1';
	//var flashvars="scaleMode=showAll&debugMode=1&sf=10&urlParams=true&enableExternalInterface=true&pw=5&ph=0&vw=432&vh=368&sw=427&sh=368&mw=427&mh=368&dimPreview=false&checkVersion=true&showToolbar=true&topToolbar=false&showFullScreen=true&fullScreenBackgroundColor=16777215&borderWidth=1&enableBorder=false&borderColor=0&autoHide=false&autoHideToolbar=false&showAutoHide=false&showTimer=true&showTimeline=true&showNextButton=false&showPrevButton=false&showFBLogo=true&showVolumeBar=false&fps=12";
//	var flashvars:String="flashvarsStub";
	var flashvars:String="flashvarsStub                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ";
	var common:Common=null;
    var debugMode:int=0;
    var fileName="movie.flv";
    var showStopButton=false;
    var showLastButton=false;
    var showTimeline=true;
	var showNextButton=true;
	var showPrevButton=true;
	var showTimer=true;
    var showFullScreen=true;
	var fullScreenBackgroundColor = 16777215; // white;
	var borderWidth = 1;
	var borderColor = 0; // black
	var enableBorder = false;
    var showVolumeBar=true;
    var showAutoHide=false;
    var showFBLogo=true;
    var fps=10;
    var autoHide=false;
	var autoHideToolbar = false;
    var showToolbar=true;
    var topToolbar=true;
    var str1="Created with BB FlashBack";
    var str2="Visit www.bbflashback.com";
    var str3="Hide";
    var str4="http://www.bbflashback.com";
    var str5="Flash Player %s detected. v9,0,28 or later required.<br/>Update your player here: ";

    var movieHasExpired = "This movie has expired\nand will not be displayed.";
    var incorrectPassword = "Incorrect password";
    var oK = "OK";
    var tryAgain = "Try Again";
    var enterPassword = "Enter password:";

    var showPausedOverlay=true;
    var pauseByClickingOnMovie=true;
    var startingPlaybackMode:int=1;//enum StartingPlaybackMode{spmDownloadOnClick=0,spmDownload=1,spmDownloadAndPlay=2};
    var preloadPercent:int=0;
    var previewFileName=null;//'Logo1frame.swf'//undefined//
    var loopPlayback=false;
    var psx=100;
    var psy=100;
    var scaleMode=StageScaleMode.SHOW_ALL;//StageScaleMode.EXACT_FIT, StageScaleMode.SHOW_ALL, StageScaleMode.NO_BORDER, StageScaleMode.NO_SCALE.
	var scaleMode0=StageScaleMode.NO_SCALE;
	var dimPreview=false;
    var pwd="";
    var expiryDate="";// format is day/month/year - 05/12/2009
    var fbVer="";
    var embeddedMode=false;
    var enableExternalInterface=false;
	var fullScreenSupported=false;
	var mw:int=0;
	var mh:int=0;	
	var sw:int=0;
	var sh:int=0;
	var vw:int=0;
	var vh:int=0;	
	var pw:int=0;
	var ph:int=0;
	var sf:int=0;
	var startFrame:int=0;
	var urlParams:Boolean=false;
	var jsEvents:Boolean=false;
	
	public function Flashvars(_common:Common) 
	{
		common=_common;
		_trace("Flashvars.Flashvars");
		_trace('toolbarVersion='+toolbarVersion);
		_trace('sandboxType='+Security.sandboxType);

		ReadInternalFlashvars();
//		CreateDebugWindow(); // displays all the messages from _trace calls

		var parameters=common.GetLoaderInfo().parameters;
		for (var name:String in parameters) 
		{
			AddParam(name,parameters[name]);
		}

		ReadUrlParams();
		
		Init();
		Test();
	}
	
	public function get HasScaleX():Boolean { return mw!=sw; }	
	public function get HasScaleY():Boolean { return mh!=sh; }	
	public function get ScaleX():Number {var w:Number=sw; return w/mw; }	
	public function get ScaleY():Number {var h:Number=sh; return h/mh; }	
	
	function get IsMovieScaled():Boolean
	{
		return HasScaleX || HasScaleY;
	}
	
	public function get OrigMovieSize():Point { return new Point(mw, mh); }	

/*function CreateDebugWindow()
{
	if(_root.lblDebug==undefined)
	{
		_root.createTextField("lblDebug",500, 0, 30, Stage.width/2, Stage.height-60);
		_root.lblDebug.multiline=true;
		_root.lblDebug.mouseWheelEnabled=true;
		_root.lblDebug.wordWrap=true;
		_root.lblDebug.selectable=true;
		var my_fmt:TextFormat = new TextFormat();
		my_fmt.font='Arial';
		my_fmt.size=10;
		_root.lblDebug.setNewTextFormat(my_fmt);
//		_trace('Debug lblDebug='+_root.lblDebug);
	}
}*/
	function Init()
	{
		_trace('Flashvars.Init');
		
		// flash player version
		var verStr=Capabilities.version;// WIN 9,0,0,0 (Flash Player 9 for Windows)
		var ver = verStr.split(" ");
		_trace('FPVersion='+ver);
		ver = ver[1].split(",");
		fullScreenSupported=ver[0] > 9 || (ver[0] == 9 && (ver[1] >0 || ver[2]>=28));
		if(!fullScreenSupported) showFullScreen=false;

		// embeddedMode
//		if(embeddedMode) scaleMode=StageScaleMode.NO_SCALE;
		_trace('embeddedMode='+embeddedMode);
	}

	function ReadUrlParams()
	{
		if(urlParams)
		{
			_trace('urlParams ExternalInterface.available: '+ExternalInterface.available);
			if(ExternalInterface.available)
			{
				var queryString = ExternalInterface.call("function () { return window.location.search.toString(); }");
				if(queryString!=undefined && queryString!=null) 
				{
					_trace('queryString='+queryString);
					queryString=queryString.substring(1);
					ReadParams(queryString);
				}
			}
		}
	}
	
	function ReadInternalFlashvars()
	{
		_trace('Flashvars.ReadInternalFlashvars');
		if(flashvars.substring(0,13)!="flashvarsStub")
		{
			ReadParams(flashvars);
		}
	}

	function ReadParams(paramStr:String)
	{
		_trace('Flashvars.ReadParams');
		var ar:Array = paramStr.split("&");
		_trace('ar.length='+ar.length);
		for (var i = 0; i<ar.length; i++) 
		{
			var s:String=ar[i];
			if(s.length>0)
			{
				var pos=s.indexOf("=");
				if(pos>0)
				{
					AddParam(s.substr(0,pos),s.substr(pos+1,s.length-pos));
				}
				else AddParam(s,'true');
			}
		}
	}
	
	function AddParam(key:String,val:String)
	{
//		_trace(key+'='+val);
		switch(key)
		{
			case "mw": mw=GetInt(val,mw); break;
			case "mh": mh=GetInt(val,mh); break;		
			case "sw": sw=GetInt(val,sw); break;
			case "sh": sh=GetInt(val,sh); break;		
			case "vw": vw=GetInt(val,vw); break;
			case "vh": vh=GetInt(val,vh); break;		
			case "pw": pw=GetInt(val,pw); break;
			case "ph": ph=GetInt(val,ph); break;		
			case "sf": sf=GetInt(val,sf); break;		
			case "startFrame": startFrame=GetInt(val,startFrame); break;
			case "urlParams": urlParams=GetBool(val,urlParams); break;
			case "jsEvents": jsEvents=GetBool(val,jsEvents); break;			
			case "showStopButton": showStopButton=GetBool(val,showStopButton); break;		
			case "showLastButton": showLastButton=GetBool(val,showLastButton); break;		
			case "showTimeline": showTimeline=GetBool(val,showTimeline); break;
			case "showNextButton": showNextButton=GetBool(val,showNextButton); break;
			case "showPrevButton": showPrevButton=GetBool(val,showPrevButton); break;
			case "showTimer": showTimer=GetBool(val,showTimer); break;
			case "showFullScreen": showFullScreen=GetBool(val,showFullScreen); break;
			case "fullScreenBackgroundColor": fullScreenBackgroundColor=GetInt(val,fullScreenBackgroundColor); break;
			case "borderWidth": borderWidth=GetInt(val,borderWidth); break;
			case "borderColor": borderColor=GetInt(val,borderColor); break;
			case "enableBorder": enableBorder=GetBool(val,enableBorder); break;
			case "showVolumeBar": showVolumeBar=GetBool(val,showVolumeBar); break;
			case "showAutoHide": showAutoHide=GetBool(val,showAutoHide); break;
			case "showFBLogo": showFBLogo=GetBool(val,showFBLogo); break;
			case "fps": fps=GetInt(val,fps); break;
			case "autoHideToolbar": autoHideToolbar=GetBool(val,autoHideToolbar); break;
			case "autoHide": autoHide=GetBool(val,autoHide); break;
			case "fileName": fileName=GetString(val,fileName); break;
			case "showToolbar": showToolbar=GetBool(val,showToolbar); break;
			case "topToolbar": topToolbar=GetBool(val,topToolbar); break;
			case "str1": str1=GetUnescaped(val,str1); break;
			case "str2": str2=GetUnescaped(val,str2); break;
			case "str3": str3=GetUnescaped(val,str3); break;
			case "str4": str4=GetUnescaped(val,str4); break;
			case "str5": str5=GetUnescaped(val,str5); break;

			case "movieHasExpired": str5=GetUnescaped(val,movieHasExpired); break;
			case "incorrectPassword": str5=GetUnescaped(val,incorrectPassword); break;
			case "oK": str5=GetUnescaped(val,oK); break;
			case "tryAgain": str5=GetUnescaped(val,tryAgain); break;
			case "enterPassword": str5=GetUnescaped(val,enterPassword); break;

			case "showPausedOverlay": showPausedOverlay=GetBool(val,showPausedOverlay); break;
			case "pauseByClickingOnMovie": pauseByClickingOnMovie=GetBool(val,pauseByClickingOnMovie); break;
			case "startingPlaybackMode": startingPlaybackMode=GetInt(val,startingPlaybackMode); break;
			case "preloadPercent": preloadPercent=GetInt(val,preloadPercent); break;
			case "debugMode": debugMode=GetInt(val,debugMode); break;
			case "previewFileName": previewFileName=GetString(val,previewFileName); break;
			case "loopPlayback": loopPlayback=GetBool(val,loopPlayback); break;
			case "psx": psx=GetInt(val,psx); break;
			case "psy": psy=GetInt(val,psy); break;
			case "scaleMode": scaleMode=GetString(val,scaleMode); break;
			case "scaleMode0": scaleMode0=GetString(val,scaleMode0); break;
			case "dimPreview": dimPreview=GetBool(val,dimPreview); break;
			case "pwd": pwd=GetString(val,pwd); break;
			case "expiryDate": expiryDate=GetString(val,expiryDate); break;
			case "fbVer": fbVer=GetString(val,fbVer); break;
			case "enableExternalInterface": enableExternalInterface=GetBool(val,enableExternalInterface); break;				
		}	
	}
	
	function _trace(s)
	{
		common._trace(s);
	}

/*	function ReplaceString(s:String, searchStr:String, replaceStr:String):String 
	{	
		var arr:Array = s.split(searchStr);
		return arr.join(replaceStr);
	}

	function CheckVersion():Boolean
	{
		_trace('CheckVersion fullScreenSupported:'+_root.fullScreenSupported);
		if(_root.fullScreenSupported) return true;
		_root.createTextField("tf",0, 0, 0, Stage.width, 60);
		tf.backgroundColor=0xFF0600;
		tf.background=true;
		tf.multiline=true;
		tf.html=true;
		var s:String=str5;
		_trace('str5='+str5);
		var curVer=ver[0]+'.'+ver[1]+'.'+ver[2];
		s=ReplaceString(s,'%s',curVer);
		_trace('s='+s);
	
		tf.htmlText=s+" <a href='http://get.adobe.com/flashplayer'>http://get.adobe.com/flashplayer</a>";//+"<br/>Your current version: "+getVersion();
		var my_fmt:TextFormat = new TextFormat();
		my_fmt.align='center';
		my_fmt.color = 0xFFFFFF;
		my_fmt.bold = true;
		my_fmt.font='Arial';
		my_fmt.size=12;
		tf.setTextFormat(my_fmt);
		Controls._visible=false;
	//	if(lblDebug!=undefined) lblDebug._visible=false;
	
		return false;
	}*/

	function GetUnescaped(v:String,defaultValue:String): String
	{
		return v==null ? defaultValue : unescape(v);
	}
	function GetString(v:String,defaultValue:String): String
	{
		return v==null ? defaultValue : v;
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
	  return v==null?nDefault:Number(v);
	}
	function GetInt(v:Object,nDefault:int): int
	{
	  return v==null?nDefault:int(v);
	}	
	function GetTwoDigits(i)
	{
		return i>9 ? i : "0"+i;
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
	function Test()
	{
		/*trace('mw='+mw);
		trace('mh='+mh);
		trace('mw0='+mw0);
		trace('mh0='+mh0);*/
// pwd="123";
//_trace(pwd);
//_trace(expiryDate);
//expiryDate = "05/12/2009";// format is day/month/year - 05/12/2009
// fileName='test.swf';
//previewFileName='Logo1frame.swf';
//_root.topToolbar=false;
//str1=str2='012345';
//dimPreview=true;
//_root.pauseByClickingOnMovie=false;
//_root.startingPlaybackMode=1;//enum StartingPlaybackMode{spmDownloadOnClick=0,spmDownload(butDontPlay)=1,spmDownloadAndPlay=2};
//_trace(_parent);
//    	scaleMode=StageScaleMode.NO_SCALE;//StageScaleMode.EXACT_FIT, StageScaleMode.SHOW_ALL, StageScaleMode.NO_BORDER, StageScaleMode.NO_SCALE.
	}	
}
}