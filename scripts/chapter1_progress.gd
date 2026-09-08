extends Node
## 챕터 1 메인 퍼즐 "닫힌 일기장" 진행 상태 (DESIGN.md §8.1, 2026-09-07 확정).
## 오토로드로 등록해서 chapter1_real.tscn을 낮잠/각성으로 오가며 다시
## 로드해도(change_scene_to_file) 값이 유지되게 한다.
##
## stage는 순환(낮잠↔각성) 1회마다 1씩 오른다 — 각성(꿈→현실) 트리거가
## advance_cycle()을 호출한다 (nap_trigger.gd의 advances_chapter1_cycle 참고).

const MAX_STAGE := 4

var stage: int = 1
var has_key := false
var has_stamp := false
var diary_opened := false

func advance_cycle() -> void:
	if stage < MAX_STAGE:
		stage += 1
