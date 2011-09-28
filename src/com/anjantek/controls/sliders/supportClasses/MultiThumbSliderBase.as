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
	import com.anjantek.controls.sliders.interfaces.IValueBounding;
	import com.anjantek.controls.sliders.interfaces.IValueLayout;
	import com.anjantek.controls.sliders.interfaces.IValueSnapping;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.core.InteractionMode;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.ResizeEvent;
	import mx.utils.ObjectUtil;
	import mx.utils.object_proxy;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
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
		[SkinPart(required="true", type="com.anjantek.controls.sliders.components.supportClasses.SliderThumb")]
		public var thumb: IFactory;
		
		[SkinPart(required="true")]
		public var track: Button;
		
		[SkinPart(required="false", type="com.anjantek.controls.sliders.components.supportClasses.SliderTrackHighlight")]
		public var trackHighlight: IFactory;
		
		[SkinPart(required="false", type="spark.components.Group")]
		public var contentGroupHighlight: Group
		
		[SkinPart(required="false", type="com.anjantek.controls.sliders.components.supportClasses.SliderMarker")]
		public var marker: IFactory;
		
		[SkinPart(required="false", type="spark.components.Group")]
		public var contentGroupMarker: Group
		
		private const DEFAULT_MINIMUM: Number = 0;
		private const DEFAULT_MAXIMUM: Number = 100;
		private const DEFAULT_SNAP_INTERVAL: Number = 1;
		private const DEFAULT_ALLOW_OVERLAP: Boolean = false;
		
		private var thumbValueChanged: Boolean = false;
		
		private var animating: Boolean = false;
		private var draggingThumb: Boolean = false;
		private var thumbPressOffset: Point;
		private var keyDownOnThumb: Boolean = false;
		
		private var thumbs: Vector.<SliderThumb>;
		private var trackHighlightButtons: Vector.<SliderTrackHighlight>;
		private var markerComponents: Vector.<SliderMarker>;
		
		private var focusedThumbIndex: uint = 0;
		private var animatedThumb: SliderThumb;
		
		//-------------------------------------------------------------------------------------------------
		
		public function MultiThumbSliderBase()
		{
			super();
			
			thumbs = new Vector.<SliderThumb>();
			trackHighlightButtons = new Vector.<SliderTrackHighlight>();
			markerComponents = new Vector.<SliderMarker>();
			
			if(!newMinimum)
				minimum = DEFAULT_MINIMUM;
			
			if(!newMaximum)
				maximum = DEFAULT_MAXIMUM;
			
			this.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//------------------------------ PROPERTIES - START -------------------------------------------------------------------
		
		private var minimumChanged: Boolean = false;
		
		private var newMinimum: Number;
		
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
		
		private var maximumChanged: Boolean = false;
		
		private var newMaximum: Number;
		
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
		
		private var snapIntervalChanged: Boolean = false;
		
		private var _snapInterval: Number = DEFAULT_SNAP_INTERVAL;
		
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
		
		private var dataProviderChanged:Boolean;
		
		private var _dataProvider: IList = new ArrayCollection();
		
		[Bindable("dataProviderChanged")]
		[Inspectable(category="Data")]
		public function get dataProvider():IList
		{
			return _dataProvider;
		}
		
		public function set dataProvider( value:IList ):void
		{
			if( value != _dataProvider )
			{
				if (dataProvider)
					dataProvider.removeEventListener( CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler );
				
				_dataProvider = value;
				
				reactToDataProviderUpdate();
				
				if (dataProvider)
					dataProvider.addEventListener( CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true );
				
				dispatchEvent(new Event("dataProviderChanged"));
				dataProviderChanged = true;
				invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var markersChanged: Boolean = false;
		
		private var _markers: Array = new Array();
		
		// Contains the values for which "markers" will be created on the track.
		// These will just be labels on the track, indicating the value at that point.
		// These markers will not be movable and their values will not be part of the "values" array.
		public function get markers(): Array
		{
			return _markers;
		}
		
		public function set markers(value: Array): void
		{
			if( value != _markers )
			{
				_markers = value;
				markersChanged = true;
				invalidateProperties();
			}  
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var allowOverlapChanged: Boolean = false;
		
		private var _allowOverlap: Boolean = DEFAULT_ALLOW_OVERLAP;
		
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
		
		private var _allowDuplicateValues: Boolean = true;
		
		public function get allowDuplicateValues(): Boolean
		{
			return _allowDuplicateValues;
		}
		
		public function set allowDuplicateValues(value: Boolean): void
		{
			if(value != _allowDuplicateValues)
			{
				_allowDuplicateValues = value;
				
				if( ! _allowDuplicateValues )
					removeDataProviderDuplicateValues();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var accentColorsChanged: Boolean = false;
		
		private var _accentColors:Array;
		
		[Bindable]
		public function get accentColors(): Array
		{
			return _accentColors;
		}
		
		public function set accentColors(colors:Array):void
		{
			_accentColors = colors;
			accentColorsChanged = true;
			invalidateProperties();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var showTrackHighlightChanged: Boolean = false;
		
		private var _showTrackHighlight:Boolean = true;
		
		[Bindable]
		public function get showTrackHighlight():Boolean
		{
			return _showTrackHighlight;
		}
		
		public function set showTrackHighlight(show:Boolean):void
		{
			_showTrackHighlight = show;
			showTrackHighlightChanged = true;
			invalidateProperties();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//----------------------------------
		//  valueField
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _valueField:String = "value";
		
		/**
		 *  @private
		 */
		private var valueFieldChanged:Boolean; 
		
		[Inspectable(category="Data", defaultValue="value")]
		
		/**
		 *  The name of the field in the data provider items to display 
		 *  as the value. 
		 * 
		 *  If valueField is set to an empty string (""), no field will 
		 *  be considered on the data provider to represent value.
		 * 
		 *  @default "value" 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get valueField():String
		{
			return _valueField;
		}
		
		/**
		 *  @private
		 */
		public function set valueField(value:String):void
		{
			if (value == _valueField)
				return;
			
			_valueField = value;
			valueFieldChanged = true;
			invalidateProperties();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//----------------------------------
		//  fixedValueField
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _fixedValueField:String = "fixedValue";
		
		/**
		 *  @private
		 */
		private var fixedValueFieldChanged:Boolean; 
		
		[Inspectable(category="Data", defaultValue="fixedValue")]
		
		/**
		 *  The name of the field in the data provider items to display 
		 *  as the fixedValue. 
		 * 
		 *  If fixedValueField is set to an empty string (""), no field will 
		 *  be considered on the data provider to represent fixedValue.
		 * 
		 *  @default "fixedValue" 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get fixedValueField():String
		{
			return _fixedValueField;
		}
		
		/**
		 *  @private
		 */
		public function set fixedValueField(value:String):void
		{
			if (value == _fixedValueField)
				return;
			
			_fixedValueField = value;
			fixedValueFieldChanged = true;
			invalidateProperties();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//----------------------------------
		//  labelField
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _labelField:String = "label";
		
		/**
		 *  @private
		 */
		private var labelFieldChanged:Boolean; 
		
		[Inspectable(category="Data", defaultValue="label")]
		
		/**
		 *  The name of the field in the data provider items to display 
		 *  as the label. 
		 * 
		 *  If labelField is set to an empty string (""), no field will 
		 *  be considered on the data provider to represent label.
		 * 
		 *  @default "label" 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get labelField():String
		{
			return _labelField;
		}
		
		/**
		 *  @private
		 */
		public function set labelField(value:String):void
		{
			if (value == _labelField)
				return;
				
			_labelField = value;
			labelFieldChanged = true;
			invalidateProperties();
		}
		
		//------------------------------ PROPERTIES - END -------------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------
		
		private function creationCompleteHandler( event: FlexEvent ): void
		{
			// When the track highlights are created on initialization, the position and dimensions are set wrong
			// because the dimensions of the "track" component itself are not yet finalized. So, re-calculating the properties of the
			// track highlights when the track component has been fully created.
			for each( var track_highlight: SliderTrackHighlight in trackHighlightButtons )
			{
				updateTrackHighlightDisplay( track_highlight );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function partAdded(partName: String, instance: Object): void
		{
			super.partAdded( partName, instance );
			
			if(partName == "thumb")
			{
				var instance_thumb: SliderThumb = SliderThumb( instance );
				
				var slideDuration: Number = getStyle("slideDuration");
				
				instance_thumb.setStyle("slideDuration", slideDuration);
				
				instance_thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
				instance_thumb.addEventListener(ThumbMouseEvent.PRESS, thumbPressHandler);
				instance_thumb.addEventListener(ThumbKeyEvent.KEY_DOWN, thumbKeyDownHandler);
				instance_thumb.addEventListener(FlexEvent.VALUE_COMMIT, thumbValueCommitHandler);
				instance_thumb.addEventListener(ThumbEvent.ADD_THUMB_CLICKED, addThumb_clickHandler);
				instance_thumb.addEventListener(ThumbEvent.REMOVE_THUMB_CLICKED, removeThumb_clickHandler);
				
				instance_thumb.focusEnabled = true;
			}
			else if(partName == "track")
			{
				track.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
				
				track.focusEnabled = false;
			}
			else if(partName == "trackHighlight")
			{
				var instance_track_highlight: SliderTrackHighlight = SliderTrackHighlight( instance );
				instance_track_highlight.addEventListener(ResizeEvent.RESIZE, trackHighlight_resizeHandler);
				instance_track_highlight.addEventListener( Event.CHANGE, trackHighlight_labelChangeHandler);
				
				// track is only clickable if in mouse interactionMode
				if (getStyle("interactionMode") == InteractionMode.MOUSE)
					instance_track_highlight.addEventListener(MouseEvent.MOUSE_DOWN, trackHighlight_mouseDownHandler);
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function partRemoved(partName: String, instance: Object): void
		{
			super.partRemoved(partName, instance);
			
			if(partName == "thumb")
			{
				var instance_thumb: SliderThumb = SliderThumb(instance);
				
				instance_thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumbMouseDownHandler);
				instance_thumb.removeEventListener(ThumbMouseEvent.PRESS, thumbPressHandler);
				instance_thumb.removeEventListener(ThumbKeyEvent.KEY_DOWN, thumbKeyDownHandler);
				instance_thumb.removeEventListener(FlexEvent.VALUE_COMMIT, thumbValueCommitHandler);
				instance_thumb.removeEventListener(ThumbEvent.ADD_THUMB_CLICKED, addThumb_clickHandler);
				instance_thumb.removeEventListener(ThumbEvent.REMOVE_THUMB_CLICKED, removeThumb_clickHandler);
			}
			else if(partName == "track")
			{
				var track: Button = Button(instance);
				
				track.removeEventListener(MouseEvent.MOUSE_DOWN, trackMouseDownHandler);
			}
			else if(partName == "trackHighlight")
			{
				var instance_track_highlight: SliderTrackHighlight = SliderTrackHighlight( instance );
				instance_track_highlight.removeEventListener(MouseEvent.MOUSE_DOWN, trackHighlight_mouseDownHandler);
				instance_track_highlight.removeEventListener(ResizeEvent.RESIZE, trackHighlight_resizeHandler);
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
			
			if(dataProviderChanged || minimumChanged || maximumChanged || snapIntervalChanged || allowOverlapChanged)
			{
				if(valueBasedLayout)
				{
					if(minimumChanged)
						valueBasedLayout.minimum = newMinimum;
					if(maximumChanged)
						valueBasedLayout.maximum = newMaximum;
				}
				
				// Compare newValues to the existing values.
				// Add and remove thumbs accordingly.
				var currentValues: Vector.<Number> = getValuesFromThumbs();
				
				for each( var current_value: Number in currentValues )
				{
					// Check if the current value exists in the new thumbs array.
					// If not found, remove the thumb at the current value.
					if( -1 == newValues.indexOf( current_value ) )
						removeThumbAt( current_value );
				}
				
				for each( var dp_item: Object in dataProvider )
				{
					var new_value: Number = Number( dp_item[ valueField ] );
					// Check if the new value already exists in the existing thumbs array.
					// If not found, add the thumb at the new value.
					if( -1 == currentValues.indexOf( new_value ) )
					{
						addThumbAt( dp_item );
					}
					else
					{
						// If a thumb at the value already exists, then just update its properties.
						var thumb_component: SliderThumb = getThumbAtValue( new_value );
						updateThumbProperties( thumb_component, dp_item );
					}
				}
				
				if( contentGroupHighlight && trackHighlight )
				{
					removeAllTrackHighlights();
					createTrackHighlightsFromDataProvider();
				}
				
				dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
				
				minimumChanged = false;
				maximumChanged = false;
				snapIntervalChanged = false;
				dataProviderChanged = false;
				allowOverlapChanged = false;
			}
			
			if(thumbValueChanged && !animating && !isDraggingThumbWithLiveDraggingDisabled)
			{
				dispatchEvent(new Event(Event.CHANGE));
				
				thumbValueChanged = false;
			}
			
			if( showTrackHighlightChanged )
			{
				for each( var track_highlight: SliderTrackHighlight in trackHighlightButtons )
				{
					track_highlight.visible = _showTrackHighlight;
				}
				
				showTrackHighlightChanged = false;
			}
			
			if( accentColorsChanged )
			{
				for each( var _thl: SliderTrackHighlight in trackHighlightButtons )
				{
					var data_provider_item: Object = _thl.dataProviderItem;
					var dp_value: Number = data_provider_item[ valueField ];
					var index_of_dp_value: Number = newValues.indexOf( dp_value );
					updateTrackHighlightColor( _thl, index_of_dp_value );
				}
				
				accentColorsChanged = false;
			}
			
			if( markersChanged )
			{
				if( contentGroupMarker && marker )
				{
					removeAllMarkers();
					createMarkersFrom( _markers );
				}
				
				markersChanged = false;
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function addThumbAt( dp_item: Object ): void
		{
			var thumb_component: SliderThumb = SliderThumb( createDynamicPartInstance("thumb") );
			
			if( ! thumb_component )
				throw new ArgumentError("Thumb part must be of type " +	getQualifiedClassName(SliderThumb));
			
			updateThumbProperties( thumb_component, dp_item );
			
			var value: Number = Number( dp_item[ valueField ] );
			thumb_component.value = value;
			
			addElement(thumb_component);
			thumbs.push(thumb_component);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function updateThumbProperties( thumb_component: SliderThumb, dp_item: Object ): void
		{
			thumb_component.snapInterval = snapInterval;
			thumb_component.dataProviderItem = dp_item;
			
			var value: Number = Number( dp_item[ valueField ] );
			var index_of_value: Number = newValues.indexOf( value );
			
			// If the value is not a fixed_value.
			if( -1 == newFixedValues.indexOf( value ) )
			{
				// If there is a neighboring thumb (previous) at a value lesser than this thumb, constrain this thumb to the previous thumb's value.
				if( index_of_value > 0 )
				{
					var previous_value: Number = newValues[ index_of_value - 1 ];
					var previous_thumb: SliderThumb = getThumbAtValue( previous_value );
					
					if( previous_thumb )
						thumb_component.constrainMinimumTo( previous_thumb, allowDuplicateValues );
					else
						thumb_component.minimum = minimum;
				}
				else
				{
					thumb_component.minimum = minimum;
				}
				
				// If there is a neighboring thumb (next) at a value greater than this thumb, constrain this thumb to the next thumb's value.
				if( index_of_value < newValues.length - 1 )
				{
					var next_value: Number = newValues[ index_of_value + 1 ];
					var next_thumb: SliderThumb = getThumbAtValue( next_value );
					
					if( next_thumb )
						thumb_component.constrainMaximumTo( next_thumb, allowDuplicateValues );
					else
						thumb_component.maximum = maximum;
				}
				else
				{
					thumb_component.maximum = maximum;
				}
				
				thumb_component.isValueFixed = false;
			}
			else
			{
				// If the value is a fixed value, then the max and min of the thumb should be the value itself.
				thumb_component.minimum = value;
				thumb_component.maximum = value;
				thumb_component.isValueFixed = true;
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function createTrackHighlightsFromDataProvider(): void
		{
			for each( var dp_item: Object in dataProvider )
			{
				var track_highlight: SliderTrackHighlight = SliderTrackHighlight( createDynamicPartInstance("trackHighlight") );
				
				if( ! track_highlight )
					throw new ArgumentError( "Track highlight part must be of type " + getQualifiedClassName(SliderTrackHighlight) );
				
				track_highlight.value = dp_item[ valueField ];
				track_highlight.dataProviderItem = dp_item;
				
				trackHighlightButtons.push( track_highlight );
				// Update this track HL with the properties of the current DP item.
				updateTrackHighlightDisplay( track_highlight );
				
				contentGroupHighlight.addElement( track_highlight );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		protected function updateTrackHighlightDisplay( track_highlight: SliderTrackHighlight ):void
		{
			var dp_item: Object = track_highlight.dataProviderItem;
			var dp_value: Number = dp_item[ valueField ];
			var index_of_dp_value: Number = newValues.indexOf( dp_value );
			var _thumb: SliderThumb = getThumbAtValue( dp_value );
			
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
			
			// If first thumb.
			if( 0 == index_of_dp_value )
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
				// Since newValues is sorted, the previous value would be at the previous index in the newValues vector.
				var previous_thumb_value: Number = newValues[ index_of_dp_value - 1];
				var previous_thumb: SliderThumb = getThumbAtValue( previous_thumb_value );
				
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
			
			updateTrackHighlightColor( track_highlight, index_of_dp_value );
			track_highlight.visible = showTrackHighlight;
			
			if( dp_item.hasOwnProperty( labelField ) && dp_item[ labelField ] is String )
				track_highlight.label = String( dp_item[ labelField ] );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function updateTrackHighlightColor( track_highlight: SliderTrackHighlight, index_of_dp_value: Number ): void
		{
			if( !track_highlight )
				return;
			
			// Color of the track highlight
			var index_color_to_use: Number;
			
			if( index_of_dp_value <= accentColors.length - 1 )
				index_color_to_use = index_of_dp_value;
			else
				index_color_to_use = index_of_dp_value % accentColors.length;
			
			track_highlight.setStyle( "themeColor", uint( accentColors[ index_color_to_use ] ) );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function createMarkersFrom(array_markers: Array): void
		{
			for(var index: int = 0; index < array_markers.length; index++)
			{
				var marker_component: SliderMarker = SliderMarker( createDynamicPartInstance("marker") );
				
				if( ! marker_component )
					throw new ArgumentError("Slider Marker part must be of type " + getQualifiedClassName( SliderMarker ) );
				
				marker_component.value = array_markers[ index ];
				markerComponents.push( marker_component );
				
				contentGroupMarker.addElement( marker_component );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function removeThumbAt( value: Number ): void
		{
			const _thumb: SliderThumb = getThumbAtValue( value );
			
			if( ! _thumb )
				throw new Error( "No thumb found at " + value );
			
			removeThumb( _thumb );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function removeThumb( thumb_instance: SliderThumb ): void
		{
			removeDynamicPartInstance( "thumb", thumb_instance );
			removeElement( thumb_instance );
			
			const _index: Number = thumbs.indexOf( thumb_instance );
			thumbs.splice( _index, 1 );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function removeAllTrackHighlights(): void
		{
			for each( var track_hl: SliderTrackHighlight in trackHighlightButtons )
			{
				removeDynamicPartInstance( "trackHighlight", track_hl );
				contentGroupHighlight.removeElement( track_hl );
			}
			
			trackHighlightButtons.splice( 0, trackHighlightButtons.length );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function removeAllMarkers(): void
		{
			for each( var _marker: SliderMarker in markerComponents )
			{
				removeDynamicPartInstance( "marker", _marker );
				contentGroupMarker.removeElement( _marker );
			}
			
			markerComponents.splice(0, markerComponents.length);
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
			
			if(!animating && !isDraggingThumbWithLiveDraggingDisabled)
			{
				invalidateThumbValues();
			}
			
			if( _thumb.dataProviderItem && 
				_thumb.dataProviderItem.hasOwnProperty( valueField ) )
			{
				_thumb.dataProviderItem[ valueField ] = _thumb.value;
				dataProvider.itemUpdated( _thumb.dataProviderItem, valueField );
			}
			
			// Constrain the neighboring thumbs only after the DP has been updated.
			// This is because the constrainNeighboringThumbs function uses the 
			// newValues vector and it needs to be up-to-date.
			if(!allowOverlap && thumbs.length > 1)
			{
				constrainNeighboringThumbs( _thumb );
			}
			
			contentGroup.invalidateDisplayList();
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
		
		private function constrainNeighboringThumbs( thumb_component: SliderThumb ): void
		{
			var index_of_value: Number = newValues.indexOf( thumb_component.value );
			var _thumb: SliderThumb;
			
			if( index_of_value > 0 )
			{
				_thumb = getThumbAtValue( newValues[ index_of_value - 1 ] );
				// If the thumb is a fixed_value thumb, then the constraints should not be messed with.
				if( ! _thumb.isValueFixed )
					_thumb.constrainMaximumTo( thumb_component, allowDuplicateValues );
			}
			
			if( index_of_value < newValues.length - 1 )
			{
				_thumb = getThumbAtValue( newValues[ index_of_value + 1 ] );
				// If the thumb is a fixed_value thumb, then the constraints should not be messed with.
				if( ! _thumb.isValueFixed )
					_thumb.constrainMinimumTo( thumb_component, allowDuplicateValues );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function trackMouseDownHandler(event: MouseEvent): void
		{
			if(valueBasedLayout)
			{
				var trackRelative: Point = track.globalToLocal(new Point(event.stageX, event.stageY));
				var trackClickValue: Number = valueBasedLayout.pointToValue(trackRelative);
				var nearestThumb: SliderThumb = nearestThumbTo(trackClickValue);
				
				if( nearestThumb )
				{
					if(getStyle("slideDuration") != 0)
						beginThumbAnimation(nearestThumb, trackClickValue);
					else
						nearestThumb.value = trackClickValue;
				}
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function nearestThumbTo(value: Number): SliderThumb
		{           
			var nearestValue: Number = valueBasedLayout.maximum;
			var nearestThumb: SliderThumb;
			
			for(var index: int = 0; index < thumbs.length; index++)
			{
				var thumb: SliderThumb = thumbs[index];
				var valueDelta: Number = Math.abs(thumb.value - value);
				
				var valueInRange: Boolean = allowOverlap || (thumb.minimum <= value && thumb.maximum >= value);
				
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
		
		//-------------------------------------------------------------------------------------------------
		
		private function addThumb_clickHandler( event: ThumbEvent ): void
		{
			const thumb_component: SliderThumb = SliderThumb( event.currentTarget );
			var current_value: Number = thumb_component.value;
			var local_values: Vector.<Number> = ObjectUtil.copy( newValues.sort( Array.NUMERIC ) ) as Vector.<Number>;
			
			// To accommodate the new thumb, we may have to move some of the neighboring thumbs around. 
			// To figure out in which direction we need to do the "spreading out", we first go in one
			// direction; if not successful, we then reset the changes of the first trial and try the other direction.
			// So, during these two "trials", we should not edit the actual dataProvider. We use a local copy.
			var local_data_provider: IList = ObjectUtil.copy( dataProvider ) as IList;
			
			const index_current_value: Number = local_values.indexOf( current_value );
			var next_value: Number = local_values[ index_current_value + 1 ];
			var gap_between_values: Number = next_value - current_value;
			var new_value: Number;
			var dp_item: Object;
			
			// The difference between the current and next values should be greater than
			// the snapInterval. Only then, we can insert another value between them.
			// NOTE: It is NOT enough if the gap is exactly the snapInterval, because we 
			// are inserting a new thumb in this gap.
			// Contrastingly, in all other checks below, for all the other values, we are satisfied with
			// a gap of snapInterval, because we are not inserting a thumb in those gaps.
			if( gap_between_values <= snapInterval )
			{
				// 1. Increment the next_value by snapInterval.
				// 2. Make sure that the new next_value and the value after it are separated
				// by at least snapInterval.
				// 3. If not, repeat (from step 1) for the value after the new next_value.
				
				// Before incrementing next_value, we also need to get the (local) DP item corresponding to it.
				// Even the value of the DP item should be incremented below.
				dp_item = getItemOfValue( next_value, local_data_provider );
				
				next_value += snapInterval;
				
				if( next_value > maximum )
					next_value = maximum;
				
				
				dp_item[ valueField ] = next_value;
				local_values[ index_current_value + 1 ] = next_value;
				
				var successfully_spread: Boolean = false;
				
				for( var i: Number = index_current_value + 1 ; i <=  local_values.length - 1 ; i++ )
				{
					var i_value: Number = local_values[ i ];
					var i_plus_one_value: Number = ( i == local_values.length - 1 ) ? maximum : local_values[ i + 1 ];
					
					// We are satisfied if the gap is at least snapInterval.
					if( i_plus_one_value - i_value >= snapInterval )
					{
						successfully_spread = true;
						break;
					}
					else if( i == local_values.length - 1 )
					{
						successfully_spread = false;
						break;
					}
					else
					{
						// Before incrementing i_plus_one_value, we also need to get the (local) DP item corresponding to it.
						// Even the value of the DP item should be incremented below.
						dp_item = getItemOfValue( i_plus_one_value, local_data_provider );
						
						i_plus_one_value += snapInterval;
						
						if( i_plus_one_value > maximum )
							i_plus_one_value = maximum;
						
						dp_item[ valueField ] = i_plus_one_value;
						local_values[ i + 1 ] = i_plus_one_value;
					}
				}
				
				if( ! successfully_spread )
				{
					// Try spreading in the other direction.
					local_values = ObjectUtil.copy( newValues.sort( Array.NUMERIC ) ) as Vector.<Number>;
					local_data_provider = ObjectUtil.copy( dataProvider ) as IList;
					
					// Before decrementing current_value, we also need to get the (local) DP item corresponding to it.
					// Even the value of the DP item should be decremented below.
					dp_item = getItemOfValue( current_value, local_data_provider );
					
					current_value -= snapInterval;
					
					if( current_value < minimum )
						current_value = minimum;
					
					dp_item[ valueField ] = current_value;
					local_values[ index_current_value ] = current_value;
					
					
					for( var j: Number = index_current_value ; j >= 0 ; j-- )
					{
						var j_value: Number = local_values[ j ];
						var j_minus_one_value: Number = ( 0 == j ) ? minimum : local_values[ j - 1 ];
						
						// We are satisfied if the gap is at least snapInterval.
						if( j_value - j_minus_one_value >= snapInterval )
						{
							successfully_spread = true;
							break;
						}
						else if( 0 == j )
						{
							successfully_spread = false;
							break;
						}
						else
						{
							// Before decrementing j_minus_one_value, we also need to get the (local) DP item corresponding to it.
							// Even the value of the DP item should be decremented below.
							dp_item = getItemOfValue( j_minus_one_value, local_data_provider );
							
							j_minus_one_value -= snapInterval;
							
							if( j_minus_one_value < minimum )
								j_minus_one_value = minimum;
							
							dp_item[ valueField ] = j_minus_one_value;
							local_values[ j - 1 ] = j_minus_one_value;
						}
					}
					
					if( ! successfully_spread )
					{
						trace("Can't insert new thumb because of lack of space.");
						Alert.show( "Sorry, no space for a new thumb!", "You have run out of thumbs!" );
						return;
					}
				}
			}
			
			current_value = local_values[ index_current_value ];
			next_value = local_values[ index_current_value + 1 ];
			gap_between_values = next_value - current_value;
			
			// The new value should be equi-distant between the two values.
			new_value = current_value + Math.round( gap_between_values / 2 );
			
			var new_dp_item: Object = { value: new_value };
			local_data_provider.addItem( new_dp_item );
			dataProvider = local_data_provider;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function removeThumb_clickHandler( event: ThumbEvent ): void
		{
			const thumb_component: SliderThumb = SliderThumb( event.currentTarget );
			dataProvider.removeItemAt( dataProvider.getItemIndex( thumb_component.dataProviderItem ) );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function thumbMouseDownHandler(event: MouseEvent): void
		{                    
			visuallyMoveToFront(IVisualElement(event.currentTarget));
		}
		
		//---------------------------------------Thumb Code - End----------------------------------------------------------
		
		//-------------------------------------Track Highlight Code - Start------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function trackHighlight_resizeHandler(event:Event):void
		{
			var track_highlight: SliderTrackHighlight = SliderTrackHighlight( event.currentTarget );
			updateTrackHighlightDisplay( track_highlight );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function trackHighlight_labelChangeHandler( event: Event ): void
		{
			var track_highlight: SliderTrackHighlight = SliderTrackHighlight( event.currentTarget );
			var dp_item: Object = track_highlight.dataProviderItem;
			
			dp_item[ labelField ] = track_highlight.label;
			dataProvider.itemUpdated( dp_item, labelField );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Handle mouse-down events for the slider track hightlight. We
		 *  calculate the value based on the new position and then
		 *  move the thumb to the correct location as well as
		 *  commit the value.
		 */
		protected function trackHighlight_mouseDownHandler(event:MouseEvent):void
		{
			trackMouseDownHandler(event);
		}
		
		//-------------------------------------Track Highlight Code - End------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------
		
		private function get valueBasedLayout(): IValueLayout
		{
			return (layout as IValueLayout);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getThumbAtValue( value: Number ): SliderThumb
		{
			var thumb_at_value: SliderThumb = null;
			
			for each( var _thumb: SliderThumb in thumbs )
			{
				if( _thumb.value == value )
				{
					thumb_at_value = _thumb;
					break;
				}
			}
			
			return thumb_at_value;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getTrackHighlightAtValue( value: Number ): SliderTrackHighlight
		{
			var track_highlight: SliderTrackHighlight = null;
			
			for each( var _thl: SliderTrackHighlight in trackHighlightButtons )
			{
				if( _thl.value == value )
				{
					track_highlight = _thl;
					break;
				}
			}
			
			return track_highlight;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getValuesFromThumbs(): Vector.<Number>
		{
			var thumbValues: Vector.<Number> = new Vector.<Number>();
			
			for each( var _thumb: SliderThumb in thumbs )
			{
				thumbValues.push( _thumb.value );
			}
			
			return thumbValues.sort( Array.NUMERIC );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function visuallyMoveToFront(instance: IVisualElement): void
		{
			var lastIndexElement: IVisualElement = getElementAt(numElements - 1);
			
			if(instance != lastIndexElement)
				swapElements(instance, lastIndexElement);
		}
		
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
		
		private function removeDataProviderDuplicateValues(): void
		{
			var duplicate_items: ArrayCollection = new ArrayCollection();
			var vector_values: Vector.<Number> = new Vector.<Number>();
			
			for each( var dp_item: Object in dataProvider )
			{
				if( dp_item.hasOwnProperty( valueField ) && dp_item[ valueField ] is Number )
				{
					var value: Number = Number( dp_item[ valueField ] );
					
					if( -1 == vector_values.indexOf( value ) )
					{
						vector_values.push( value );
					}
					// If already seen - this is a duplicate item.
					else
					{
						duplicate_items.addItem( dp_item );
					}
				}
			}
			
			// Remove duplicate items.
			for each( var duplicate_item: Object in duplicate_items )
			{
				dataProvider.removeItemAt( dataProvider.getItemIndex( duplicate_item ) );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getValuesFromDataProvider(): Vector.<Number>
		{
			var thumbValues: Vector.<Number> = new Vector.<Number>();
			
			for each( var dp_item: Object in dataProvider )
			{
				if( dp_item.hasOwnProperty( valueField ) && dp_item[ valueField ] is Number )
					thumbValues.push( Number( dp_item[ valueField ] ) );
			}
			
			return thumbValues.sort( Array.NUMERIC );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getFixedValuesFromDataProvider(): Vector.<Number>
		{
			var fixed_values: Vector.<Number> = new Vector.<Number>();
			
			for each( var dp_item: Object in dataProvider )
			{
				if( dp_item.hasOwnProperty( fixedValueField ) &&
					dp_item[ fixedValueField ] is Boolean &&
					dp_item.hasOwnProperty( valueField ) && 
					dp_item[ valueField ] is Number )
				{
					var is_fixed_value: Boolean = Boolean( dp_item[ fixedValueField ] );
					
					if( is_fixed_value )
						fixed_values.push( Number( dp_item[ valueField ] ) );
				}
			}
			
			return fixed_values.sort( Array.NUMERIC );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var newValues: Vector.<Number>;
		private var newFixedValues: Vector.<Number>;
		
		private function reactToDataProviderUpdate(): void
		{
			if( ! allowDuplicateValues )
				removeDataProviderDuplicateValues();
			
			newValues = getValuesFromDataProvider();
			newFixedValues = getFixedValuesFromDataProvider();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getTrackHighlightOfDataProviderItem( dp_item: Object ): SliderTrackHighlight
		{
			for each( var track_highlight: SliderTrackHighlight in trackHighlightButtons )
			{
				if( dp_item == track_highlight.dataProviderItem )
					return track_highlight;
			}
			
			return null;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function getItemOfValue( value: Number, collection: IList ): Object
		{
			for each( var dp_item: Object in collection )
			{
				if( dp_item.hasOwnProperty( valueField ) && 
					dp_item[ valueField ] is Number )
				{
					var dp_item_value: Number = Number( dp_item[ valueField ] );
					
					if( value == dp_item_value )
						return dp_item;
				}
			}
			
			return null;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Called when contents within the dataProvider changes.  
		 *
		 *  @param event The collection change event
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected function dataProvider_collectionChangeHandler( event: CollectionEvent ):void
		{
			var i: uint;
			
			switch (event.kind)
			{ 
				/*case CollectionEventKind.ADD: 
					for( i = 0; i < event.items.length; i++ )
					{ 
						
					}
					break;
				
				case CollectionEventKind.REMOVE: 
					for( i = 0; i < event.items.length; i++ )
					{ 
						
					}
					break;*/
				
				case CollectionEventKind.UPDATE: 
					for each( var event_object: * in event.items ) 
					{ 
						if (event_object is PropertyChangeEvent)
						{ 
							var property_change_event: PropertyChangeEvent = PropertyChangeEvent( event_object );
							
							if( null != property_change_event )
							{
								// Even if one valueField has been updated, refresh the slider. Hence the "break".
								if( valueField == property_change_event.property )
								{
									reactToDataProviderUpdate();
									dataProviderChanged = true;
									invalidateProperties();
									break;
								}
							} 
						}
					}
					break;
				
				/*case CollectionEventKind.RESET: 
					// Data provider is being reset, clear out the selection
					if (dataProvider.length == 0)
					{
						// Remove everything.
					}
					else
					{
						dataProviderChanged = true; 
						invalidateProperties(); 
					}
					break;
				
				case CollectionEventKind.REFRESH:
					dataProviderChanged = true; 
					invalidateProperties(); 
					break;*/
				
				default:
					reactToDataProviderUpdate();
					dataProviderChanged = true;
					invalidateProperties();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}