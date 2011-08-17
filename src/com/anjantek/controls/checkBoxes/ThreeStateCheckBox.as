package com.anjantek.controls.checkBoxes
{
	import avmplus.getQualifiedClassName;
	
	import mx.events.FlexEvent;
	
	import spark.components.CheckBox;
	import com.anjantek.controls.checkBoxes.skins.ThreeStateCheckBoxSkin;
	
	
	/**
	 *  Up State of the Button when it's partially selected
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[SkinState("upAndPartial")]
	
	/**
	 *  Over State of the Button when it's partially selected
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[SkinState("overAndPartial")]
	
	/**
	 *  Down State of the Button when it's partially selected
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[SkinState("downAndPartial")]
	
	/**
	 *  Disabled State of the Button when it's partially selected
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[SkinState("disabledAndPartial")]
	
	//-------------------------------------------------------------------------------------------------
	
	public class ThreeStateCheckBox extends CheckBox
	{
		public function ThreeStateCheckBox()
		{
			super();
			setStyle("skinClass", ThreeStateCheckBoxSkin);
		}
		
		//----------------------------------
		//  partial
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the partial property 
		 */
		private var _partial:Boolean;
		
		[Bindable]
		[Inspectable(category="General", defaultValue="false")]
		
		/**
		 *  Contains <code>true</code> if the button is in the partial state, 
		 *  and <code>false</code> if it is in the non-partial state.
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */    
		public function get partial():Boolean
		{
			return _partial;
		}
		
		public function set partial(value:Boolean):void
		{
			if (value == _partial)
				return;
			
			_partial = value;
			
			// If partial is being set to true, make sure "selected" is set to false;
			if( value )
				selected = false;
			
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			invalidateSkinState();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override public function set selected(value:Boolean):void
		{
			// If selected is being set to true, make sure "partial" is set to false;
			if( value )
				partial = false;
			
			super.selected = value;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function getCurrentSkinState():String
		{
			var super_skin_state: String = super.getCurrentSkinState();
			
			var skin_class: * = getStyle( "skinClass" );
			var skin_class_name: String = getQualifiedClassName( skin_class );
			var allowed_skin_class_name: String = getQualifiedClassName( ThreeStateCheckBoxSkin );
			
			if( skin_class_name != allowed_skin_class_name )
			{
				trace("Wrong skin class being used for the three state check box!!");
				return super_skin_state;
			}
			
			if ( ! partial )
				return super_skin_state;
			else
				return super_skin_state + "AndPartial";
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}