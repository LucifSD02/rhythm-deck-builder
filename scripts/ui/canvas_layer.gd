extends CanvasLayer
@onready var label: Label = $Label
@onready var grid_container: GridContainer = $GridContainer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func combat_check() -> void:
	print("combat finished")
	label.text = "combat finished"
