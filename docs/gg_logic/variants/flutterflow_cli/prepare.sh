#!/usr/bin/env bash
set -euo pipefail

# Run from any directory. Default mode is a read + validated dry-run.
task_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
variants_root="$(cd -- "$task_dir/.." && pwd)"
variant="${1:-}"
case "$variant" in
  basic|rpc|admin) shift ;;
  *) printf '%s\n' 'Usage: prepare.sh basic|rpc|admin [--workspace DIR] [--project-id ID] [--offline-snapshot FILE] [--apply --backup-commit ID]'; exit 64 ;;
esac

task_workspace='/private/tmp/ff-ai-pfg-transfer'
task_project_id='play-for-good-o0lpcq'
task_extra_args=()
task_offline=false
while (($#)); do
  case "$1" in
    --workspace) task_workspace="$2"; shift 2 ;;
    --project-id) task_project_id="$2"; shift 2 ;;
    --offline-snapshot) task_offline=true; task_extra_args+=("$1" "$2"); shift 2 ;;
    --backup-commit) task_extra_args+=("$1" "$2"); shift 2 ;;
    --apply) task_extra_args+=("$1"); shift ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 64 ;;
  esac
done
if ! "$task_offline"; then
  if [[ -f /Users/a123/.config/flutterflow-ai/env ]]; then
    set -a
    source /Users/a123/.config/flutterflow-ai/env
    set +a
  fi
  task_key="${FF_API_KEY:-${FLUTTERFLOW_API_KEY:-}}"
  [[ -n "$task_key" ]] || { printf '%s\n' 'FlutterFlow secret environment is missing.' >&2; exit 1; }
  if [[ ! -f "$task_workspace/pubspec.yaml" ]]; then
    flutterflow ai init "$task_workspace" --project "$task_project_id" --api-key "$task_key"
  fi
else
  [[ -f "$task_workspace/pubspec.yaml" ]] || { printf '%s\n' 'Offline mode requires an initialized FlutterFlow AI workspace.' >&2; exit 1; }
fi

mkdir -p -- "$task_workspace/dsl" "$task_workspace/gg_reports"
cp -- "$task_dir/transfer.dart" "$task_workspace/dsl/gg_transfer.dart"
cd -- "$task_workspace"
dart analyze dsl/gg_transfer.dart
dart run dsl/gg_transfer.dart \
  --variants-root "$variants_root" --variant "$variant" \
  --project-id "$task_project_id" --report-dir "$task_workspace/gg_reports" \
  ${task_extra_args[@]+"${task_extra_args[@]}"}
