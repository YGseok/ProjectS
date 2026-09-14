extends SceneTree
## 통합 테스트 — 프롤로그 -> 1장 -> 일상 -> 2장 -> 일상 -> 3장(호수) ->
## 최종 화면까지 챕터 1~3 전체 페이즈 전환이 한 번에 이어지는지 검증한다
## (사람 피드백, 2026-09-14: "일상 파트를 만들고, 각 페이즈별 전환이
## 가능한지를 우선 테스트한다", DESIGN.md §11.5). 2/3장의 아이템 이름/
## 대사는 전부 placeholder — 이 테스트가 확인하는 건 내용이 아니라
## "챕터 전환 구조 자체가 처음부터 끝까지 안 끊기고 이어지는가"이다.
##
## 실행: godot4 --headless --script res://tests/test_full_story_progression.gd --path <project>

var _player: Node2D
var _all_passed := true

func _initialize() -> void:
	# 1) 프롤로그 -> Esc로 건너뛰고 챕터 1 현실(일상) 도착.
	change_scene_to_file("res://scenes/chapter1_intro.tscn")
	await process_frame
	await process_frame
	await _send_action("ui_cancel")
	await _wait_scene_change("Chapter1Real", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"프롤로그 스킵 후 챕터 1 현실 도착, 실제: %s" % [current_scene.name if current_scene else "null"])

	var progress: Node = root.get_node("Chapter1Progress")
	var chapter_progress: Node = root.get_node("ChapterProgress")
	_assert(chapter_progress.current_chapter == 1, "시작 시 진행 챕터는 1")

	# 2) 낮잠 -> 챕터 1 꿈 진입 -> 퍼즐(열쇠+나무패) 풀고 탈출.
	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Dream", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Dream",
		"낮잠 -> 챕터 1 꿈 진입, 실제: %s" % [current_scene.name if current_scene else "null"])

	_player = get_first_node_in_group("player")
	await _skip_title_if_active()
	var floorboard: Node2D = current_scene.get_node("Floorboard")
	var hopscotch: Node2D = current_scene.get_node("HopscotchKey")
	var jar: Node2D = current_scene.get_node("JarStamp")
	await _move_to(hopscotch.position)
	await _interact_close()
	await _move_to(jar.position)
	await _interact_close()
	await _move_to(floorboard.position)
	await _interact_close()
	_assert(progress.diary_opened, "챕터 1 퍼즐 완료(일기 개봉)")

	await _wait_scene_change("Chapter1End", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1End",
		"챕터 1 종료 화면 도착, 실제: %s" % [current_scene.name if current_scene else "null"])
	_assert(chapter_progress.current_chapter == 2,
		"챕터 1 탈출 후 진행 챕터가 2로 올라감, 실제: %d" % chapter_progress.current_chapter)

	# 3) 종료 화면에서 Enter -> 일상(챕터 1 현실) 복귀.
	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Real", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"챕터 1 종료 후 일상으로 복귀, 실제: %s" % [current_scene.name if current_scene else "null"])

	# 4) 다시 낮잠 -> 이번엔 챕터 2 꿈으로 이어져야 한다(NapTrigger가
	# ChapterProgress.current_chapter를 보고 동적으로 분기).
	_player = get_first_node_in_group("player")
	await _send_action("ui_accept")
	await _wait_scene_change("Chapter2Dream", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter2Dream",
		"두 번째 낮잠 -> 챕터 2 꿈으로 분기됨, 실제: %s" % [current_scene.name if current_scene else "null"])

	# 5) 챕터 2 퍼즐: 조각 3개 모으고 탈출 트리거.
	_player = get_first_node_in_group("player")
	await _skip_title_if_active()
	var item_a: Node2D = current_scene.get_node("KeyItemA")
	var item_b: Node2D = current_scene.get_node("KeyItemB")
	var item_c: Node2D = current_scene.get_node("KeyItemC")
	var escape2: Node2D = current_scene.get_node("EscapeTrigger")

	await _move_to(escape2.position)
	await _interact_close()
	_assert(not chapter_progress.is_escaped(2), "조각을 모으기 전에는 탈출 트리거가 안 열림")

	# EscapeTrigger(480,160)와 KeyItemA(416,160)가 같은 줄에 나란히 있어서
	# (둘 다 자기 타일을 막는 동적 콜리전이 있음) 그 사이를 곧장 가로지를
	# 수 없다 — 콜리전 없는 y=192행으로 한 번 내려갔다 가는 우회가 필요
	# (다른 테스트들에서 같은 상황에 쓴 것과 동일한 패턴).
	await _move_to(Vector2(512, 192))
	await _move_to(item_a.position)
	await _interact_close()
	await _move_to(item_b.position)
	await _interact_close()
	# KeyItemC(896,480)로 곧장 내려가면 원두막 지붕 콜리전(x832-1120,
	# y352-416)에 막힌다 — 지붕 아래(y480)로 먼저 내려간 뒤 옆으로
	# 접근한다(v0.22 발판 테스트에서 쓴 것과 동일한 우회).
	await _move_to(Vector2(608, 192))
	await _move_to(Vector2(608, 480))
	await _move_to(item_c.position)
	await _interact_close()
	_assert(chapter_progress.all_items_collected(2), "챕터 2 조각 3개를 모두 모음")

	await _move_to(Vector2(512, 192))
	await _move_to(escape2.position)
	await _interact_close()
	_assert(chapter_progress.is_escaped(2), "조각을 모두 모은 뒤 탈출 트리거로 챕터 2 탈출")
	_assert(chapter_progress.current_chapter == 3,
		"챕터 2 탈출 후 진행 챕터가 3으로 올라감, 실제: %d" % chapter_progress.current_chapter)

	# "2장 종료" 타이틀은 명시적으로 스킵하지 않고 자동 타임아웃(2.5초)에
	# 맡긴다 — 스킵으로 보낸 ui_accept가 같은 프레임에 다음 씬(Chapter2End)
	# 에도 "새로 눌림"으로 보여 화면이 뜨자마자 스킵돼버리는 문제가 있었다
	# (챕터 1/3의 종료 화면 전환도 같은 이유로 명시적 스킵 없이 자동
	# 타임아웃만 쓴다 — 이쪽이 더 안전하다고 실측으로 확인됨).
	await _wait_scene_change("Chapter2End", 4.0)
	_assert(current_scene != null and current_scene.name == "Chapter2End",
		"챕터 2 종료 화면 도착, 실제: %s" % [current_scene.name if current_scene else "null"])

	# 6) 종료 화면 -> 일상 복귀 -> 세 번째 낮잠 -> 챕터 3(호수) 꿈.
	await _send_action("ui_accept")
	await _wait_scene_change("Chapter1Real", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter1Real",
		"챕터 2 종료 후 일상으로 복귀, 실제: %s" % [current_scene.name if current_scene else "null"])

	_player = get_first_node_in_group("player")
	await _send_action("ui_accept")
	await _wait_scene_change("Chapter3Dream", 3.0)
	_assert(current_scene != null and current_scene.name == "Chapter3Dream",
		"세 번째 낮잠 -> 챕터 3(호수) 꿈으로 분기됨, 실제: %s" % [current_scene.name if current_scene else "null"])

	# 7) 챕터 3(호수) 퍼즐: 조각 3개 모으고 탈출 -> 최종 화면(일상 복귀
	# 아님, 마지막 챕터라서).
	_player = get_first_node_in_group("player")
	await _skip_title_if_active()
	var lake_a: Node2D = current_scene.get_node("KeyItemA")
	var lake_b: Node2D = current_scene.get_node("KeyItemB")
	var lake_c: Node2D = current_scene.get_node("KeyItemC")
	var escape3: Node2D = current_scene.get_node("EscapeTrigger")

	await _move_to(lake_a.position)
	await _interact_close()
	await _move_to(lake_b.position)
	await _interact_close()
	# 호수(x256-1024, y224-544)를 가로질러 남쪽 기슭(KeyItemC)까지 가야
	# 하는데 곧장 가면 호수 콜리전에 막힌다 — 호수 동쪽 바깥(x1152)을
	# 남북 통로로 삼아 우회한다.
	await _move_to(Vector2(1152, 608))
	await _move_to(lake_c.position)
	await _interact_close()
	_assert(chapter_progress.all_items_collected(3), "챕터 3(호수) 조각 3개를 모두 모음")

	await _move_to(Vector2(1152, 608))
	await _move_to(Vector2(1152, 128))
	await _move_to(escape3.position)
	await _interact_close()
	_assert(chapter_progress.is_escaped(3), "조각을 모두 모은 뒤 탈출 트리거로 챕터 3 탈출")

	await _wait_scene_change("Chapter3End", 4.0)
	_assert(current_scene != null and current_scene.name == "Chapter3End",
		"챕터 3(마지막) 종료 후 최종 화면 도착(일상 복귀 아님), 실제: %s" %
			[current_scene.name if current_scene else "null"])

	_finish()


