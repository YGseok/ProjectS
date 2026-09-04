extends CanvasLayer
## 전역 대화 시스템 (오토로드, project.godot에 등록). 쯔꾸르 스타일 —
## 화면 하단에 대화창을 띄우고 스페이스바/Enter(ui_accept)로 한 줄씩
## 진행하다가 더 이어질 대화가 없으면 종료한다.

signal dialogue_started
signal dialogue_ended

@onready var _panel: Panel = $Panel
@onready var _label: Label = $Panel/Label

var _lines: Array[String] = []
var _index := 0
var _active := false
var _started_frame := -1
var _ended_frame := -1

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
	_label.text = _lines[_index]
	dialogue_started.emit()

func _process(_delta: float) -> void:
	if not _active:
		return
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
	_label.text = _lines[_index]

func _end_dialogue() -> void:
	_active = false
	_ended_frame = Engine.get_process_frames()
	_panel.visible = false
	_lines = []
	_index = 0
	dialogue_ended.emit()
