extends Node2D
## 상호작용 가능한 NPC — 플레이어가 인접 타일에서 이 NPC 쪽을 바라보고
## 상호작용키(Enter/Space, ui_accept)를 누르면 대화를 시작한다.
## DESIGN.md 대화 시스템 사양: "NPC를 바라보고 스페이스바" 로 시작.
##
## "blocks_movement" 그룹에 속해서 collision_map.gd가 벽처럼 막는다(사람
## 피드백, 2026-09-09) — NPC 타일 위로 플레이어가 겹쳐 걸어 들어갈 수
## 없다. 상호작용 자체는 원래도 인접 타일(TILE_SIZE 거리)에서 하도록
## 되어 있어서 이 변경으로 인한 영향은 없다.

const TILE_SIZE := 32.0
const FACE_DOT_THRESHOLD := 0.9

@export var dialogue_lines: Array[String] = ["..."]

var _player: Node2D

func _ready() -> void:
	add_to_group("blocks_movement")

func _process(_delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
	if _player == null or DialogueSystem.is_active() or DialogueSystem.just_ended_this_frame() \
			or ItemPopup.is_active() or ItemPopup.just_closed_this_frame():
		return
	if not Input.is_action_just_pressed("ui_accept"):
		return

	var to_npc: Vector2 = global_position - _player.global_position
	if to_npc.length() > TILE_SIZE * 1.5:
		return
	if to_npc.normalized().dot(_player.facing) < FACE_DOT_THRESHOLD:
		return

	DialogueSystem.start_dialogue(dialogue_lines)
