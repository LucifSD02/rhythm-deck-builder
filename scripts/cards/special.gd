class_name Special
extends Resource

@export_enum("No curse", "Weaken curse", "Slowness curse") var curse_type: String
@export_enum("No transformation", "Wolf", "Dragon") var transform_type: String
@export var accuracy_modifier : AccuracyModifier

func curse() -> void:
	pass

func tranform() -> void:
	pass
