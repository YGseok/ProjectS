# RESOURCE_LIST.md — 필요 리소스 목록

마지막 갱신: 2026-10-06 (v0.37 기준 전수 점검)

## ID 규칙

`분류-NNN` 형식. 앞 두 글자로 분류를 나누고, 백의 자리로 하위 대역을 나눈다.
번호는 한 번 붙이면 재사용하지 않는다(폐기돼도 결번으로 둠). 대역당 99개.

| 접두 | 분류 | 대역 |
|---|---|---|
| **CH** | 캐릭터 | `1xx` 주인공 · `2xx` 일상 NPC · `3xx` 스토리 인물 · `4xx` 꿈속 존재/왜곡 인물 |
| **MP** | 맵 | `1xx` 바닥 타일 · `2xx` 벽/건물/지붕 · `3xx` 물/지형 · `4xx` 배경·연출 화면 |
| **OB** | 오브젝트 | `1xx` 자연물 · `2xx` 생활 소품 · `3xx` 퍼즐/키 아이템 · `4xx` 단서/스토리 오브젝트 · `5xx` 공포 연출 |
| **UI** | UI | `1xx` 인벤토리/아이템 아이콘 · `2xx` 미니맵 · `3xx` HUD/패널/대화창 |

새 분류가 필요하면(예: 이펙트 `FX`) 이 표에 먼저 추가하고 쓴다.

상태: `적용됨` · `부분 적용` · `재발주 필요` · `발주 대기`(발주서에 넣을 준비 됨) · `발주됨(ORDER-NNN)` ·
`적용 대기`(이미 받은 시트에 그림이 있음, 잘라 붙이기만 하면 됨) · `보류`(기획 미정)

---

## CH — 캐릭터

| ID | 리소스 | 파일 | 원본 | 상태 | 메모 |
|---|---|---|---|---|---|
| CH-101 | 주인공 4방향(정지) | `sprites/characters/player/player_{down,left,right,up}.png` | pc001 | 적용됨 | 흰 원피스 10세 여아, 70 px |
| CH-102 | 주인공 걷기 애니메이션 | — | pc001 | 적용 대기 | pc001이 3열×4행 걷기 시트인데 가운데 프레임만 사용 중. 좌우 프레임 잘라 `player.gd`에 애니메이션 추가 |
| CH-201 | 지팡이 할아버지 | `sprites/characters/npc/grandpa_cane.png` | npc001~003 | 부분 적용 | 정면만. 측면/뒷면은 원본에 있음(적용 대기) |
| CH-202 | 앞치마 아저씨 | `sprites/characters/npc/ajusshi_apron.png` | npc001~003 | 부분 적용 | 〃 |
| CH-203 | 조끼 할머니 | `sprites/characters/npc/grandma_vest.png` | npc001~003 | 부분 적용 | 〃 |
| CH-204 | 갈색 머리 여자아이 | `sprites/characters/npc/girl_brown.png` | npc001~003 | 부분 적용 | 〃 |
| CH-301 | 언니 (환상) | — | — | 보류 | DESIGN §2/§5. 등장 시점·형태 미정 |
| CH-302 | 계모 (현실) | — | — | 보류 | DESIGN §2.4 |
| CH-303 | 계모 (꿈속 실체화) | — | — | 보류 | DESIGN §4.2 "추악하게 실체화된 계모" — 현실판과 같은 모습이라는 보장 없음 |

## MP — 맵

`tiles/village/village_tiles.png` 한 장에 슬롯 순서대로 들어 있음(0~7).

| ID | 리소스 | 파일 / 슬롯 | 원본 | 상태 | 메모 |
|---|---|---|---|---|---|
| MP-101 | 잔디 | village_tiles #0 | asset001 | 적용됨 | |
| MP-102 | 밭(흙) | village_tiles #1 | asset001 | 적용됨 | |
| MP-103 | 마루 | village_tiles #5 | asset002 | 적용됨 | |
| MP-104 | 원두막 바닥 | village_tiles #6 | asset002 | 적용됨 | |
| MP-105 | 방바닥 | village_tiles #7 | asset002 | 적용됨 | |
| MP-201 | 돌담 벽 | village_tiles #3 | asset001 | 적용됨 | |
| MP-202 | 기와지붕 타일 | village_tiles #4 | asset004 | 적용됨 | |
| MP-203 | 원두막 지붕(분리 스프라이트) | — | — | 보류 | "건물 뒤" 오클루전 리빌용. 지붕이 타일이면 반투명 처리 불가 — 구현 방침 정해지면 발주 |
| MP-301 | 호수 물 | village_tiles #2 | asset004 | 적용됨 | |
| MP-401 | 챕터 종료 화면 배경 | — | — | 보류 | 지금은 검은 화면+텍스트(의도된 최소 구성) |

