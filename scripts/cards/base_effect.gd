class_name BaseEffect
extends Resource

var activation_bar: int = 0


func trigger(_accuracy: float) -> Array:
	return []

func condition_met(context: CombatContext) -> bool:
	return true

func resolve(context: CombatContext) -> EffectResult:
	return EffectResult.new()
