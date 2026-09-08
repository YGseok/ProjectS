extends Node2D
## 챕터 1 프롤로그 — 자동 재생 다이얼로그 시퀀스 (사람 피드백, 2026-09-08):
## "내가 누구고 어떤 상황에 놓여있는지, 프롤로그가 필요함. 실질적인
## 플레이보다는 자동 재생 및 다이얼로그 위주. 해당 다이얼로그는 특정
## 버튼으로 스킵이 가능해야 함."
##
## 한 줄이 AUTO_ADVANCE_SECONDS 뒤 자동으로 넘어가거나(자동 재생),
## ui_accept(Enter/Space)를 누르면 그 즉시 다음 줄로 넘어간다(한 줄
## 스킵). ui_cancel(Esc)을 누르면 전체를 건너뛰고 바로 챕터 1로 간다
## (전체 스킵).
##
## 텍스트는 DESIGN.md §8에 이미 확정된 사실(10세 여자아이, 매년 여름
## 시골 옛집 방문, 가족과 함께, 도착한 날 낮잠)만 사용한 **임시
## 자리표시 텍스트**다 — 실제 대사/연출은 스토리 세션에서 확정 후 교체할 것.

const AUTO_ADVANCE_SECONDS := 3.0
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
var _timer := 0.0
var _finished := false

func _ready() -> void:
	_show_line(0)

func _process(delta: float) -> void:
	if _finished:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		_finish()
		return
	_timer += delta
	if _timer >= AUTO_ADVANCE_SECONDS or Input.is_action_just_pressed("ui_accept"):
		_advance()

func _advance() -> void:
	_index += 1
	if _index >= LINES.size():
		_finish()
		return
	_show_line(_index)

func _show_line(i: int) -> void:
	_label.text = LINES[i]
	_timer = 0.0

func _finish() -> void:
	if _finished:
		return
	_finished = true
	get_tree().change_scene_to_file(NEXT_SCENE)
