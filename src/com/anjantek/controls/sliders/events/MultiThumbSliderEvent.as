package com.anjantek.controls.sliders.events
{
	import flash.events.Event;
	
	public class MultiThumbSliderEvent extends Event
	{
		public static const VALUE_CHANGE: String = "valueChange";
		public static const LABEL_CHANGE: String = "labelChange";
		
		public function MultiThumbSliderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}