package com.anjantek.controls.sliders.supportClasses
{
	import com.anjantek.controls.sliders.interfaces.IValueCarrying;
	import com.anjantek.controls.sliders.interfaces.IValueSnapping;
	
	import mx.core.IFactory;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.formatters.NumberFormatter;

	public class SliderThumbBase extends SkinnableComponent implements IFocusManagerComponent, IValueCarrying
	{
		[SkinPart(required="false")]
		public var button: Button;
		
		[SkinPart(required="false", type="spark.components.DataRenderer")]
		public var dataTip: IFactory;
		
		[SkinPart(required="false")]
		public var label: Label;
		
		private const DEFAULT_VALUE: Number = 0;
		private const DEFAULT_MINIMUM: Number = 0;
		private const DEFAULT_MAXIMUM: Number = 100;
		private const DEFAULT_SNAP_INTERVAL: Number = 1;
		
		private var _value: Number;
		private var newValue: Number = DEFAULT_VALUE;
		private var valueChanged: Boolean = false;
		protected var valueRange: ValueRange;
		
		//-------------------------------------------------------------------------------------------------
		
		public function SliderThumbBase()
		{
			valueRange = new ValueRange(DEFAULT_MINIMUM, DEFAULT_MAXIMUM, DEFAULT_SNAP_INTERVAL);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function get value(): Number
		{
			if(valueChanged)
				return newValue;
			else
				return _value;
		}
		
		public function set value(value: Number): void
		{
			if(this.value != value)
			{
				newValue = value;
				valueChanged = true;
				invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var dataFormatter: NumberFormatter;
		public var formattedValuePrecision: Number = 0;
		
		public function get formattedValue(): String
		{
			var formatted_value: String;
			
			if(dataFormatter == null)
				dataFormatter = new NumberFormatter();
			
			dataFormatter.fractionalDigits = formattedValuePrecision;
			
			formatted_value = dataFormatter.format( value );
			
			return formatted_value;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function commitProperties(): void
		{
			super.commitProperties();
			
			newValue = valueRange.getNearestValidValueTo(newValue);
			
			if(newValue != _value)
			{
				_value = newValue;
				
				if( label )
					updateLabel();
				
				dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			}
			
			valueChanged = false;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function updateLabel(): void
		{
			label.text = formattedValue;
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}