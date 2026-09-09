extends Node
## 챕터 1 메인 퍼즐 "닫힌 일기장" 진행 상태 (DESIGN.md §8.1, 2026-09-07
## 확정, 구조 2026-09-09 갱신). 오토로드로 등록해서 chapter1_dream.tscn을
## 다시 로드해도(change_scene_to_file) 값이 유지되게 한다.
##
## 2026-09-09부터 퍼즐이 "순환(낮잠↔각성)마다 하나씩"이 아니라 "꿈 방문
## 한 번 안에서 전부"로 바뀌면서, 순환 횟수를 세던 stage/MAX_STAGE/
## advance_cycle()은 더 이상 쓰이지 않아 삭제함 — 이제 has_key/has_stamp
## 조합만으로 퍼즐 진행을 판단한다.

var has_key := false
var has_stamp := false
var diary_opened := false
