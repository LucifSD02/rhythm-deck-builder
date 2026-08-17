@icon("res://addons/at-icons/node/note_double.svg")
extends StateBase

var timeline: Timeline
var combat_state_machine: CombatStateMachine

@onready var sequence_creator: SequenceCreator = %SequenceCreator
@onready var state_label: Label = %StateLabel
@onready var context: CombatContext
@onready var note_hits: Array[NoteHit] = []
@onready var timeline_ui: TimelineUi = %TimelineUI


func enter(_context: CombatContext, _combat_state_machine: CombatStateMachine) -> void:
	combat_state_machine = _combat_state_machine
	context = _context
	timeline = context.timeline
	sequence_creator.convert_to_sequence(timeline, false)
	sequence_creator.convert_to_sequence(context.enemy_timeline, true)
	state_label.text = "Current StateBase: Rhythm state"


func update(_delta: float) -> void:
	pass


func exit() -> void:
	if combat_state_machine == null:
		return
	timeline_ui.clear_timeline()
	combat_state_machine.change_state(combat_state_machine.execution_state, self)


func log_note_hits(id: int, judgement: float) -> void:
	var new_hit: NoteHit = NoteHit.new(id, judgement)
	note_hits.append(new_hit)
	print(id, " ", judgement)


func sequence_complete() -> void:
	print("Sequence complete")
	var timeline_accuracy: float = get_accuracy_for_timeline(note_hits)
	context.judgement_whole_timeline = timeline_accuracy
	print("Accuracy of timeline: ", timeline_accuracy)
	for card in range(timeline.cards.size()):
		var card_accuracy: float = get_accuracy_for_card(note_hits, card)
		print("Accuracy of card ", card, ": ", card_accuracy)
	exit()


func card_complete(card_id: int) -> void:
	var accuracy: float = get_accuracy_for_card(note_hits, card_id)
	context.judgements_individual_cards.set(card_id, accuracy)
	print("Card ", card_id, " Complete, accuracy: ", accuracy)


func get_accuracy_for_timeline(_note_hits: Array[NoteHit]) -> float:
	var total_timeline_score: float = 0
	var total_note_hits: int = _note_hits.size()

	for note_hit in note_hits:
		total_timeline_score += note_hit.score

	return total_timeline_score / total_note_hits


func get_accuracy_for_card(_note_hits: Array[NoteHit], card_id: int) -> float:
	var total_card_score: float = 0
	var total_note_hits: int = 0

	for note_hit in _note_hits:
		if note_hit.card_id == card_id:
			total_card_score += note_hit.score
			total_note_hits += 1

	return total_card_score / total_note_hits


class NoteHit:
	var card_id: int
	var score: float


	func _init(_card_id: int, _score: float) -> void:
		self.card_id = _card_id
		self.score = _score
