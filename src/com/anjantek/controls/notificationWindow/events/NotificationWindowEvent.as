package com.anjantek.controls.notificationWindow.events
{
	import flash.events.Event;
	
	public class NotificationWindowEvent extends Event
	{
		public static const CLOSE: String = "close";
		
		//-------------------------------------------------------------------------------------------------
		
		public var payload: String;
		
		public function NotificationWindowEvent(type:String, _payload: String = "", bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			payload = _payload;
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}