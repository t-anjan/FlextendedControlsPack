package com.anjantek.controls.lists
{
	import mx.events.FlexEvent;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;
	
	public class AwesomeList extends List
	{
		public function AwesomeList()
		{
			super();
		}
		
		//-------------------------------------------------------------------------------------------------

		private var _selectionMode: String = "single";

		[Inspectable(defaultValue="single", enumeration="none,single,multiple")]
		public function get selectionMode():String
		{
			return _selectionMode;
		}

		public function set selectionMode(value:String):void
		{
			_selectionMode = value;
			
			if( "multiple" == _selectionMode )
			{
				this.allowMultipleSelection = true;
				
				if( this.hasEventListener( IndexChangeEvent.CHANGING ) )
					this.removeEventListener( IndexChangeEvent.CHANGING, selectionChangingHandler );
			}
			else if( "single" == _selectionMode )
			{
				this.allowMultipleSelection = false;
				
				if( this.hasEventListener( IndexChangeEvent.CHANGING ) )
					this.removeEventListener( IndexChangeEvent.CHANGING, selectionChangingHandler );
			}
			else if( "none" == _selectionMode )
			{
				this.allowMultipleSelection = false;
				
				if( ! this.hasEventListener( IndexChangeEvent.CHANGING ) )
					this.addEventListener( IndexChangeEvent.CHANGING, selectionChangingHandler );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		protected function selectionChangingHandler( event: IndexChangeEvent ): void
		{
			if( "none" == _selectionMode )
				event.preventDefault();
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}