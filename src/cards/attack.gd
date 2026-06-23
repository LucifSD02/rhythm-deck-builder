class_name Attack
extends BaseEffect

@export var attack_damage: int = 0
@export var debuff_duration: int = 0

func trigger(accuracy: float) -> Array:
	return [attack_damage * accuracy]
