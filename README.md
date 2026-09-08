# ProjectS — 구조 안내

한국 호러 어드벤처 게임 프로젝트 (Godot 4.x) + AI 자율 개발 루프 스캐폴딩.

**설치 위치: `D:\Claude\ProjectS`**

```
docs/
  DESIGN.md          # 무엇을 만드는가, 완료 기준 (사람이 채움, 거의 안 바뀜)
  STATUS.md          # 지금 위치 / 다음 할 일 큐 / 완료 기록 (매 이터레이션 갱신)
  feedback/
    INBOX.md         # 사람의 지시/피드백 큐 (최우선)
  scenario/          # GPT 등 외부에서 정리 중인 스토리 시놉시스 (날짜별 .md)
qa/
  QACapture.tscn/.gd # 시각 QA 부트스트랩 씬 — GAME_START 씬을 로드→대기→PNG 저장→종료
  run_qa.sh          # import 1회 → 실제 창 실행 → PNG 저장 (시각 확인용)
  output/            # 캡처된 스크린샷 (git 추적 안 함)
  README.md          # QA 도구 + 자동 상호작용 테스트 상세 사용법
tests/
  test_*.gd          # 헤드리스 자동 상호작용/유닛 테스트 (키 입력 시뮬레이션)
  run_all.sh         # tests/ 안의 test_*.gd 전부 실행 + 통과/실패 요약
loop/
  loop.sh            # Claude Code(-p, 헤드리스, 매번 새 세션)를 무한 반복 실행
  PROMPT.md           # 매 이터레이션 -p 로 전달되는 지시문
  STOP                # 이 파일이 생기면 루프가 멈춘다 (기본적으로 없음)
  logs/               # 이터레이션별 실행 로그
scenes/
  chapter1_intro.tscn # 챕터 1 프롤로그 (자동 재생 + 스킵 가능한 인트로)
  chapter1_real.tscn  # 챕터 1 현실 파트
  chapter1_dream.tscn # 챕터 1 꿈 파트
  chapter1_end.tscn   # 챕터 1 종료 화면 (챕터 2 없어서 최소 임시 상태)
  common/             # 재사용 컴포넌트 (대화창, NPC, 낮잠/각성 트리거, 페이드,
                      #   아이템 팝업, 인벤토리 UI, 목표 힌트)
  test/               # 파이프라인/타일셋 검증용 임시 테스트 씬
  dungeon.tscn        # QA 도구 동작 확인용 최소 플레이스홀더
scripts/              # 게임 코드 (플레이어, NPC, 대화 시스템, 배경, 챕터 1 퍼즐,
                      #   인벤토리/팝업/힌트 UI, 발판 컴포넌트 등)
shaders/              # 커스텀 셰이더 (나무 오클루전 반투명 리빌 등)
assets/
  tiles/main/         # 메인 배경 타일셋 (라이선스: THIRD_PARTY_LICENSES 참고)
  props/nature/       # 마당 장식용 자연 오브젝트
  props/main_tileset_props/  # 챕터 1 퍼즐 소품(장독/공기돌 등) 크롭본
  props/ui_icons/     # 아이템 팝업/인벤토리용 자리표시 아이콘
  sprites/            # 캐릭터 스프라이트 (확정된 주인공 아트는 아직 없음)
  THIRD_PARTY_LICENSES/  # 외부 에셋 라이선스 원문
tools/
  *.gd + README.md    # 에셋 준비/점검용 헤드리스 일회성 스크립트 모음
Setting/              # 여러 PC 간 Claude 메모리/설정 동기화 (CLAUDE.md 참고)
project.godot
```

## 개발 워크플로 요약

1. 작업 전 `docs/DESIGN.md` → `docs/STATUS.md` → `docs/feedback/INBOX.md`
   순서로 읽는다 (INBOX가 최우선).
2. 씬/코드를 고쳤으면:
   - **시각 확인**: `GAME_START=<씬키> ./qa/run_qa.sh` 로 스크린샷을 찍어
     직접 눈으로 확인한다.
   - **입력 반응 확인**: 방향키/Enter 같은 입력에 반응하는 로직을 새로
     만들었다면 `tests/`에 자동 테스트를 추가하고 `./tests/run_all.sh`
     로 전체를 재확인한다 (정적 스크린샷만으로는 키 입력 반응을 검증
     못 함).
3. `docs/STATUS.md`를 다음 세션(기억 없음)에게 남기는 인수인계서로
   갱신한다 — 지금 위치, 다음 할 일 큐, 완료 기록.

## 빠른 시작 (Windows)

1. **Git Bash** 또는 **WSL**을 열어서 프로젝트 폴더로 이동:
   ```bash
   cd /d/Claude/ProjectS
   ```
2. QA 도구가 잘 동작하는지 확인:
   ```bash
   GAME_START=chapter1_real ./qa/run_qa.sh
   ```
   `qa/output/chapter1_real.png` 가 생성되면 성공. 열어서 실제로 확인할 것.
   (Godot 실행 파일이 PATH에 없다면 `GODOT_BIN` 환경변수로 지정 —
   `qa/README.md`의 Windows 참고 섹션 확인.)
3. 자동 테스트 전체 실행:
   ```bash
   ./tests/run_all.sh
   ```
4. `docs/DESIGN.md`를 읽고 지시가 있으면 `docs/feedback/INBOX.md`에 적는다.
5. (선택) 자율 루프 시작:
   ```bash
   ./loop/loop.sh
   ```
   멈추려면: `touch loop/STOP`

## 요구사항

- Godot 4.x (`godot4` 또는 `godot4.exe` 실행 파일. PATH에 없다면 `GODOT_BIN` 지정)
- Claude Code CLI (`claude` 명령. PATH에 없다면 `CLAUDE_BIN` 지정, `loop/loop.sh` 사용 시에만 필요)
- Windows에서 `qa/run_qa.sh`, `tests/run_all.sh`, `loop/loop.sh` 실행을 위한
  **Git Bash 또는 WSL**
