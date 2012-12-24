package com.anjantek.controls.lists
{
	import flash.events.MouseEvent;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.states.SetStyle;
	import mx.states.State;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class AwesomeList extends List
	{
		public function AwesomeList()
		{
			super();
			this.addEventListener( FlexEvent.INITIALIZE, initializeHandler );
		}
		
		//-------------------------------------------------------------------------------------------------

		protected function initializeHandler( event: FlexEvent ): void
		{
			const state_base: State = new State( {name:"base", overrides: [new SetStyle(this, "contentBackgroundColor", "#FFFFFF")] } );
			const state_error: State = new State( {name:"error", overrides: [new SetStyle(this, "contentBackgroundColor", "#FFDEDE")] } );
			const state_valid: State = new State( {name:"valid", overrides: [new SetStyle(this, "contentBackgroundColor", "#CFFFD7")] } );
			states = [ state_base, state_error, state_valid ];
		}
		
		//-------------------------------------------------------------------------------------------------

		public static const NONE_SELECTION_MODE: String = "none";
		public static const SINGLE_SELECTION_MODE: String = "single";
		public static const MULTIPLE_SELECTION_MODE: String = "multiple";
		
		private var _selectionMode: String = AwesomeList.SINGLE_SELECTION_MODE;

		[Inspectable(defaultValue="single", enumeration="none,single,multiple")]
		public function get selectionMode():String
		{
			return _selectionMode;
		}

		public function set selectionMode(value:String):void
		{
			_selectionMode = value;
			
			if( AwesomeList.MULTIPLE_SELECTION_MODE == _selectionMode )
			{
				this.allowMultipleSelection = true;
				
				if( this.hasEventListener( IndexChangeEvent.CHANGING ) )
					this.removeEventListener( IndexChangeEvent.CHANGING, selectionChangingHandler );
			}
			else if( AwesomeList.SINGLE_SELECTION_MODE == _selectionMode )
			{
				this.allowMultipleSelection = false;
				
				if( this.hasEventListener( IndexChangeEvent.CHANGING ) )
					this.removeEventListener( IndexChangeEvent.CHANGING, selectionChangingHandler );
			}
			else if( AwesomeList.NONE_SELECTION_MODE == _selectionMode )
			{
				this.allowMultipleSelection = false;
				
				if( ! this.hasEventListener( IndexChangeEvent.CHANGING ) )
					this.addEventListener( IndexChangeEvent.CHANGING, selectionChangingHandler );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function selectionChangingHandler( event: IndexChangeEvent ): void
		{
			if( AwesomeList.NONE_SELECTION_MODE == _selectionMode )
				event.preventDefault();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function selectAll(): void
		{
			if ( dataProvider )
			{
				var vct: Vector.<Object> = Vector.<Object>(dataProvider);
				selectedItems = vct;
				this.validateNow();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function set selectedLabels( labels: Vector.<String> ): void
		{
			if( (dataProvider != null) && (labels != null) )
			{
				var select_indices: Vector.<int> = new Vector.<int>();
				
				for each( var _label: String in labels )
				{
					for( var i: Number = 0 ; i <= dataProvider.length - 1 ; i++ )
					{
						if( itemToLabel( dataProvider[i] ) == _label )
						{
							select_indices.push( i );
						}
					}
				}
			}
			
			selectedIndices = select_indices;
			validateNow();
		}
		
		//-------------------------------------------------------------------------------------------------

		private var _enableAutoMultiSelection: Boolean = false;

		public function get enableAutoMultiSelection():Boolean
		{
			return _enableAutoMultiSelection;
		}

		public function set enableAutoMultiSelection(value:Boolean):void
		{
			_enableAutoMultiSelection = value;
			
			if( _enableAutoMultiSelection )
				selectionMode = AwesomeList.MULTIPLE_SELECTION_MODE;
		}

		
		//-------------------------------------------------------------------------------------------------
		/**
		 * Override the mouseDown handler to act as though the Ctrl key is always down
		 */
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			if( ! enableAutoMultiSelection || AwesomeList.MULTIPLE_SELECTION_MODE != selectionMode )
			{
				super.item_mouseDownHandler( event );
				return;
			}
			
			var newIndex:Number = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
			
			// always assume the Ctrl key is pressed.
			event.ctrlKey = true;
			
			selectedIndices = calculateSelectedIndices(newIndex, event.shiftKey, event.ctrlKey);
			
			var e: IndexChangeEvent = new IndexChangeEvent(IndexChangeEvent.CHANGE);
			e.oldIndex = selectedIndex;
			e.newIndex = newIndex;
			
			// Save the new selected indices and dispatch a change event to inform any listeners about the change.
			commitSelection(); 
			dispatchEvent(e);
		}
		
		//-------------------------------------------------------------------------------------------------

	}
}