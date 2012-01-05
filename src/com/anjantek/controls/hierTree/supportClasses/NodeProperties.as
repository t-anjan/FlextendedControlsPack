package com.anjantek.controls.hierTree.supportClasses
{
	[Bindable]
	public class NodeProperties
	{
		public function NodeProperties( uid: String, data: Object, parentUID: String, childrenUIDs: Vector.<String>, level: Number )
		{
			Update_Properties( uid, data, parentUID, childrenUIDs, level );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public var uid: String;
		public var data: Object;
		public var parentUID: String;
		public var childrenUIDs: Vector.<String>;
		public var level: Number;
		
		public var isExpanded: Boolean;
		public var isSelected: Boolean;
		
		//-------------------------------------------------------------------------------------------------
		
		public function Update_Properties( uid: String, data: Object, parentUID: String, childrenUIDs: Vector.<String>, level: Number ): void
		{
			this.uid = uid;
			this.data = data;
			this.parentUID = parentUID;
			this.childrenUIDs = childrenUIDs;
			this.level = level;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function get hasChildren(): Boolean
		{
			return ( (null != childrenUIDs ) && (childrenUIDs.length > 0 ) );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function get isRoot(): Boolean
		{
			return ( null == parentUID || "" == parentUID );
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}