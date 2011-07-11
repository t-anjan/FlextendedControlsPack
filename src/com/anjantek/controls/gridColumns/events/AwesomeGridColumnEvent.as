package com.anjantek.controls.gridColumns.events
{
	import flash.events.Event;
	
	public class AwesomeGridColumnEvent extends Event
	{
		
		//----------------------------------------------------------------------------------------------------------
		
		public static const DATA_UPDATED_IN_CELL: String = "data_updated_in_cell";
		
		//----------------------------------------------------------------------------------------------------------
		
		public var payload: Object;
		
		public function AwesomeGridColumnEvent(type:String, _payload: Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			payload = _payload;
		}
		
		//----------------------------------------------------------------------------------------------------------
		
	}
}