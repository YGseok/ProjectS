# tools/ — 헤드리스 Godot 일회성 스크립트 모음

전부 `SceneTree`를 상속하고 `godot4 --headless --script res://tools/<파일> --path <project>`
로 실행하는 일회성 도구다. 게임 코드가 아니라 에셋 준비/점검용.

`--script` 모드에서는 프로젝트 오토로드(예: `DialogueSystem`)가 **전역
식별자로 컴파일이 안 된다**(`Identifier not found` 오류) — 필요하면
`root.get_node_or_null("이름")`으로 찾을 것. 자세한 내용/예시는
`qa/README.md`의 "상호작용 자동 테스트" 절 참고 (그 함정은 `tests/`에서
발견됐지만 `tools/`의 `--script` 스크립트에도 똑같이 적용됨).

## 파일별 용도

| 파일 | 용도 | 상태 |
|---|---|---|
| `inspect_assets.gd` | 에셋 이미지들의 픽셀 크기 출력 (타일 그리드/스프라이트 프레임 크기 확인용). 매번 조사할 파일 목록을 코드에서 직접 수정해서 씀 | 재사용 중 |
| `build_main_tileset.gd` | `assets/tiles/main/`(A4·A5 시트)에서 고른 셀들로 `main_tileset.tres` 조립. 새 좌표를 추가하려면 여기 좌표 배열을 수정하고 재실행 | 재사용 중, `assets/tiles/main/main_tileset.tres` 생성원 |
| `build_interior_tileset.gd` | `assets/tiles/interior_test/`(엘프 소녀 데모 팩, 개별 PNG 파일들)로 `interior_test.tres` 조립 | `pipeline_test.tscn` 전용, 팩 자체가 파이프라인 검증용이라 더 안 씀 |
| `upscale_preview.gd` | 작은 도트 이미지를 최근접 보간으로 확대 저장 (컨펌용 미리보기) | `gen_player_sprite.gd`와 짝, 아래 참고 |
| `gen_player_sprite.gd` | 주인공 캐릭터 도트 스프라이트를 절차적(원/사각형 조합)으로 그려서 PNG 저장 | **중단됨** — 진짜 이미지 생성이 아니라 도형 조합이라 한계가 있어 v7까지 반복하다 접음 (STATUS.md 2026-09-04 참고). 캐릭터 아트는 외부 에셋으로 대체 예정. 코드는 도트 그리기 기법 참고용으로만 남겨둠 |

## 새 도구를 추가할 때

- 파일 이름과 한 줄 용도를 위 표에 추가할 것.
- 특정 에셋 좌표(타일 좌표, 크롭 범위 등)를 하드코딩하는 도구라면, 그
  결과물을 쓰는 쪽 폴더의 README에도 좌표 표를 남겨서(예:
  `assets/tiles/main/README.md`) 재실행 없이도 뭘 골랐는지 알 수 있게
  할 것.
- 순수 디버그용 크롭/미리보기 스크립트(예: 예전에 있던
  `crop_tile_preview.gd`)는 좌표를 다 찾고 나면 지워도 된다 — 결과
  좌표만 README에 남으면 충분하다.
