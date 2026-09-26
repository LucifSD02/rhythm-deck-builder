@icon("res://addons/at-icons/node/note_double.svg")
extends StateBase

var timeline: Timeline
var combat_state_machine: CombatStateMachine
var context: CombatContext
var note_hits: Array[NoteHit] = []

@onready var sequence_creator: SequenceCreator = %SequenceCreator
@onready var state_label: Label = %StateLabel
@onready var timeline_ui: TimelineUI = %TimelineUI


func enter(p_context: CombatContext, p_combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = p_combat_state_machine
	context = p_context
	timeline = context.timeline
	sequence_creator.convert_to_sequence(timeline, false)
	sequence_creator.convert_to_sequence(context.enemy_timeline, true)
	state_label.text = "Current state: Rhythm"


func update(_delta: float) -> void:
	pass


func exit() -> void:
	if combat_state_machine == null:
		return
	timeline_ui.clear_timeline()
	combat_state_machine.change_state(combat_state_machine.execution_state, self)


func on_note_hit(card_id: int, judgement: float) -> void:
	var new_hit: NoteHit = NoteHit.new(card_id, judgement)
	note_hits.append(new_hit)
	print(card_id, " ", judgement)


func on_last_note_reached() -> void:
	print("Sequence complete")
	var timeline_accuracy: float = get_accuracy_for_timeline(note_hits)
	context.judgement_whole_timeline = timeline_accuracy
	print("Accuracy of timeline: ", timeline_accuracy)
	for card_id in range(timeline.cards.size()):
		var card_accuracy: float = get_accuracy_for_card(note_hits, card_id)
		print("Accuracy of card ", card_id, ": ", card_accuracy)
	exit()


func on_card_last_note_reached(card_id: int) -> void:
	var accuracy: float = get_accuracy_for_card(note_hits, card_id)
	context.judgements_individual_cards.set(card_id, accuracy)
	print("Card ", card_id, " complete, accuracy: ", accuracy)


func get_accuracy_for_timeline(hits: Array[NoteHit]) -> float:
	var total_timeline_score: float = 0
	var total_note_hits: int = hits.size()

	for note_hit in hits:
		total_timeline_score += note_hit.score

	return total_timeline_score / total_note_hits


func get_accuracy_for_card(hits: Array[NoteHit], card_id: int) -> float:
	var total_card_score: float = 0
	var total_note_hits: int = 0

	for note_hit in hits:
		if note_hit.card_id == card_id:
			total_card_score += note_hit.score
			total_note_hits += 1

	return total_card_score / total_note_hits


class NoteHit:
	var card_id: int
	var score: float


	func _init(p_card_id: int, p_score: float) -> void:
		card_id = p_card_id
		score = p_score
