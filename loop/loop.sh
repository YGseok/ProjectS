#!/usr/bin/env bash
# loop/loop.sh — Claude Code를 "기억 없는" 새 헤드리스 세션(-p)으로
# 무한 반복 실행한다.
#
# 핵심 원칙: --continue 를 쓰지 않는다. 매 이터레이션은 완전히 독립적인
# 새 세션이며, 모든 문맥은 docs/DESIGN.md, docs/STATUS.md,
# docs/feedback/INBOX.md 세 파일로만 전달된다 (loop/PROMPT.md 가 이 세 파일을
# 먼저 읽으라고 지시한다).
#
# 중단: loop/STOP 파일을 만들면, 현재 이터레이션이 끝난 뒤 다음 이터레이션을
# 시작하지 않고 종료한다.
#
# 사용법 (Git Bash / WSL):
#   ./loop/loop.sh
#   LOOP_SLEEP_SECONDS=10 ./loop/loop.sh
#   CLAUDE_BIN=/c/path/to/claude.exe ./loop/loop.sh
#
# 멈추기:
#   touch loop/STOP
#
# 다시 시작하려면 STOP 파일을 지우고 스크립트를 다시 실행:
#   rm loop/STOP && ./loop/loop.sh

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOOP_DIR="$PROJECT_DIR/loop"
LOG_DIR="$LOOP_DIR/logs"
STOP_FILE="$LOOP_DIR/STOP"
PROMPT_FILE="$LOOP_DIR/PROMPT.md"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
SLEEP_BETWEEN="${LOOP_SLEEP_SECONDS:-5}"

mkdir -p "$LOG_DIR"

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "[LOOP] 오류: 프롬프트 파일이 없습니다: $PROMPT_FILE" >&2
  exit 1
fi

if ! command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
  echo "[LOOP] 오류: '$CLAUDE_BIN' 실행 파일을 찾을 수 없습니다. CLAUDE_BIN 환경변수로 경로를 지정하세요." >&2
  exit 1
fi

echo "[LOOP] 프로젝트: $PROJECT_DIR"
echo "[LOOP] 중단하려면: touch $STOP_FILE"

PROMPT_CONTENT="$(cat "$PROMPT_FILE")"

iteration=0
while true; do
  if [[ -f "$STOP_FILE" ]]; then
    echo "[LOOP] STOP 파일 발견 ($STOP_FILE). 루프를 시작하지 않고 종료합니다."
    break
  fi

  iteration=$((iteration + 1))
  ts="$(date +%Y%m%d_%H%M%S)"
  log_file="$LOG_DIR/iter_${iteration}_${ts}.log"

  echo "[LOOP] === 이터레이션 #$iteration 시작 ($ts) ==="
  echo "[LOOP] 로그: $log_file"

  # --continue 사용 금지: 매번 완전히 새로운, 이전 기억이 없는 세션.
  (
    cd "$PROJECT_DIR" && "$CLAUDE_BIN" -p "$PROMPT_CONTENT"
  ) >"$log_file" 2>&1
  exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    echo "[LOOP] === 이터레이션 #$iteration 종료 (성공) ==="
  else
    echo "[LOOP] === 이터레이션 #$iteration 종료 (exit=$exit_code, 로그 확인 요망) ==="
  fi

  if [[ -f "$STOP_FILE" ]]; then
    echo "[LOOP] STOP 파일 발견. 다음 이터레이션을 시작하지 않고 종료합니다."
    break
  fi

  sleep "$SLEEP_BETWEEN"
done

echo "[LOOP] 루프 종료됨. 다시 시작하려면: rm $STOP_FILE && $0"
