package com.anjantek.controls.gridColumns
{
	import com.anjantek.controls.gridColumns.headerRenderers.DGCheckBoxHeaderRenderer;
	import com.anjantek.controls.gridColumns.itemRenderers.CheckBoxGridItemRenderer;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	
	import spark.skins.spark.DefaultGridHeaderRenderer;

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
			class_factory_check_box_header_renderer = new ClassFactory( DGCheckBoxHeaderRenderer );
			class_factory_default_header_renderer = new ClassFactory( DefaultGridHeaderRenderer );
			Determine_Header_Renderer();
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		private var _headerClickable: Boolean = true;
		
		[Bindable]
		public function set headerClickable( value: Boolean ): void
		{
			_headerClickable = value;
			Determine_Header_Renderer();
		}
		
		public function get headerClickable(): Boolean
		{
			return _headerClickable;
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		private var _renderCheckBoxHeader: Boolean = true;
		
		public function set renderCheckBoxHeader( value: Boolean ): void
		{
			_renderCheckBoxHeader = value;
			Determine_Header_Renderer();
		}
		
		public function get renderCheckBoxHeader(): Boolean
		{
			return _renderCheckBoxHeader;
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		private function Determine_Header_Renderer(): void
		{
			if( _renderCheckBoxHeader )
			{
				class_factory_check_box_header_renderer.properties = { clickable: headerClickable };
				this.headerRenderer = class_factory_check_box_header_renderer;
				this.resizable = false;
			}
			else
			{
				this.headerRenderer = class_factory_default_header_renderer;
				this.resizable = true;
			}
		}
		
		//----------------------------------------------------------------------------------------------------------
		
	}
}