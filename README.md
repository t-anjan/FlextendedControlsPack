This is a Flex 4.5 library project containing a number of custom components.

I am in the process of making sample, demo applications to showcase each of the components. But until that is realeased, feel free to explore the source code by yourselves.

# 1. DropDownLists

## SoupedUpDropDownList

This is a custom implementation of the Spark DropDownList.

The SoupedUpeDropDownList contains two main features:

1. A built-in button which allows the user to clear the selection in the drop down list.
2. Shows validity indications in the component by highlighting the component in different colors, green for "valid" and red for "error".

### Demo application with source

Please visit [this](http://anjantek.com/2011/08/07/flex-4-5-spark-dropdownlist-show-clear-button-show-validity-indication-soupedupdropdownlist/) page to view a demo of the component. The source of the demo application is also available there.

# 2. DataGrids

## AwesomeDataGrid

Based on the Spark DataGrid, the `AwesomeDataGrid` adds the following additional features.

Note: To utilize these features, the `AwesomeDataGrid` should be used along with the accompanying custom GridColumns (like `AwesomeGridColumn`) and custom GridItemRenderers (like `AwesomeGridItemRenderer`).

1. Supports the prevention of selection of rows when certain columns are clicked. The user can specify these `no select` columns.
2. Supports having an edit button in a cell, which, when clicked, opens the item editor of the cell.

## SetDPSelectedDataGrid

Based on the `AwesomeDataGrid`, the `SetDPSelectedDataGrid` sets a specific property called `selected` on the data provider's item when that item is selected in the DataGrid.

Sounds simple, but saves major hassle for such a common task as this.

## AutoMultiSelectDataGrid

Based on the `SetDPSelectedDataGrid`, the `AutoMultiSelectDataGrid` allows selecting multiple rows in the DataGrid without the need to press any additional keys.

Again, this is a very commonly needed feature. This component saves a lot of time, being a drop-in replacement for the original Spark DataGrid.

# 3. GridColumns

## AwesomeGridColumn

Based on the plain old Spark GridColumn, the `AwesomeGridColumn` supports the following additional properties.

1. **selectable** - Will clicking on a row in this column cause the row to be selected?
2. **validityProperties** - A comma-separated list of Boolean properties on the data provider item. These items are called to ascertain the validity of the cell in this column. If any of the properties return false, the item renderer highlights the cell with the invalid property. *Note*: You need to use the `AwesomeGridItemRenderer` for this property to take effect.
3. **validityErrorString** - The error string to display on the cell when an invalid cell is found by evaluating the `validityProperties` property.
4. **textRestrict** - The restriction on the types of characters allowed to be entered in the itemEditor of this column.
5. **textMaxChars** - The max number of characters that can be entered in the itemEditor of this column.
6. **allowDuplicates** - Can duplicate values exist in this column?

## CheckBoxGridColumn

Based on the `AwesomeGridColumn`, the `CheckBoxGridColumn` is built to hold the `CheckBoxGridItemRenderer`. As the name suggests, this column displays a check box in each row. It has the following features.

It has a custom header renderer which is a three state check box. The header displays one of its three states:

* *Unticked* - If all check boxes in the column are unticked.
* *Partial* - If some check boxes in the column are ticked, but not all.
* *Ticked* - If all check boxes in the column are ticked.

The `CheckBoxGridColumn` supports the following properties.

1. **headerClickable** - Can the header be clicked to mass-select or mass-unselect all the check boxes in the column?
2. **controlProperty** - Is there a specific Boolean property of the data provider items which the check boxes are supposed to mimic? If no property is specified, the check boxes mimic the selection of the row.
3. **canEditItemRendererProperty** - Check this boolean property on the data provider to determine if the `controlProperty` is allowed to be edited.

# 4. GridItemRenderers

## AwesomeGridItemRenderer

Based on the Spark `GridItemRenderer`, the `AwesomeGridItemRenderer` is the heart behind all the features of the `AwesomeGridColumn`. The properties set on the `AwesomeGridColumn` take effect in this item renderer.

1. Verifies the validity properties.
2. If any validity property evaluates to false, the item renderer shows an error state.
3. If specified, shows the error string.
4. If the column and the data grid are editable, shows the edit button on the cell.

## CheckBoxGridItemRenderer

Based on the Spark `GridItemRenderer`, the `CheckBoxGridItemRenderer` is one major part of the feature-set of the `CheckBoxGridColumn` (the other being the `CheckBoxGridHeaderRenderer`).

This item renderer renders a check box and takes care of either mimicking either the `controlProperty` of the data provider item or the selection status of the data grid row.

If a particular row's `canEditItemRendererProperty` returns false, then the `CheckBoxGridItemRenderer` will not be editable.

## RadioButtonGridItemRenderer

Based on the Spark `GridItemRenderer`, the `RadioButtonGridItemRenderer` is very similar to the `CheckBoxGridItemRenderer` in that it mimics the selection status of the row. This item renderer is meant to be used in those data grids which have a `selectionMode` of `singleRow`.

### Demo application with source

Please visit [this](http://anjantek.com/2011/09/04/flex-4-5-spark-datagrid-radio-button-itemrenderer/) page to view a demo of the component. The source of the demo application is also available there.

## CheckBoxGridHeaderRenderer

Based on the Spark `GridItemRenderer`, the `CheckBoxGridHeaderRenderer` is the designated header for the `CheckBoxGridColumn`. It displays a check box which supports three states according the check boxes' selection status in the `CheckBoxGridColumn`. This is explained in the `CheckBoxGridColumn` section above.

If the column has a `headerText` property set, the string is shown beside the check box. 

Clicking this header serves as a control to select or unselect all the check boxes in the column. Only the checkboxes which are allowed to be toggled are toggled, based on the `canEditItemRendererProperty` of each data provider item. The header's three-state checkbox also changes state taking into account the non-toggle-able checkboxes.

# 5. GridItemEditors

## UsualGridItemEditor

Based on the `DefaultGridItemEditor`, the `UsualGridItemEditor` adds a couple of frequently used features to the default item editor.

1. When opening the item editor, to populate the item editor, if the `dataField` property is not set on the column, then use the `itemToLabel` method of the column to populate the editor.
2. Implement the `allowDuplicates` property of the `AwesomeGridColumn`. If the entered value is already found elsewhere in the column, then a `GridColumnEvent.DUPLICATE_DATA_FOUND` event is dispatched to the data grid.
3. When the item editor's data is saved successfully, a `GridColumnEvent.DATA_UPDATED_IN_CELL` event is dispatched to the data grid.
4. Implements the textRestrict and the textMaxChars properties of the `AwesomeGridColumn`.
5. Trim's the entered data automatically on retrieve.

# 6. NotificationWindow

This is a component based on the Spark `TitleWindow` component. This is an unobtrusive, non-modal popup window to be used for the purpose of showing notification messages to the user. The notification hides automatically after 3 seconds, unless the user hovers the mouse pointer over it.

# 7. MultiThumbSlider

This is a Spark Slider component with a lot of additional features. The component is a fusion of the work of Patrick Mowrer ([here](https://github.com/pmowrer/spark-components) and [here](http://www.patrickmowrer.com/2010/10/18/multiple-thumb-spark-slider-component)) and [Patrick Heinzelmann](https://github.com/patrickheinzelmann/Spark-Slider-with-Track-Highlight). It has been so heavily modified that it retains little resemblance to either of the above components. But full credit to both Patricks for their amazing work which set me in the right direction.

**NOTE: Only the horizontal orientation of the slider has been tested extensively. Since I did not need the vertical orientation, I haven't made the skins for it. Anyone who needs the vertical orientation can easily create the required skins by referring to the horizontal version of the skins.**

The main features are the following.

1. Multiple thumbs can be displayed. Thumbs can be fixed or movable.
2. A colored track highlight can be shown between the thumbs.
	* **accentColors** - The color of the track highlights can be specified as an array of `accentColors`.
	* The colors from the array will be used in the order in which they were specified in the array, to highlight the consecutive track intervals.
	* If the number of track intervals is greater than the number of colors in the `accentColors` array, then the colors will be repeated from the start of the array again.
	* **showTrackHighlight** - Using this property, you can control if you want the colored track highlights to be shown.
3. A label can be assigned and displayed for each interval between the thumbs. The label can be edited in-place.
4. The component accepts a `dataProvider` object which is used to compute the position of the thumbs and display the labels. 
	* Moving the thumbs and editing the labels updates the `dataProvider` immediately.
	* Updates to the `dataProvider` are reflected immediately in the `MultiThumbSlider`.
	* **valueField**, **labelField** and **fixedValueField** properties can be used to specify the properties on the dataProvider objects which should be read to obtain the corresponding information.
5. Thumbs can be added and removed directly from within the component: Unobtrusive 'Add Thumb' and 'Remove Thumb' buttons appear near each thumb on mouse over.
6. Apart from thumbs, additional thumb-like, fixed objects called `Markers` can be displayed on the slider. `Markers` will not be part of the `dataProvider`. This is useful when you want to point to a location on the slider using a thumb-like object, but you don't necessarily want that position to be part of the `dataProvider`.
	* **markers** - This is the array which takes the list of values where `markers` should appear.
7. **defaultTrackHighlightLabel** - The default label for new thumb intervals can be specified using this property.
8. **allowDuplicateValues** - As the name suggests, you can control if duplicate values are allowed for thumbs. **Currently, there are some serious issues with `fixedValues` when this property is set to `true`. I haven't tested this yet.**
9. **allowOverlap** - As the name suggests, you can control if you want the thumbs to be moved over and beyond one another. **Currently, this property is non-functional.**
