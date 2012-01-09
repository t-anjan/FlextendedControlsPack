package com.anjantek.controls.hierTree.layouts
{
	import com.anjantek.controls.hierTree.interfaces.INodeContainer;
	
	import flash.geom.Point;
	
	import mx.core.ILayoutElement;
	import mx.core.UIComponent;
	import mx.effects.Parallel;
	import mx.events.EffectEvent;
	
	import spark.components.supportClasses.GroupBase;
	import spark.effects.Move;
	import spark.effects.Scale;
	import spark.layouts.supportClasses.LayoutBase;
	
	public class HierVerticalLayout extends LayoutBase
	{
		public function HierVerticalLayout()
		{
			super();
		}
		
		//--------------------------------------PROPERTIES START-----------------------------------------------------------
		
		//----------------------------------
		//  gap
		//----------------------------------
		
		private var _gap:int = 2;
		
		[Inspectable(category="General")]
		
		/**
		 *  The vertical space between layout elements, in pixels.
		 * 
		 *  Note that the gap is only applied between layout elements, so if there's
		 *  just one element, the gap has no effect on the layout.
		 * 
		 *  @default 6
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get gap():int
		{
			return _gap;
		}
		
		/**
		 *  @private
		 */
		public function set gap(value:int):void
		{
			if (_gap == value) 
				return;
			
			_gap = value;
			
			if( target )
				target.invalidateDisplayList();
		}
		
		//---------------------------------------PROPERTIES END----------------------------------------------------------
		
		private var _containerWidth: Number;
		private var effects: Parallel = new Parallel();
		private var vector_x: Vector.<Number> = new Vector.<Number>();
		private var vector_y: Vector.<Number> = new Vector.<Number>();
		private var dx: Number;
		
		override public function updateDisplayList(width:Number, height:Number):void
		{
			//trace("updateDisplaylist. Width: ", width, ". Height: ", height);
			
			_containerWidth = width;
			var count:int = target.numElements;
			
			if( 0 == count )
				return;
			
			var contentHeight: Number = 0;
			var contentWidth: Number = 0;
			var layoutElement: ILayoutElement;
			var elementWidth: Number;
			var elementHeight: Number;
			vector_x.splice( 0, vector_x.length );
			vector_y.splice( 0, vector_y.length );
			
			// First pass: Set the size and calculate content height first.
			// Content height cannot be calculated here because the 'x' of the elements needs to be set first.
			// Only if the 'x' is set, we can calculate the distance between the left-most and the right-most elements,
			// which is the width of the content.
			for( var i:int = 0 ; i < count ; i++ )
			{
				layoutElement = target.getElementAt(i);
				// Setting the size.
				layoutElement.setLayoutBoundsSize( NaN, NaN );
				
				elementHeight = Math.ceil( layoutElement.getLayoutBoundsHeight() );
				contentHeight += elementHeight + gap;
			}
			
			var x: Number = 0;
			var y: Number = Math.round( height / 2 );
			
			// To show the items vertically middle-aligned, calculate the correction factor.
			var dy: Number = Math.round( contentHeight / 2 );
			
			// Correct the initial 'y', which will make the whole content middle-aligned. 
			y -= dy;
			
			//-------------
			
			// Second pass: Calculate the 'x' and 'y' for each element and store it.
			// After calculating each 'x', store the lowest x1 and highest x2, which will be used to calculate content width.
			// The content width will then be used to calculate the 'dx' to move the whole content to center-aligned position.
			var previousLayoutElement: ILayoutElement;
			
			var x1: Number = 0;
			var x2: Number = 0;
			
			for( i = 0 ; i < count ; i++ )
			{
				layoutElement = target.getElementAt(i);
				
				// Y Calculation.
				vector_y.push( y );
				elementHeight = Math.ceil( layoutElement.getLayoutBoundsHeight() );
				y += elementHeight + gap;
				
				// X Calculation.
				elementWidth = Math.ceil( layoutElement.getLayoutBoundsWidth() );
				
				if( null == previousLayoutElement )
				{
					x = Math.round( (_containerWidth - elementWidth) / 2 );
				}
				else
				{
					x = calculateXFromPreviousElement( layoutElement, previousLayoutElement );
					
					// The previousLayoutElement's x could have been changed in the previous iteration of this loop.
					// This new x would be present in the vector_x. The element itself would still have the old x.
					// The variable 'x' in the above line would have been calculated using the previousLayoutElement's
					// old position. So, we correct the variable x accordingly.
					var diff_x: Number = vector_x[ i - 1 ] - previousLayoutElement.getLayoutBoundsX();
					x += diff_x;
				}
				
				vector_x.push( x );
				
				// Store the lowest x1 and the highest x2 seen during the running of the loop.
				if( 0 == i )
				{
					x1 = x;
					x2 = x + elementWidth;
				}
				else
				{
					if( x < x1 )
						x1 = x;
					
					if( x + elementWidth > x2 )
						x2 = x + elementWidth;
				}
				
				previousLayoutElement = layoutElement;
			}
			
			contentWidth = x2 - x1;
			//trace( "Content x1 and x2:", x1, x2 );
			
			var container_center_x: Number = Math.round( _containerWidth / 2 );
			var content_center_x: Number = Math.round( x1 + (contentWidth / 2) );
			// To show the items horizontally center-aligned, calculate the correction factor.
			dx = container_center_x - content_center_x;
			//trace( "Container Center X:", container_center_x, "Content Center X:", content_center_x, "Dx:", dx );
			
			//-------------------
			
			target.autoLayout = false;
			effects.children.splice( 0 );
			effects.duration = 500;
			effects.suspendBackgroundProcessing = true;
			
			// Third pass: Set the x and y on each element.
			for( i = 0 ; i < count ; i++ )
			{
				// Correct the x to make sure the contentGroup as a whole is center-aligned.
				vector_x[ i ] = vector_x[ i ] + dx;
				layoutElement = target.getElementAt(i);
				
				if( added_index == i )
				{
					added_index = NaN;
					processNewItem( i, layoutElement );
				}
				else
				{
					processExistingItem( i, layoutElement );
				}
			}
			
			if( effects.children.length > 0 )
			{
				effects.addEventListener(EffectEvent.EFFECT_END, onEffectsEndHandler );
				effects.play();
			}
			else
				target.autoLayout = true;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var added_index: Number;
		
		override public function elementAdded(index:int):void
		{
			//trace("elementAdded: ", index);
			added_index = index;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function processNewItem( i: Number, layoutElement: ILayoutElement ): void
		{
			var x: Number = vector_x[ i ];
			var y: Number = vector_y[ i ];
			
			var scale_effect: Scale = new Scale( layoutElement );
			scale_effect.scaleXFrom = 0.1;
			scale_effect.scaleXTo = 1;
			scale_effect.scaleYFrom = 0.1;
			scale_effect.scaleYTo = 1;
			
			effects.addChild( scale_effect );
			
			var move_effect: Move = new Move( layoutElement );
			// Center point of the previous expanded item.
			var elementWidth: Number = Math.ceil( layoutElement.getLayoutBoundsWidth() );
			move_effect.xFrom = x + (elementWidth / 2);
			move_effect.xTo = x;
			move_effect.yFrom = y;
			move_effect.yTo = y;
			
			effects.addChild( move_effect );
			//layoutElement.setLayoutBoundsPosition( x, y );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function processExistingItem( i: Number, layoutElement: ILayoutElement ): void
		{
			var x: Number = vector_x[ i ];
			var y: Number = vector_y[ i ];
			
			var current_x: Number = layoutElement.getLayoutBoundsX();
			var current_y: Number = layoutElement.getLayoutBoundsY();
			
			if( x != current_x || y != current_y )
			{
				var move_effect: Move = new Move( layoutElement );
				move_effect.xFrom = current_x;
				move_effect.xTo = x;
				move_effect.yFrom = current_y;
				move_effect.yTo = y;
				effects.addChild( move_effect );
				//layoutElement.setLayoutBoundsPosition( x, y );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var horizontal_center_effects: Parallel;
		
		private function onEffectsEndHandler( event: EffectEvent ): void
		{
			effects.removeEventListener(EffectEvent.EFFECT_END, onEffectsEndHandler);
			target.autoLayout = true;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function calculateXFromPreviousElement( layoutElement: ILayoutElement, previousLayoutElement: ILayoutElement ): Number
		{
			var calculated_x: Number;
			var elementWidth:Number = Math.ceil( layoutElement.getLayoutBoundsWidth() );
			
			if( previousLayoutElement is INodeContainer )
			{
				var node_container: INodeContainer = previousLayoutElement as INodeContainer;
				var container_content_point: Point = new Point( node_container.expandedItemX, node_container.expandedItemY );
				var global_point: Point = UIComponent( node_container ).contentToGlobal( container_content_point );
				var local_point: Point = target.globalToLocal( global_point );
				//trace("X of center of expanded item:", local_point.x );
				calculated_x = Math.round( local_point.x - ( elementWidth / 2 ) );
			}
			else
				calculated_x = Math.round(target.width / 2);
			
			return calculated_x;
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}