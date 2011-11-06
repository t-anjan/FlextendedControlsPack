package com.anjantek.controls.sliders.events
{
	import flash.events.Event;
	
	public class MultiThumbSliderEvent extends Event
	{
		public static const VALUE_CHANGE: String = "valueChange";
		public static const LABEL_CHANGE: String = "labelChange";
		public static const THUMB_ADDED: String = "thumbAdded";
		public static const THUMB_REMOVED: String = "thumbRemoved";
		
		public var payload: Object;
		
		public function MultiThumbSliderEvent(type:String, payload: Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.payload = payload;
		}
	}
}