## 첫 방문 시 자동으로 뜨는 챕터 타이틀 카드(1장/2장/3장)가 떠 있으면
## Enter로 넘겨서 닫는다. 이걸 안 하면 카드가 떠 있는 동안 이동이 막혀
## 있어서 _move_to()가 "막혔다"고 오판하고 첫 이동에서 곧바로 포기해
## 버린다(진행-없음 감지 가드는 "일시적 차단"과 "영구적 차단"을 구분
## 못 함).
func _skip_title_if_active() -> void:
	var title_card: Node = root.get_node_or_null("ChapterTitleCard")
	if title_card != null and title_card.is_active():
		await _send_action("ui_accept")
		await process_frame


## 대화/팝업이 뜨면 전부 닫고 나올 때까지 Enter를 반복 전송한다.
func _interact_close() -> void:
	await _send_action("ui_accept")
	var dialogue: Node = root.get_node_or_null("DialogueSystem")
	var popup: Node = root.get_node_or_null("ItemPopup")
	var guard := 0
	while guard < 20 and ((dialogue and dialogue.is_active()) or (popup and popup.is_active())):
		await _send_action("ui_accept")
		guard += 1


## x축 우선 이동, 막히면 y축으로 우회 시도(다른 테스트들과 동일한 패턴).
func _move_to(target: Vector2) -> void:
	var guard := 0
	while not _player.position.is_equal_approx(target) and guard < 150:
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


func _wait_scene_change(expected_name: String, timeout_sec: float) -> void:
	var elapsed := 0.0
	var step := 0.05
	while elapsed < timeout_sec:
		if current_scene != null and current_scene.name == expected_name:
			return
		await create_timer(step).timeout
		elapsed += step


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
