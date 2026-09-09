extends Node2D
class_name InteractableBase
## 근접 상호작용 오브젝트 공통 베이스 (플레이어가 범위 안에서 ui_accept를
## 누르면 _on_interact() 호출). 하위 클래스는 _on_interact()를 오버라이드
## 하고, 진행 단계에 따라 나타났다 사라져야 하면 _is_visible_now()도
## 오버라이드한다. 씬 전환은 하지 않는다 — 그건 nap_trigger.gd 담당.
##
## blocks_movement=true(기본)면 "blocks_movement" 그룹에 속해서
## collision_map.gd가 벽처럼 막는다(사람 피드백, 2026-09-09 "NPC 및 대화
## 가능한 오브젝트에도 벽처럼 충돌 판정을 추가한다"). 숨겨진 동안
## (visible=false, 아직 등장 안 한 단계)은 collision_map.gd가 알아서
## 무시하므로 별도 처리 불필요. **나무/덤불(scenery_flavor.gd)은 예외** —
## 그쪽은 이미 트렁크 모양에 맞춘 전용 사각형(chapter1_real.tscn의
## CollisionMap.blocked_rects)으로 따로 막혀 있고, 스프라이트 기준점이
## 타일 중심과 어긋나 있어서 이 범용 "가장 가까운 칸" 방식을 그대로
## 적용하면 트렁크와 안 맞는 엉뚱한 칸이 막히는 부작용이 생긴다 —
## scenery_flavor.gd에서 false로 끈다.
##
## interact_radius 기본값을 32px(정확히 타일 하나)보다 살짝 크게 잡은
## 이유: 오브젝트 자신의 타일이 이제 막혀서, 플레이어가 더는 오브젝트와
## 같은 칸에 설 수 없고 인접 칸(정확히 32px 거리)에서만 상호작용해야
## 하기 때문 — 28이면 그 거리를 못 미쳐서 상호작용이 아예 불가능해짐.
@export var blocks_movement: bool = true
@export var interact_radius: float = 34.0
@export var prompt_text: String = "Enter: 살펴보기"

@onready var _prompt_label: Label = get_node_or_null("PromptLabel")

var _player: Node2D

func _ready() -> void:
	if blocks_movement:
		add_to_group("blocks_movement")
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
	if not show_now or _player == null or DialogueSystem.is_active() or DialogueSystem.just_ended_this_frame() or ItemPopup.is_active() or ItemPopup.just_closed_this_frame():
		if _prompt_label:
			_prompt_label.visible = false
		return
	var in_range := global_position.distance_to(_player.global_position) <= interact_radius
	if _prompt_label:
		_prompt_label.visible = in_range
	if in_range and Input.is_action_just_pressed("ui_accept"):
		_on_interact()
