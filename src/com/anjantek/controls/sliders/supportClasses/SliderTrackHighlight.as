package com.anjantek.controls.sliders.supportClasses
{
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.events.SandboxMouseEvent;
import mx.events.StateChangeEvent;
import mx.states.State;

import spark.components.TextInput;
import spark.components.supportClasses.SkinnableComponent;
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
		}

		//-------------------------------------------------------------------------------------------------

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);

			if (instance == labelEditor)
			{
				labelEditor.text = label;
				labelEditor.maxChars = maxLabelLength;

				labelEditor.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
				labelEditor.addEventListener( MouseEvent.CLICK, editor_clickHandler );
				labelEditor.addEventListener( TextOperationEvent.CHANGE, labelEditor_changeHandler );
			}
		}

		//-------------------------------------------------------------------------------------------------

		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);

			if (instance == labelEditor)
			{
				labelEditor.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
				labelEditor.removeEventListener( MouseEvent.CLICK, editor_clickHandler );
				labelEditor.removeEventListener( TextOperationEvent.CHANGE, labelEditor_changeHandler );
			}
		}

		//-------------------------------------------------------------------------------------------------
		
		protected function mouseDownHandler( event: MouseEvent ): void
		{
			event.stopPropagation();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function editor_clickHandler( event: MouseEvent ): void
		{
			event.stopPropagation();
		}

		//-------------------------------------------------------------------------------------------------

		/**
		 *  @private
		 */
		protected function labelEditor_changeHandler(event: TextOperationEvent):void
		{
			finishEditing();
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
		}

		//-------------------------------------------------------------------------------------------------
		
		private const DISABLED_SKIN_STATE: String = "disabled";
		protected const BASE_SKIN_STATE: String = "base";
		
		override protected function getCurrentSkinState():String
		{
			var super_skin_state: String = super.getCurrentSkinState();
			
			if( !labelEditor )
				return BASE_SKIN_STATE;
			
			if( ! enabled )
				return DISABLED_SKIN_STATE;
			else
				return BASE_SKIN_STATE;
		}
		
		//-------------------------------------------------------------------------------------------------

	}
}
