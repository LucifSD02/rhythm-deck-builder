class_name AccuracyModifier
extends Resource

@export_enum("No value multiplier", "2x Multiplier", "0.5x Multiplier") var accuracy_multiplier: String

func execute(card: Resource) -> float:
	if card is Attack:
		return multiply(card.attack_damage)
	elif card is Shield:
		return multiply(card.shield_amount)
	return 0.0

func multiply(stat: float) -> float:
	match accuracy_multiplier:
		0: return stat * 1
		1: return stat * 2
		2: return stat * 0.5
	return stat
