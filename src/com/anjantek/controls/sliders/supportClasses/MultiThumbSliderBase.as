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
	import com.anjantek.controls.sliders.events.ThumbKeyEvent;
	import com.anjantek.controls.sliders.events.ThumbMouseEvent;
	import com.anjantek.controls.sliders.interfaces.IValueBounding;
	import com.anjantek.controls.sliders.interfaces.IValueLayout;
	import com.anjantek.controls.sliders.interfaces.IValueSnapping;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.core.InteractionMode;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	
	[Style(name="slideDuration", type="Number", format="Time", inherit="no")]
	[Style(name="liveDragging", type="Boolean", inherit="no")]
	[Style(name="dataTipOffsetX", type="Number", format="Length", inherit="yes")]
	[Style(name="dataTipOffsetY", type="Number", format="Length", inherit="yes")]
	
	/**
	 *  The color for each slider track.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="accentColors", type="Array", format="Color", inherit="yes", theme="spark")]
	
	/**
	 *  Specifies whether to enable track highlighting between thumbs
	 *  (or a single thumb and the beginning of the track).
	 *
	 *  @default false
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="showTrackHighlight", type="Boolean", inherit="no")]
	
	public class MultiThumbSliderBase extends SkinnableContainer implements IValueBounding, IValueSnapping
	{
		[SkinPart(required="false", type="com.anjantek.controls.sliders.components.supportClasses.SliderThumb")]
		public var thumb: IFactory;
		
		[SkinPart(required="false")]
		public var track: Button;
		
		[SkinPart(required="false", type="spark.components.Button")]
		public var trackHighlight: IFactory;
		
		[SkinPart(required="false", type="spark.components.Group")]
		public var contentGroupHighlight: Group
		
		private const DEFAULT_MINIMUM: Number = 0;
		private const DEFAULT_MAXIMUM: Number = 100;
		private const DEFAULT_SNAP_INTERVAL: Number = 1;
		private const DEFAULT_VALUES: Array = [0, 100];
		private const DEFAULT_ALLOW_OVERLAP: Boolean = false;
		
		private var newMinimum: Number;
		private var newMaximum: Number;
		private var _snapInterval: Number = DEFAULT_SNAP_INTERVAL;
		private var newValues: Array;
		private var _allowOverlap: Boolean = DEFAULT_ALLOW_OVERLAP;
		
		private var minimumChanged: Boolean = false;
		private var maximumChanged: Boolean = false;
		private var valuesChanged: Boolean = false;
		private var allowOverlapChanged: Boolean = false;
		private var snapIntervalChanged: Boolean = false;
		private var thumbValueChanged: Boolean = false;
		private var accentColorsChanged: Boolean = false;
		private var showTrackHighlightChanged: Boolean = false;
		
		private var animating: Boolean = false;
		private var draggingThumb: Boolean = false;
		private var thumbPressOffset: Point;
		private var keyDownOnThumb: Boolean = false;
		
		private var thumbs: Vector.<SliderThumb>;
		private var trackHighlightButtons: Vector.<Button>;
		
		private var focusedThumbIndex: uint = 0;
		private var animatedThumb: SliderThumb;
		
		//-------------------------------------------------------------------------------------------------
		
		public function MultiThumbSliderBase()
		{
			super();
			
			thumbs = new Vector.<SliderThumb>();
			trackHighlightButtons = new Vector.<Button>();
			
			if(!newMinimum)
				minimum = DEFAULT_MINIMUM;
			if(!newMaximum)
				maximum = DEFAULT_MAXIMUM;
			if(!newValues)
				values = DEFAULT_VALUES;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//------------------------------ PROPERTIES - START -------------------------------------------------------------------
		
		public function get minimum(): Number
		{
			if(minimumChanged)
				return newMinimum;
			else if(valueBasedLayout)
				return valueBasedLayout.minimum;
			else
				return 0;
		}
		
		public function set minimum(value: Number): void
		{
			if(value != minimum)
			{
				newMinimum = value;
				minimumChanged = true;
				invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function get maximum(): Number
		{
			if(maximumChanged)
				return newMaximum;
			if(valueBasedLayout)
				return valueBasedLayout.maximum;
			else
				return 0;
		}
		
		public function set maximum(value: Number): void
		{
			if(value != maximum)
			{
				newMaximum = value;
				maximumChanged = true;
				invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function get snapInterval(): Number
		{
			return _snapInterval;
		}
		
		public function set snapInterval(value: Number): void
		{
			if(value != _snapInterval)
			{
				_snapInterval = value;
				snapIntervalChanged = true;
				invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		[Bindable(event = "valueCommit")]
		[Bindable(event = "change")]
		public function get values(): Array
		{
			if(valuesChanged)
			{
				return newValues;
			}
			else
			{
				var thumbValues: Array = [];
				
				if(thumb)
				{
					for(var index: int = 0; index < numberOfThumbs; index++)
					{
						var value: Number = getThumbAt(index).value;
						thumbValues.push(value);
					}
				}
				
				return thumbValues;
			}
		}
		
		public function set values(value: Array): void
		{
			if(value != values)
			{
				newValues = value;
				valuesChanged = true;
				invalidateProperties();
			}  
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function get allowOverlap(): Boolean
		{
			return _allowOverlap;
		}
		
		public function set allowOverlap(value: Boolean): void
		{
			if(value != _allowOverlap)
			{
				_allowOverlap = value;
				allowOverlapChanged = true;
				invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		[Bindable]
		private var _accentColors:Array;
		
		public function get accentColors(): Array
		{
			return this._accentColors;
		}
		
		public function set accentColors(color:Array):void
		{
			this._accentColors = color;
			accentColorsChanged = true;
			invalidateProperties();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		[Bindable]
		private var _showTrackHighlight:Boolean = true;
		
		public function get showTrackHighlight():Boolean
		{
			return this._showTrackHighlight;
		}
		
		public function set showTrackHighlight(show:Boolean):void
		{
			_showTrackHighlight = show;
			showTrackHighlightChanged = true;
			invalidateProperties();
		}
		
		//------------------------------ PROPERTIES - END -------------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function partAdded(partName: String, instance: Object): void
		{
			super.partAdded(partName, instance);
			
			if(partName == "thumb")
			{
				var thumb: SliderThumb = SliderThumb(instance);
				var slideDuration: Number = getStyle("slideDuration");
				
				thumb.setStyle("slideDuration", slideDuration);
				
				thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
				thumb.addEventListener(ThumbMouseEvent.PRESS, thumbPressHandler);
				thumb.addEventListener(ThumbKeyEvent.KEY_DOWN, thumbKeyDownHandler);
				thumb.addEventListener(FlexEvent.VALUE_COMMIT, thumbValueCommitHandler);
				
				thumb.focusEnabled = true;
			}
			else if(partName == "track")
			{
				track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
				
				track.focusEnabled = false;
			}
			else if(partName == "trackHighlight")
			{
				var instance_track_highlight: Button = Button( instance );
				instance_track_highlight.focusEnabled = false;
				instance_track_highlight.addEventListener(ResizeEvent.RESIZE, trackHighLight_resizeHandler);
				
				// track is only clickable if in mouse interactionMode
				if (getStyle("interactionMode") == InteractionMode.MOUSE)
					instance_track_highlight.addEventListener(MouseEvent.MOUSE_DOWN, trackHighLight_mouseDownHandler);
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function partRemoved(partName: String, instance: Object): void
		{
			super.partRemoved(partName, instance);
			
			if(partName == "thumb")
			{
				var thumb: SliderThumb = SliderThumb(instance);
				
				thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
				thumb.removeEventListener(ThumbMouseEvent.PRESS, thumbPressHandler);
				thumb.removeEventListener(ThumbKeyEvent.KEY_DOWN, thumbKeyDownHandler);
				thumb.removeEventListener(FlexEvent.VALUE_COMMIT, thumbValueCommitHandler);
			}
			else if(partName == "track")
			{
				var track: Button = Button(instance);
				
				track.removeEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
			}
			else if(partName == "trackHighlight")
			{
				var instance_track_highlight: Button = Button( instance );
				instance_track_highlight.removeEventListener(MouseEvent.MOUSE_DOWN, trackHighLight_mouseDownHandler);
				instance_track_highlight.removeEventListener(ResizeEvent.RESIZE, trackHighLight_resizeHandler);
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			var anyStyle:Boolean = styleProp == null || styleProp == "styleName";
			
			super.styleChanged(styleProp);
			if (styleProp == "showTrackHighlight" || anyStyle)
			{
				showTrackHighlightChanged = true;
				invalidateProperties();
			}
			
			if (styleProp == "accentColors" || anyStyle)
			{
				accentColorsChanged = true;
				invalidateProperties();
			}
			
			invalidateDisplayList();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function commitProperties(): void
		{
			super.commitProperties();
			
			if(valuesChanged || minimumChanged || maximumChanged || snapIntervalChanged || allowOverlapChanged)
			{
				if(valueBasedLayout)
				{
					if(minimumChanged)
						valueBasedLayout.minimum = newMinimum;
					if(maximumChanged)
						valueBasedLayout.maximum = newMaximum;
				}
				
				if(thumb)
				{
					if(!valuesChanged)
						newValues = values;
					
					if(!allowOverlap)
						newValues = newValues.sort(Array.NUMERIC);
					
					removeAllThumbs();
					createThumbsFrom(newValues);
					
					if( contentGroupHighlight && trackHighlight )
					{
						removeAllTrackHighlights();
						createTrackHighlightsFrom( newValues );
					}
					
					dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
				}
				
				minimumChanged = false;
				maximumChanged = false;
				snapIntervalChanged = false;
				valuesChanged = false;
				allowOverlapChanged = false;
			}
			
			if(thumbValueChanged && !animating && !isDraggingThumbWithLiveDraggingDisabled)
			{
				dispatchEvent(new Event(Event.CHANGE));
				
				thumbValueChanged = false;
			}
			
			if( showTrackHighlightChanged )
			{
				for each( var track_highlight: Button in trackHighlightButtons )
				{
					track_highlight.visible = _showTrackHighlight;
				}
				
				showTrackHighlightChanged = false;
			}
			
			if( true )
			{
				for( var i: Number = 0 ; i <= trackHighlightButtons.length - 1 ; i++ )
				{
					var track_hl: Button = trackHighlightButtons[ i ];
					track_hl.setStyle( "themeColor", uint( accentColors[ i ] ) );
				}
				
				accentColorsChanged = false;
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function createThumbsFrom(values: Array): void
		{   
			for(var index: int = 0; index < values.length; index++)
			{
				var thumb: SliderThumb = SliderThumb(createDynamicPartInstance("thumb"));
				
				if(!thumb)
				{
					throw new ArgumentError("Thumb part must be of type " +
						getQualifiedClassName(SliderThumb));
				}
				
				thumb.minimum = minimum;
				thumb.maximum = maximum;
				thumb.snapInterval = snapInterval;
				thumb.value = values[index];
				
				addElement(thumb);
				thumbs.push(thumb);
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function createTrackHighlightsFrom(values: Array): void
		{
			for(var index: int = 0; index < values.length; index++)
			{
				var track_highlight: Button = Button( createDynamicPartInstance("trackHighlight") );
				
				if( ! track_highlight )
				{
					throw new ArgumentError("Track highlight part must be of type " +
						getQualifiedClassName(Button));
				}
				
				trackHighlightButtons.push( track_highlight );
				updateTrackHighlightDisplay( index );
				
				contentGroupHighlight.addElement( track_highlight );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		protected function updateTrackHighlightDisplay( _index: Number ):void
		{
			var _thumb: SliderThumb = thumbs[ _index ];
			
			// The vector should have, at least, (_index + 1) items.
			if( trackHighlightButtons.length < (_index + 1) )
				return;
			
			var track_highlight: Button = trackHighlightButtons[ _index ];
			
			if( !_thumb || !track || !track_highlight )
				return;
			
			var hl_x: Number;
			var hl_y: Number = 0;
			var hl_width: Number;
			var hl_height: Number = track.getLayoutBoundsHeight();
			
			var track_width: Number = track.getLayoutBoundsWidth();
			var range: Number = maximum - minimum;
			
			var thumb_track_x: Number;
			var thumb_global_position: Point;
			var parent_thumb_x: Number;
			
			if( 0 == _index )
			{
				hl_x = 0;
				
				// calculate thumb position.
				thumb_track_x = (range > 0) ? ((_thumb.value - minimum) / range) * track_width : 0;
				
				// convert to parent's coordinates.
				thumb_global_position = track.localToGlobal( new Point(thumb_track_x, 0) );
				parent_thumb_x = _thumb.parent.globalToLocal( thumb_global_position ).x;
				
				hl_width = Math.round( parent_thumb_x );
			}
			else
			{
				var previous_thumb: SliderThumb = thumbs[ _index - 1 ];
				
				// calculate previous thumb position.
				var previous_thumb_track_x: Number = (range > 0) ? ((previous_thumb.value - minimum) / range) * track_width : 0;
				
				// convert to parent's coordinates.
				var previous_thumb_global_position: Point = track.localToGlobal( new Point(previous_thumb_track_x, 0) );
				var parent_previous_thumb_x: Number = previous_thumb.parent.globalToLocal( previous_thumb_global_position ).x;
				
				hl_x = parent_previous_thumb_x;
				
				// calculate thumb position.
				thumb_track_x = (range > 0) ? ((_thumb.value - minimum) / range) * track_width : 0;
				
				// convert to parent's coordinates.
				thumb_global_position = track.localToGlobal( new Point(thumb_track_x, 0) );
				parent_thumb_x = _thumb.parent.globalToLocal( thumb_global_position ).x;
				
				hl_width = Math.round( parent_thumb_x - parent_previous_thumb_x );
			}
			
			track_highlight.setLayoutBoundsPosition( hl_x, hl_y );
			track_highlight.setLayoutBoundsSize( hl_width, hl_height );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function removeAllThumbs(): void
		{
			for(var index: int = 0; index < thumbs.length; index++)
			{
				removeDynamicPartInstance("thumb", thumbs[index]);
				removeElement(thumbs[index]);
			}
			
			thumbs.splice(0, thumbs.length);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function removeAllTrackHighlights(): void
		{
			for(var index: int = 0; index < trackHighlightButtons.length; index++)
			{
				removeDynamicPartInstance("trackHighlight", trackHighlightButtons[index]);
				contentGroupHighlight.removeElement(trackHighlightButtons[index]);
			}
			
			trackHighlightButtons.splice( 0, trackHighlightButtons.length );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function get valueBasedLayout(): IValueLayout
		{
			return (layout as IValueLayout);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function get numberOfThumbs(): int
		{
			return thumbs.length;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getThumbAt(index: int): SliderThumb
		{
			return thumbs[index];
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getIndexOf(thumb: SliderThumb): int
		{
			return thumbs.indexOf(thumb);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function thumbMouseDownHandler(event: MouseEvent): void
		{                    
			visuallyMoveToFront(IVisualElement(event.currentTarget));
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function visuallyMoveToFront(instance: IVisualElement): void
		{
			var lastIndexElement: IVisualElement = getElementAt(numElements - 1);
			
			if(instance != lastIndexElement)
				swapElements(instance, lastIndexElement);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function thumbPressHandler(event: ThumbMouseEvent): void
		{
			if(animating)
				animatedThumb.stopAnimation();
			
			var thumb: SliderThumb = SliderThumb(event.currentTarget);
			
			// Store the delta between mouse pointer's position on thumb down and the current value of the thumb.
			// On dragging, this value is used to offset the new value, making it appear as
			// if the mouse pointer stays in the same position over the thumb. Can't trust the thumb's
			// own measurements here since it doesn't know how the layout is positioning it relative to its value.
			var thumbPressPoint: Point = contentGroup.globalToLocal(new Point(event.stageX, event.stageY));
			var thumbPoint: Point = valueBasedLayout.valueToPoint(thumb.value);            
			thumbPressOffset = new Point(thumbPoint.x - thumbPressPoint.x, thumbPoint.y - thumbPressPoint.y);
			
			thumb.addEventListener(ThumbMouseEvent.DRAGGING, thumbDraggingHandler);
			thumb.addEventListener(ThumbMouseEvent.RELEASE, thumbReleaseHandler);
			
			draggingThumb = true;
			dispatchChangeStart();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function thumbDraggingHandler(event: ThumbMouseEvent): void
		{
			var thumb: SliderThumb = SliderThumb(event.currentTarget);
			
			if(valueBasedLayout)
			{
				var draggedTo: Point = contentGroup.globalToLocal(new Point(event.stageX, event.stageY));
				draggedTo.offset(thumbPressOffset.x, thumbPressOffset.y);
				
				thumb.value = valueBasedLayout.pointToValue(draggedTo);
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function thumbReleaseHandler(event: ThumbMouseEvent): void
		{
			var thumb: SliderThumb = SliderThumb(event.currentTarget);
			
			thumb.removeEventListener(ThumbMouseEvent.DRAGGING, thumbDraggingHandler);
			thumb.removeEventListener(ThumbMouseEvent.RELEASE, thumbReleaseHandler);            
			
			draggingThumb = false;
			dispatchChangeEnd();
			
			invalidateThumbValues();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function thumbKeyDownHandler(event: ThumbKeyEvent): void
		{
			var thumb: SliderThumb = SliderThumb(event.currentTarget);
			
			if(animating)
				stopAnimation();
			
			if(!keyDownOnThumb)
			{
				dispatchChangeStart();
				keyDownOnThumb = true;
				thumb.addEventListener(ThumbKeyEvent.KEY_UP, thumbKeyUpHandler);
			}
			
			thumb.value = event.newValue;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function thumbKeyUpHandler(event: ThumbKeyEvent): void
		{
			var thumb: SliderThumb = SliderThumb(event.currentTarget);
			
			dispatchChangeEnd();
			keyDownOnThumb = false;
			thumb.removeEventListener(ThumbKeyEvent.KEY_UP, thumbKeyUpHandler);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function thumbValueCommitHandler(event: FlexEvent): void
		{
			var _thumb: SliderThumb = SliderThumb( event.currentTarget );
			
			if(!allowOverlap && numberOfThumbs > 1)
			{
				constrainThumb( _thumb );
			}
			
			if(!animating && !isDraggingThumbWithLiveDraggingDisabled)
			{
				invalidateThumbValues();
			}
			
			contentGroup.invalidateDisplayList();
			
			var index: Number = thumbs.indexOf( _thumb );
			// Update the HL track of the thumb that was updated. 
			updateTrackHighlightDisplay( index );
			
			// If this is not the first thumb, then update the display of the previous HL track as well,
			// because, obviously, the width of that track should change too.
			if( 0 != index &&
				trackHighlightButtons.length >= index && 
				trackHighlightButtons[ index - 1 ] )
			{
				updateTrackHighlightDisplay( index - 1 );
			}
			
			// If there is an HL track after the current one, update its display too.
			if( trackHighlightButtons.length >= (index + 2) && 
				trackHighlightButtons[ index + 1 ] )
			{
				updateTrackHighlightDisplay( index + 1 );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function invalidateThumbValues(): void
		{
			if(!thumbValueChanged)
			{
				thumbValueChanged = true;
				invalidateProperties();
			}            
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function get isDraggingThumbWithLiveDraggingDisabled(): Boolean
		{
			return draggingThumb && !getStyle("liveDragging");    
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function constrainThumb(thumb: SliderThumb): void
		{
			var thumbIndex: int = getIndexOf(thumb);
			
			if(thumbIndex != 0)
				getThumbAt(thumbIndex - 1).constrainMaximumTo(thumb);
			
			if(thumbIndex != numberOfThumbs - 1)
				getThumbAt(thumbIndex + 1).constrainMinimumTo(thumb);           
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function trackMouseDownHandler(event: MouseEvent): void
		{
			if(valueBasedLayout)
			{
				var trackRelative: Point = track.globalToLocal(new Point(event.stageX, event.stageY));
				var trackClickValue: Number = valueBasedLayout.pointToValue(trackRelative);
				var nearestThumb: SliderThumb = nearestThumbTo(trackClickValue);
				
				if(getStyle("slideDuration") != 0)
					beginThumbAnimation(nearestThumb, trackClickValue);
				else
					nearestThumb.value = trackClickValue;
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function nearestThumbTo(value: Number): SliderThumb
		{           
			var nearestValue: Number = valueBasedLayout.maximum;
			var nearestThumb: SliderThumb;
			
			for(var index: int = 0; index < numberOfThumbs; index++)
			{
				var thumb: SliderThumb = getThumbAt(index);
				var valueDelta: Number = Math.abs(thumb.value - value);
				
				var valueInRange: Boolean 
				= allowOverlap || (thumb.minimum <= value && thumb.maximum >= value)
				
				if(valueDelta < nearestValue && valueInRange)
				{
					nearestValue = valueDelta;
					nearestThumb = thumb;
				}
			} 
			
			return nearestThumb;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function beginThumbAnimation(thumb: SliderThumb, value: Number): void
		{
			if(animating)
				animatedThumb.stopAnimation();
			
			animating = true;
			animatedThumb = thumb;
			animatedThumb.animateMovementTo(value, endAnimation);
			
			dispatchChangeStart();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function stopAnimation(): void
		{
			animatedThumb.stopAnimation();  
			
			endAnimation();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function endAnimation(): void
		{
			animatedThumb = null;
			animating = false;   
			
			dispatchChangeEnd();
		}
		
		//---------------------------------------Thumb Code - End----------------------------------------------------------
		
		//-------------------------------------Track Highlight Code - Start------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function trackHighLight_resizeHandler(event:Event):void
		{
			var track_highlight: Button = Button( event.currentTarget );
			var index: Number = trackHighlightButtons.indexOf( track_highlight );
			updateTrackHighlightDisplay( index );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Handle mouse-down events for the slider track hightlight. We
		 *  calculate the value based on the new position and then
		 *  move the thumb to the correct location as well as
		 *  commit the value.
		 */
		protected function trackHighLight_mouseDownHandler(event:MouseEvent):void
		{
			trackMouseDownHandler(event);
		}
		
		//-------------------------------------Track Highlight Code - End------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------
		
		private function dispatchChangeStart(): void
		{
			dispatchEvent(new FlexEvent(FlexEvent.CHANGE_START));
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function dispatchChangeEnd(): void
		{
			dispatchEvent(new FlexEvent(FlexEvent.CHANGE_END));
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}