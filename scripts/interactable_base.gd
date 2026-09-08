extends Node2D
class_name InteractableBase
## 근접 상호작용 오브젝트 공통 베이스 (플레이어가 범위 안에서 ui_accept를
## 누르면 _on_interact() 호출). 하위 클래스는 _on_interact()를 오버라이드
## 하고, 진행 단계에 따라 나타났다 사라져야 하면 _is_visible_now()도
## 오버라이드한다. 씬 전환은 하지 않는다 — 그건 nap_trigger.gd 담당.

@export var interact_radius: float = 28.0
@export var prompt_text: String = "Enter: 살펴보기"

@onready var _prompt_label: Label = get_node_or_null("PromptLabel")

var _player: Node2D

func _ready() -> void:
	if _prompt_label:
		_prompt_label.text = prompt_text
		_prompt_label.visible = false

func _is_visible_now() -> bool:
	return true

func _on_interact() -> void:
	pass

func _process(_delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
	var show_now := _is_visible_now()
	visible = show_now
	if not show_now or _player == null or DialogueSystem.is_active() or DialogueSystem.just_ended_this_frame() or ItemPopup.is_active():
		if _prompt_label:
			_prompt_label.visible = false
		return
	var in_range := global_position.distance_to(_player.global_position) <= interact_radius
	if _prompt_label:
		_prompt_label.visible = in_range
	if in_range and Input.is_action_just_pressed("ui_accept"):
		_on_interact()
