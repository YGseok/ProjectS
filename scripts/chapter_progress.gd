extends Node
## 챕터 2 이후의 범용 진행 상태 저장소(사람 피드백, 2026-09-14: "2개의
## 챕터의 퍼즐 내용은 챕터 1과 유사하게, 키 아이템 3개를 찾고, 탈출
## 트리거를 수행하면 나오는 식으로 임의 구성한다"). 챕터 1은 이미
## `Chapter1Progress`(has_key/has_stamp/diary_opened)가 따로 있고
## 테스트가 많이 물려 있어서 안 건드린다 — 챕터 2부터는 이 범용
## 저장소를 쓴다. 챕터 번호를 key로 한 Dictionary라 챕터가 늘어나도
## 새 스크립트 없이 항목만 늘리면 된다(DESIGN.md §11).

## 지금 진행 중인 챕터 번호 — `NapTrigger`가 이 값을 보고 어느 꿈 씬으로
## 이어질지 정한다(nap_trigger.gd의 target_scene_by_chapter 참고). 각
## 챕터의 탈출 트리거(chapter_escape_trigger.gd)가 성공하면 1 올린다.
## 챕터 1은 이 값과 무관하게 독립적으로 동작(Chapter1Progress 참고) —
## 챕터 1 종료 시점에 이 값을 2로 맞춰서 넘겨받는다.
var current_chapter: int = 1

var _chapters := {}

func _get_chapter(chapter: int) -> Dictionary:
	if not _chapters.has(chapter):
		_chapters[chapter] = {"items": [false, false, false], "escaped": false, "started": false}
	return _chapters[chapter]

func has_item(chapter: int, index: int) -> bool:
	return _get_chapter(chapter)["items"][index]

func collect_item(chapter: int, index: int) -> void:
	_get_chapter(chapter)["items"][index] = true

func items_collected_count(chapter: int) -> int:
	var items: Array = _get_chapter(chapter)["items"]
	var n := 0
	for v in items:
		if v:
			n += 1
	return n

func all_items_collected(chapter: int) -> bool:
	return items_collected_count(chapter) == 3

func is_escaped(chapter: int) -> bool:
	return _get_chapter(chapter)["escaped"]

func set_escaped(chapter: int) -> void:
	_get_chapter(chapter)["escaped"] = true

func is_started(chapter: int) -> bool:
	return _get_chapter(chapter)["started"]

func set_started(chapter: int) -> void:
	_get_chapter(chapter)["started"] = true

## 개발자용 챕터 이동 치트(debug_warp.gd) 전용 — 임의의 진행 상태로
## 강제로 덮어쓴다(items_found개를 앞에서부터 모은 것으로 표시).
func force_state(chapter: int, items_found: int, escaped: bool, started: bool) -> void:
	var items: Array[bool] = [false, false, false]
	for i in range(mini(items_found, items.size())):
		items[i] = true
	_chapters[chapter] = {"items": items, "escaped": escaped, "started": started}

## 개발자용 챕터 이동 치트 전용 — 모든 챕터 진행 상태를 지우고 1장부터
## 다시 시작하는 상태로 되돌린다. 각 체크포인트로 이동하기 직전에 항상
## 호출해서, 이전 워프에서 남은 상태가 섞여 들어가지 않게 한다.
func reset_all() -> void:
	_chapters = {}
	current_chapter = 1
