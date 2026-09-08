extends CanvasLayer
## 획득한 아이템을 화면 좌상단에 상시 표시하는 인벤토리 UI (사람 피드백,
## 2026-09-08 — "획득한 아이템은 적절한 위치(좌상단?)에 쌓여야함... 이후
## 이벤트에서 다시 쓰일 일 없는 아이템이라면 제거"). 챕터 1은 열쇠/나무패
## 두 개뿐이고 둘 다 일기 개봉(diary_opened) 시점에 함께 쓰여서 소진되므로,
## 그 시점에 한꺼번에 지운다 — 아이템이 늘어나면 슬롯을 더 추가할 것.

@onready var _key_slot: Control = $KeySlot
@onready var _stamp_slot: Control = $StampSlot

func _process(_delta: float) -> void:
	var consumed := Chapter1Progress.diary_opened
	_key_slot.visible = Chapter1Progress.has_key and not consumed
	_stamp_slot.visible = Chapter1Progress.has_stamp and not consumed
