extends Node2D
## 상호작용 트리거 — 플레이어가 가까이 있을 때 상호작용키(Enter/Space)를
## 누르면 검은 페이드 후 target_scene 으로 전환한다.
##
## 챕터 1 현실→꿈 낮잠 트리거, 꿈→현실 각성 트리거 둘 다 이 스크립트를
## 재사용한다. 각성 쪽 인스턴스(WakeTrigger)는 `advances_chapter1_cycle`을
## true로 켜서, 각성할 때마다 `Chapter1Progress.advance_cycle()`로 메인
## 퍼즐 "닫힌 일기장"(DESIGN.md §8.1) 1~3단계 진행 단계를 1씩 올린다.
## **(2026-09-08 갱신)** 예전엔 여기 "마지막 단계 일기 개봉이 각성을
## 유발해야 하는데 아직 안 됨"이라고 적어뒀었지만, 그건 이미 별도로
## 해결됐다 — `floorboard.gd`가 일기 개봉과 동시에 `chapter1_end.tscn`
## 으로 직접 전환하므로(`DialogueSystem.dialogue_ended` 훅, WakeTrigger를
## 거치지 않음), 이 트리거는 1~3단계 순환용으로만 쓰이는 게 지금은 오히려
## 맞는 상태다. 다만 `PromptLabel`의 "(임시)" 표기는 남아있다 — 각성 자체
## (씬 전환 방식)를 나중에 더 다듬을 수도 있다는 뜻으로 남겨둠, 완전히
## 틀린 표기는 아니지만 오해 소지가 있어 여기 남겨서 다음에 볼 때 참고.
##
## 대화창/아이템 팝업이 열려 있거나 막 닫힌 프레임에는 반응하지 않는다 —
## 지금 오브젝트 배치상 실제로 겹치는 자리는 없지만(NapTrigger가 정확히
## 플레이어 스폰 위치라 특히 조심), 같은 종류의 "닫는 입력이 같은 프레임에
## 다른 걸 재트리거" 버그를 `interactable_base.gd`/`item_popup.gd`에서
## 이미 두 번 겪어서(2026-09-08) 여기도 방어적으로 막아둔다.

@export var target_scene: String = ""
@export var interact_radius: float = 24.0
@export var prompt_text: String = "Enter"
@export var advances_chapter1_cycle: bool = false

@onready var _prompt_label: Label = $PromptLabel

var _player: Node2D

func _ready() -> void:
	_prompt_label.text = prompt_text
	_prompt_label.visible = false

func _process(_delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
	if _player == null or target_scene.is_empty():
		return

	var in_range := global_position.distance_to(_player.global_position) <= interact_radius
	_prompt_label.visible = in_range

	var blocked := DialogueSystem.is_active() or DialogueSystem.just_ended_this_frame() \
		or ItemPopup.is_active() or ItemPopup.just_closed_this_frame()
	if in_range and not blocked and Input.is_action_just_pressed("ui_accept"):
		if advances_chapter1_cycle:
			Chapter1Progress.advance_cycle()
		var fade := get_tree().get_first_node_in_group("fade_overlay")
		if fade:
			fade.fade_to_scene(target_scene)
		else:
			get_tree().change_scene_to_file(target_scene)
