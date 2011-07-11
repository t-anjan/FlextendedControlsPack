package com.anjantek.controls.buttons
{
	import spark.components.Button;
	
	//--------------------------------------
	//  SkinStates
	//--------------------------------------
	
	/**
	 *  Skin state for the valid state of the Button control.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[SkinState("valid")]
	
	//-------------------------------------------------------------------------------------------------
	
	/**
	 *  Skin state for the invalid (error) state of the Button control.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[SkinState("error")]
	
	//-------------------------------------------------------------------------------------------------
	
	public class ButtonWithError extends Button
	{
		public function ButtonWithError()
		{
			super();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public var showValidity: Boolean = false;
		public var isValid: Boolean = true;
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function getCurrentSkinState():String
		{
			var super_skin_state: String = super.getCurrentSkinState();
			//trace( "openButton Super state is: " + super_skin_state );
			
			if( ! showValidity )
				return super_skin_state;
			
			if ( ! enabled )
				return "disabled";
			
			if( "up" == super_skin_state )
				return isValid ? "upValid" : "upError";
			
			if( "over" == super_skin_state )
				return isValid ? "overValid" : "overError";
			
			if( "down" == super_skin_state )
				return isValid ? "downValid" : "downError";
			
			return "up";
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}