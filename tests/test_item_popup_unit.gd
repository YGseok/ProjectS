extends SceneTree
## 자동 유닛 테스트 — scripts/item_popup.gd의 등장 애니메이션(스케일/
## 페이드, 2026-09-08 v0.02 추가)이 실제로 재생되고 끝까지 안착하는지
## NPC/오브젝트 없이 직접 검증한다.
##
## 실행: godot4 --headless --script res://tests/test_item_popup_unit.gd --path <project>

var _all_passed := true

func _initialize() -> void:
	change_scene_to_file("res://scenes/chapter1_real.tscn")
	await process_frame
	await process_frame

	var popup: Node = root.get_node_or_null("ItemPopup")
	_assert(popup != null, "ItemPopup 오토로드를 찾음")
	if popup == null:
		_finish()
		return

	var panel: Control = popup.get_node("Panel")

	popup.show_item("테스트", null)
	await process_frame
	await process_frame

	_assert(popup.is_active(), "show_item() 호출 후 is_active() true")
	_assert(panel.scale.x < 1.0 and panel.modulate.a < 1.0,
		"등장 직후엔 아직 스케일/알파가 최종값(1.0)에 못 미침, 실제: scale=%s alpha=%s" %
			[panel.scale, panel.modulate.a])

	# 애니메이션(0.18초)이 끝날 만큼 기다린다.
	await create_timer(0.3).timeout
	_assert(panel.scale.is_equal_approx(Vector2.ONE),
		"애니메이션 종료 후 스케일이 정확히 1.0으로 안착, 실제: %s" % [panel.scale])
	_assert(is_equal_approx(panel.modulate.a, 1.0),
		"애니메이션 종료 후 알파가 정확히 1.0으로 안착, 실제: %s" % [panel.modulate.a])

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
