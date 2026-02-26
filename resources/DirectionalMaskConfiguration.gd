extends CPMB_MaskConfiguration
class_name CPMB_DirectionalMaskConfiguration

@export var direction : Vector3 = Vector3.UP

enum PolarityType {BIPOLAR, MONOPOLAR_POSITIVE, MONOPOLAR_NEGATIVE}
@export var polarity : PolarityType = PolarityType.BIPOLAR
