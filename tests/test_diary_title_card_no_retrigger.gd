extends SceneTree
## 자동 회귀 테스트 — 사람 피드백(2026-09-14): "일기장을 열 때, 대화
## 인풋이 되어, 챕터 화면을 넘기는데, 챕터 종료와 '떼어낸 페이지를 다시
## 읽어본다' 대화창이 겹침."
##
## 원인: 일기 개봉 대화가 끝나면 floorboard.gd가 "1장 종료" 타이틀 카드를
## 띄우는데(chapter_title_card.gd), 그 타이틀을 ui_accept로 스킵하는 바로
## 그 입력이 같은 프레임에 옆에 서 있는 Floorboard에도 "새로 눌림"으로
## 보여서 diary_opened==true 분기("떼어낸 페이지를 다시 읽어본다")가 다시
## 열려버렸다. 그 대화창은 DialogueSystem이 오토로드라 씬이
## chapter1_end로 바뀐 뒤에도 안 닫힌 채 남아서 챕터 종료 화면과 겹쳐
## 보였다 — DialogueSystem/ItemPopup에서 이미 두 번 겪은 것과 같은
## "닫는 입력이 같은 프레임에 다른 걸 재트리거" 버그 클래스.
##
## 이 테스트는 일기를 연 직후 "1장 종료" 타이틀이 뜬 그 프레임에 곧바로
## ui_accept를 한 번 더 보내서(스킵 시도) 재현하고, 대화창이 다시 열리지
## 않는지 + 최종적으로 챕터 종료 화면까지 대화창 없이 깔끔하게 전환되는지
## 확인한다.
##
## 실행: godot4 --headless --script res://tests/test_diary_title_card_no_retrigger.gd --path <project>

var _player: Node2D
var _all_passed := true

func _initialize() -> void:
	# "1장 시작" 타이틀은 이 테스트의 관심사가 아니므로 미리 넘겨둔다.
	root.get_node("Chapter1Progress").chapter_started = true

	change_scene_to_file("res://scenes/chapter1_dream.tscn")
	await process_frame
	await process_frame

	_player = get_first_node_in_group("player")
	var progress: Node = root.get_node("Chapter1Progress")
	var dialogue: Node = root.get_node("DialogueSystem")
	var title_card: Node = root.get_node("ChapterTitleCard")
	_assert(_player != null, "player 그룹 노드를 찾음")
	if _player == null:
		_finish()
		return

	# 열쇠/나무패를 이미 가진 상태로 만들어서 곧바로 일기를 열 수 있게 함
	# (이 테스트의 초점은 획득 과정이 아니라 개봉 직후 상황이므로).
	progress.has_key = true
	progress.has_stamp = true

	var floorboard: Node2D = current_scene.get_node("Floorboard")
	await _move_to(floorboard.position)

	# 일기 개봉 대화(7줄)를 끝까지 진행 — 마지막 줄을 닫는 입력으로 대화가
	# 끝나고, floorboard.gd가 곧바로 "1장 종료" 타이틀 카드를 띄운다.
	for i in range(8):
		await _send_action("ui_accept")
	_assert(progress.diary_opened, "일기가 정상적으로 개봉됨")
	await process_frame
	_assert(not dialogue.is_active(), "일기 대화가 정상적으로 닫힘")
	_assert(title_card.is_active(), "일기 개봉 직후 '1장 종료' 타이틀 카드가 뜸")

	# 버그 재현: 타이틀이 떠 있는 바로 그 시점에 ui_accept를 한 번 더
	# 보낸다(플레이어 입장에서는 "타이틀 넘기려는" 자연스러운 입력) —
	# 이게 옆에 서 있는 Floorboard까지 재트리거해서 "떼어낸 페이지를
	# 다시 읽어본다" 대화가 다시 열리면 안 된다.
	await _send_action("ui_accept")
	_assert(not dialogue.is_active(),
		"타이틀 카드를 스킵하는 입력이 판자를 재트리거해서 대화를 다시 열지 않음")

	# 최종적으로 대화창이 열린 채로 남지 않고 챕터 종료 화면으로 깔끔하게
	# 전환돼야 한다 — DialogueSystem은 오토로드라 씬이 바뀌어도 안 닫힌
	# 채로 남으면 새 화면과 겹쳐 보인다(이번 버그의 실제 증상).
	await _wait_scene_change("Chapter1End", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1End",
		"챕터 종료 화면으로 정상 전환됨, 실제: %s" %
			[current_scene.name if current_scene else "null"])
	_assert(not dialogue.is_active(),
		"챕터 종료 화면 도착 후에도 대화창이 열린 채로 남아있지 않음")

	_finish()


func _wait_scene_change(expected_name: String, timeout_sec: float) -> void:
	var elapsed := 0.0
	var step := 0.05
	while elapsed < timeout_sec:
		if current_scene != null and current_scene.name == expected_name:
			return
		await create_timer(step).timeout
		elapsed += step


func _move_to(target: Vector2) -> void:
	var guard := 0
	while not _player.position.is_equal_approx(target) and guard < 100:
		guard += 1
		var diff := target - _player.position
		var x_action := ""
		var y_action := ""
		if absf(diff.x) > 0.01:
			x_action = "ui_right" if diff.x > 0 else "ui_left"
		if absf(diff.y) > 0.01:
			y_action = "ui_down" if diff.y > 0 else "ui_up"
		if x_action == "" and y_action == "":
			break
		var before := _player.position
		if x_action != "":
			await _move_one_tile(x_action)
		if _player.position.is_equal_approx(before) and y_action != "":
			await _move_one_tile(y_action)
		if _player.position.is_equal_approx(before):
			break


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
