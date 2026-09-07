extends Node2D
## 상호작용 트리거 — 플레이어가 가까이 있을 때 상호작용키(Enter/Space)를
## 누르면 검은 페이드 후 target_scene 으로 전환한다.
##
## 챕터 1 현실→꿈 낮잠 트리거, 꿈→현실 각성 트리거 둘 다 이 스크립트를
## 재사용한다. 각성 쪽 인스턴스(WakeTrigger)는 `advances_chapter1_cycle`을
## true로 켜서, 각성할 때마다 `Chapter1Progress.advance_cycle()`로 메인
## 퍼즐 "닫힌 일기장"(DESIGN.md §7.1) 진행 단계를 1씩 올린다. 각성 자체는
## 여전히 Enter만 누르면 되는 **임시** 트리거이고(진짜로는 마지막 단계
## 일기 개봉이 각성을 유발해야 함, DESIGN.md §7.1 참고), 지금은 왕복 자체가
## 막히지 않도록 열어둔 상태다.

@export var target_scene: String = ""
@export var interact_radius: float = 24.0
@export var prompt_text: String = "Enter"
@export var advances_chapter1_cycle: bool = false

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
		if advances_chapter1_cycle:
			Chapter1Progress.advance_cycle()
		var fade := get_tree().get_first_node_in_group("fade_overlay")
		if fade:
			fade.fade_to_scene(target_scene)
		else:
			get_tree().change_scene_to_file(target_scene)
