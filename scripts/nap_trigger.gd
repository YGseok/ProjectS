extends Node2D
## 상호작용 트리거 — 플레이어가 가까이 있을 때 상호작용키(Enter/Space)를
## 누르면 검은 페이드 후 target_scene 으로 전환한다.
##
## 챕터 1 현실→꿈 낮잠 트리거(NapTrigger)가 이 스크립트를 쓴다.
## **(2026-09-09 갱신)** 예전엔 꿈→현실 각성 트리거(WakeTrigger)도 같은
## 스크립트를 재사용하면서 `advances_chapter1_cycle`로 순환 단계를
## 올렸는데, 퍼즐 구조가 "순환마다 하나씩"에서 "꿈 방문 한 번 안에서
## 전부"로 바뀌면서 그 순환 개념 자체가 없어졌다 — WakeTrigger는
## `chapter1_dream.tscn`에서 완전히 제거됐고(꿈 안에서 일기를 여는 것,
## 즉 `floorboard.gd`가 유일한 탈출 경로), 그래서 `advances_chapter1_cycle`
## 필드도 함께 삭제함(더 이상 아무도 안 씀).
##
## 대화창/아이템 팝업/챕터 타이틀 카드가 열려 있거나 막 닫힌 프레임에는
## 반응하지 않는다 — 지금 오브젝트 배치상 실제로 겹치는 자리는 없지만
## (NapTrigger가 정확히 플레이어 스폰 위치라 특히 조심), 같은 종류의
## "닫는 입력이 같은 프레임에 다른 걸 재트리거" 버그를
## `interactable_base.gd`/`item_popup.gd`에서 이미 두 번, 챕터 타이틀
## 카드에서 세 번째로 겪어서(2026-09-08, 2026-09-14) 여기도 방어적으로
## 막아둔다.
##
## **(2026-09-14 갱신, DESIGN.md §11)** 챕터 2/3부터는 현실(일상)을
## 챕터마다 새로 안 만들고 `chapter1_real.tscn`을 계속 공유 허브로 쓴다
## — 그래서 이 낮잠 트리거 하나가 지금 진행 중인 챕터에 맞는 꿈으로
## 동적으로 분기해야 한다. `target_scene_by_chapter`가 비어 있으면
## (기본값) 예전처럼 `target_scene`을 그대로 쓰는 완전히 호환되는
## 동작이고, 값이 있으면 `ChapterProgress.current_chapter`(1-based)에
## 맞는 인덱스를 그 배열에서 찾아 쓴다 — 범위를 벗어나면 안전하게
## `target_scene`으로 대체한다.

@export var target_scene: String = ""
@export var target_scene_by_chapter: Array[String] = []
@export var interact_radius: float = 24.0
@export var prompt_text: String = "Enter"

@onready var _prompt_label: Label = $PromptLabel

var _player: Node2D

func _ready() -> void:
	_prompt_label.text = prompt_text
	_prompt_label.visible = false

func _current_target_scene() -> String:
	if target_scene_by_chapter.is_empty():
		return target_scene
	var index := ChapterProgress.current_chapter - 1
	if index >= 0 and index < target_scene_by_chapter.size():
		return target_scene_by_chapter[index]
	return target_scene

func _process(_delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
	var effective_target := _current_target_scene()
	if _player == null or effective_target.is_empty():
		return

	var in_range := global_position.distance_to(_player.global_position) <= interact_radius
	_prompt_label.visible = in_range

	var blocked := DialogueSystem.is_active() or DialogueSystem.just_ended_this_frame() \
		or ItemPopup.is_active() or ItemPopup.just_closed_this_frame() \
		or ChapterTitleCard.is_active() or ChapterTitleCard.just_ended_this_frame()
	if in_range and not blocked and Input.is_action_just_pressed("ui_accept"):
		var fade := get_tree().get_first_node_in_group("fade_overlay")
		if fade:
			fade.fade_to_scene(effective_target)
		else:
			get_tree().change_scene_to_file(effective_target)
