package com.anjantek.controls.sliders.supportClasses
{
	import com.anjantek.controls.sliders.skins.track.HSliderWideTrackHighlightSkin;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	import mx.events.SandboxMouseEvent;
	import mx.events.StateChangeEvent;
	import mx.states.State;
	
	import spark.components.Button;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.core.IDisplayText;
	import spark.events.TextOperationEvent;
	
	//-------------------------------------------------------------------------------------------------
	
	[Event(name="change", type="flash.events.Event")]
	
	//-------------------------------------------------------------------------------------------------
	
	public class SliderTrackHighlight extends SkinnableComponent
	{
		
		[SkinPart(required="true")]
		
		/**
		 *  A skin part that allows editing of the label.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var labelEditor:TextInput;
		
		//-------------------------------------------------------------------------------------------------
		
		//------------------------------------PROPERTIES - START-------------------------------------------------------------
		
		//----------------------------------
		//  label
		//----------------------------------
		
		private var _label: String = "";
		
		public function set label(value:String):void
		{
			_label = value;
		}
		
		/**
		 *  @private
		 */
		public function get label():String          
		{
			return _label;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public var maxLabelLength: Number = 10;
		
		//-------------------------------------------------------------------------------------------------
		
		public var value: Number;
		
		//-------------------------------------------------------------------------------------------------
		
		public var dataProviderItem: Object;
		
		//-------------------------------------PROPERTIES - END------------------------------------------------------------
		
		public function SliderTrackHighlight()
		{
			super();
			setStyle( 'skinClass', HSliderWideTrackHighlightSkin );
			Add_States();
			
			this.currentState = BASE_STATE;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected const BASE_STATE: String = "base";
		protected const EDIT_STATE: String = "edit";
		
		protected function Add_States(): void
		{
			var state_base: State = new State();
			state_base.name = BASE_STATE;
			
			var state_edit: State = new State();
			state_edit.name = EDIT_STATE;
			
			this.addEventListener( StateChangeEvent.CURRENT_STATE_CHANGE, currentStateChangeHandler );
			
			states = [ state_base, state_edit ];
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var editMode: Boolean = false;
		
		protected function currentStateChangeHandler( event: StateChangeEvent ): void
		{
			//trace("State changed: " + event.newState );
			
			switch( event.newState )
			{
				case BASE_STATE:
				{
					editMode = false;
					removeEditStateListeners();
					break;
				}
					
				case EDIT_STATE:
				{
					editMode = true;
					addEditStateListeners();
					break;
				}
				
				default:
				{
					editMode = false;
					removeEditStateListeners();
					break;
				}
			}
			
			this.invalidateSkinState();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function addEditStateListeners(): void
		{
			addSystemMouseHandlers();
			labelEditor.addEventListener( KeyboardEvent.KEY_UP, labelEditor_keyUpHandler );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function removeEditStateListeners(): void
		{
			removeSystemMouseHandlers();
			labelEditor.removeEventListener( KeyboardEvent.KEY_UP, labelEditor_keyUpHandler );
			
			if( stage )
				stage.focus = null;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == labelEditor)
			{
				labelEditor.text = label;
				labelEditor.maxChars = maxLabelLength;
				
				labelEditor.addEventListener( MouseEvent.MOUSE_DOWN, labelEditor_mouseDownHandler );
				labelEditor.addEventListener( MouseEvent.CLICK, labelEditor_clickHandler );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == labelEditor)
			{
				labelEditor.removeEventListener( MouseEvent.MOUSE_DOWN, labelEditor_mouseDownHandler );
				labelEditor.removeEventListener( MouseEvent.CLICK, labelEditor_clickHandler );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function labelEditor_mouseDownHandler( event: MouseEvent ): void
		{
			event.stopPropagation();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function labelEditor_clickHandler( event: MouseEvent ): void
		{
			event.stopPropagation();
			this.currentState = EDIT_STATE;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private const DISABLED_SKIN_STATE: String = "disabled";
		
		override protected function getCurrentSkinState():String
		{
			var super_skin_state: String = super.getCurrentSkinState();
			
			if( !labelEditor )
				return BASE_STATE;
			
			if( ! enabled )
				return DISABLED_SKIN_STATE;
			else if( editMode )
				return EDIT_STATE;
			else
				return BASE_STATE;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  This method adds the systemManager_mouseUpHandler as an event listener to
		 *  the stage and the systemManager so that it gets called even if mouse events
		 *  are dispatched outside of this component. This is used to close the editor
		 *  when the user clicks anywhere outside the editor component.
		 */
		protected function addSystemMouseHandlers():void
		{
			systemManager.getSandboxRoot().addEventListener( MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);
			systemManager.getSandboxRoot().addEventListener( SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  This method removes the systemManager_mouseUpHandler as an event
		 *  listener from the stage and the systemManager.
		 */
		protected function removeSystemMouseHandlers():void
		{
			systemManager.getSandboxRoot().removeEventListener(	MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true /* useCapture */);
			systemManager.getSandboxRoot().removeEventListener( SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemManager_mouseUpHandler );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		protected function systemManager_mouseUpHandler(event:Event):void
		{
			// If the target is the editor or if the target's parent is the editor, do nothing.
			if (event.target == labelEditor.textDisplay || 
				event.target.parent == labelEditor.textDisplay)
			{
				return;
			}
			
			finishEditing();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function labelEditor_keyUpHandler( event: KeyboardEvent ): void
		{
			// If Escape key is pressed, exit editor without saving.
			if( Keyboard.ESCAPE == event.keyCode )
				finishEditing( false );
			else if( Keyboard.ENTER == event.keyCode )
				finishEditing( true );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function finishEditing( save: Boolean = true ): void
		{
			if( save )
			{
				label = labelEditor.text;
				var label_change_event: Event = new Event( Event.CHANGE );
				dispatchEvent( label_change_event );
			}
			else
				labelEditor.text = label;
			
			this.currentState = BASE_STATE;
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}