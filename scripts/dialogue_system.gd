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

func _ready() -> void:
	_panel.visible = false

func is_active() -> bool:
	return _active

func start_dialogue(lines: Array[String]) -> void:
	if _active or lines.is_empty():
		return
	_lines = lines
	_index = 0
	_active = true
	_panel.visible = true
	_label.text = _lines[_index]
	dialogue_started.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_advance()

func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		_end_dialogue()
		return
	_label.text = _lines[_index]

func _end_dialogue() -> void:
	_active = false
	_panel.visible = false
	_lines = []
	_index = 0
	dialogue_ended.emit()
