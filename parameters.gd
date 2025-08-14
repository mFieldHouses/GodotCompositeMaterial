@tool
extends EditorInspectorPlugin

var hide_parameters = ["shader", "next_pass", "render_priority"]

var adapting_values = {
	"vertex_displacement_mode" : {
		0: {
			"vertex_displacement_scale" : false,
			"vertex_displacement_map" : false
		},
		1 : {
			"vertex_displacement_scale" : true,
			"vertex_displacement_map" : true
		}
	},
	 "orm_mode" : {
		0: {
			"orm_map" : true,
			"occlusion_map" : false,
			"roughness_map" : false,
			"metallic_map" : false
		},
		1: {
			"orm_map" : false,
			"occlusion_map" : true,
			"roughness_map" : true,
			"metallic_map" : true
		}
	},
	"directional_mask_mode" : {
		0: {
			"directional_mask_space" : false,
			"directional_mask_color_ramp" : false,
			"directional_mask_mixing_step" : false
		},
		-1: {
			"directional_mask_space" : true,
			"directional_mask_color_ramp" : true,
			"directional_mask_mixing_step" : true
		}
	},
	"positional_mask_mode" : {
		0: {
			"positional_mask_axis" : false,
			"positional_mask_color_ramp" : false,
			"positional_mask_max" : false,
			"positional_mask_min" : false,
			"positional_mask_mixing_step" : false
		},
		-1 : {
			"positional_mask_axis" : true,
			"positional_mask_color_ramp" : true,
			"positional_mask_max" : true,
			"positional_mask_min" : true,
			"positional_mask_mixing_step" : true
		},
	},
	"vertex_color_mask_mode" : {
		0 : {
			"vertex_color_mask_target_color" : false
		}
	}
}

func _can_handle(object):
	return object is CompositeMaterial or object is CompositeMaterialLayer


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
		#print("parse property")
		if name in hide_parameters:
			return false
		
		
		return false
