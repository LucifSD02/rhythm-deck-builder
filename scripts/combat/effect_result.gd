class_name EffectResult
extends RefCounted

enum Category { DAMAGE, SHIELD, HEAL, MODIFIER }
enum Operation { ADD, MULTIPLY }
enum Scope { THIS_CARD, THIS_BAR, RELATIVE_CELLS }

var comments: Array[String] = ["result affected by: "]
var target_cells: Array[TimelineCell] = [] # only meaningful when scope == RELATIVE_CELLS
var category: Category
var magnitude: float
var target: EffectBase.Target
var source_card: CardData
var cell: TimelineCell
# Only meaningful when category == MODIFIER
var modifies_category: Category
var operation: Operation
var scope: Scope
