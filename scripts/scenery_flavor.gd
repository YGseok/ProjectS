extends InteractableBase
class_name SceneryFlavor
## 재사용 가능한 배경 장식물 조사 컴포넌트 — 상태 변화 없는 순수 분위기
## 텍스트만 보여준다. 사람 피드백(2026-09-08, "인터렉션 오브젝트나 풋
## 스위치 등, 무언가가 더 필요하다")에 대한 안전한 대응 하나 — 새로운
## 진상/사건이 아니라 나무/덤불 같은 기존 배경 장식에 순수 환경 묘사
## 텍스트만 추가해서, 새 퍼즐 배치나 스토리 결정 없이도 조사할 거리를
## 늘린다. `lines`를 인스펙터에서 지정해서 여러 장식물에 재사용한다
## (gonggi_stones.gd처럼 전용 스크립트를 오브젝트마다 새로 만드는 대신).

@export var lines: Array[String] = ["..."]

func _ready() -> void:
	# 트렁크는 이미 전용 사각형으로 막혀 있다(chapter1_real.tscn의
	# CollisionMap 참고) — interactable_base.gd의 범용 "가장 가까운 칸"
	# 충돌을 여기서도 켜면 스프라이트 기준점이 타일 중심과 어긋나 있어서
	# 트렁크와 안 맞는 엉뚱한 칸이 막히는 부작용이 생긴다(2026-09-09).
	blocks_movement = false
	super._ready()

func _on_interact() -> void:
	DialogueSystem.start_dialogue(lines)
