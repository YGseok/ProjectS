extends SceneTree
## 자동 테스트 — 챕터 탈출 후 일상 파트에서 얻는 "단서" 오브젝트
## (scripts/clue_object.gd)가 해당 챕터를 탈출하기 전에는 안 보이고
## 상호작용도 안 되다가, 탈출 후(ChapterProgress.current_chapter가
## 올라간 뒤)에만 나타나서 지정한 placeholder 대사를 보여주는지
## 검증한다(INBOX.md 2026-09-09 "탈출한 후... 단서를 얻을 수 있는 일상
## 플레이", 2026-09-15 사람 확인 "기능부터 만들고 내용은 나중에").
##
## 실행: godot4 --headless --script res://tests/test_clue_objects.gd --path <project>

var _player: Node2D
var _dialogue: Node
var _chapter_progress: Node
var _last_seen_text := ""
var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	_dialogue = root.get_node_or_null("DialogueSystem")
	_chapter_progress = root.get_node_or_null("ChapterProgress")
	_assert(_player != null, "player 그룹 노드를 찾음")
	_assert(_dialogue != null, "DialogueSystem 오토로드를 찾음")
	_assert(_chapter_progress != null, "ChapterProgress 오토로드를 찾음")
	if _player == null or _dialogue == null or _chapter_progress == null:
		_finish()
		return

	var clue1: Node2D = current_scene.get_node("ClueChapter1")
	var clue2: Node2D = current_scene.get_node("ClueChapter2")
	_assert(clue1 != null, "ClueChapter1 노드를 찾음")
	_assert(clue2 != null, "ClueChapter2 노드를 찾음")

	# (608,160) -> (608,608)(14칸 아래) -> (352,608)(8칸 왼쪽, ClueChapter1 옆).
	for i in range(14):
		await _move_one_tile("ui_down")
	for i in range(8):
		await _move_one_tile("ui_left")
	_assert(_player.position.is_equal_approx(Vector2(352, 608)),
		"ClueChapter1 옆까지 이동, 실제: %s" % [_player.position])

	await process_frame
	_assert(not clue1.visible, "1장을 탈출하기 전에는 ClueChapter1이 안 보임")

	await _send_action("ui_accept")
	_assert(not _dialogue.is_active(), "안 보이는 단서는 Enter를 눌러도 반응하지 않음")

	# 1장 탈출을 흉내낸다 — floorboard.gd가 실제로 하는 것과 동일하게
	# ChapterProgress.current_chapter를 2로 올림.
	_chapter_progress.current_chapter = 2
	await process_frame
	_assert(clue1.visible, "1장 탈출 후 ClueChapter1이 보임")

	await _interact_close()
	_assert(_last_seen_text == "밭 한쪽에 낯익은 글씨가 적힌 종잇조각이 떨어져 있다.",
		"ClueChapter1 대사가 지정한 placeholder와 일치, 실제: '%s'" % _last_seen_text)

	# (352,608) -> (448,608)(3칸 오른쪽, ClueChapter2 옆).
	for i in range(3):
		await _move_one_tile("ui_right")
	_assert(_player.position.is_equal_approx(Vector2(448, 608)),
		"ClueChapter2 옆까지 이동, 실제: %s" % [_player.position])

	await process_frame
	_assert(not clue2.visible, "2장을 탈출하기 전에는 ClueChapter2가 안 보임(1장만 탈출한 상태)")

	# 2장 탈출을 흉내낸다.
	_chapter_progress.current_chapter = 3
	await process_frame
	_assert(clue2.visible, "2장 탈출 후 ClueChapter2가 보임")

	await _interact_close()
	_assert(_last_seen_text == "평소와 다르게, 마루 밑에서 희미한 냄새가 난다.",
		"ClueChapter2 대사가 지정한 placeholder와 일치, 실제: '%s'" % _last_seen_text)

	_finish()


func _interact_close() -> void:
	await _send_action("ui_accept")
	var label: Label = _dialogue.get_node("Panel/Label")
	_last_seen_text = label.text
	var guard := 0
	while _dialogue.is_active() and guard < 20:
		await _send_action("ui_accept")
		guard += 1


func _move_one_tile(action: String) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	var start_guard := 0
	while not _player._moving and start_guard < 10:
		await process_frame
		start_guard += 1
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	var move_guard := 0
	while _player._moving and move_guard < 60:
		await process_frame
		move_guard += 1


func _send_action(action: String) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	await process_frame
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame
	await process_frame


func _assert(condition: bool, description: String) -> void:
	if condition:
		print("[TEST] PASS - %s" % description)
	else:
		printerr("[TEST] FAIL - %s" % description)
		_all_passed = false


func _finish() -> void:
	if _all_passed:
		print("[TEST] ALL PASSED")
		quit(0)
	else:
		printerr("[TEST] SOME FAILED")
		quit(1)
