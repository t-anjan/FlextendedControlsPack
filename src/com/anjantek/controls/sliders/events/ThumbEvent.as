package com.anjantek.controls.sliders.events
{
	import flash.events.Event;
	
	public class ThumbEvent extends Event
	{
		public static const ADD_THUMB_CLICKED: String = "add_thumb_clicked";
		public static const REMOVE_THUMB_CLICKED: String = "remove_thumb_clicked";
		
		public function ThumbEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}