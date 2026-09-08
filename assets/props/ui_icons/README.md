# assets/props/ui_icons/ — UI 아이콘 자리표시(placeholder)

`tools/gen_item_icons.gd`로 절차적 생성한 32×32 단색 사각형 + 테두리
아이콘. 아이템 획득 팝업(`scripts/item_popup.gd`)과 인벤토리 UI
(`scripts/inventory_ui.gd`)에서 쓴다.

**전부 임시 아트**다 — 캐릭터 아트와 같은 정책(기능 구현 우선, 실제
아이콘은 나중에 검수 단계에서 교체). 실제 아이콘으로 교체되면 이
폴더와 `tools/gen_item_icons.gd`는 지워도 된다.

## 파일

| 파일 | 색 | 용도 |
|---|---|---|
| `key_icon.png` | 금색 칠 + 어두운 갈색 테두리 | 사방치기에서 얻는 열쇠 (`hopscotch_key.gd`) |
| `stamp_icon.png` | 갈색 칠 + 어두운 갈색 테두리 | 장독에서 얻는 나무패 (`jar_stamp.gd`) |

새 아이템 아이콘이 필요하면 `tools/gen_item_icons.gd`의 `_icons`
딕셔너리에 `이름: [칠 색, 테두리 색]`을 추가하고 재실행할 것.
