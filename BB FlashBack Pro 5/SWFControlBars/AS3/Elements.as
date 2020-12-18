package AS3{
import flash.text.*;
import flash.geom.Rectangle;
import flash.events.*;
import flash.net.*;
import AS3.Element;

public class Elements
{
	public var items:Array=new Array();
	public function Elements():void
	{
		trace("Elements");
	}	

/*	public function LoadXml(xml:XML):void 
	{
		trace("Elements.LoadXml");
		for each (var element:XML in xml.element) 
		{
			var el:Element=new Element();
			el.x=element.x;
			el.y=element.y;
			el.w=element.w;
			el.h=element.h;
			el.time=element.time;
			el.type=element.type;
			items.push(el);
		}
	}
	public function GetItem(index:int): Element
	{
		return items[index];
	}	
	*/
	public function Add(el:Element)
	{
		items.push(el);		
	}
	public function GetElementById(id:int):Element
	{
		for each(var el in items)
		{
			if(el.id==id) return el;
		}
		return null;
	}
}
}