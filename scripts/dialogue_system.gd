extends CanvasLayer
## 전역 대화 시스템 (오토로드, project.godot에 등록). 쯔꾸르 스타일 —
## 화면 하단에 대화창을 띄우고 스페이스바/Enter(ui_accept)로 한 줄씩
## 진행하다가 더 이어질 대화가 없으면 종료한다.
##
## 타자기 효과: 한 줄이 뜰 때 글자가 순차적으로 나타난다
## (`Label.visible_ratio` 이용, 2026-09-08 추가 — INBOX.md "지금은
## 재미가 없다" 피드백에 대한 안전한 손맛 개선). **입력 처리는 전혀
## 안 바꿨다** — `_label.text`는 여전히 즉시 전체 줄로 설정되고,
## `ui_accept`는 여전히 그 즉시 다음 줄로 진행한다(타이핑 도중에
## 눌러도 그냥 다음 줄로 넘어갈 뿐, 별도의 "타이핑 완료" 단계는 없다).
## 이렇게 해야 기존 자동 테스트들(대화 진행을 한 번의 ui_accept로
## 가정하는 것들)이 전부 그대로 통과한다 — 눈에 보이는 것만 바뀌었지
## `.text` 값이나 진행 로직은 그대로.

signal dialogue_started
signal dialogue_ended

const CHARS_PER_SECOND := 40.0

@onready var _panel: Panel = $Panel
@onready var _label: Label = $Panel/Label

var _lines: Array[String] = []
var _index := 0
var _active := false
var _started_frame := -1
var _ended_frame := -1
var _reveal_progress := 0.0

func _ready() -> void:
	_panel.visible = false

func is_active() -> bool:
	return _active

## 이 프레임에 막 대화가 끝났는지 — NPC가 "닫기"와 같은 입력으로 바로
## 재시작해버리는 것을 막기 위해 쓴다 (npc.gd 참고).
func just_ended_this_frame() -> bool:
	return Engine.get_process_frames() == _ended_frame

func start_dialogue(lines: Array[String]) -> void:
	if _active or lines.is_empty():
		return
	_lines = lines
	_index = 0
	_active = true
	_started_frame = Engine.get_process_frames()
	_panel.visible = true
	_show_line(_index)
	dialogue_started.emit()

func _process(delta: float) -> void:
	if not _active:
		return
	if _label.visible_ratio < 1.0:
		_reveal_progress += CHARS_PER_SECOND * delta
		var total := _label.text.length()
		_label.visible_ratio = 1.0 if total <= 0 else clampf(_reveal_progress / float(total), 0.0, 1.0)
	# NPC가 이 프레임에 막 start_dialogue()를 호출했을 수 있다 — 같은
	# ui_accept 입력으로 시작과 동시에 진행/종료되는 걸 막는다.
	if Engine.get_process_frames() == _started_frame:
		return
	if Input.is_action_just_pressed("ui_accept"):
		_advance()

func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		_end_dialogue()
		return
	_show_line(_index)

func _show_line(i: int) -> void:
	_label.text = _lines[i]
	_label.visible_ratio = 0.0
	_reveal_progress = 0.0

func _end_dialogue() -> void:
	_active = false
	_ended_frame = Engine.get_process_frames()
	_panel.visible = false
	_lines = []
	_index = 0
	dialogue_ended.emit()
