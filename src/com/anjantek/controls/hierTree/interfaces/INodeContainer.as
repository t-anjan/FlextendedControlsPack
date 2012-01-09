package com.anjantek.controls.hierTree.interfaces
{
	import mx.core.IUIComponent;

	public interface INodeContainer extends IUIComponent
	{
		function invalidateList():void;
		
		function get expandedItemX(): Number;
		function set expandedItemX( value: Number ): void;
		
		function get expandedItemY(): Number;
		function set expandedItemY( value: Number ): void;
	}
}