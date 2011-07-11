package com.anjantek.controls.gridColumns.events
{
	import flash.events.Event;
	
	import spark.components.gridClasses.GridColumn;
	
	public class GridColumnEvent extends Event
	{
		
		//----------------------------------------------------------------------------------------------------------
		
		public static const DATA_UPDATED_IN_CELL: String = "dataUpdatedInCell";
		public static const DUPLICATE_DATA_FOUND: String = "duplicateDataFound";
		
		//----------------------------------------------------------------------------------------------------------
		
		public var payload: Object;
		public var column: GridColumn;
		
		public function GridColumnEvent(type:String, _payload: Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			payload = _payload;
		}
		
		//----------------------------------------------------------------------------------------------------------
		
	}
}