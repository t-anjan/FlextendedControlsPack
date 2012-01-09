package com.anjantek.controls.hierTree.supportClasses
{
	import com.anjantek.controls.hierTree.events.HierTreeEvent;
	import com.anjantek.controls.hierTree.interfaces.INodeContainer;
	import com.anjantek.controls.hierTree.skins.LevelListSkin;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.core.IFactory;
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import spark.components.List;
	import spark.layouts.HorizontalLayout;
	
	[Event(name="nodeDoubleClick", type="com.anjantek.controls.hierTree.events.HierTreeEvent")]
	
	public class LevelList extends List implements INodeContainer
	{
		public function LevelList()
		{
			super();
			this.setStyle( 'skinClass', LevelListSkin );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public var level: Number;
		
		//-------------------------------------------------------------------------------------------------
		
		private var _expandedItemX: Number = 0;
		
		public function get expandedItemX(): Number
		{
			return _expandedItemX;
		}
		
		public function set expandedItemX( value: Number ): void
		{
			_expandedItemX = value;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var _expandedItemY: Number = 0;
		
		public function get expandedItemY(): Number
		{
			return _expandedItemY;
		}
		
		public function set expandedItemY( value: Number ): void
		{
			_expandedItemY = value;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override public function set dataProvider(value:IList):void
		{
			super.dataProvider = value;
			autoFitContent();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//-----------------------------------PROPERTIES END--------------------------------------------------------------
		
		/**
		 * Forces the list to redraw all item renderers.
		 */
		public function invalidateList():void
		{
			dispatchEvent( new HierTreeEvent( HierTreeEvent.REFRESH_HIER ) );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private const PADDING_AROUND_DATA_GROUP: Number = 10;
		
		public function autoFitContent(): void
		{
			if( layout is HorizontalLayout && dataProvider && dataGroup )
			{
				var hor_layout: HorizontalLayout = layout as HorizontalLayout;
				var num_items: Number = dataProvider.length;
				this.width = PADDING_AROUND_DATA_GROUP + hor_layout.paddingLeft + hor_layout.paddingRight + ( num_items * hor_layout.columnWidth ) + ( ( num_items - 1) * hor_layout.gap );
				//trace("level:", level, "DG width:", dataGroup.width );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var sample_ir_instance: UIComponent;
		
		public function setExpandedItemPosition( index: Number ): void
		{
			var renderer: IVisualElement = dataGroup.getElementAt( index );
			var x_in_data_group: Number;
			var y_in_data_group: Number;
			
			if( renderer )
			{
				x_in_data_group = renderer.getLayoutBoundsX() + ( renderer.getLayoutBoundsWidth() / 2 );
				y_in_data_group = renderer.getLayoutBoundsY() + ( renderer.getLayoutBoundsHeight() / 2 );
			}
			else
			{
				if( ! sample_ir_instance )
					sample_ir_instance = UIComponent( itemRenderer.newInstance() );
				const ir_width: Number = sample_ir_instance.width;
				const ir_height: Number = sample_ir_instance.height;
				x_in_data_group = (index * ir_width) + (ir_width / 2);
				y_in_data_group = (index * ir_height) + (ir_height / 2);
			}
			
			var data_group_point: Point = new Point( x_in_data_group, y_in_data_group );
			var global_point: Point = dataGroup.contentToGlobal( data_group_point );
			var local_point: Point = this.globalToLocal( global_point );
			expandedItemX = Math.round( local_point.x );
			expandedItemY = Math.round( local_point.y );
			//trace( "Exp Items from List: ", expandedItemX, expandedItemY );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function dataProvider_collectionChangeHandler(event:Event):void
		{
			super.dataProvider_collectionChangeHandler( event );
			
			if (event is CollectionEvent)
			{
				var ce:CollectionEvent = CollectionEvent(event);
				
				if( CollectionEventKind.ADD == ce.kind || CollectionEventKind.REMOVE == ce.kind ||
					CollectionEventKind.REFRESH == ce.kind || CollectionEventKind.RESET == ce.kind )
				{
					autoFitContent();
				}
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}