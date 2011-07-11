package com.anjantek.controls.gridColumns.payloads
{
	import spark.components.gridClasses.GridColumn;

	public class CellDataUpdatedPayload
	{
		
		public var row_index: Number;
		public var column: GridColumn;
		public var new_text: String;
		
		//-------------------------------------------------------------------------------------------------

		
		public function CellDataUpdatedPayload( _row_index: Number, _column: GridColumn, _new_text: String )
		{
			row_index = _row_index;
			column = _column;
			new_text = _new_text;
		}
		
		//-------------------------------------------------------------------------------------------------

		
	}
}