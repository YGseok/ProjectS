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
(`docs/DESIGN.md` §3 참고).
