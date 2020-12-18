package AS3{
import flash.text.*;
import flash.geom.Rectangle;
import flash.events.*;
import AS3.ButtonElement;
import AS3.PauseElement;

public class Element // eventId messageId pausedgraphic
{
	// Constants
	public static const typeMarker:int = 9;
	public static const typeText:int = 10;
	public static const typeHighlight:int=41;
	public static const typeBitmap:int=33;
	public static const typeButton:int=36;
	public static const typePause:int=50;
	// Actions
	public static const actionNone:int = 0;
	public static const actionPlay:int = 1;
	public static const actionPause:int=2;
	public static const actionGotoFrame:int=3;
	public static const actionGotoMarker:int=4;		
	public static const actionGotoObject:int=5;
	public static const actionGotoSound:int=6;
	public static const actionUrl:int=7;
	public static const actionJScript:int=8;
	// variables
	public var type:int;
	public var id:int;
	public var pausedGraphic:Boolean = true;
	public var time:int = 0;// ms
	public static var common = null;
	
	public static function _trace(str:String)
	{
		common._trace(str);
	}
	
	public function Element(ss:Array)
	{		
		var i:int = 1;	
		id=int(ss[i++]);
		type = int(ss[i++]);
		pausedGraphic = int(ss[i++])>0;
	}

	public function get Button():ButtonElement{return null;}
	public function get Pause():PauseElement{return null;}
	
	public static function Parse(txt:String):Element
	{
		var lines:Array=txt.split("\r\n");
		var str=lines[0];
		var ss:Array = str.split(";");
		// eventId messageId pausedgraphic pause x y width height duration action [url or jumpto playafter]
		if (ss.length > 2 && ss[0] == "fb")
		{
			var type:int = int(ss[2]);
			switch (type)
			{
				case typeButton: return new ButtonElement(ss,lines);
				case typePause: return new PauseElement(ss, lines);
				default: return new Element(ss);
			}
		}
		OnParsingError(str);
		return null;
	}

	public static function OnParsingError(str:String)
	{
		throw new Error("Wrong interactive element string format: " + str);
	}

	public static function GetId(str:String):int
	{
		try
		{
			var startIndex:int = 3;
			var pos:int = str.indexOf(';', startIndex);
			if (pos > startIndex)
			{
				var s:String = str.substr(startIndex, pos - startIndex);
				return int(s);
			}
		}
		catch(ex)
		{
			trace(ex);
		}
		OnParsingError(str);
		return -1;
	}

	public static function IsPaused(str:String):Boolean
	{
		try
		{
			var ss:Array = str.split(";");
			// fb eventId messageId pausedgraphic pause x y width height duration action [url or jumpto playafter]
			if (ss.length < 4) return true;
			else
			{
				var p:int=int(ss[4]);
				return p!=0;
			}
		}
		catch(ex)
		{
			trace(ex);
		}
		OnParsingError(str);
		return false;
	}	
	
}

}