package AS3{
import flash.text.*;
import flash.geom.Rectangle;
import flash.events.*;
import AS3.Element;
import AS3.Coords;
import AS3.CoordsList;
import flash.display.*;

public class ButtonElement extends Element
{
	public var pause:Boolean;
	public var x:int,y:int,width:int,height:int;
	public var duration:int;// ms
	public var action:int;
	public var url:String="";
	public var jscript:String="";
	public var jumpto:int=0;
	public var playafter:Boolean=false;
	public var shape:Sprite =new Sprite ();
	var coordsList:CoordsList = new CoordsList();
	public function ButtonElement(ss:Array, lines:Array)
	{
		super(ss);
		_trace("Button constructor ss: " + ss);
		// pause x y width height duration action [url or jumpto;playafter]
		var i:int = 4;
		pause = int(ss[i++])>0;
		x = int(ss[i++]);
		y = int(ss[i++]);
		width = int(ss[i++]);
		height = int(ss[i++]);
		duration = int(ss[i++]);
		action = int(ss[i++]);
		_trace("Button constructor: before switch");
		switch (action)
		{
			case actionUrl:
				url = ss[i++];
				break;
			case actionJScript:
				jscript = GetJScript(ss,i);
				break;
			case actionGotoFrame:
			case actionGotoMarker:
			case actionGotoObject:
				jumpto = int(ss[i++]);
				playafter = int(ss[i++])>0;
				break;
		}
		_trace("jumpto: " + jumpto);
		ReadCoords(lines);
		shape.visible=false;
	}
	
	function ReadCoords(lines:Array)
	{
		for (var i:int = 1; i < lines.length; i++) ReadCoordsLine(lines[i]);
	}

	function ReadCoordsLine(line:String)
	{
		var ss:Array = line.split(';');
		if (ss.length == 5)
		{
			var ii:Array=new Array();
			for(var i:int=0;i<ss.length;i++) ii[i]=int(ss[i]);
			var coords:Coords = new Coords(ii);
			coordsList.Add(coords);
		}
	}
	
	public function GetJScript(ss:Array, index:int)
	{
		_trace("GetJStript :" + ss.join(";"));
		var s='';
		for(var i=index;i<ss.length;i++)
		{
			s+=ss[i];
			s+=';';
		}
		return s;
	}
	
	function ScaleX(w0:int, w:int)
	{
		if(w0!=w && w0!=0)
		{
			x=x*w/w0;
			width=width*w/w0;
		}
	}
	
	function ScaleY(h0:int, h:int)
	{
		if(h0!=h && h0!=0)
		{
			y=y*h/h0;
			height=height*h/h0;
		}
	}
	
	public override function get Button():ButtonElement{return this;}

	function InitShape(debugMode:Boolean)
	{
/*		trace('x='+x);
		trace('w='+width);
		shape.x=0;
		shape.y=0;
		shape.width=width;
		shape.height=height;*/
		shape.graphics.clear();
		if(debugMode)
		{
			shape.graphics.lineStyle(1, 0xff0000);
			shape.graphics.beginFill(0xff0000, 0.25);
			shape.graphics.drawRect(x, y, width, height);
		  	shape.graphics.endFill();
		}
		else
		{
			shape.graphics.beginFill(0xff0000, 0.0);
			shape.graphics.drawRect(x, y, width, height);
		  	shape.graphics.endFill();
		}
		// Steve Pinter: line from mine code
		//shape.visible=false;
	}
	
	function UpdateCoords(timeMs:int,debugMode:Boolean)
	{
		var coords: Coords = coordsList.GetCoords(timeMs);
		if (coords != null)
		{
			width = coords.width;
			height = coords.height;
			x = coords.x;
			y = coords.y;
		}
		InitShape(debugMode);		
	}
	
	public function Contains(_x:int,_y:int):Boolean 
	{
		return x<_x && _x<x+width && y<_y && _y<y+height;
	}

	public function IsVisible(playerPosition:int):Boolean // milliseconds
	{
	
		// Steve Pinter: mine variant:
	//	var delta:int = 5;
		//_trace("IsVisible playerPosition: " + playerPosition + " time: " + time + " duration: " + duration);
		//return playerPosition >= time/*-delta*/ && playerPosition <= time + duration/* +delta*/;
	
//		var delta:int = 0;
		return playerPosition >= time/*-delta*/ && playerPosition <= time + duration/*+delta*/;
	}
}
}