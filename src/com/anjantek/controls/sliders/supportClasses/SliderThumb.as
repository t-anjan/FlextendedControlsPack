/**
 * The MIT License
 *
 * Copyright (c) 2011 Patrick Mowrer
 *  
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions: 
 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

package com.anjantek.controls.sliders.supportClasses
{
	import com.anjantek.controls.sliders.events.ThumbEvent;
	import com.anjantek.controls.sliders.events.ThumbKeyEvent;
	import com.anjantek.controls.sliders.events.ThumbMouseEvent;
	import com.anjantek.controls.sliders.interfaces.ISliderThumbAnimation;
	import com.anjantek.controls.sliders.interfaces.IValueBounding;
	import com.anjantek.controls.sliders.interfaces.IValueCarrying;
	import com.anjantek.controls.sliders.interfaces.IValueSnapping;
	
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import mx.core.IFactory;
	import mx.core.InteractionMode;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.events.MoveEvent;
	import mx.events.SandboxMouseEvent;
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.Button;
	import spark.components.DataRenderer;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.formatters.NumberFormatter;
	
	use namespace mx_internal;
	
	[Style(name="focusAlpha", type="Number", inherit="no", theme="spark", minValue="0.0", maxValue="1.0")]
	[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	[Style(name="slideDuration", type="Number", format="Time", inherit="no")]
	
	public class SliderThumb extends SliderThumbBase implements IValueCarrying, IValueBounding, IValueSnapping, IFocusManagerComponent
	{
		private var dataTipInstance: DataRenderer;
		private var _isValueFixed: Boolean = false;
		private var animation: ISliderThumbAnimation;
		private var isDragging: Boolean;
		
		[SkinPart(required="false")]
		public var removeThumb: Button;
		
		[SkinPart(required="false")]
		public var addThumb: Button;
		
		public function SliderThumb()
		{
			super();
		}
		
		//------------------------------ PROPERTIES - START -------------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------
		
		public function get minimum(): Number
		{
			return valueRange.minimum;
		}
		
		public function set minimum(value: Number): void
		{
			if(value != minimum)
			{
				valueRange.minimum = value;
				invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function get maximum(): Number
		{
			return valueRange.maximum;
		}
		
		public function set maximum(value: Number): void
		{
			if(value != maximum)
			{
				valueRange.maximum = value;
				invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function get snapInterval(): Number
		{
			return valueRange.snapInterval;
		}
		
		public function set snapInterval(value: Number): void
		{
			if(value != snapInterval)
			{
				valueRange.snapInterval = value;
				invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override public function get formattedValue(): String
		{
			var formatted_value: String = super.formattedValue;
			
			if( _isValueFixed )
				formatted_value += " (fixed)";
			
			return formatted_value;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function get isValueFixed(): Boolean
		{
			return _isValueFixed;
		}
		
		public function set isValueFixed(value: Boolean): void
		{
			if( this.value != _isValueFixed )
			{
				_isValueFixed = value;
				enabled = (! _isValueFixed );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//----------------------------------
		//  hovered
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the hovered property 
		 */
		private var _hovered:Boolean = false;
		
		/**
		 *  Indicates whether the mouse pointer is over the button.
		 *  Used to determine the skin state.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */ 
		protected function get hovered():Boolean
		{
			return _hovered;
		}
		
		/**
		 *  @private
		 */ 
		protected function set hovered(value:Boolean):void
		{
			if (value == _hovered)
				return;
			
			_hovered = value;
			invalidateSkinState();
		}
		
		//------------------------------ PROPERTIES - END -------------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------
		
		public function constrainMinimumTo( thumb: SliderThumb, allowOverlappingThumbs: Boolean = true ): void
		{
			if( isValueFixed )
				return;
			
			var nearestGreaterInterval: Number = valueRange.roundToNearestGreaterInterval(thumb.value);
			
			if( ! allowOverlappingThumbs )
				nearestGreaterInterval += snapInterval;
			
			minimum = nearestGreaterInterval;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function constrainMaximumTo( thumb: SliderThumb, allowOverlappingThumbs: Boolean = true ): void
		{
			if( isValueFixed )
				return;
			
			var nearestLesserInterval: Number = valueRange.roundToNearestLesserInterval(thumb.value);
			
			if( ! allowOverlappingThumbs )
				nearestLesserInterval -= snapInterval;
			
			maximum = nearestLesserInterval;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function animateMovementTo(value: Number, endHandler: Function): void
		{
			var slideDuration: Number = getStyle("slideDuration");
			
			animation = new SimpleSliderThumbAnimation(this);
			animation.play(slideDuration, valueRange.getNearestValidValueTo(value), endHandler);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function stopAnimation(): void
		{
			if(animationIsPlaying)
				animation.stop();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function get animationIsPlaying(): Boolean
		{
			return animation && animation.isPlaying();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function partAdded(partName: String, instance: Object): void
		{
			if(partName == "button")
			{
				button.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				this.addEventListener( MouseEvent.ROLL_OVER, rollOverHandler );
				this.addEventListener( MouseEvent.ROLL_OUT, rollOutHandler );
			}
			else if(partName == "dataTip")
			{
				systemManager.toolTipChildren.addChild(DisplayObject(instance));
				
				if( ! hasEventListener( MoveEvent.MOVE ) )
					addEventListener(MoveEvent.MOVE, moveHandler);
				
				dataTipInstance = DataRenderer(instance);
				updateDataTip();
			}
			else if( partName == "label" )
			{
				if( ! hasEventListener( MoveEvent.MOVE ) )
					addEventListener(MoveEvent.MOVE, moveHandler);
				
				updateLabel();
			}
			else if( partName == "removeThumb" )
			{
				removeThumb.addEventListener( MouseEvent.CLICK, removeThumb_clickHandler );
			}
			else if( partName == "addThumb" )
			{
				addThumb.addEventListener( MouseEvent.CLICK, addThumb_clickHandler );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function partRemoved(partName: String, instance: Object): void
		{
			if(partName == "button")
			{
				button.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
			else if(partName == "dataTip")
			{
				systemManager.toolTipChildren.removeChild(DisplayObject(instance));
				dataTipInstance = null;
			}
			else if( partName == "removeThumb" )
			{
				removeThumb.removeEventListener( MouseEvent.CLICK, removeThumb_clickHandler );
			}
			else if( partName == "addThumb" )
			{
				addThumb.removeEventListener( MouseEvent.CLICK, addThumb_clickHandler );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override public function drawFocus(isFocused: Boolean): void
		{
			if(button)
			{
				button.drawFocusAnyway = true;
				button.drawFocus(isFocused);
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//---------------------------------- MOUSE EVENTS - START ---------------------------------------------------------------
		
		private function mouseDownHandler(event: MouseEvent): void
		{
			if(isDragging)
				return;
			
			var sandboxRoot: DisplayObject = systemManager.getSandboxRoot();
			
			sandboxRoot.addEventListener(MouseEvent.MOUSE_MOVE, systemMouseMoveHandler, true);
			sandboxRoot.addEventListener(MouseEvent.MOUSE_UP, systemMouseUpHandler, true);
			sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemMouseUpHandler);  
			
			var globalClick: Point = new Point(event.stageX, event.stageY);
			isDragging = true;
			
			dispatchThumbEvent(ThumbMouseEvent.PRESS, globalClick);     
			
			if(dataTip)
				createDynamicPartInstance("dataTip");
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function systemMouseMoveHandler(event: MouseEvent): void
		{
			dispatchThumbEvent(ThumbMouseEvent.DRAGGING,  new Point(event.stageX, event.stageY));
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function systemMouseUpHandler(event: MouseEvent): void
		{
			var sandboxRoot: DisplayObject = systemManager.getSandboxRoot();
			
			sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE, systemMouseMoveHandler, true);
			sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, systemMouseUpHandler, true);
			sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, systemMouseUpHandler); 
			
			isDragging = false;    
			
			dispatchThumbEvent(ThumbMouseEvent.RELEASE, new Point(event.stageX, event.stageY));
			
			if(dataTip)
				removeDynamicPartInstance("dataTip", dataTipInstance);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function dispatchThumbEvent(type: String, point: Point): void
		{
			dispatchEvent(new ThumbMouseEvent(type, point.x, point.y));            
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function moveHandler(event: MoveEvent): void
		{
			if(dataTipInstance && !animationIsPlaying)
			{
				updateDataTip();
			}
			
			if( label && !animationIsPlaying )
			{
				updateLabel();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function rollOverHandler( event: MouseEvent ): void
		{
			hovered = true;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function rollOutHandler( event: MouseEvent ): void
		{
			hovered = false;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function removeThumb_clickHandler( event: MouseEvent ): void
		{
			var remove_thumb_clicked_event: ThumbEvent = new ThumbEvent( ThumbEvent.REMOVE_THUMB_CLICKED );
			this.dispatchEvent( remove_thumb_clicked_event );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function addThumb_clickHandler( event: MouseEvent ): void
		{
			var add_thumb_clicked_event: ThumbEvent = new ThumbEvent( ThumbEvent.ADD_THUMB_CLICKED );
			this.dispatchEvent( add_thumb_clicked_event );
		}
		
		//---------------------------------- MOUSE EVENTS - END ---------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------
		
		private function updateDataTip(): void
		{
			var dataTipPosition: Point = parent.localToGlobal(getCenterPointCoordinatesOf(this));
			dataTipPosition.offset(getStyle("dataTipOffsetX"), getStyle("dataTipOffsetY"));
			
			dataTipInstance.setLayoutBoundsPosition(dataTipPosition.x, dataTipPosition.y);
			dataTipInstance.data = value;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getCenterPointCoordinatesOf(component: UIComponent): Point
		{
			var x: Number = component.getLayoutBoundsX() + (component.getLayoutBoundsWidth() / 2);
			var y: Number = component.getLayoutBoundsY() + (component.getLayoutBoundsHeight() / 2);
			
			return new Point(x, y);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function keyDownHandler(event: KeyboardEvent): void
		{
			super.keyDownHandler(event);
			
			if(event.isDefaultPrevented())
				return;
			
			var newValue: Number = value;
			var thumbKeyEvent: ThumbKeyEvent;
			
			switch(event.keyCode)
			{
				case Keyboard.DOWN: 
				case Keyboard.LEFT: 
				{
					newValue = valueRange.getNearestValidValueTo(value - snapInterval);
					break;
				}
					
				case Keyboard.UP: 
				case Keyboard.RIGHT: 
				{
					newValue = valueRange.getNearestValidValueTo(value + snapInterval);
					break;
				}
			}
			
			event.preventDefault();
			
			if(newValue != value)
			{            
				thumbKeyEvent = new ThumbKeyEvent(ThumbKeyEvent.KEY_DOWN, newValue);
				dispatchEvent(thumbKeyEvent);
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function keyUpHandler(event: KeyboardEvent): void
		{
			var thumbKeyEvent: ThumbKeyEvent;
			
			switch(event.keyCode)
			{
				case Keyboard.DOWN: 
				case Keyboard.LEFT: 
				case Keyboard.UP: 
				case Keyboard.RIGHT: 
				{
					thumbKeyEvent = new ThumbKeyEvent(ThumbKeyEvent.KEY_UP, value);
					dispatchEvent(thumbKeyEvent);
					
					event.preventDefault();
					break;
				}
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function getCurrentSkinState():String
		{
			if (!enabled)
				return "disabled";
			
			if( getStyle("interactionMode") == InteractionMode.MOUSE && hovered )
				return "over";
			
			return "up";
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}