# 시각 QA 도구

AI(또는 사람)가 자기가 만든 화면을 직접 "눈으로" 확인하기 위한 도구.
루프의 각 이터레이션은 코드/씬을 고친 뒤 이 도구로 실제 스크린샷을 찍어야 한다.

## 빠른 사용법

```bash
GAME_START=dungeon ./qa/run_qa.sh
```

- `res://scenes/dungeon.tscn` 을 로드
- 30프레임(기본값) 대기
- `qa/output/dungeon.png` 로 저장 후 종료

여러 씬을 한 번에 확인하려면:

```bash
./qa/run_all.sh
```

알려진 씬 목록(`qa/run_all.sh` 안의 `SCENES` 배열)을 순서대로 캡처하고
성공/실패 개수를 요약한다. 새 씬을 추가했으면 그 배열에 한 줄 추가할 것.
**주의**: exit 0는 "크래시 없이 PNG가 저장됐다"는 뜻일 뿐, 화면이 실제로
맞게 나왔는지는 여전히 `qa/output/`의 PNG를 직접 봐야 안다.

## 환경변수

| 변수            | 필수 | 기본값                          | 설명                                             |
|-----------------|------|----------------------------------|--------------------------------------------------|
| `GAME_START`    | O    | -                                 | 시작 씬 키. `res://scenes/<key>.tscn` 로 매핑됨   |
| `QA_FRAME`      | X    | `30`                              | 캡처 전 대기 프레임 수 (위치 인자 `$1`로도 가능)   |
| `QA_OUTPUT`     | X    | `qa/output/<key>.png`             | 출력 PNG 경로 (위치 인자 `$2`로도 가능)            |
| `QA_SCENE_PATH` | X    | -                                 | `res://scenes/<key>.tscn` 규칙을 무시하고 직접 지정 |
| `GODOT_BIN`     | X    | `godot4`                          | Godot 실행 파일 이름/경로 (Windows: `godot4.exe` 또는 전체 경로) |

예시:

```bash
# 다른 프레임에서 캡처
GAME_START=chapter1 QA_FRAME=90 ./qa/run_qa.sh

# 규칙에서 벗어난 씬 직접 지정
GAME_START=boss_intro QA_SCENE_PATH=res://scenes/cutscenes/boss_intro.tscn ./qa/run_qa.sh

# 출력 경로를 이터레이션별로 구분해서 보관하고 싶을 때
GAME_START=dungeon QA_OUTPUT=qa/output/dungeon_iter12.png ./qa/run_qa.sh
```

## Windows 사용 시 참고 (D:\Claude\ProjectS)

- `qa/run_qa.sh`, `loop/loop.sh`는 bash 스크립트다. **Git Bash** 또는 **WSL**에서
  실행해야 한다 (더블클릭 실행 X, cmd/PowerShell 그대로 실행 X).
- Godot 실행 파일 경로가 PATH에 없다면 매번 지정하기보다:
  ```bash
  export GODOT_BIN="/c/Program Files/Godot/Godot_v4.3-stable_win64.exe"
  ```
  같은 식으로 `~/.bashrc`에 등록해두면 편하다.
- Windows Git Bash에는 `DISPLAY`/`xvfb` 개념이 없다 — Godot가 알아서 실제
  OS 창을 띄우므로 정상 동작한다 (스크립트의 마지막 분기가 이 경우를 처리).

## 왜 실제 창을 띄우는가

`--headless` 로 완전히 돌리면 더미 렌더링 드라이버가 사용되어 실제 시각적
결과(조명, 셰이더, UI 배치 등)를 신뢰할 수 없다. 그래서:

1. **임포트만** 헤드리스로 1회 수행 (`--headless --editor --quit-after N`) —
   `.godot/imported` 캐시를 만들어 이후 실행이 빨라지고 안정적이게 함.
2. **실제 실행/캡처**는 창을 띄운 상태로 진행. 리눅스 서버/컨테이너
   환경이라면 `xvfb-run` (가상 프레임버퍼)을 자동으로 사용한다.
   설치: `apt-get install -y xvfb`

## 동작 원리

`qa/QACapture.tscn` (+ `qa/QACapture.gd`) 이 부트스트랩 씬 역할을 한다.
프로젝트의 `run/main_scene` 을 바꾸지 않고, CLI에서 직접 이 씬을 지정해서
실행한다:

```bash
godot4 --path . res://qa/QACapture.tscn
```

이 씬은 `GAME_START` 에 해당하는 실제 게임 씬을 자식으로 로드하고,
지정된 프레임만큼 기다린 뒤 뷰포트를 PNG로 저장하고 종료한다.

## 실패 시 종료 코드

- 성공: `exit 0`, PNG 파일 존재
- 실패(씬 없음, 인스턴스화 실패, 저장 실패 등): `exit 1`, 에러 로그가
  stderr / Godot 콘솔 출력에 `[QA]` 접두어로 남음

이터레이션 루프는 이 exit code와 PNG 파일 존재 여부로 "완료" 여부를 1차
판단하고, 최종 판단은 사람이 스크린샷을 직접 보고 내린다
(`docs/DESIGN.md` §7.3 참고).

## 상호작용(키 입력) 자동 테스트 — `tests/`

이 도구는 **정적 스크린샷**만 확인한다 — 방향키를 눌러 실제로 이동하는지,
Enter로 NPC와 대화가 시작/진행/종료되는지 같은 **입력에 따른 동작**은
스크린샷만으로 검증 못 한다. 그런 상호작용은 `tests/`의 헤드리스
Godot 스크립트로 자동 검증한다 — 사람이 직접 키보드로 눌러볼 필요 없이,
`Input.parse_input_event()`로 실제 키 입력과 동일하게 시뮬레이션한다.

