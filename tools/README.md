# tools/ — Godot 일회성 스크립트 모음

대부분 `SceneTree`를 상속하고 `godot4 --headless --script res://tools/<파일> --path <project>`
로 실행하는 일회성 도구다. 게임 코드가 아니라 에셋 준비/점검용.

예외로 `verify_occlusion.gd`처럼 실제 렌더링 픽셀을 캡처해야 하는 도구는
`--headless` 없이 창모드로 실행해야 한다 (헤드리스는 더미 렌더러라
`get_texture().get_image()`가 null). **창모드에서 실행할 때는 반드시
`--script` 플래그를 명시할 것** — `godot4 --path <project> res://tools/x.gd`
처럼 스크립트 경로를 위치 인자로만 주면(플래그 없이) 조용히 아무 로직도
실행하지 않고 바로 종료해버리는 경우가 있었다(정상 종료 코드 0, 로그도
전혀 안 남음 — 스크립트가 아예 실행 안 됐다는 신호). 또한 창모드 stdout이
안정적으로 안 잡힐 때가 있어서, 이런 스크립트는 `res://qa/output/`에
자체 로그 파일도 같이 남기는 패턴을 쓴다(`verify_occlusion.gd` 참고).

`--script` 모드에서는 프로젝트 오토로드(예: `DialogueSystem`)가 **전역
식별자로 컴파일이 안 된다**(`Identifier not found` 오류) — 필요하면
`root.get_node_or_null("이름")`으로 찾을 것. 자세한 내용/예시는
`qa/README.md`의 "상호작용 자동 테스트" 절 참고 (그 함정은 `tests/`에서
발견됐지만 `tools/`의 `--script` 스크립트에도 똑같이 적용됨).

## 파일별 용도

| 파일 | 용도 | 상태 |
|---|---|---|
| `verify_occlusion.gd` | 플레이어를 나무 캐노피/밑둥 뒤로 이동시킨 뒤 실제 창을 캡처해서 오클루전 반투명 리빌 셰이더가 시각적으로 동작하는지 확인 (`res://qa/output/occlusion_check.png` + `occlusion_log.txt`). **창모드 전용**(헤드리스 불가), 실행 시 `--script` 플래그 필수 | 재사용 중 — 나무 오클루전 확인용으로 작성했지만 건물/원두막 지붕 등 다른 오브젝트 검증에도 좌표만 바꿔서 재사용 가능 |

## 새 도구를 추가할 때

- 파일 이름과 한 줄 용도를 위 표에 추가할 것. (실제로 `crop_outside_props.gd`
  를 추가하고 이 표를 안 고쳐서 한동안 빠져 있었던 적이 있다 — 도구를
  만든 바로 그 이터레이션에서 표까지 같이 갱신할 것.)
- 특정 에셋 좌표(타일 좌표, 크롭 범위 등)를 하드코딩하는 도구라면, 그
  결과물을 쓰는 쪽 폴더의 README에도 좌표 표를 남겨서(예:
  `assets/tiles/main/README.md`) 재실행 없이도 뭘 골랐는지 알 수 있게
  할 것.
- 순수 디버그용 크롭/미리보기 스크립트(예: 예전에 있던
  `crop_tile_preview.gd`)는 좌표를 다 찾고 나면 지워도 된다 — 결과
  좌표만 README에 남으면 충분하다.
