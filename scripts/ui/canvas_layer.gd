extends CanvasLayer

@onready var state_label: Label = %StateLabel



func combat_check() -> void:
	print("combat finished")
	state_label.text = "combat finished"
