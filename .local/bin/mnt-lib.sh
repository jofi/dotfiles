#!/usr/bin/env bash
set -euo pipefail

# ----- config (override via env) -----
MNT_BASE="${MNT_BASE:-$HOME/mnt}"
SSHFS_OPTS="${SSHFS_OPTS:-reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,sshfs_sync,workaround=rename,cache=yes}"
SQUASHFUSE_OPTS="${SQUASHFUSE_OPTS:-ro,allow_other}"
ARCHIVEMOUNT_OPTS="${ARCHIVEMOUNT_OPTS:-ro}"
RATARMOUNT_OPTS="${RATARMOUNT_OPTS:---foreground}"

die(){ echo "✗ $*" >&2; exit 1; }
need(){ command -v "$1" >/dev/null 2>&1 || die "missing dep: $1"; }

os(){
  case "$(uname -s)" in
    Linux) echo linux ;;
    Darwin) echo mac ;;
    *) echo other ;;
  esac
}

uidgid(){
  if command -v id >/dev/null 2>&1; then
    echo "$(id -u):$(id -g)"
  else
    echo "0:0"
  fi
}

sanitize(){
  echo "$*" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's#[/ :@]+#-#g; s#[^a-z0-9._-]##g; s#-+#-#g; s#^[-.]+##; s#[-.]+$##'
}

ensure_dir(){ mkdir -p "$1"; }

mnt_path(){ echo "${MNT_BASE}/${1}/${2}"; }

is_mounted(){
  local path="$1"
  if [[ "$(os)" == "linux" ]]; then
    mountpoint -q -- "$path"
  else
    mount | grep -F " on ${path} " >/dev/null 2>&1
  fi
}

umount_path(){
  local path="$1"
  [[ -e "$path" ]] || { echo "… $path (does not exist)"; return 0; }
  if ! is_mounted "$path"; then
    echo "… $path (not mounted)"
    return 0
  fi
  if command -v fusermount3 >/dev/null 2>&1; then
    fusermount3 -u "$path" || fusermount3 -uz "$path"
  elif command -v fusermount >/dev/null 2>&1; then
    fusermount -u "$path" || fusermount -uz "$path"
  else
    umount "$path" 2>/dev/null || umount -f "$path"
  fi
}

# Return filesystem type for a given mountpoint (portable).
fs_type_of(){
  local mnt="$1"
  case "$(os)" in
    mac)
      stat -f %T -- "$mnt" 2>/dev/null || true
      ;;
    linux)
      if [[ -r /proc/self/mountinfo ]]; then
        awk -v mp="$mnt" '
          $5==mp {
            for(i=1;i<=NF;i++) if($i=="-"){print $(i+1); exit}
          }
        ' /proc/self/mountinfo
      fi
      ;;
    *)
      :
      ;;
  esac
}

# Verbose line printer: "✓ /path [fstype]"
print_status_line(){
  local path="$1" verbose="${2:-0}"
  if is_mounted "$path"; then
    if [[ "$verbose" == "1" ]]; then
      local t; t="$(fs_type_of "$path" || true)"
      [[ -n "${t:-}" ]] && echo "✓ $path [$t]" || echo "✓ $path"
    else
      echo "✓ $path"
    fi
  else
    echo "· $path"
  fi
}

# List mounts under a category (ssh|sqfs|arc).
list_mounts(){
  local sub="${1:-}" verbose="${2:-0}"
  if [[ -z "$sub" ]]; then
    echo "list_mounts: missing argument (expected: ssh|sqfs|arc)" >&2
    return 2
  fi
  local root="${MNT_BASE}/${sub}"
  [[ -d "$root" ]] || return 0

  shopt -s nullglob
  shopt -s dotglob
  local dirs=( "$root"/*/ )
  shopt -u dotglob
  shopt -u nullglob

  ((${#dirs[@]})) || return 0

  local d
  for d in "${dirs[@]}"; do
    d="${d%/}"
    print_status_line "$d" "$verbose"
  done
}

# Resolve a name to a full mount path (ssh/sqfs/arc). Prints the first match.
resolve_mount_path(){
  local name="${1:-}"
  [[ -n "$name" ]] || return 1
  local sname; sname="$(sanitize "$name")"
  local d
  for sub in ssh sqfs arc; do
    d="$(mnt_path "$sub" "$sname")"
    if [[ -e "$d" ]]; then
      echo "$d"
      return 0
    fi
  done
  [[ -e "$name" ]] && { echo "$name"; return 0; }
  return 1
}