## OB — 오브젝트

| ID | 리소스 | 파일 | 원본 | 상태 | 메모 |
|---|---|---|---|---|---|
| OB-101 | 큰 나무 | `props/nature/tree_green.png` | asset001 | 적용됨 | 140×215 |
| OB-102 | 작은 나무 | `props/nature/tree_small.png` | asset001 | 적용됨 | 150×165 |
| OB-103 | 열매 덤불 | `props/nature/bush_berry.png` | asset001 | **재발주 필요** | v0.37 QA: 오른쪽 세로 잘림 + 점 자국. 140×170. 챕터1 꿈/일상/챕터2 사용 |
| OB-201 | 장독 | `props/main_tileset_props/jar.png` | asset001 | 적용됨 | 48×48 |
| OB-301 | 공기돌 | `props/main_tileset_props/gonggi_stone.png` | asset002 | 적용됨 | 챕터1 퍼즐 |
| OB-302 | 사방치기 | `props/main_tileset_props/hopscotch.png` | asset002 | **재발주 필요** | v0.37 QA: 위쪽 반원 잘림 + 나무 가지에 가려짐. 155×210, 땅에 그린 분필 그림 |
| OB-303 | 헐거운 마루판 | `props/main_tileset_props/floorboard_loose.png` | asset002 | 적용됨 | 48×48 |
| OB-304 | 삐걱임 발판 | `props/main_tileset_props/creaky_plate.png` | asset004 | 적용됨 | 48×48 |
| OB-305 | 조각(깨진 동전) | `props/main_tileset_props/fragment_item.png` | asset002 | 적용됨 | 챕터2/3 KeyItemA/B/C 셋 다 이것 재사용 중 → OB-306~308로 대체 예정 |
| OB-306 | 조각 A | — | — | 발주 대기 | 서로 구분되는 모양 3종, 각 48~64 px. 어떤 사물로 할지 시놉시스에서 골라 제안 필요 |
| OB-307 | 조각 B | — | — | 발주 대기 | 〃 |
| OB-308 | 조각 C | — | — | 발주 대기 | 〃 |
| OB-309 | 탈출문 | `props/main_tileset_props/exit_door.png` | asset004 | 적용됨 | 챕터2/3, 60×85 |
| OB-401 | 단서: 종이 | `props/main_tileset_props/clue_paper.png` | asset004 | 적용됨 | 일상 파트 ClueChapter1 |
| OB-402 | 단서: 마루 밑 | `props/main_tileset_props/clue_underfloor.png` | asset004 | 적용됨 | 일상 파트 ClueChapter2 |
| OB-501 | 벽 낙서 "미워" | `props/main_tileset_props/wall_scribble.png` | asset004 | 적용됨 | WallMarkFlash |

## UI

| ID | 리소스 | 파일 | 원본 | 상태 | 메모 |
|---|---|---|---|---|---|
| UI-101 | 열쇠 아이콘 | `props/ui_icons/key_icon.png` | asset002 | 적용됨 | 32×32 |
| UI-102 | 나무패(도장) 아이콘 | `props/ui_icons/stamp_icon.png` | asset002 | 적용됨 | 32×32 |
| UI-201 | 미니맵 플레이어 | `props/ui_icons/mm_player.png` | asset004 | 적용됨 | 10×10 |
| UI-202 | 미니맵 NPC | `props/ui_icons/mm_npc.png` | asset004 | 적용됨 | 10×10 |
| UI-203 | 미니맵 벽 | `props/ui_icons/mm_wall.png` | asset004 | 적용됨 | 10×10 |

---

## 후보 (ID 미부여)

DESIGN §5 / 시놉시스 2026-09-07 §1.D의 공포 소재. 챕터 설계에서 채택되면 해당 대역에서 ID를 받아 위 표로 올린다.

| 소재 | 예정 대역 | 예상 리소스 |
|---|---|---|
| 벽을 빼곡히 채운 공포 낙서 | OB-5xx | 벽 오버레이 여러 장(OB-501 "미워"의 확장판) |
| 나무에 걸린 옷가지 | OB-5xx | 나무에 겹쳐 놓는 옷 스프라이트 |
| 자신을 쳐다보는 군중 | CH-4xx | 얼굴 없는 실루엣 인물 여러 명 |
| 농담하는 마을 어른 | CH-4xx | 기존 NPC(CH-2xx)의 꿈속 왜곡판 |
| 서낭당 + 방울 | MP-2xx / OB-5xx | 돌무더기+오색천 나무, 방울 소품 |
| 일기장 | OB-4xx + UI-1xx | DESIGN §2.3 핵심 오브젝트 — 필드 소품 + 인벤토리 아이콘 |
