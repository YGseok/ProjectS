extends CanvasLayer
## 개발자용 챕터 이동 치트 (사람 피드백, 2026-09-09: "각 챕터 앞뒤로
## 점프할 수 있도록, 개발자용 챕터 이동 치트를 만든다. 모든 상황에서
## 접근 및 스킵이 가능하면 좋을 것 같다... 이동하면 현재 진행도를 날리고,
## 해당 진행도 시작지점에 보유하고 있어야하는 아이템만 지니게 한다.")
##
## F9로 메뉴를 열고 닫는다. 대화창/아이템 팝업 등 다른 시스템 상태와
## 무관하게 항상 반응해야 "모든 상황에서 접근 가능"이 되므로, 다른
## 인터랙션 스크립트들과 달리 DialogueSystem.is_active() 같은 체크를
## 전혀 하지 않는다. 메뉴가 열려 있을 때 숫자 키(1,2,3...)를 누르면 그
## 체크포인트로 즉시 이동하면서 Chapter1Progress를 그 지점에 맞는 값으로
## 덮어쓴다(그 이후 단계에서만 얻었을 아이템은 없어짐).
##
## 지금은 챕터 1까지만 구현돼 있어서 체크포인트도 그만큼만 등록했다 —
## 나중에 챕터 2/3...이 추가되면 CHECKPOINTS에 항목만 더 넣으면 된다.
## `OS.is_debug_build()`가 false인 배포 빌드에서는 아예 반응하지 않는다
## (플레이어에게 노출되면 안 되는 개발자 전용 기능이라서).
##
## 2026-09-09 퍼즐 구조 변경(꿈 방문 한 번 안에서 전부 진행) 이후,
## "1장 시작" 체크포인트는 이제 chapter1_real이 아니라 chapter1_dream으로
## 바로 이동한다 — 퍼즐 오브젝트가 전부 꿈 쪽으로 옮겨갔기 때문.

## chapter_started를 true로 두는 체크포인트는 "1장 시작" 타이틀 카드를
## 다시 띄우지 않는다 — 개발 중 반복 테스트할 때마다 2.5초씩 카드를
## 기다리지 않아도 되게 하기 위함(프롤로그만 예외 — 진짜 처음부터
## 시작하는 상태를 재현해야 하므로 false).
const CHECKPOINTS: Array[Dictionary] = [
	{"label": "프롤로그", "scene": "res://scenes/chapter1_intro.tscn",
		"has_key": false, "has_stamp": false, "diary_opened": false, "chapter_started": false},
	{"label": "1장 진행 중(꿈, 아이템 없음)", "scene": "res://scenes/chapter1_dream.tscn",
		"has_key": false, "has_stamp": false, "diary_opened": false, "chapter_started": true},
	{"label": "1장 종료", "scene": "res://scenes/chapter1_end.tscn",
		"has_key": true, "has_stamp": true, "diary_opened": true, "chapter_started": true},
]

@onready var _panel: Panel = $Panel
@onready var _list_label: Label = $Panel/ListLabel

var _menu_open := false

func _ready() -> void:
	add_to_group("debug_warp")
	_panel.visible = false
	var lines: Array[String] = ["[개발자 치트] 챕터 이동 — F9로 닫기"]
	for i in range(CHECKPOINTS.size()):
		lines.append("%d: %s" % [i + 1, CHECKPOINTS[i]["label"]])
	_list_label.text = "\n".join(lines)

func is_menu_open() -> bool:
	return _menu_open

func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F9:
		_menu_open = not _menu_open
		_panel.visible = _menu_open
		get_viewport().set_input_as_handled()
		return
	if not _menu_open:
		return
	var index: int = int(event.keycode) - int(KEY_1)
	if index >= 0 and index < CHECKPOINTS.size():
		_warp_to(CHECKPOINTS[index])
		get_viewport().set_input_as_handled()

func _warp_to(checkpoint: Dictionary) -> void:
	Chapter1Progress.has_key = checkpoint["has_key"]
	Chapter1Progress.has_stamp = checkpoint["has_stamp"]
	Chapter1Progress.diary_opened = checkpoint["diary_opened"]
	Chapter1Progress.chapter_started = checkpoint["chapter_started"]
	_menu_open = false
	_panel.visible = false
	get_tree().change_scene_to_file(checkpoint["scene"])
