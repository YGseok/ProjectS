extends Node2D
## 챕터 1 프롤로그 — 다이얼로그 시퀀스. 원래(2026-09-08, "실질적인
## 플레이보다는 자동 재생 및 다이얼로그 위주")는 일정 시간 뒤 자동으로도
## 넘어갔지만, 자동 재생이 오히려 불편하다는 사람 피드백(2026-09-09
## "오프닝 다이얼로그가 자동 재생되지 않도록 한다")으로 **자동 진행은
## 제거**했다 — 이제 한 줄씩 ui_accept(Enter/Space)를 눌러야만 다음 줄로
## 넘어간다(수동 진행). ui_cancel(Esc)을 누르면 전체를 건너뛰고 바로
## 챕터 1로 간다(전체 스킵) — 이 부분은 그대로 유지.
##
## 텍스트는 DESIGN.md §8에 이미 확정된 사실(10세 여자아이, 매년 여름
## 시골 옛집 방문, 가족과 함께, 도착한 날 낮잠)만 사용한 **임시
## 자리표시 텍스트**다 — 실제 대사/연출은 스토리 세션에서 확정 후 교체할 것.
##
## 타자기 효과: `dialogue_system.gd`와 같은 방식(`Label.visible_ratio`)
## 으로 글자가 순차적으로 나타난다(2026-09-08 추가). 순수 시각 효과라
## 진행 로직과는 무관 — 타이핑 도중에 ui_accept를 눌러도 그냥 다음
## 줄로 넘어갈 뿐, 별도의 "타이핑 완료" 단계는 없다.

const CHARS_PER_SECOND := 40.0
const NEXT_SCENE := "res://scenes/chapter1_real.tscn"

const LINES: Array[String] = [
	"...",
	"매년 여름이면, 이 집에 온다.",
	"시골에 있는, 원래 우리 가족이 살던 옛집.",
	"엄마, 아빠, 그리고 나. 올해도 어김없이.",
	"오늘은 유난히 덥다. 매미 소리가 시끄럽다.",
	"툇마루에 잠깐 앉아 있었을 뿐인데...",
]

@onready var _label: Label = $Label

var _index := 0
var _reveal_progress := 0.0
var _finished := false

func _ready() -> void:
	_show_line(0)

func _process(delta: float) -> void:
	if _finished:
		return
	if _label.visible_ratio < 1.0:
		_reveal_progress += CHARS_PER_SECOND * delta
		var total := _label.text.length()
		_label.visible_ratio = 1.0 if total <= 0 else clampf(_reveal_progress / float(total), 0.0, 1.0)
	if Input.is_action_just_pressed("ui_cancel"):
		_finish()
		return
	if Input.is_action_just_pressed("ui_accept"):
		_advance()

func _advance() -> void:
	_index += 1
	if _index >= LINES.size():
		_finish()
		return
	_show_line(_index)

func _show_line(i: int) -> void:
	_label.text = LINES[i]
	_label.visible_ratio = 0.0
	_reveal_progress = 0.0

func _finish() -> void:
	if _finished:
		return
	_finished = true
	get_tree().change_scene_to_file(NEXT_SCENE)
