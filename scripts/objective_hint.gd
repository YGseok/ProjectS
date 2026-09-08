extends CanvasLayer
## 현재 목표 힌트 (사람 피드백, 2026-09-08 — "어디에서 왜 무엇을
## 해야하는지 인지하기 어려움. 좀더 게임같이 개연성있게 연결시켜보자").
##
## 새 스토리 텍스트를 만들지 않고, `Chapter1Progress`의 기계적 상태
## (stage/has_key/has_stamp/diary_opened)만으로 "지금 뭘 해야 하는지"를
## 짧게 안내한다 — 각 오브젝트가 이미 대사로 드러내는 정보를 화면에
## 상시 요약해서 보여주는 것뿐, 새로운 진상/사건을 노출하지 않는다.

@onready var _label: Label = $Label

func _process(_delta: float) -> void:
	# 대화창/아이템 팝업도 화면 하단을 쓰는데(DialogueSystem 패널이 이
	# 라벨과 y좌표가 살짝 겹침), 그 위에 힌트가 함께 떠 있으면 대화창
	# 밑으로 텍스트 한 조각이 삐져나와 보이는 시각 버그가 있었다(실제
	# 창 캡처로 발견, 2026-09-08). 대화/팝업 중엔 힌트를 그냥 숨긴다.
	if DialogueSystem.is_active() or ItemPopup.is_active():
		_label.visible = false
		return
	_label.visible = true
	_label.text = _current_hint()

func _current_hint() -> String:
	var p := Chapter1Progress
	if p.diary_opened:
		return ""
	if p.has_key and p.has_stamp:
		return "마루 밑 판자를 다시 살펴보자."
	if p.has_key and not p.has_stamp:
		if p.stage >= 3:
			return "집 안 항아리(장독)를 살펴보자."
		return "자물쇠에 맞는 게 하나 더 필요할 것 같다."
	if p.stage >= 2:
		return "마당 흙바닥을 잘 살펴보자."
	return "마루 밑에서 뭔가 이상한 낌새가 느껴진다."
