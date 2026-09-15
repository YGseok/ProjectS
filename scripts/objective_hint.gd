extends "res://scripts/objective_hint_base.gd"
## 챕터 1 꿈 파트 목표 힌트 (사람 피드백, 2026-09-08 — "어디에서 왜 무엇을
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
##
## 화면 하단 페이드/숨김 공통 로직은 `objective_hint_base.gd` 참고
## (2026-09-15, `daily_life_hint.gd`와 공유하려고 분리).

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
