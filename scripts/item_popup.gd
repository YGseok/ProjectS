extends CanvasLayer
## 아이템 획득 팝업 (오토로드) — 아이콘 + 이름을 화면 중앙쯤에 띄우고
## ui_accept(Enter/Space) 입력 한 번으로 닫는다. 사람 피드백(2026-09-08,
## docs/feedback/INBOX.md): "아이템 획득 피드백이 부족함 — 아이템 이미지,
## 이름과 함께 획득 팝업이 떠야함. 키 입력을 하면 닫힘."
##
## DialogueSystem과 마찬가지로 is_active()를 노출해서 player.gd가 팝업이
## 떠 있는 동안 이동 입력을 무시하게 한다.

signal popup_shown
signal popup_closed

@onready var _panel: Panel = $Panel
@onready var _icon: TextureRect = $Panel/Icon
@onready var _label: Label = $Panel/Label

var _active := false
var _shown_frame := -1

func _ready() -> void:
	_panel.visible = false

func is_active() -> bool:
	return _active

func show_item(item_name: String, icon: Texture2D) -> void:
	if _active:
		return
	_active = true
	_shown_frame = Engine.get_process_frames()
	_label.text = item_name
	_icon.texture = icon
	_panel.visible = true
	popup_shown.emit()

func _process(_delta: float) -> void:
	if not _active:
		return
	# 팝업을 띄운 바로 그 입력으로 같은 프레임에 즉시 닫혀버리는 걸 막는다
	# (dialogue_system.gd의 _started_frame과 같은 이유).
	if Engine.get_process_frames() == _shown_frame:
		return
	if Input.is_action_just_pressed("ui_accept"):
		_active = false
		_panel.visible = false
		popup_closed.emit()
