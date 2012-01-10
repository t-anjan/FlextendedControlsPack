package com.anjantek.controls.hierTree.events
{
	import flash.events.Event;
	
	public class HierTreeEvent extends Event
	{
		public function HierTreeEvent(type:String, payload: Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.payload = payload;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public var payload: Object;
		
		//-------------------------------------------------------------------------------------------------
		
		public static const NODE_DOUBLE_CLICK: String = "nodeDoubleClick";
		public static const NODE_EXPAND_BUTTON_CLICK: String = "nodeExpandButtonClick";
		public static const NODE_COLLAPSE_BUTTON_CLICK: String = "nodeCollapseButtonClick";
		public static const SELECTION_CHANGE: String = "selectionChange";
		public static const ITEM_CLOSE: String = "itemClose";
		public static const ITEM_OPEN: String = "itemOpen";
		public static const ITEM_OPENING: String = "itemOpening";
		
		public static const REFRESH_HIER: String = "refreshHier";
		public static const DATA_LOADED: String = "dataLoaded";
	}
}