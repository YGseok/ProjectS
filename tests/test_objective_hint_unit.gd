extends SceneTree
## 자동 유닛 테스트 — scripts/objective_hint.gd의 텍스트 전환 페이드
## (2026-09-08 v0.04 추가)가 실제 내용 변경 시에만 재생되고, 같은
## 내용이 유지되는 동안엔 재발동하지 않는지 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_objective_hint_unit.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	var hint: Node = current_scene.get_node_or_null("ObjectiveHint")
	_assert(hint != null, "ObjectiveHint 노드를 찾음")
	if hint == null:
		_finish()
		return

	var label: Label = hint.get_node("Label")
	var progress: Node = root.get_node("Chapter1Progress")

	# 초기 힌트가 다 뜰 때까지 기다린다(0.25초 페이드).
	await create_timer(0.35).timeout
	_assert(is_equal_approx(label.modulate.a, 1.0),
		"초기 힌트가 페이드 완료 후 완전히 보임, 실제 alpha=%s" % [label.modulate.a])
	var first_text := label.text

	# 상태가 그대로인 동안 여러 프레임이 지나도 알파가 1.0에서 안 흔들려야
	# 한다(내용이 안 바뀌었으니 페이드가 재발동하면 안 됨).
	for i in range(10):
		await process_frame
	_assert(label.text == first_text and is_equal_approx(label.modulate.a, 1.0),
		"내용이 안 바뀌면 페이드가 재발동하지 않고 alpha=1.0 유지")

	# 실제로 내용을 바꾸면(열쇠 획득) 알파가 다시 0 근처로 내려갔다가
	# 페이드로 올라와야 한다.
	progress.has_key = true
	await process_frame
	await process_frame
	_assert(label.text != first_text, "상태 변경 시 힌트 텍스트가 실제로 바뀜")
	_assert(label.modulate.a < 1.0,
		"내용이 바뀌는 순간엔 페이드가 다시 시작돼 알파가 1.0 미만, 실제=%s" % [label.modulate.a])

	await create_timer(0.35).timeout
	_assert(is_equal_approx(label.modulate.a, 1.0), "새 힌트도 페이드 완료 후 완전히 보임")

	_finish()


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
