package com.anjantek.controls.hierTree.supportClasses
{
	import com.anjantek.controls.hierTree.events.HierTreeEvent;
	
	import mx.collections.ICollectionView;
	import mx.core.IFactory;
	
	import spark.components.List;
	
	[Event(name="nodeDoubleClick", type="com.anjantek.controls.hierTree.events.HierTreeEvent")]
	
	public class LevelList extends List
	{
		public function LevelList()
		{
			super();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public var level: Number;
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 * Forces the list to redraw all item renderers.
		 */
		public function invalidateList():void
		{
			dispatchEvent( new HierTreeEvent( HierTreeEvent.REFRESH_HIER ) );
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}