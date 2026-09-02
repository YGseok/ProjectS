#!/usr/bin/env bash
# qa/run_qa.sh — 시각 QA 캡처 실행 스크립트
#
# 사용법:
#   GAME_START=dungeon ./qa/run_qa.sh [프레임수] [출력경로]
#   QA_FRAME=45 QA_OUTPUT=/tmp/out.png GAME_START=dungeon ./qa/run_qa.sh
#
# 3단계:
#   1) import   — 리소스를 1회 임포트 (헤드리스, 화면 없음, .godot/imported 생성)
#   2) 실행     — 실제 창(가능하면 Xvfb 가상 디스플레이)을 띄워 지정 씬 로드
#   3) 저장     — 지정 프레임에서 PNG로 뷰포트를 저장하고 즉시 종료
#
# 필요 환경변수:
#   GAME_START   (필수) 씬 키. res://scenes/<key>.tscn 규칙으로 매핑됨
#   QA_FRAME     (선택) 캡처 전 대기할 프레임 수. 기본 30. 위치 인자 $1로도 지정 가능
#   QA_OUTPUT    (선택) 출력 PNG 경로. 기본 qa/output/<key>.png. 위치 인자 $2로도 지정 가능
#   QA_SCENE_PATH(선택) res://scenes/<key>.tscn 규칙을 무시하고 직접 씬 경로 지정
#   GODOT_BIN    (선택) godot 실행 파일 이름/경로. 기본 godot4
#                       Windows에서는 보통 godot4.exe (GODOT_BIN=godot4.exe 로 지정)
#
# Windows 참고: 이 스크립트는 bash 스크립트이므로 Git Bash 또는 WSL에서 실행하세요.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot4}"

if [[ -z "${GAME_START:-}" ]]; then
  echo "[QA] 오류: GAME_START 환경변수를 지정하세요. 예) GAME_START=dungeon $0" >&2
  exit 1
fi

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  echo "[QA] 오류: '$GODOT_BIN' 실행 파일을 찾을 수 없습니다. GODOT_BIN 환경변수로 경로를 지정하세요." >&2
  echo "[QA]       (Windows 예: GODOT_BIN=\"/c/Path/To/Godot_v4.x.exe\")" >&2
  exit 1
fi

export QA_FRAME="${QA_FRAME:-${1:-30}}"
export QA_OUTPUT="${QA_OUTPUT:-${2:-$PROJECT_DIR/qa/output/${GAME_START}.png}}"

mkdir -p "$(dirname "$QA_OUTPUT")"

echo "[QA] 프로젝트 경로 : $PROJECT_DIR"
echo "[QA] GAME_START    : $GAME_START"
echo "[QA] QA_FRAME       : $QA_FRAME"
echo "[QA] QA_OUTPUT       : $QA_OUTPUT"

echo "[QA] (1/3) 리소스 임포트 중 (헤드리스)..."
IMPORT_LOG="$(mktemp)"
if ! "$GODOT_BIN" --headless --editor --quit-after 60 --path "$PROJECT_DIR" >"$IMPORT_LOG" 2>&1; then
  echo "[QA] 경고: 임포트 단계가 0이 아닌 코드로 종료됨. 로그 확인:" >&2
  tail -n 40 "$IMPORT_LOG" >&2 || true
  echo "[QA] (참고) 이미 임포트된 프로젝트라면 이 경고는 무시해도 되는 경우가 많습니다." >&2
fi

RUN_CMD=("$GODOT_BIN" --path "$PROJECT_DIR" "res://qa/QACapture.tscn")

echo "[QA] (2/3) 실제 창을 띄워 실행 및 캡처..."
if [[ -n "${DISPLAY:-}" ]]; then
  "${RUN_CMD[@]}"
elif command -v xvfb-run >/dev/null 2>&1; then
  xvfb-run -a --server-args="-screen 0 1280x720x24" "${RUN_CMD[@]}"
else
  # Windows(Git Bash)에서는 DISPLAY/xvfb 개념이 없고, Godot가 알아서
  # 실제 OS 창을 띄운다. 이 분기는 정상 동작 경로다.
  "${RUN_CMD[@]}"
fi

echo "[QA] (3/3) 결과 확인..."
if [[ -f "$QA_OUTPUT" ]]; then
  echo "[QA] 성공: 스크린샷이 저장되었습니다 -> $QA_OUTPUT"
  exit 0
else
  echo "[QA] 실패: 출력 파일을 찾을 수 없습니다 -> $QA_OUTPUT" >&2
  exit 1
fi
