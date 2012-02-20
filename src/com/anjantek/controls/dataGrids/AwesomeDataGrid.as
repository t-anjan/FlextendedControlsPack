package com.anjantek.controls.dataGrids
{
	import com.anjantek.controls.gridColumns.AwesomeGridColumn;
	import com.anjantek.controls.gridColumns.itemRenderers.AwesomeGridItemRenderer;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.gridClasses.GridColumn;
	import spark.components.gridClasses.GridSelectionMode;
	import spark.events.GridEvent;
	import spark.events.GridSelectionEvent;
	
	[Event(name="duplicateDataFound", type="com.anjantek.controls.gridColumns.events.GridColumnEvent")]
	[Event(name="dataUpdatedInCell", type="com.anjantek.controls.gridColumns.events.GridColumnEvent")]
	
	public class AwesomeDataGrid extends DataGrid
	{
		public function AwesomeDataGrid()
		{
			super();
			this.addEventListener( GridSelectionEvent.SELECTION_CHANGING, selectionChangingHandler );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function selectionChangingHandler(event:GridSelectionEvent):void
		{
			//trace("DG Selection changing inside:", event.eventPhase);
			//trace(event.target);
			//trace(event.currentTarget + "\n");
			
			// Prevent selection change if clicked on any column other than the selectable columns.
			var data_grid: DataGrid = DataGrid( event.currentTarget );
			var column_index: Number;
			
			// One of the two parameters should give the correct index of column clicked (not -1).
			column_index = ( -1 != event.selectionChange.columnIndex ) ? event.selectionChange.columnIndex : data_grid.grid.hoverColumnIndex;
			// Clicked column has been found.
			
			if( -1 != column_index )
			{
				var _column: GridColumn = data_grid.columns.getItemAt( column_index ) as GridColumn;
				//trace("Clicked on column : " + _column.headerText );
				
				// If the clicked column is set to disable selection, then disallow selection.
				if( _column is AwesomeGridColumn )
				{
					var _set_selected_column: AwesomeGridColumn = AwesomeGridColumn( _column );
					
					if( ! _set_selected_column.selectable )
						event.preventDefault();
				}
			}
			else
			{
				trace("Received column index is -1"); 
				event.preventDefault();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		// **************** NOTE: This function has been copied and placed again in the AMS DataGrid (AutoMultiSelectDataGrid). ************** */
		// Any changes made here, please reproduce in that DataGrid as well. 
		// The reason for having to re-implement the function again there is explained there.
		override protected function grid_mouseDownHandler(event:GridEvent):void
		{
			//trace("Grid Mouse Down");
			//trace(event.target)
			//trace(event.currentTarget + "\n");
			
			if( event.itemRenderer is AwesomeGridItemRenderer && event.column.editable && event.column.grid.dataGrid.editable )
			{
				var agir: AwesomeGridItemRenderer = event.itemRenderer as AwesomeGridItemRenderer;
				var button_edit: Button = agir.button_edit;
				var rect_button: Rectangle = button_edit.getBounds( button_edit.parent );
				//trace("Button rect:", rect_button );
				
				var click_global_point: Point = grid.localToGlobal( new Point( event.localX, event.localY ) );
				var click_agir_local_point: Point = button_edit.parent.globalToLocal( click_global_point );
				//trace("Click local:", click_agir_local_point );
				
				// If the click is on the edit button, then don't dispatch any selectionChanging or selectionChange events.
				// Only if the click has fallen outside the edit button, dispatch the usual events.
				if( ! rect_button.containsPoint( click_agir_local_point ) )
					super.grid_mouseDownHandler( event );
			}
			else
				super.grid_mouseDownHandler( event );
			
		}
		
		//-------------------------------------------------------------------------------------------------
		
		// ***** Fixing what seems to a bug in the DG. ***** //
		// When the datagrid's selectionMode is set to "multipleRows", this bug is reproducible.
		// Suppose one or more items are selected in the DG. Then, if any column header is clicked
		// to sort the collection by that column, the selected items get deselected.
		// So, storing the selected items before the sorting happens and re-selecting the items
		// after sorting.
		override public function sortByColumns(columnIndices:Vector.<int>, isInteractive:Boolean=false):Boolean
		{
			if( GridSelectionMode.MULTIPLE_ROWS != selectionMode )
				return super.sortByColumns( columnIndices, isInteractive );
			
			var selected_items: Vector.<Object> = this.selectedItems;
			var response: Boolean = super.sortByColumns( columnIndices, isInteractive );
			this.selectedItems = selected_items;
			
			return response;
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}