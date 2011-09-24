package com.anjantek.controls.sliders.supportClasses
{

	public class SliderMarker extends SliderThumbBase
	{
		public function SliderMarker()
		{
			super();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override public function get formattedValue(): String
		{
			var formatted_value: String = super.formattedValue;
			formatted_value += " (fixed)";
			return formatted_value;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function partAdded(partName: String, instance: Object): void
		{
			if( partName == "label" )
				updateLabel();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function getCurrentSkinState():String
		{
			if (!enabled)
				return "disabled";
			
			return "normal";
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}