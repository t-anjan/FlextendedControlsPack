package com.anjantek.controls.hierTree
{
	import com.anjantek.controls.hierTree.events.HierTreeEvent;
	import com.anjantek.controls.hierTree.itemRenderers.DefaultNodeItemRenderer;
	import com.anjantek.controls.hierTree.skins.HierTreeSkin;
	import com.anjantek.controls.hierTree.supportClasses.LevelList;
	import com.anjantek.controls.hierTree.supportClasses.NodeProperties;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	import mx.controls.treeClasses.ITreeDataDescriptor;
	import mx.controls.treeClasses.ITreeDataDescriptor2;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.effects.Parallel;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.EffectEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.SkinnableContainer;
	import spark.effects.Move;
	import spark.effects.Scale;
	import spark.events.IndexChangeEvent;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.utils.LabelUtil;

	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when a branch is closed or collapsed.
	 */
	[Event(name="itemClose", type="com.anjantek.controls.hierTree.events.HierTreeEvent")]
	
	/**
	 *  Dispatched when a branch is opened or expanded.
	 */
	[Event(name="itemOpen", type="com.anjantek.controls.hierTree.events.HierTreeEvent")]
	
	/**
	 *  Dispatched when a node selection is changed.
	 */
	[Event(name="selectionChange", type="com.anjantek.controls.hierTree.events.HierTreeEvent")]

	public class HierTree extends SkinnableContainer
	{
		[SkinPart(required="true", type="com.anjantek.controls.hierTree.supportClasses.LevelList")]
		public var levelList: IFactory;
		
		//-------------------------------------------------------------------------------------------------
		
		public function HierTree()
		{
			super();
			
			setStyle( 'skinClass', HierTreeSkin );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//------------------------------ PROPERTIES - START -------------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------
		
		private var dataProviderChanged:Boolean;
		
		private var _dataProvider: IList;
		
		[Bindable("dataProviderChanged")]
		[Inspectable(category="Data")]
		public function get dataProvider():IList
		{
			return _dataProvider;
		}
		
		public function set dataProvider( value:IList ):void
		{
			if (_dataProvider == value)
				return;
			
			removeDataProviderListener();
			_dataProvider = value;  // listener will be added by commitProperties()
			dataProviderChanged = true;
			invalidateProperties();
			dispatchEvent(new Event("dataProviderChanged"));
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
		
		//-------------------------------------------------------------------------------------------------
		
		//----------------------------------
		//  labelFunction
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _labelFunction:Function; 
		
		/**
		 *  @private
		 */
		private var labelFunctionChanged:Boolean; 
		
		[Inspectable(category="Data")]
		
		/**
		 *  A user-supplied function to run on each item to determine its label.  
		 *  The <code>labelFunction</code> property overrides 
		 *  the <code>labelField</code> property.
		 *
		 *  <p>You can supply a <code>labelFunction</code> that finds the 
		 *  appropriate fields and returns a displayable string. The 
		 *  <code>labelFunction</code> is also good for handling formatting and 
		 *  localization. </p>
		 *
		 *  <p>The label function takes a single argument which is the item in 
		 *  the data provider and returns a String.</p>
		 *  <pre>
		 *  myLabelFunction(item:Object):String</pre>
		 *
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		
		/**
		 *  @private
		 */
		public function set labelFunction(value:Function):void
		{
			if (value == _labelFunction)
				return;
				
			_labelFunction = value;
			labelFunctionChanged = true;
			invalidateProperties(); 
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var _uidField:String = "uid";
		
		private var uidFieldChanged:Boolean; 
		
		[Inspectable(category="Data", defaultValue="uid")]
		
		public function get uidField():String
		{
			return _uidField;
		}
		
		public function set uidField(value:String):void
		{
			if (value == _uidField)
				return;
			
			_uidField = value;
			uidFieldChanged = true;
			invalidateProperties();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//----------------------------------
		//  itemRenderer
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the itemRenderer property.
		 */
		private var _itemRenderer:IFactory = new ClassFactory(DefaultNodeItemRenderer);
		
		private var itemRendererChanged:Boolean;
		
		[Inspectable(category="Data")]
		
		/**
		 *  The item renderer to use for data items. 
		 *  The class must implement the IDataRenderer interface.
		 *  If defined, the <code>itemRendererFunction</code> property
		 *  takes precedence over this property.
		 *
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get itemRenderer():IFactory
		{
			return _itemRenderer;
		}
		
		/**
		 *  @private
		 */
		public function set itemRenderer(value:IFactory):void
		{
			_itemRenderer = value;
			
			itemRendererChanged = true;
			invalidateProperties();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//----------------------------------
		//  itemRendererFunction
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the itemRendererFunction property.
		 */
		
		private var _itemRendererFunction:Function;
		
		private var itemRendererFunctionChanged:Boolean;
		
		[Inspectable(category="Data")]
		
		/**
		 *  Function that returns an item renderer IFactory for a 
		 *  specific item.  You should define an item renderer function 
		 *  similar to this sample function:
		 *  
		 *  <pre>
		 *    function myItemRendererFunction(item:Object):IFactory</pre>
		 * 
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get itemRendererFunction():Function
		{
			return _itemRendererFunction;
		}
		
		/**
		 *  @private
		 */
		public function set itemRendererFunction(value:Function):void
		{
			_itemRendererFunction = value;
			
			removeDataProviderListener();
			
			itemRendererFunctionChanged = true;
			invalidateProperties();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//----------------------------------
		//  selectedItem
		//----------------------------------
		
		/**
		 *  @private
		 */
		private var _selectedItem: NodeProperties;
		
		/*[Bindable("change")]
		[Bindable("valueCommit")]
		[Inspectable(category="General", defaultValue="null")]*/
		
		public function get selectedItem(): NodeProperties
		{
			return _selectedItem;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var _expandedItems: Vector.<String> = new Vector.<String>();
		
		public function get expandedItems():Vector.<String>
		{
			return _expandedItems;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var _nodesMap: Dictionary;
		
		public function get nodesMap(): Dictionary
		{
			return _nodesMap;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		// dataDescriptor
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _dataDescriptor:ITreeDataDescriptor = new DefaultDataDescriptor();
		
		[Inspectable(category="Data")]
		
		/**
		 *  Tree delegates to the data descriptor for information about the data.
		 *  This data is then used to parse and move about the data source.
		 *  <p>When you specify this property as an attribute in MXML you must
		 *  use a reference to the data descriptor, not the string name of the
		 *  descriptor. Use the following format for the property:</p>
		 *
		 * <pre>&lt;mx:Tree id="tree" dataDescriptor="{new MyCustomTreeDataDescriptor()}"/&gt;></pre>
		 *
		 *  <p>Alternatively, you can specify the property in MXML as a nested
		 *  subtag, as the following example shows:</p>
		 *
		 * <pre>&lt;mx:Tree&gt;
		 * &lt;mx:dataDescriptor&gt;
		 * &lt;myCustomTreeDataDescriptor&gt;</pre>
		 *
		 * <p>The default value is an internal instance of the
		 *  DefaultDataDescriptor class.</p>
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function set dataDescriptor(value:ITreeDataDescriptor):void
		{
			_dataDescriptor = value;
		}
		
		/**
		 *  Returns the current ITreeDataDescriptor.
		 *
		 *   @default DefaultDataDescriptor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get dataDescriptor():ITreeDataDescriptor
		{
			return ITreeDataDescriptor(_dataDescriptor);
		}
		
		//------------------------------ PROPERTIES - END -------------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------------------
		
		override protected function commitProperties():void
		{ 
			super.commitProperties();
			var level_list: LevelList;
			
			if (dataProviderChanged)
			{
				dataProviderChanged = false;
				React_To_DP_Change();
			}
			
			if( uidFieldChanged )
			{
				uidFieldChanged = false;
				React_To_DP_Change();
			}
			
			if (itemRendererChanged)
			{
				itemRendererChanged = false;
				
				for each( level_list in level_lists )
				{
					level_list.itemRenderer = itemRenderer;
				}
			}
			
			if (itemRendererFunctionChanged)
			{
				itemRendererFunctionChanged = false;
				
				for each( level_list in level_lists )
				{
					level_list.itemRendererFunction = itemRendererFunction;
				}
			}
			
			if (labelFieldChanged)
			{
				labelFieldChanged = false;
				
				for each( level_list in level_lists )
				{
					level_list.labelField = labelField;
				}
			}
			
			if (labelFunctionChanged)
			{
				labelFunctionChanged = false;
				
				for each( level_list in level_lists )
				{
					level_list.labelFunction = labelFunction;
				}
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function React_To_DP_Change(): void
		{
			Build_Nodes_Map();
			removeAllLevels();
			lowest_displayed_level = 0;
			addLevel( 0, dataProvider );
			Restore_Expand_Collapse_Status();
			addDataProviderListener();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Build_Nodes_Map(): void
		{
			_nodesMap = new Dictionary();
			
			for each( var obj: Object in dataProvider )
			{
				Build_Nodes_Map_For_Object_And_Children( obj, null, 0 );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Build_Nodes_Map_For_Object_And_Children( obj: Object, parent: Object, level: Number ): void
		{
			var uid: String = String( obj[ _uidField ] );
			var parent_uid: String;
			
			if( null == parent )
				parent_uid = "";
			else
				parent_uid = String( parent[ _uidField ] );
			
			// Not using the Get_Children_UIDs method here because we also need to
			// build the nodes map for the children when looping. So merging the operations below in a single loop.
			var children_uids: Vector.<String> = new Vector.<String>();
			var children: ICollectionView = _dataDescriptor.getChildren( obj );
			
			for each( var child: Object in children )
			{
				var child_uid: String = String( child[ _uidField ] );
				if( -1 == children_uids.indexOf( child_uid ) )
				{
					children_uids.push( child_uid );
					Build_Nodes_Map_For_Object_And_Children( child, obj, level + 1 );
				}
			}
			
			if( null != _nodesMap[ uid ] && _nodesMap[ uid ] is NodeProperties )
			{
				var node_properties: NodeProperties = NodeProperties( _nodesMap[ uid ] );
				node_properties.Update_Properties( uid, obj, parent_uid, children_uids, level );
			}
			else
				_nodesMap[ uid ] = new NodeProperties( uid, obj, parent_uid, children_uids, level );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Restore_Expand_Collapse_Status(): void
		{
			// If any items were previously expanded, try to expand them again, if they are found in the new dataProvider.
			// The expanded items vector has the UIDs in the order of levels. We will try to expand the highest level first. 
			// So, traverse the vector from the back.
			for( var i: Number = _expandedItems.length - 1 ; i >= 0  ; i-- )
			{
				var uid: String = _expandedItems[ i ];
				if( null != _nodesMap[ uid ] && _nodesMap[ uid ] is NodeProperties )
				{
					var node_properties: NodeProperties = NodeProperties( _nodesMap[ uid ] );
					
					if( node_properties.hasChildren )
					{
						expandItem( uid );
						break;
					}
				}
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Get_Children_UIDs( obj: Object ): Vector.<String>
		{
			var children_uids: Vector.<String> = new Vector.<String>();
			var children: ICollectionView = _dataDescriptor.getChildren( obj );
			
			for each( var child: Object in children )
			{
				var uid: String = String( child[ _uidField ] );
				if( -1 == children_uids.indexOf( uid ) )
					children_uids.push( uid );
			}
			
			return children_uids;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function addLevel( level: Number, _data_provider: IList ): void
		{
			var level_list: LevelList;
			
			// If a list is already present at the next level. just change its data provider.
			if( level_lists.length >= level + 1 )
			{
				level_list = level_lists[ level ];
				level_list.dataProvider = Build_Level_List_Data_Provider( _data_provider );
				contentGroup.invalidateDisplayList();
			}
			else
			{
				level_list = LevelList( createDynamicPartInstance("levelList") );
				level_list.itemRenderer = itemRenderer;
				level_list.itemRendererFunction = itemRendererFunction;
				level_list.labelField = labelField;
				level_list.labelFunction = labelFunction;
				level_list.level = level;
				level_list.dataProvider = Build_Level_List_Data_Provider( _data_provider );
				
				contentGroup.addElementAt( level_list, level );
				level_lists.push( level_list );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Build_Level_List_Data_Provider( raw_objects: IList ): ArrayCollection
		{
			var _data_provider: ArrayCollection = new ArrayCollection();
			
			for each( var obj: Object in raw_objects )
			{
				var object_uid: String = String( obj[ _uidField ] );
				var node_properties: NodeProperties = _nodesMap[ object_uid ] as NodeProperties;
				if( null != node_properties )
					_data_provider.addItem( node_properties );
			}
			
			return _data_provider;
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function removeAllLevels(): void
		{
			contentGroup.removeAllElements();
			level_lists.splice( 0, level_lists.length );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var removed_effects: Parallel = new Parallel();
		
		private function removeAllLevelsBelowLowestDisplayedLevel(): void
		{
			removed_effects.children.splice( 0 );
			removed_effects.suspendBackgroundProcessing = true;
			removed_effects.duration = 500;
			
			for( var i: Number = contentGroup.numElements - 1 ; i > lowest_displayed_level ; i-- )
			{
				var item_to_be_removed: IVisualElement = contentGroup.getElementAt( i );
				var scale_effect: Scale = new Scale( item_to_be_removed );
				scale_effect.scaleXTo = 0.1;
				scale_effect.scaleYTo = 0.1;
				
				removed_effects.addChild( scale_effect );
				
				var elementWidth: Number = Math.ceil( item_to_be_removed.getLayoutBoundsWidth() );
				var move_effect: Move = new Move( item_to_be_removed );
				move_effect.xTo = item_to_be_removed.getLayoutBoundsX() + (elementWidth / 2);
				
				removed_effects.addChild( move_effect );
			}
			
			if( removed_effects.children.length > 0 )
			{
				this.autoLayout = false;
				removed_effects.addEventListener( EffectEvent.EFFECT_END, onRemovedEffectsEndHandler );
				removed_effects.play();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function onRemovedEffectsEndHandler( event: EffectEvent ): void
		{
			removed_effects.removeEventListener( EffectEvent.EFFECT_END, onRemovedEffectsEndHandler );
			
			this.autoLayout = true;
			
			for( var i: Number = contentGroup.numElements - 1 ; i > lowest_displayed_level ; i-- )
			{
				contentGroup.removeElement( contentGroup.getElementAt( i ) );
			}
			
			var start_index: Number = lowest_displayed_level + 1;
			var delete_count: Number = level_lists.length - start_index;
			level_lists.splice( start_index, delete_count );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var level_lists: Vector.<LevelList> = new Vector.<LevelList>();
		
		/**
		 *  @private
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (partName == "levelList")
			{
				var instance_level_list: LevelList = LevelList( instance );
				instance_level_list.addEventListener( IndexChangeEvent.CHANGE, onLevelListSelectionChange );
				instance_level_list.addEventListener( HierTreeEvent.NODE_DOUBLE_CLICK, onNodeDoubleClick );
				instance_level_list.addEventListener( HierTreeEvent.NODE_EXPAND_BUTTON_CLICK, onNodeExpandButtonClick );
				instance_level_list.addEventListener( HierTreeEvent.NODE_COLLAPSE_BUTTON_CLICK, onNodeCollapseButtonClick );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{        
			super.partRemoved(partName, instance);
			
			if (partName == "levelList")
			{
				var instance_level_list: LevelList = LevelList( instance );
				instance_level_list.removeEventListener( IndexChangeEvent.CHANGE, onLevelListSelectionChange );
				instance_level_list.removeEventListener( HierTreeEvent.NODE_DOUBLE_CLICK, onNodeDoubleClick );
				instance_level_list.removeEventListener( HierTreeEvent.NODE_EXPAND_BUTTON_CLICK, onNodeExpandButtonClick );
				instance_level_list.removeEventListener( HierTreeEvent.NODE_COLLAPSE_BUTTON_CLICK, onNodeCollapseButtonClick );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  Given a data item, return the correct text a renderer
		 *  should display while taking the <code>labelField</code> 
		 *  and <code>labelFunction</code> properties into account. 
		 *
		 *  @param item A data item 
		 *  
		 *  @return String representing the text to display for the 
		 *  data item in the  renderer. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function itemToLabel(item:Object):String
		{
			return LabelUtil.itemToLabel(item, labelField, labelFunction);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function onLevelListSelectionChange( event: IndexChangeEvent ): void
		{
			var level_list: LevelList = event.currentTarget as LevelList;
			
			if( _selectedItem == level_list.selectedItem )
				return;
			
			for each( var ll: LevelList in level_lists )
			{
				if( ll != level_list )
				{
					ll.selectedIndex = -1;
				}
			}
			
			var node_properties: NodeProperties = NodeProperties( level_list.selectedItem );
			Set_Is_Selected_On_Node_Properties( node_properties );
			
			_selectedItem = node_properties;
			var selection_change_event: HierTreeEvent = new HierTreeEvent( HierTreeEvent.SELECTION_CHANGE );
			dispatchEvent( selection_change_event );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Set_Is_Selected_On_Node_Properties( selected_node_properties: NodeProperties ): void
		{
			for each( var _node_properties: NodeProperties in _nodesMap )
			{
				_node_properties.isSelected = (_node_properties.uid == selected_node_properties.uid);
			}
			
			Invalidate_Lists();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function onNodeExpandButtonClick( event: HierTreeEvent ): void
		{
			var level_list: LevelList = event.currentTarget as LevelList;
			var to_expand_item: NodeProperties = event.payload as NodeProperties;
			var to_expand_item_uid: String = to_expand_item.uid;
			
			// If leaf node, return.
			if( ! to_expand_item.hasChildren )
				return;
			
			expandItem( to_expand_item_uid );
			var item_open_event: HierTreeEvent = new HierTreeEvent( HierTreeEvent.ITEM_OPEN, to_expand_item.data );
			dispatchEvent( item_open_event );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function onNodeCollapseButtonClick( event: HierTreeEvent ): void
		{
			var level_list: LevelList = event.currentTarget as LevelList;
			var to_collapse_item: NodeProperties = event.payload as NodeProperties;
			var to_collapse_item_uid: String = to_collapse_item.uid;
			
			// If leaf node, return.
			if( ! to_collapse_item.hasChildren )
				return;
			
			collapseItem( to_collapse_item_uid );
			var item_close_event: HierTreeEvent = new HierTreeEvent( HierTreeEvent.ITEM_CLOSE, to_collapse_item.data );
			dispatchEvent( item_close_event );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private var lowest_displayed_level: Number;
		
		private function onNodeDoubleClick( event: HierTreeEvent ): void
		{
			var level_list: LevelList = event.currentTarget as LevelList;
			var double_clicked_item: NodeProperties = event.payload as NodeProperties;
			var double_clicked_item_uid: String = double_clicked_item.uid;
			
			// If leaf node, return.
			if( ! double_clicked_item.hasChildren )
				return;
			
			// If the double-clicked node is already expanded, collapse it.
			if( -1 != _expandedItems.indexOf( double_clicked_item_uid ) )
			{
				collapseItem( double_clicked_item_uid );
				var item_close_event: HierTreeEvent = new HierTreeEvent( HierTreeEvent.ITEM_CLOSE, double_clicked_item.data );
				dispatchEvent( item_close_event );
			}
			else
			{
				expandItem( double_clicked_item_uid );
				var item_open_event: HierTreeEvent = new HierTreeEvent( HierTreeEvent.ITEM_OPEN, double_clicked_item.data );
				dispatchEvent( item_open_event );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function expandItem( object_uid: String ): void
		{
			if( null == object_uid || "" == object_uid )
				return;
			
			var node_properties: NodeProperties = _nodesMap[ object_uid ] as NodeProperties;
			
			if( ! node_properties.hasChildren )
				return;
			
			var object_level: Number = node_properties.level;
			
			// If the object's level is equal to or lower than the lowest displayed level, then it is a straightforward expand operation.
			if( object_level <= lowest_displayed_level )
			{
				actualExpandItem( object_uid );
			}
			else
			{
				// Before expanding the "object" (which is somewhere way below the lowest_displayed_level)
				// the "object's" parents up to the lowest displayed level have to be expanded first.
				if( ! node_properties.isRoot )
					expandItem( node_properties.parentUID );
				actualExpandItem( object_uid );
			}
			
			_expandedItems.splice( 0, _expandedItems.length );
			Build_Expanded_Items( object_uid );
			Set_Is_Expanded_On_Node_Properties();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function actualExpandItem( object_uid: String ): void
		{
			var node_properties: NodeProperties = _nodesMap[ object_uid ] as NodeProperties;
			var object_level: Number = node_properties.level;
			var object: Object = node_properties.data;
			
			// Store the expanded item position.
			var _list: LevelList = level_lists[ object_level ];
			var item_index: Number = _list.dataProvider.getItemIndex( node_properties );
			_list.setExpandedItemPosition( item_index );
			
			//----------
			
			lowest_displayed_level = object_level + 1;
			
			var _children: IList = _dataDescriptor.getChildren( object ) as IList;
			addLevel( lowest_displayed_level, _children );
			// Remove any lists that are present after the lowest_displayed_level.
			removeAllLevelsBelowLowestDisplayedLevel();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Build_Expanded_Items( uid: String ): void
		{
			if( null == uid || "" == uid )
				return;
			
			var node_properties: NodeProperties = _nodesMap[ uid ] as NodeProperties;
			
			if( null != node_properties )
			{
				_expandedItems.unshift( uid );
				
				// If it has a parent, add that too.
				if( ! node_properties.isRoot )
					Build_Expanded_Items( node_properties.parentUID );
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		public function collapseItem( object_uid: String ): void
		{
			// Make sure the UID sent is really expanded.
			// If not found in the expandedItems vector, return.
			if( -1 == _expandedItems.indexOf( object_uid ) )
				return;
			
			var node_properties: NodeProperties = _nodesMap[ object_uid ] as NodeProperties;
			var object_level: Number = node_properties.level;
			var object: Object = node_properties.data;
			
			//----------
			
			_expandedItems = new Vector.<String>();
			if( ! node_properties.isRoot )
				Build_Expanded_Items( node_properties.parentUID );
			Set_Is_Expanded_On_Node_Properties();
			
			lowest_displayed_level = object_level;
			
			// Remove any lists that are present after the lowest_displayed_level.
			removeAllLevelsBelowLowestDisplayedLevel();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Set_Is_Expanded_On_Node_Properties(): void
		{
			for each( var _node_properties: NodeProperties in _nodesMap )
			{
				_node_properties.isExpanded = (-1 != _expandedItems.indexOf( _node_properties.uid ) );
			}
			
			Invalidate_Lists();
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Invalidate_Lists(): void
		{
			for each( var ll: LevelList in level_lists )
			{
				ll.invalidateList();
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function addDataProviderListener():void
		{
			if( _dataProvider && !( _dataProvider.hasEventListener( CollectionEvent.COLLECTION_CHANGE ) ) )
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler, false, 0, true);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function removeDataProviderListener():void
		{
			if( _dataProvider && _dataProvider.hasEventListener( CollectionEvent.COLLECTION_CHANGE ) )
				_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataProvider_collectionChangeHandler);
		}
		
		//-------------------------------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Called when contents within the dataProvider changes.  We will catch certain 
		 *  events and update our children based on that.
		 *
		 *  @param event The collection change event
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		private function dataProvider_collectionChangeHandler(event:CollectionEvent):void
		{
			var i: Number;
			var list: LevelList;
			switch (event.kind)
			{
				case CollectionEventKind.ADD:
				{
					// items are added
					trace("Collection change: New" );
					for( i = 0 ; i <= event.items.length - 1 ; i++ )
					{ 
						var new_item: Object = event.items[i];
						var new_item_uid: String = String( new_item[ _uidField ] );
						
						if( "" == new_item_uid )
							break;
						
						Build_Nodes_Map_For_Object_And_Children( new_item, null, 0 );
						list = level_lists[ 0 ] as LevelList;
						list.dataProvider.addItem( NodeProperties( _nodesMap[ new_item_uid ] ) );
					}
					break;
				}
					
				case CollectionEventKind.REPLACE:
				{
					// items are replaced
					trace("Collection change: Replace" );
					removeDataProviderListener();
					dataProviderChanged = true;
					invalidateProperties();
					break;
				}
					
				case CollectionEventKind.REMOVE:
				{
					// items are removed
					trace("Collection change: Remove" );
					for( i = 0 ; i <= event.items.length - 1 ; i++ )
					{ 
						var deleted_item: Object = event.items[i];
						var deleted_item_uid: String = String( deleted_item[ _uidField ] );
						
						if( "" == deleted_item_uid )
							break;
						
						Build_Nodes_Map();
						list = level_lists[ 0 ] as LevelList;
						i = list.dataProvider.getItemIndex( NodeProperties( _nodesMap[ deleted_item_uid ] ) );
						list.dataProvider.removeItemAt( i );
					}
					break;
				}
					
				case CollectionEventKind.MOVE:
				{
					// one item is moved
					trace("Collection change: Move" );
					removeDataProviderListener();
					dataProviderChanged = true;
					invalidateProperties();
					break;
				}
					
				case CollectionEventKind.REFRESH:
				{
					// from a filter or sort...let's just reset everything
					trace("Collection change: Refresh" );
					removeDataProviderListener();
					dataProviderChanged = true;
					invalidateProperties();
					break;
				}
					
				case CollectionEventKind.RESET:
				{
					// reset everything
					trace("Collection change: Reset" );
					removeDataProviderListener();                
					dataProviderChanged = true;
					invalidateProperties();
					break;
				}
					
				case CollectionEventKind.UPDATE:
				{
					//update the renderer's data and data-dependant properties. 
					trace("Collection change: Update" );
					for (i = 0; i < event.items.length; i++)
					{
						var pe:PropertyChangeEvent = event.items[i] as PropertyChangeEvent; 
						
						if( null == pe )
							break;
						
						var object: Object = pe.source;
						var object_uid: String = String( object[ _uidField ] );
						
						if( "" == object_uid )
							break;
						
						var node_properties: NodeProperties = _nodesMap[ object_uid ] as NodeProperties;
						// If no node properties object has been found, then consider that the object is new.
						// Reset the data provider.
						if( null == node_properties )
						{
							removeDataProviderListener();
							dataProviderChanged = true;
							invalidateProperties();
							break;
						}
						
						Update_View_For_Node_Properties_Update( node_properties );
					}
					break;
				}
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Update_View_For_Node_Properties_Update( node_properties: NodeProperties ): void
		{
			var object: Object = node_properties.data;
			var object_uid: String = node_properties.uid;
			
			var list: LevelList;
			
			// First, update the list showing the updated item.
			// Check if the level of the updated node is currently visible.
			if( node_properties.level <= level_lists.length - 1 )
			{
				list = level_lists[ node_properties.level ];
				// If the node is found in the list, update it.
				if( -1 != list.dataProvider.getItemIndex( node_properties ) )
					list.dataProvider.itemUpdated( node_properties );
			}
			
			//----------- Handling changes to children -----------------
			// 1. First check if there has been any change to the children.
			// 2. If there is no change in the children, then just break.
			// 3. If there is a change in the children, then rebuild the nodes map for the updated node and its children.
			// 4. If the updated node is NOT currently expanded, then just expand the node.
			//    The expanding will take care setting the dataProvider to the child list.
			//    Since the nodesMap has been rebuilt, ALL the new items will appear
			//    in the child list. So, we can break out of the loop.
			// 5. If the updated node is already expanded, then we have to just get the list at the next level
			//    and add to / remove from its dataProvider.
			
			var children_uids: Vector.<String> = Get_Children_UIDs( object );
			var old_children_uids: Vector.<String> = node_properties.childrenUIDs;
			
			var added_children_uids: Vector.<String> = Get_Added_Children_UIDs( children_uids, old_children_uids );
			var deleted_children_uids: Vector.<String> = Get_Deleted_Children_UIDs( children_uids, old_children_uids );
			
			if( 0 == added_children_uids.length && 0 == deleted_children_uids.length )
				return;
			
			// Since the object's children have been updated, rebuild the nodesMap for this object and its children hierarchy.
			var parent_object: Object = node_properties.isRoot ? null : NodeProperties( _nodesMap[ node_properties.parentUID ] ).data;
			Build_Nodes_Map_For_Object_And_Children( object, parent_object, node_properties.level );
			
			if( -1 == _expandedItems.indexOf( object_uid ) )
			{
				// The expanding will take care setting the dataProvider to the child list.
				// Since the nodesMap has been rebuilt, ALL the new items will appear
				// in the child list. So, we can break out of the loop.
				expandItem( object_uid );
				return;
			}
			else
			{
				// Already expanded.
				// Get the list containing the children.
				list = level_lists[ node_properties.level + 1 ];
				
				for each( var added_uid: String in added_children_uids )
				{
					// Add the new item to the list's dataProvider.
					list.dataProvider.addItem( NodeProperties( _nodesMap[ added_uid ] ) );
				}
				
				for each( var deleted_uid: String in deleted_children_uids )
				{
					// Add the new item to the list's dataProvider.
					var index: Number = list.dataProvider.getItemIndex( NodeProperties( _nodesMap[ deleted_uid ] ) );
					list.dataProvider.removeItemAt( index );
				}
			}
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Get_Added_Children_UIDs( new_children_uids: Vector.<String>, old_children_uids: Vector.<String> ): Vector.<String>
		{
			return Get_Difference_Between_Vectors( new_children_uids, old_children_uids );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Get_Deleted_Children_UIDs( new_children_uids: Vector.<String>, old_children_uids: Vector.<String> ): Vector.<String>
		{
			return Get_Difference_Between_Vectors( old_children_uids, new_children_uids );
		}
		
		//-------------------------------------------------------------------------------------------------
		
		private function Get_Difference_Between_Vectors( vector_1: Vector.<String>, vector_2: Vector.<String> ): Vector.<String>
		{
			var extra_in_vector_1: Vector.<String> = new Vector.<String>();
			
			for each( var v_1_item: String in vector_1 )
			{
				if( -1 == vector_2.indexOf( v_1_item ) )
					extra_in_vector_1.push( v_1_item );
			}
			
			return extra_in_vector_1;
		}
		
		//-------------------------------------------------------------------------------------------------
		
	}
}