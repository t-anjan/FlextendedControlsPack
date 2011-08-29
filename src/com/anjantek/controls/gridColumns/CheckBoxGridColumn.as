package com.anjantek.controls.gridColumns
{
	import com.anjantek.controls.gridColumns.events.GridColumnEvent;
	import com.anjantek.controls.gridColumns.headerRenderers.CheckBoxGridHeaderRenderer;
	import com.anjantek.controls.gridColumns.itemRenderers.CheckBoxGridItemRenderer;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.IList;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	
	import spark.components.gridClasses.CellRegion;
	import spark.events.GridSelectionEvent;
	import spark.events.GridSelectionEventKind;

	public class CheckBoxGridColumn extends AwesomeGridColumn
	{
		private var class_factory_check_box_header_renderer: ClassFactory;
		private var class_factory_default_header_renderer: ClassFactory;
		
		public function CheckBoxGridColumn()
		{
			super();
			
			this.editable = false;
			this.sortable = false;
			this.width = 25;
			
			this.itemRenderer = new ClassFactory( CheckBoxGridItemRenderer );
			class_factory_check_box_header_renderer = new ClassFactory( CheckBoxGridHeaderRenderer );
			
			this.controlProperty = "";
			updateHeaderRenderer();
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		//---------------------------------------PROPERTIES - Start-------------------------------------------------------------------
		
		private var _headerClickable: Boolean = true;
		
		[Bindable]
		public function set headerClickable( value: Boolean ): void
		{
			_headerClickable = value;
			updateHeaderRenderer();
		}
		
		public function get headerClickable(): Boolean
		{
			return _headerClickable;
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		private var _controlProperty: String = "";
		
		public function set controlProperty( value: String ): void
		{
			if( value != _controlProperty )
				_controlProperty = value;
			
			if( "" == _controlProperty )
				this.selectable = true;
			else
				this.selectable = false;
		}
		
		public function get controlProperty(): String
		{
			return _controlProperty;
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		// Call this boolean property on the data provider item to determine if the checkbox state should be allowed to be edited.
		private var _canEditRendererProperty: String = "";
		
		public function set canEditRendererProperty( value: String ): void
		{
			if( value != _canEditRendererProperty )
				_canEditRendererProperty = value;
		}
		
		public function get canEditRendererProperty(): String
		{
			return _canEditRendererProperty;
		}
		
		//-----------------------------------PROPERTIES - End-----------------------------------------------------------------------
		
		//----------------------------------------------------------------------------------------------------------
		
		protected function updateHeaderRenderer(): void
		{
			class_factory_check_box_header_renderer.properties = { clickable: headerClickable };
			this.headerRenderer = class_factory_check_box_header_renderer;
		}
		
		//----------------------------------------------------------------------------------------------------------
		
	}
}