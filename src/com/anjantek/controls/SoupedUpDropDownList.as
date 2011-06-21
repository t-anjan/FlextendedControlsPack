package com.anjantek.controls
{
	import avmplus.getQualifiedClassName;
	
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	import mx.states.State;
	import mx.utils.ObjectUtil;
	
	import com.anjantek.skins.SoupedUpDropDownListSkin;
	
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
	
	[SkinState("normalError")]
	[SkinState("normalValid")]
	[SkinState("openError")]
	[SkinState("openValid")]
	
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
		
		protected function initializeHandler( event: FlexEvent ): void
		{
			//trace( "SkinClass: " + getStyle( "skinClass" ) );
			
			if( openButton is ButtonWithError )
			{
				BindingUtils.bindProperty( openButton, "showValidity", this, "showValidity" );
				BindingUtils.bindProperty( openButton, "isValid", this, "isValid" );
			}
			
			if( null != clearSelectionButton )
			{
				BindingUtils.bindProperty( clearSelectionButton, "visible", this, "showClearButton" );
				clearSelectionButton.addEventListener( MouseEvent.CLICK, clearSelectionButton_clickHandler );
			}
			
			Add_States();
			
			this.currentState = "base";
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function Add_States(): void
		{
			var state_valid: State = new State();
			state_valid.name = "valid";
			
			var state_error: State = new State();
			state_error.name = "error";
			
			var state_base: State = new State();
			state_base.name = "base";
			
			this.addEventListener( StateChangeEvent.CURRENT_STATE_CHANGE, currentStateChangeHandler );
			
			states = [ state_base, state_valid, state_error ];
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function currentStateChangeHandler( event: StateChangeEvent ): void
		{
			//trace("State changed: " + event.newState );
			
			switch( event.newState )
			{
				case "base":
				{
					showValidity = false;
					isValid = true;
					this.errorString = "";
					break;
				}
					
				case "valid":
				{
					showValidity = true;
					isValid = true;
					break;
				}
					
				case "error":
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
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function clearSelectionButton_clickHandler( event: MouseEvent ): void
		{
			this.selectedIndex = -1;
			this.dispatchEvent( new IndexChangeEvent( IndexChangeEvent.CHANGE ) );
			this.invalidateSkinState();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		[Bindable]
		public var showValidity: Boolean = false;
		
		[Bindable]
		public var isValid: Boolean = true;
		
		[Bindable]
		public var showClearButton: Boolean = false;
		
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

		
		override protected function getCurrentSkinState():String
		{
			if( null != openButton && openButton is ButtonWithError )
				openButton.invalidateSkinState();
			
			var super_skin_state: String = super.getCurrentSkinState();
			
			//trace( "DDL Super state is: " + super_skin_state );
			
			var skin_class: * = getStyle( "skinClass" );
			var skin_class_name: String = getQualifiedClassName(skin_class);
			var allowed_skin_class_name: String = getQualifiedClassName(SoupedUpDropDownListSkin);
			
			//trace("Skin class: " + getQualifiedClassName(skin_class), getQualifiedClassName(SoupedUpDropDownListSkin) + "\n" + "Skin class boolean: " + (skin_class is SoupedUpDropDownListSkin) )
			if( skin_class_name != allowed_skin_class_name )
				return super_skin_state;
			
			if( ! showValidity )
				return super_skin_state;
			
			if( ! enabled )
				return "disabled";
			
			var skin_state: String;
			
			if( isDropDownOpen )
				skin_state = isValid ? "openValid" : "openError";
			else
				skin_state = isValid ? "normalValid" : "normalError";
			
			//trace( "DDL Skin state: " + skin_state );
			return skin_state;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function set value ( _value : Object ): void
		{
			if ( (dataProvider != null) && (_value != null) ) 
			{
				for ( var i : int = 0 ; i < dataProvider.length ; i++ ) 
				{
					if ( _value == itemToLabel( dataProvider [ i ] ) ) 
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