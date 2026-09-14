extends PressurePlate
class_name PressurePlateFlavor
## 순수 분위기용 발판 — 밟으면 짧은 대사 한 줄을 딱 한 번만 보여준다.
## 사람 피드백(2026-09-08 "인터렉션 오브젝트나 풋 스위치 등, 무언가가
## 더 필요하다", 2026-09-14 "레벨 디자인 및 배치는 임의로 일임")에
## 대한 대응 — `scenery_flavor.gd`와 같은 철학으로, 새로운 진상/사건이
## 아니라 순수 환경 디테일 텍스트만 추가한다. `one_shot`을 강제로 켜서
## 반복 트리거되지 않게 한다(문이 열리는 등 반복 가능한 효과가
## 필요해지면 `PressurePlate`를 직접 쓰는 별도 하위 클래스를 만들 것).

@export var line: String = "..."

func _ready() -> void:
	one_shot = true
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	DialogueSystem.start_dialogue([line])
