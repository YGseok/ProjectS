extends CanvasLayer
## 화면 하단에 "지금 뭘 해야 하는지" 짧은 힌트를 보여주는 공용 베이스.
## 하위 클래스는 `_current_hint()`만 오버라이드해서 그 씬만의 힌트
## 로직을 정의한다. 대화/팝업 중엔 자동으로 숨고, 힌트 내용이 바뀌는
## 순간엔 페이드로 갈아끼운다 — `objective_hint.gd`(챕터 1 꿈)에 있던
## 공통 로직을 뽑아냈다(2026-09-15, 사람 피드백 "일상 단계에서도 뭘
## 해야 다음 스텝으로 넘어가는지 알려주자"에 따라 `daily_life_hint.gd`
## 도 같은 동작이 필요해져서).

@onready var _label: Label = $Label

var _last_hint := ""
var _fade_tween: Tween

func _process(_delta: float) -> void:
	# 대화창/아이템 팝업도 화면 하단을 쓰는데(DialogueSystem 패널이 이
	# 라벨과 y좌표가 살짝 겹침), 그 위에 힌트가 함께 떠 있으면 대화창
	# 밑으로 텍스트 한 조각이 삐져나와 보이는 시각 버그가 있었다(실제
	# 창 캡처로 발견, 2026-09-08). 대화/팝업 중엔 힌트를 그냥 숨긴다.
	if DialogueSystem.is_active() or ItemPopup.is_active():
		_label.visible = false
		return
	_label.visible = true
	var hint := _current_hint()
	if hint != _last_hint:
		_last_hint = hint
		# 목표가 바뀌는 순간 그냥 툭 바뀌는 대신 살짝 페이드로 갈아끼운다
		# (2026-09-08, "손맛" 개선 — item_popup.gd/dialogue_system.gd와
		# 같은 계열). `.text`는 여전히 즉시 새 값으로 바뀌어서(애니메이션
		# 때문에 지연되지 않음) 기존 테스트의 즉시 비교 어서션에 영향 없음.
		_label.text = hint
		_label.modulate.a = 0.0
		if _fade_tween:
			_fade_tween.kill()
		_fade_tween = create_tween()
		_fade_tween.tween_property(_label, "modulate:a", 1.0, 0.25)

func _current_hint() -> String:
	return ""
