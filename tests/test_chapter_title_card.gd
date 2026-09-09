extends SceneTree
## 자동 테스트 — 챕터 시작/종료 타이틀 카드(scripts/chapter_title_card.gd,
## 2026-09-09 사람 피드백 "첫 꿈 들어간 후 1챕터 타이틀이 뜨고... 첫 꿈
## 탈출하면, 1챕터 완료 타이틀이 뜬다")가 실제로 뜨고, ui_accept로
## 스킵되고, 첫 방문에만 뜨는지(재방문 시 중복 안 뜸) 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_chapter_title_card.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame

	var title_card: Node = root.get_node_or_null("ChapterTitleCard")
	var chapter1_progress: Node = root.get_node_or_null("Chapter1Progress")
	_assert(title_card != null, "ChapterTitleCard 오토로드를 찾음")
	_assert(chapter1_progress != null, "Chapter1Progress 오토로드를 찾음")
	if title_card == null or chapter1_progress == null:
		_finish()
		return

	# --- 첫 방문: "1장" 타이틀이 자동으로 뜬다.
	_assert(title_card.is_active(), "첫 꿈 방문 시 타이틀 카드가 자동으로 뜸")
	_assert(chapter1_progress.chapter_started, "타이틀을 띄운 뒤 chapter_started가 true로 바뀜")

	var label: Label = title_card.get_node("Label")
	_assert(label.text.find("1장") != -1, "타이틀 텍스트에 '1장'이 포함됨, 실제: '%s'" % label.text)

	# 타이틀이 떠 있는 동안은 플레이어 이동이 막혀야 한다(대화창/팝업과
	# 같은 패턴).
	var player: Node2D = get_first_node_in_group("player")
	_assert(player != null, "player 그룹 노드를 찾음")
	if player != null:
		var pos_before: Vector2 = player.position
		await _press_and_wait("ui_right", 5)
		_assert(player.position.is_equal_approx(pos_before),
			"타이틀 카드가 떠 있는 동안은 이동 입력이 무시됨, 실제: %s" % [player.position])

	# ui_accept로 스킵하면 즉시 사라져야 한다.
	await _press_and_wait("ui_accept", 3)
	_assert(not title_card.is_active(), "Enter를 누르면 타이틀 카드가 즉시 사라짐")

	# --- 재방문: chapter_started가 이미 true이므로 다시 뜨면 안 된다.
	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame
	_assert(not title_card.is_active(), "재방문 시 타이틀 카드가 다시 뜨지 않음(chapter_started 유지)")

	_finish()


func _press_and_wait(action: String, frames: int) -> void:
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	Input.parse_input_event(press)
	for i in range(frames):
		await process_frame
	var release := InputEventAction.new()
	release.action = action
	release.pressed = false
	Input.parse_input_event(release)
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
