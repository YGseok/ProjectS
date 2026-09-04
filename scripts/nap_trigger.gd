extends Node2D
## 상호작용 트리거 — 플레이어가 가까이 있을 때 상호작용키(Enter/Space)를
## 누르면 검은 페이드 후 target_scene 으로 전환한다.
##
## 챕터 1 현실→꿈 낮잠 트리거로 사용한다. 꿈→현실 각성은 DESIGN.md §4(5)에
## 따라 원래 "메인 퍼즐 해결"로 트리거되어야 하지만, 그 퍼즐/단서 수집
## 시스템이 아직 구현되지 않아 지금은 이 트리거를 재사용해 왕복 테스트만
## 가능하게 해둔 임시 상태다 (STATUS.md 참고, 메인 퍼즐 구현 시 교체 필요).

@export var target_scene: String = ""
@export var interact_radius: float = 24.0
@export var prompt_text: String = "Enter"

@onready var _prompt_label: Label = $PromptLabel

var _player: Node2D

func _ready() -> void:
	_prompt_label.text = prompt_text
	_prompt_label.visible = false
	_player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if _player == null or target_scene.is_empty():
		return

	var in_range := global_position.distance_to(_player.global_position) <= interact_radius
	_prompt_label.visible = in_range

	if in_range and Input.is_action_just_pressed("ui_accept"):
		var fade := get_tree().get_first_node_in_group("fade_overlay")
		if fade:
			fade.fade_to_scene(target_scene)
		else:
			get_tree().change_scene_to_file(target_scene)
