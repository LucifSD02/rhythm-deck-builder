extends CanvasLayer

@onready var state_label: Label = %StateLabel


func on_combat_finished() -> void:
	print("combat finished")
	state_label.text = "combat finished"
