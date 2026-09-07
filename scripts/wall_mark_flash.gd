extends Node2D
## 벽에 아주 잠깐 스치듯 보였다 사라지는 낙서 (분필 손바닥 자국 + 숫자를
## 세던 흔적, DESIGN.md §7.1 4단계). 반복되거나 위치가 바뀌는 기믹이
## 아니라 floorboard.gd의 일기 개봉 시퀀스에서 딱 한 번만 flash()된다.

@export var flash_seconds: float = 0.2

func _ready() -> void:
	visible = false

func flash() -> void:
	visible = true
	await get_tree().create_timer(flash_seconds).timeout
	visible = false
