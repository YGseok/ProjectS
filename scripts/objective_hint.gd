extends CanvasLayer
## 현재 목표 힌트 (사람 피드백, 2026-09-08 — "어디에서 왜 무엇을
## 해야하는지 인지하기 어려움. 좀더 게임같이 개연성있게 연결시켜보자").
##
## 새 스토리 텍스트를 만들지 않고, `Chapter1Progress`의 기계적 상태
## (has_key/has_stamp/diary_opened)만으로 "지금 뭘 해야 하는지"를 짧게
## 안내한다 — 각 오브젝트가 이미 대사로 드러내는 정보를 화면에 상시
## 요약해서 보여주는 것뿐, 새로운 진상/사건을 노출하지 않는다.
##
## 2026-09-09부터 퍼즐이 꿈 방문 한 번 안에서 전부 진행되고 사방치기/
## 장독이 처음부터 둘 다 보이므로(더 이상 순환 단계로 순서가 강제되지
## 않음), 열쇠와 나무패를 어느 순서로 먼저 얻어도 자연스러운 힌트가
## 나오도록 두 조합을 모두 처리한다. `chapter1_dream.tscn`으로 옮겨
## 붙인다(퍼즐 자체가 꿈 안으로 옮겨갔으므로).

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
	var p := Chapter1Progress
	if p.diary_opened:
		return ""
	if p.has_key and p.has_stamp:
		return "마루 밑 판자를 다시 살펴보자."
	if p.has_key and not p.has_stamp:
		return "집 안 항아리(장독)를 살펴보자."
	if p.has_stamp and not p.has_key:
		return "마당 흙바닥을 잘 살펴보자."
	return "마루 밑에서 뭔가 이상한 낌새가 느껴진다. 마당과 장독도 살펴보자."
