package com.anjantek.controls.dropDownLists
{
	import avmplus.getQualifiedClassName;
	
	import com.anjantek.controls.buttons.ButtonWithError;
	import com.anjantek.controls.dropDownLists.skins.SoupedUpDropDownListSkin;
	
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	import mx.states.State;
	
	import spark.components.DropDownList;
	import spark.components.supportClasses.ButtonBase;
	import spark.events.IndexChangeEvent;
	import spark.skins.spark.DropDownListSkin;
	
	
	//--------------------------------------
	//  SkinStates
	//--------------------------------------
	
	/**
	 *  Skin state for the valid state of the DropDownListBase control.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[SkinState("valid")]
	
	//-------------------------------------------------------------------------------------------------

	/**
	 *  Skin state for the invalid (error) state of the DropDownListBase control.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[SkinState("error")]
	
	//-------------------------------------------------------------------------------------------------
	
	[SkinState("normalWithClear")]
	[SkinState("openWithClear")]
	[SkinState("disabledWithClear")]
	
	
	[SkinState("normalError")]
	[SkinState("normalErrorWithClear")]
	
	[SkinState("normalValid")]
	[SkinState("normalValidWithClear")]
	
	
	[SkinState("openError")]
	[SkinState("openErrorWithClear")]
	
	[SkinState("openValid")]
	[SkinState("openValidWithClear")]
	
	//-------------------------------------------------------------------------------------------------
	
	public class SoupedUpDropDownList extends DropDownList
	{
		public function SoupedUpDropDownList()
		{
			super();
			setStyle("skinClass", SoupedUpDropDownListSkin);
			this.addEventListener( FlexEvent.INITIALIZE, initializeHandler );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public static const BASE_STATE: String = "base";
		public static const VALID_STATE: String = "valid";
		public static const ERROR_STATE: String = "error";
		
		//-------------------------------------------------------------------------------------------------
		
		private var _showClearButton: Boolean = false;
		
		public function get showClearButton(): Boolean
		{
			return _showClearButton;
		}
		
		public function set showClearButton( value: Boolean ): void
		{
			_showClearButton = value;
			this.invalidateSkinState();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			
			if( openButton is ButtonWithError )
				openButton.enabled = value;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//----------------------------------
		//  clearSelectionButton
		//----------------------------------
		
		[SkinPart(required="false")]
		
		/**
		 *  A skin part that defines the clear selection button.  
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var clearSelectionButton:ButtonBase;
		
		//-------------------------------------------------------------------------------------------------
		
		
		//-------------------------------------------------------------------------------------------------
		
		protected function initializeHandler( event: FlexEvent ): void
		{
			//trace( "SkinClass: " + getStyle( "skinClass" ) );
			
			if( null != clearSelectionButton )
				clearSelectionButton.addEventListener( MouseEvent.CLICK, clearSelectionButton_clickHandler );
			
			Add_States();
			
			this.currentState = SoupedUpDropDownList.BASE_STATE;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function Add_States(): void
		{
			var state_valid: State = new State();
			state_valid.name = SoupedUpDropDownList.VALID_STATE;
			
			var state_error: State = new State();
			state_error.name = SoupedUpDropDownList.ERROR_STATE;
			
			var state_base: State = new State();
			state_base.name = SoupedUpDropDownList.BASE_STATE;
			
			this.addEventListener( StateChangeEvent.CURRENT_STATE_CHANGE, currentStateChangeHandler );
			
			states = [ state_base, state_valid, state_error ];
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var showValidity: Boolean = false;
		
		private var isValid: Boolean = true;
		
		protected function currentStateChangeHandler( event: StateChangeEvent ): void
		{
			//trace("State changed: " + event.newState );
			
			switch( event.newState )
			{
				case SoupedUpDropDownList.BASE_STATE:
				{
					showValidity = false;
					isValid = true;
					this.errorString = "";
					break;
				}
					
				case SoupedUpDropDownList.VALID_STATE:
				{
					showValidity = true;
					isValid = true;
					break;
				}
					
				case SoupedUpDropDownList.ERROR_STATE:
				{
					showValidity = true;
					isValid = false;
					break;
				}
					
				default:
				{
					showValidity = false;
					isValid = true;
					this.errorString = "";
					break;
				}
			}
			
			// Reflect the validity status on the openButton.
			if( openButton is ButtonWithError )
			{
				var open_button_with_error: ButtonWithError = ButtonWithError( openButton );
				open_button_with_error.showValidity = showValidity;
				open_button_with_error.isValid = isValid;
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function clearSelectionButton_clickHandler( event: MouseEvent ): void
		{
			var change_event: IndexChangeEvent = new IndexChangeEvent( IndexChangeEvent.CHANGE );
			change_event.oldIndex = this.selectedIndex;
			this.selectedIndex = -1;
			change_event.newIndex = -1;
			this.dispatchEvent( change_event );
			
			this.invalidateSkinState();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function getCurrentSkinState():String
		{
			if( null != openButton && openButton is ButtonWithError )
				openButton.invalidateSkinState();
			
			var super_skin_state: String = super.getCurrentSkinState();
			
			//trace( "DDL Super state is: " + super_skin_state );
			
			var skin_state: String;
			
			if( ! showValidity )
				skin_state = super_skin_state;
			else if( ! enabled )
				skin_state = "disabled";
			else
			{
				if( isDropDownOpen )
					skin_state = isValid ? "openValid" : "openError";
				else
					skin_state = isValid ? "normalValid" : "normalError";
			}
			
			//trace( "DDL Skin state: " + skin_state );
			if( showClearButton )
				return skin_state + "WithClear";
			else
				return skin_state;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function set selectedLabel ( _label : String ): void
		{
			if ( (dataProvider != null) && (_label != null) ) 
			{
				for ( var i : int = 0 ; i < dataProvider.length ; i++ ) 
				{
					if ( _label.toLowerCase() == itemToLabel( dataProvider [ i ] ).toLowerCase() ) 
					{
						selectedIndex = i;
						validateNow();
						return;
					}
				}
			}
			
			selectedIndex = -1;
			validateNow();
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}