```bash
godot4 --headless --script res://tests/test_dialogue_interaction.gd --path .
```

전체 테스트를 한 번에 돌리려면 (테스트가 늘어날수록 유용):

```bash
./tests/run_all.sh
# 또는: GODOT_BIN=/c/Path/To/Godot.exe ./tests/run_all.sh
```

`tests/` 안의 `test_*.gd` 전부를 순서대로 실행하고 마지막에 통과/실패
개수와 실패한 테스트 이름을 요약해준다. 하나라도 실패하면 exit 1.

- 성공: 각 검증 단계가 `[TEST] PASS - ...`로 출력되고 마지막에
  `[TEST] ALL PASSED`, `exit 0`.
- 실패: 실패한 항목이 `[TEST] FAIL - ...`로 출력되고 `exit 1`.

### 새 상호작용 테스트를 만들 때 알아둘 것 (직접 겪은 함정)

- `SceneTree`를 상속한 스크립트를 `--script`로 실행하면, 프로젝트
  오토로드(예: `DialogueSystem`)가 **전역 식별자로는 컴파일이 안 된다**
  (`Identifier not found` 컴파일 에러). `get_tree().root.get_node("이름")`
  으로 직접 찾아서 써야 한다. (반면 일반 씬으로 로드되는 스크립트— 플레이어,
  NPC 스크립트 등 —에서는 오토로드 전역 식별자가 정상 작동한다. `--script`
  최상위 스크립트에서만 이 문제가 생긴다.)
- 이동처럼 **폴링 기반**(`Input.is_action_pressed`) 입력은 `Input.
  parse_input_event()`로 누른 뒤 최소 한 프레임을 기다려야 다음 로직이
  반응한다. 누르자마자 바로 떼면 반응하기 전에 릴리즈될 수 있으니, "눌렀다
  → 반응할 때까지(예: 이동 시작) 몇 프레임 대기 → 뗀다" 순서로 짜는 게
  안전하다.
- **같은 프레임 이중 트리거**에 주의: "가까이서 Enter로 상호작용 시작"과
  "Enter로 진행/종료" 를 같은 입력(`ui_accept`)으로 처리하면, 시작과 종료가
  같은 프레임에 겹칠 수 있다. 실제로 "대화를 닫는 그 Enter가 같은 프레임에
  NPC를 다시 트리거해 무한 재시작되는" 버그를 이 방식으로 잡아냈다
  (`scripts/dialogue_system.gd`의 `_started_frame`/`_ended_frame`,
  `scripts/npc.gd`의 `just_ended_this_frame()` 참고). 새 상호작용을 만들
  때도 "시작 프레임/종료 프레임"을 추적해서 같은 프레임 재진입을 막을 것.
- **타입이 안 맞는 배열을 넘기면 조용히 멈춰버린다**: 예를 들어
  `func f(lines: Array[String])`로 선언된 함수에 그냥 `[]`(타입 없는
  빈 배열 리터럴)를 넘기면 `SCRIPT ERROR: Invalid type...`가 찍히지만
  프로세스가 exit 하지 않고 그대로 멈춘다(타임아웃 전까지 응답 없음).
  깔끔하게 실패하지 않으니 헷갈리기 쉽다 — `var x: Array[String] = []`
  처럼 변수에 타입을 명시해서 넘길 것.
- **`get_first_node_in_group()`을 `_ready()`에서 한 번만 호출하면 씬
  트리 노드 순서에 몰래 의존하게 된다**: `_ready()`는 씬에 선언된
  순서대로 호출되므로, 찾으려는 그룹(예: `"player"`)의 노드가 아직
  `add_to_group()`을 안 한 시점(= 그 노드가 이 스크립트보다 씬 파일에서
  더 아래에 선언된 경우)이면 조회 결과가 계속 `null`로 고정된다. 크래시도
  안 나고 에러도 안 찍혀서 눈치채기 어렵다 — 이 프로젝트에서 최소 두 번
  겪었다(`occlusion_reveal_manager.gd`, `interactable_base.gd` — 둘 다
  나중에 씬에서 다른 노드 재배치를 하다가 우연히 드러남, STATUS.md
  2026-09-07 참고). **기본 패턴으로 삼을 것**: `_ready()`에서 한 번
  조회하지 말고, `_process()`에서 `if _x == null: _x =
  get_tree().get_first_node_in_group(...)`처럼 값이 없을 때마다
  다시 찾도록 짤 것 — 노드 선언 순서가 나중에 바뀌어도 안전하다.
- **테스트 안에서 시그널 카운터로 지역 `int` 변수를 쓰면 람다가 카운트를
  못 늘린다**: `var count := 0; signal.connect(func(): count += 1)`
  처럼 짜면, 람다가 실행돼서 `count`를 늘려도 바깥 스코프의 `count`는
  계속 0으로 보인다 — GDScript 람다가 지역 변수를 **값으로 캡처**하지
  참조로 공유하지 않기 때문(`test_pressure_plate.gd` 작성 중 발견,
  2026-09-08). 눌린 횟수/호출 횟수 같은 걸 시그널 콜백에서 세야 하면
  `var count := [0]`처럼 배열(참조 타입)에 담아 `count[0] += 1`로
  늘리고 `count[0]`으로 읽을 것.
