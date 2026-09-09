extends CanvasLayer
## 챕터 시작/종료를 알리는 타이틀 카드 (사람 피드백, 2026-09-09: "첫 꿈
## 들어간 후 1챕터 타이틀이 뜨고... 첫 꿈 탈출하면, 1챕터 완료 타이틀이
## 뜬다"). show_title()을 호출하면 화면 전체를 덮는 반투명 검은 배경
## 위에 텍스트를 띄우고, ui_accept를 누르거나 AUTO_HIDE_SECONDS가 지나면
## 자동으로 사라진다. 오토로드라 씬이 바뀌어도(예: 대화가 끝나며 다음
## 씬으로 전환되기 직전에 이 카드를 띄우는 경우) 계속 유지된다.
##
## 호출부는 `await ChapterTitleCard.show_title(...)`로 카드가 사라질
## 때까지 기다렸다가 다음 동작(씬 전환 등)을 이어갈 수 있다.
## player.gd가 is_active()를 확인해서 타이틀이 떠 있는 동안 이동을 막는다
## (대화창/아이템 팝업과 같은 패턴).

const AUTO_HIDE_SECONDS := 2.5

@onready var _background: ColorRect = $Background
@onready var _label: Label = $Label

var _active := false

func _ready() -> void:
	_background.visible = false
	_label.visible = false

func is_active() -> bool:
	return _active

func show_title(text: String) -> void:
	if _active:
		return
	_label.text = text
	_background.visible = true
	_label.visible = true
	_active = true
	var timer := get_tree().create_timer(AUTO_HIDE_SECONDS)
	while _active:
		await get_tree().process_frame
		if timer.time_left <= 0.0 or Input.is_action_just_pressed("ui_accept"):
			_active = false
	_background.visible = false
	_label.visible = false
