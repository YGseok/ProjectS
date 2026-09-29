# assets/ — 리소스 출처 (2026-09-21 전면 교체)

게임에 쓰이는 모든 이미지는 아래 **사람이 직접 제공한 원본 시트**에서 잘라낸 것이다
(외부 에셋 팩은 전부 제거함). 원본은 이 폴더 루트에 보관 — 다시 자르려면 여기서.

| 원본 | 내용 | 파생물 |
|---|---|---|
| `pc001.jpg` | 주인공 4방향(3열×4행 걷기 시트) | `sprites/characters/player/player_{down,left,right,up}.png` (가운데 열, 70px 높이) |
| `npc001.jpg` `npc002.jpg` `npc003.jpg` | NPC 여러 명(정면/측면/뒷면) | `sprites/characters/npc/` — 현재 4명 사용(grandpa_cane, ajusshi_apron, grandma_vest, girl_brown). npc002/003의 나머지 인물은 미사용 |
| `asset001.png` | 지형/작물/건물/울타리/소품 시트 | `tiles/village/village_tiles.png`(잔디·밭·물·벽·지붕), `props/nature/`(나무·덤불), `props/main_tileset_props/jar.png` |
| `asset002.png` (`asset003.png`는 동일 이미지) | 마을 멀티시트 A~F | `tiles/village/village_tiles.png`(마루·원두막바닥·방바닥), `props/main_tileset_props/{hopscotch,gonggi_stone,fragment_item}.png`, `props/ui_icons/{key,stamp}_icon.png` |

원본이 JPG이거나 배경에 회색 체크무늬가 픽셀로 박혀 있어서, 캐릭터/소품은 코너 flood-fill +
최대 연결 성분만 남기는 방식으로 배경을 제거했다(흙 배경 소품은 배경을 그대로 둠).
`village_tiles.png` 셀 순서: 0 grass, 1 dirt, 2 water, 3 wall, 4 roof, 5 floor_porch, 6 floor_gazebo, 7 floor_interior.

## 2026-09-29 추가분

| 원본 | 내용 | 파생물 |
|---|---|---|
| `asset004.png` | 호수 물/원두막 기와지붕 타일, 챕터2·3 탈출문, 일상 단서 2종, 벽 낙서("미워"), 마루 삐걱임 발판, 미니맵 아이콘 3종 | `tiles/village/village_tiles.png` 슬롯 2(water)·4(roof) 교체, `props/main_tileset_props/{exit_door,clue_paper,clue_underfloor,wall_scribble,creaky_plate}.png`, `props/ui_icons/mm_{player,npc,wall}.png` |

카드형 시트라 배경이 흰 바탕+어두운 회색 격자였음 — 흰색/검은 테두리/회색
격자 3가지 톤을 모두 배경으로 보고 제거(`asset001/002`의 체크무늬 제거와
다른 방식). `village_tiles.png` 슬롯 순서는 위 표와 동일하게 유지.
