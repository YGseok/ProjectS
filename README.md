# ProjectS — 구조 안내

옴니버스 호러 어드벤처 게임 프로젝트 + AI 자율 개발 루프 스캐폴딩.

**설치 위치: `D:\Claude\ProjectS`**

```
docs/
  DESIGN.md          # 무엇을 만드는가, 완료 기준 (사람이 채움, 거의 안 바뀜)
  STATUS.md          # 지금 위치 / 다음 할 일 큐 / 완료 기록 (매 이터레이션 갱신)
  feedback/
    INBOX.md         # 사람의 지시/피드백 큐 (최우선)
qa/
  QACapture.tscn/.gd # 시각 QA 부트스트랩 씬 — GAME_START 씬을 로드→대기→PNG 저장→종료
  run_qa.sh          # import 1회 → 실제 창 실행 → PNG 저장
  output/            # 캡처된 스크린샷 (git 추적 안 함)
  README.md          # QA 도구 상세 사용법 (Windows 사용법 포함)
loop/
  loop.sh            # Claude Code(-p, 헤드리스, 매번 새 세션)를 무한 반복 실행
  PROMPT.md           # 매 이터레이션 -p 로 전달되는 지시문
  STOP                # 이 파일이 생기면 루프가 멈춘다 (기본적으로 없음)
  logs/               # 이터레이션별 실행 로그
scenes/
  dungeon.tscn        # 플레이스홀더 씬 (GAME_START=dungeon 동작 확인용)
project.godot         # 최소 플레이스홀더. 기존 프로젝트가 있다면 병합만 할 것
```

## 설치 방법 (Windows)

1. 압축을 풀어서 나온 `ProjectS` 폴더를 그대로 `D:\Claude\ProjectS` 위치에
   둔다 (즉 최종 경로가 `D:\Claude\ProjectS\project.godot` 가 되어야 함).
2. 이미 진행 중인 Godot 프로젝트가 있다면 `docs/`, `qa/`, `loop/`,
   `scenes/dungeon.tscn`, `.gitignore` 만 그 프로젝트에 병합하고
   `project.godot`는 덮어쓰지 않는다.
3. **Git Bash** 또는 **WSL**을 열어서 그 폴더로 이동:
   ```bash
   cd /d/Claude/ProjectS
   ```
4. QA 도구가 잘 동작하는지 먼저 손으로 확인:
   ```bash
   GAME_START=dungeon ./qa/run_qa.sh
   ```
   `qa/output/dungeon.png` 가 생성되면 성공. 열어서 실제로 눈으로 확인할 것.
   (Godot 실행 파일이 PATH에 없다면 `GODOT_BIN` 환경변수로 지정 —
   `qa/README.md`의 Windows 참고 섹션 확인.)
5. `docs/DESIGN.md` 를 읽고 프로젝트 구체 사항이 더 필요하면
   `docs/feedback/INBOX.md` 에 지시를 적는다.
6. 루프 시작:
   ```bash
   ./loop/loop.sh
   ```
7. 멈추고 싶으면:
   ```bash
   touch loop/STOP
   ```

## 요구사항

- Godot 4.x (`godot4` 또는 `godot4.exe` 실행 파일. PATH에 없다면 `GODOT_BIN` 지정)
- Claude Code CLI (`claude` 명령. PATH에 없다면 `CLAUDE_BIN` 지정)
- Windows에서 `qa/run_qa.sh`, `loop/loop.sh` 실행을 위한 **Git Bash 또는 WSL**
