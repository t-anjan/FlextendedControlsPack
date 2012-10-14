package com.anjantek.controls.dataGrids
{
	import com.anjantek.controls.gridColumns.AwesomeGridColumn;
	import com.anjantek.controls.gridColumns.events.GridColumnEvent;
	import com.anjantek.controls.gridColumns.itemRenderers.AwesomeGridItemRenderer;
	import com.anjantek.controls.gridColumns.payloads.CellDataUpdatedPayload;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.gridClasses.CellPosition;
	import spark.components.gridClasses.GridColumn;
	import spark.components.gridClasses.GridSelectionMode;
	import spark.components.gridClasses.IGridItemEditor;
	import spark.events.GridEvent;
	import spark.events.GridItemEditorEvent;
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
		
		//-----------------------------------EASY EDIT MODE - START--------------------------------------------------------------
		
		private var _easyEditMode: Boolean = false;

		[Bindable]
		public function get easyEditMode():Boolean
		{
			return _easyEditMode;
		}

		public function set easyEditMode(value:Boolean):void
		{
			_easyEditMode = value;
			verifySelectionMode( true );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override public function set selectionMode(value:String):void
		{
			super.selectionMode = value;
			verifySelectionMode( true );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function verifySelectionMode( manage_listeners: Boolean = false ): Boolean
		{
			var result: Boolean = true;
			
			if( this.easyEditMode )
			{
				if( GridSelectionMode.MULTIPLE_CELLS != this.selectionMode && GridSelectionMode.SINGLE_CELL != this.selectionMode )
				{
					trace("When in easy edit mode, selection mode can only be single cell or multiple cells. Not " + this.selectionMode);
					result = false;
				}
				else
				{
					//trace( "Easy Edit Mode - DG Selection Mode verified" );
					result = true;
				}
			}
			
			if( manage_listeners )
			{
				// The following block will get entered as soon as the class detects both, a "true" easyEditMode AND an allowed selectionMode.
				// This is because both those setters call this function with "manage_listeners set to "true".
				if( result )
				{
					// SecurityError: Error #2179: The Clipboard.generalClipboard object may only be read while processing a flash.events.Event.PASTE event.
					// Hence, having this dedicated handler for Paste.
					if( ! this.hasEventListener( Event.PASTE ) )
						this.addEventListener( Event.PASTE, handlePaste );
					
					// For an explanation on why this listener is added, look at the listener.
					if( ! this.hasEventListener( GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START ) )
						this.addEventListener( GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START, gridItemEditorSessionStartHandler );
				}
				else
				{
					this.removeEventListener( Event.PASTE, handlePaste );
					this.removeEventListener( GridItemEditorEvent.GRID_ITEM_EDITOR_SESSION_START, gridItemEditorSessionStartHandler );
				}
			}
			
			return result;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		// Escape - Keycode: 27; Charcode: 27
		// Delete - Keycode: 46; Charcode: 127
		// Backspace - Keycode: 8; Charcode: 8
		private const vector_charcodes_not_allowed: Vector.<Number> = Vector.<Number>([ 0, 27 ]);
		private const vector_delete_backspace_keycodes: Vector.<Number> = Vector.<Number>([ Keyboard.DELETE, Keyboard.BACKSPACE ]);
		
		private const vector_up_down_arrow_keys: Vector.<Number> = Vector.<Number>([ Keyboard.UP, Keyboard.DOWN ]);
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			super.keyDownHandler( event );
			
			if( !easyEditMode || !verifySelectionMode() )
				return;
			
			//trace( "String: " + String.fromCharCode( event.charCode ) + "; Keycode: " + event.keyCode + "; Charcode: " + event.charCode );
			
			if( null == this.selectedCells || 0 == this.selectedCells.length )
				return;
			
			const selected_cell_positions: Vector.<CellPosition> = this.selectedCells;
			const first_selected_cell_position: CellPosition = this.selectedCell;
			const first_selected_column: GridColumn = this.columns.getItemAt( first_selected_cell_position.columnIndex ) as GridColumn;
			
			// Verify that no item editing session is already in progress.
			if( null == this.itemEditorInstance )
			{
				const is_delete_backspace_key: Boolean = (-1 != vector_delete_backspace_keycodes.indexOf( event.keyCode ));
				
				// Handle delete and backspace.
				if( is_delete_backspace_key )
				{
					trace("Delete or backspace pressed");
					doDelete();
					return;
				}
				
				
				// Handle cut, copy and paste.
				const is_cut_key: Boolean = (Keyboard.X == event.keyCode && event.ctrlKey);
				
				if( is_cut_key )
				{
					trace("Cut pressed");
					doCut();
					return;
				}
				
				const is_copy_key: Boolean = (Keyboard.C == event.keyCode && event.ctrlKey);
				
				if( is_copy_key )
				{
					trace("Copy pressed");
					doCopy();
					return;
				}
				
				
				// ====== IMPORTANT ======= For Paste operation and typing operation, if multiple cells are selected, we should use just the first selected_cell_position.
				const is_paste_key: Boolean = (Keyboard.V == event.keyCode && event.ctrlKey);
				
				if( is_paste_key )
				{
					trace("Paste pressed - ignoring.");
					// SecurityError: Error #2179: The Clipboard.generalClipboard object may only be read while processing a flash.events.Event.PASTE event.
					// Hence, ignoring the key-press here.
					return;
				}
				
				const is_enter_key: Boolean = (Keyboard.ENTER == event.keyCode);
				
				if( is_enter_key )
				{
					trace("Enter pressed");
					// Move down to the next row, just like Excel.
					this.setSelectedCell( first_selected_cell_position.rowIndex + 1, first_selected_cell_position.columnIndex );
					return;
				}
				
				// For all other keys which are not allowed, just return.
				// ========== ONLY PLACE WHERE charCode IS USED ============.
				const is_not_allowed_key: Boolean = (-1 != vector_charcodes_not_allowed.indexOf( event.charCode ));
				
				if( is_not_allowed_key )
					return;
				
				if( !first_selected_column.editable || !this.editable )
					return;
				
				// If none of the above conditions are matched, open an item editor session.
				// The pressed key automatically gets passed into the open item editor.
				this.startItemEditorSession( first_selected_cell_position.rowIndex, first_selected_cell_position.columnIndex );
			}
			else	// If item editor session is already in progress, then respond to up and down arrows only.
			{
				const is_up_down_arrow_key: Boolean = (-1 != vector_up_down_arrow_keys.indexOf( event.keyCode ));
				
				if( is_up_down_arrow_key )
				{
					// Store the item editor's row and column indices before the item editor is closed.
					const editor_row_index: Number = this.editorRowIndex;
					const editor_column_index: Number = this.editorColumnIndex;
					
					this.endItemEditorSession();
					
					if( Keyboard.UP == event.keyCode )
						this.setSelectedCell( editor_row_index - 1, editor_column_index );
					else
						this.setSelectedCell( editor_row_index + 1, editor_column_index );
				}
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function doDelete(): void
		{
			for each( var cp: CellPosition in this.selectedCells )
			{
				updateDataInDP( cp, '' );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function doCut(): void
		{
			doCopy();
			doDelete();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function doCopy(): void
		{
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, dataGridSelectionText() );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function handlePaste( event: Event ): void
		{
			// SecurityError: Error #2179: The Clipboard.generalClipboard object may only be read while processing a flash.events.Event.PASTE event.
			// Hence, having this dedicated handler for Paste.
			if( !easyEditMode )
				return;
			
			trace("Paste pressed - in dedicated handler");
			event.preventDefault();
			doPaste();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function doPaste(): void
		{
			const text: String = Clipboard.generalClipboard.getData( ClipboardFormats.TEXT_FORMAT ) as String;
			
			if( text && (text.length > 0) ) 
				dataGridPasteText( text );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private static const FIELD_SEPARATOR_TEXT: String = '\t';
		private static const CR_LF_TEXT: String = '\r\n';
		private static const CR_TEXT: String = '\r';
		private static const LF_TEXT: String = '\n';
		
		private function dataGridSelectionText(): String
		{
			// Hold the value of the current row index, when looping through all the selected cells.
			var row_index: int = -1;
			var text: String = "";
			
			for each( var cp: CellPosition in this.selectedCells )
			{
				// Starting a new row. But NOT first row.
				if( (-1 != row_index) && (cp.rowIndex != row_index) )
					text += LF_TEXT;
				// Starting a new cell.
				else if( -1 != row_index )
					text += FIELD_SEPARATOR_TEXT;
				
				row_index = cp.rowIndex;
				
				const column: GridColumn = this.columns.getItemAt( cp.columnIndex ) as GridColumn;
				const dp_item: Object = this.dataProvider.getItemAt( row_index );
				
				text += column.itemToLabel( dp_item );
			}
			
			return text;                
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function dataGridPasteText( text: String ): void
		{
			var startRowIndex: int = -1; 
			var startColumnIndex: int = -1;
			
			// If there's a selection, use its origin to initialize startRowIndex, startColumnIndex.
			const cp: CellPosition = this.selectedCell;
			startRowIndex = cp.rowIndex;
			startColumnIndex = cp.columnIndex;
			
			// If there's no selection, but the caret's location is defined, then use 
			// that for startRowIndex, startColumnIndex.
			if( (-1 == startRowIndex) || (-1 == startColumnIndex) && this.grid )
			{
				startRowIndex = this.grid.caretRowIndex;
				startColumnIndex = this.grid.caretColumnIndex;
			}
			
			// Nowhere to paste; return.
			if( (-1 == startRowIndex) || (-1 == startColumnIndex) )
				return;
			
			// ========= FOUND WHERE TO PASTE =========
			
			// Set the value of the region (whose origin is startRowIndex, startColumnIndex) to the 
			// values in the "text" variable.
			const vector_row_strings: Vector.<String> = splitTextIntoRows( text );
			var pasteRowIndex: int = startRowIndex;
			
			var cells_to_select: Vector.<CellPosition> = new Vector.<CellPosition>();
			
			for each( var row_string: String in vector_row_strings )
			{
				if( pasteRowIndex >= this.dataProviderLength )
					break;
				
				var pasteColumnIndex: int = startColumnIndex;
				
				var vector_cell_strings: Vector.<String> = (row_string) ? Vector.<String>( row_string.split( FIELD_SEPARATOR_TEXT ) ) : new Vector.<String>();
				
				for each( var cell_string: String in vector_cell_strings )
				{
					if( pasteColumnIndex >= this.columnsLength )
						break;
					
					const cp_to_paste_at: CellPosition = new CellPosition( pasteRowIndex, pasteColumnIndex );
					updateDataInDP( cp_to_paste_at, cell_string );
					cells_to_select.push( cp_to_paste_at );
					
					pasteColumnIndex += 1;
				}
				
				pasteRowIndex += 1;
			}
			
			// Show "which" cells have just been pasted into.
			this.selectedCells = cells_to_select;
			// Move the caret to the paste operation's origin, and ensure that it's visible
			this.grid.caretRowIndex = startRowIndex;
			this.grid.caretColumnIndex = startColumnIndex;
			this.ensureCellIsVisible( startRowIndex, startColumnIndex );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function splitTextIntoRows( text: String ): Vector.<String>
		{
			// Need to handle all possible newline characters.
			if( -1 != text.indexOf( CR_LF_TEXT ) )
				return Vector.<String>( text.split( CR_LF_TEXT ) );
			else if( -1 != text.indexOf( CR_TEXT ) )
				return Vector.<String>( text.split( CR_TEXT ) );
			else
				return Vector.<String>( text.split( LF_TEXT ) );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function updateDataInDP( cell_position: CellPosition, new_text: String ): void
		{
			const row_index: Number = cell_position.rowIndex;
			const column_index: Number = cell_position.columnIndex;
			const column: GridColumn = this.columns.getItemAt( column_index ) as GridColumn;
			
			if( null == column || !column.editable || !this.editable )
				return;
			
			const dp_item: Object = this.dataProvider.getItemAt( row_index );
			trace("Current text in cell: " + column.itemToLabel( dp_item ) + ", New text: " + new_text );
			
			if( dp_item && column.dataField && dp_item.hasOwnProperty( column.dataField ) )
			{
				dp_item[ column.dataField ] = new_text;
			}
			else
			{
				// This block is for all those cases where data to be updated is part of a complex structure.
				// To update the data in such a complex structure, we need to know the exact structure of the data,
				// to dig through it and update the correct property. The data structure parsing should not be
				// done here. We just dispatch an event (containing the cell address and new text)
				// and hope that somebody listens for this event and updates the data accordingly.
				var payload: CellDataUpdatedPayload = new CellDataUpdatedPayload( row_index, column, new_text );
				var data_updated_event: GridColumnEvent = new GridColumnEvent ( GridColumnEvent.DATA_UPDATED_IN_CELL, payload );
				data_updated_event.column = column;
				this.dispatchEvent( data_updated_event );
			}
			
			// Dispatch the data update event
			this.dataProvider.itemUpdated( dp_item );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function gridItemEditorSessionStartHandler( event: GridItemEditorEvent ): void
		{
			if( !easyEditMode )
				return;
			
			// This event listener is added to handle the case where the selected cell should move down by one row when
			// an item editor is closed by pressing enter, just like in Excel.
			this.itemEditorInstance.addEventListener( KeyboardEvent.KEY_DOWN, itemEditorInstanceKeyDownHandler );
			
			// Make sure that the selected cell is always set to the cell currently being edited.
			// Consider this:
			// 1. Select a cell.
			// 2. Press Tab - goes to the next cell and starts editing session.
			// 3. But the selected cell is still the previous cell which we had explicitly selected.
			// 4. After the editor session is closed, it looks odd to have some other cell selected.
			// 5. Also, after the session is closed, pressing F2 to start an editor session, starts it at the (other) selected cell and not
			// 	  where the editor was just closed. Again, looks very odd.
			// 6. Hence, explicitly setting the selected cell every time an editor session is started. 
			if( this.selectedCell.rowIndex != event.rowIndex || this.selectedCell.columnIndex != event.columnIndex )
				this.setSelectedCell( event.rowIndex, event.columnIndex );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function itemEditorInstanceKeyDownHandler( event: KeyboardEvent ): void
		{
			// This event listener is added to handle the case where the selected cell should move down by one row when
			// an item editor is closed by pressing enter, just like in Excel.
			//trace( "Item Editor Keycode: " + event.keyCode );
			
			// Need to use the current target because the actual item editor instance has already been closed by now.
			const item_editor_instance: IGridItemEditor = event.currentTarget as IGridItemEditor;
			
			if( Keyboard.ENTER == event.keyCode )
				this.setSelectedCell( item_editor_instance.rowIndex + 1, item_editor_instance.columnIndex );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//-----------------------------------EASY EDIT MODE - END--------------------------------------------------------------
		
	}
}