@tool
extends CPMB_Base
class_name CPMB_NumericValue

signal value_changed(value : Variant, value_property_name : String) ##Signal that gets emitted when a property of the resource changes. [param value] is the new value, [param value_property_name] is the name of the shader uniform that is linked to this property.
