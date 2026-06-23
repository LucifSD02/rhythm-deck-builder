class_name Special
extends Resource

@export_enum("No curse", "Weaken curse", "Slowness curse") var curse_type
@export_enum("No transformation", "Wolf", "Dragon") var transform_type
@export var accuracy_modifier : AccuracyModifier

func curse():
	pass

func tranform():
	pass
