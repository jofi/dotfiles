#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-$HOME/.local/bin}"
MNT_BASE="${MNT_BASE:-$HOME/mnt}"

mkdir -p "$PREFIX" "$MNT_BASE"/{ssh,sqfs,ext4,arc}

note(){ printf '%s\n' "$*"; }
need(){ command -v "$1" >/dev/null 2>&1 || { note "Missing dependency: $1"; MISSING=1; }; }
OS=$(uname -s)

note "Installing mount helpers to: $PREFIX"
note "Mount base directory:       $MNT_BASE"
note

MISSING=0
# Baseline tools
need bash
need sed
need tr
need id || true
# Optional per feature (installer continues even if missing)
need sshfs || true
need squashfuse || true
need ratarmount || true
need archivemount || true
need fuse-zip || true

if [[ "${OS}" == "Darwin" ]]; then
  need ext4fuse || true
  note "On macOS, install macFUSE + tools via Homebrew (gromgit/fuse tap):"
  note "  brew install macfuse"
  note "  brew install gromgit/fuse/sshfs-mac"
  note "  brew install gromgit/fuse/squashfuse-mac"
  note "  brew install gromgit/fuse/ext4fuse-mac"
  note "  brew install gromgit/fuse/archivemount-mac"
  note "  brew install gromgit/fuse/ratarmount-mac   # or gromgit/fuse/ratarmount"
  note "  brew install gromgit/fuse/fuse-zip-mac"
fi

# ---------------- mnt-lib.sh ----------------
cat > "$PREFIX/mnt-lib.sh" <<'LIB'
#!/usr/bin/env bash
set -euo pipefail

# ----- config (override via env) -----
MNT_BASE="${MNT_BASE:-$HOME/mnt}"
SSHFS_OPTS="${SSHFS_OPTS:-reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,sshfs_sync,workaround=rename,cache=yes}"
SQUASHFUSE_OPTS="${SQUASHFUSE_OPTS:-ro,allow_other}"
EXT4FUSE_OPTS="${EXT4FUSE_OPTS:-allow_other}"
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

# List mounts under a category (ssh|sqfs|ext4|arc).
list_mounts(){
  local sub="${1:-}" verbose="${2:-0}"
  if [[ -z "$sub" ]]; then
    echo "list_mounts: missing argument (expected: ssh|sqfs|ext4|arc)" >&2
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

# Resolve a name to a full mount path (ssh/sqfs/ext4/arc). Prints the first match.
resolve_mount_path(){
  local name="${1:-}"
  [[ -n "$name" ]] || return 1
  local sname; sname="$(sanitize "$name")"
  local d
  for sub in ssh sqfs ext4 arc; do
    d="$(mnt_path "$sub" "$sname")"
    if [[ -e "$d" ]]; then
      echo "$d"
      return 0
    fi
  done
  [[ -e "$name" ]] && { echo "$name"; return 0; }
  return 1
}
LIB
chmod +x "$PREFIX/mnt-lib.sh"

# ---------------- mnt-sshfs ----------------
cat > "$PREFIX/mnt-sshfs" <<'SSH'
#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/mnt-lib.sh"
need sshfs

usage(){ cat <<EOF
Usage:
  mnt-sshfs <user@host[:port]>[:/remote/path] [name]
Env:
  MNT_BASE, SSHFS_OPTS, SSH_OPTS
EOF
}

[[ $# -ge 1 ]] || { usage; exit 2; }
remote="$1"; name="${2:-$(sanitize "$remote")}"
mount_dir="$(mnt_path ssh "$name")"
ensure_dir "$mount_dir"

uidgid_val="$(uidgid)"
opts="uid=$(echo "$uidgid_val" | cut -d: -f1),gid=$(echo "$uidgid_val" | cut -d: -f2),${SSHFS_OPTS}"
if [[ -n "${SSH_OPTS:-}" ]]; then
  opts="${opts},ssh_command=ssh\ ${SSH_OPTS// /\\ }"
fi

echo "→ mounting sshfs $remote → $mount_dir"
sshfs "$remote" "$mount_dir" -o "$opts"
echo "✓ mounted at $mount_dir"
SSH
chmod +x "$PREFIX/mnt-sshfs"

# ---------------- mnt-sqfs ----------------
cat > "$PREFIX/mnt-sqfs" <<'SQFS'
#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/mnt-lib.sh"
need squashfuse

usage(){ cat <<EOF
Usage:
  mnt-sqfs <image.sqfs> [name]
Env:
  MNT_BASE, SQUASHFUSE_OPTS
Note: /etc/fuse.conf must contain 'user_allow_other' for allow_other.
EOF
}

[[ $# -ge 1 ]] || { usage; exit 2; }
img="$1"; [[ -f "$img" ]] || die "no such file: $img"
name="${2:-$(sanitize "$(basename "$img")")}"
mount_dir="$(mnt_path sqfs "$name")"
ensure_dir "$mount_dir"

echo "→ mounting squashfs $img → $mount_dir"
squashfuse -o "$SQUASHFUSE_OPTS" "$img" "$mount_dir"
echo "✓ mounted at $mount_dir"
SQFS
chmod +x "$PREFIX/mnt-sqfs"

# ---------------- mnt-ext4 ----------------
cat > "$PREFIX/mnt-ext4" <<'EXT4'
#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/mnt-lib.sh"

usage(){ cat <<EOF
Usage:
  mnt-ext4 <image.ext4|/dev/diskX> [name]
Env:
  MNT_BASE, EXT4FUSE_OPTS
Notes:
  macOS: uses sudo ext4fuse and mounts read-only
  Linux: ext4 can be mounted natively, e.g. sudo mount -o loop,ro <image.ext4> <dir>
EOF
}

[[ $# -ge 1 ]] || { usage; exit 2; }
img="$1"; [[ -e "$img" ]] || die "no such file or device: $img"
name="${2:-$(sanitize "$(basename "$img")")}"
mount_dir="$(mnt_path ext4 "$name")"

if [[ "$(os)" == "linux" ]]; then
  cat >&2 <<EOF
ext4 images can be mounted natively on Linux; ext4fuse is not needed here.
Example:
  sudo mkdir -p "$mount_dir"
  sudo mount -o loop,ro "$img" "$mount_dir"
EOF
  exit 1
fi

need ext4fuse
ensure_dir "$mount_dir"

echo "→ mounting ext4 $img → $mount_dir"
sudo ext4fuse -o "$EXT4FUSE_OPTS" "$img" "$mount_dir"
echo "✓ mounted at $mount_dir"
EXT4
chmod +x "$PREFIX/mnt-ext4"

# ---------------- mnt-arc ----------------
cat > "$PREFIX/mnt-arc" <<'ARC'
#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/mnt-lib.sh"

usage(){ cat <<EOF
Usage:
  mnt-arc <archive.(tar|tar.gz|tgz|tar.zst|zip|iso|7z|...)> [name]
Env:
  MNT_BASE, RATARMOUNT_OPTS, ARCHIVEMOUNT_OPTS
Tools (auto-detected):
  ratarmount (tar*), fuse-zip (zip), archivemount (general fallback incl. iso)
EOF
}

[[ $# -ge 1 ]] || { usage; exit 2; }
arc="$1"; [[ -f "$arc" ]] || die "no such file: $arc"
name="${2:-$(sanitize "$(basename "$arc")")}"
mount_dir="$(mnt_path arc "$name")"
ensure_dir "$mount_dir"

ext_lc="$(echo "${arc##*.}" | tr '[:upper:]' '[:lower:]')"
case "$ext_lc" in
  zip)
    if command -v fuse-zip >/dev/null 2>&1; then
      echo "→ fuse-zip $arc → $mount_dir"
      fuse-zip "$arc" "$mount_dir"
      echo "✓ mounted at $mount_dir"; exit 0
    fi
    ;;
esac

# tar family via ratarmount if available
if [[ "$arc" =~ \.(tar|tar\.(gz|bz2|xz|zst)|tgz|tbz2|txz)$ ]] && command -v ratarmount >/dev/null 2>&1; then
  echo "→ ratarmount $arc → $mount_dir"
  ratarmount $RATARMOUNT_OPTS "$arc" "$mount_dir"
  echo "✓ mounted at $mount_dir"; exit 0
fi

# fallback: archivemount handles many formats (including ISO) read-only
need archivemount
echo "→ archivemount $arc → $mount_dir"
archivemount -o "$ARCHIVEMOUNT_OPTS" "$arc" "$mount_dir"
echo "✓ mounted at $mount_dir"
ARC
chmod +x "$PREFIX/mnt-arc"

# ---------------- umnt ----------------
cat > "$PREFIX/umnt" <<'UMNT'
#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/mnt-lib.sh"

usage(){ cat <<EOF
Usage:
  umnt <name-or-path> | all
EOF
}

umnt_all(){
  local root d
  for sub in ssh sqfs ext4 arc; do
    root="${MNT_BASE}/${sub}"
    [[ -d "$root" ]] || continue
    shopt -s nullglob
    for d in "$root"/*/; do
      d="${d%/}"
      if is_mounted "$d"; then
        echo "← unmount $d"
        umount_path "$d" || true
      fi
    done
    shopt -u nullglob
  done
}

[[ $# -ge 1 ]] || { usage; exit 2; }
arg="$1"
if [[ "$arg" == "all" ]]; then umnt_all; exit 0; fi
if [[ -e "$arg" ]]; then umount_path "$arg"; exit 0; fi

d="$(resolve_mount_path "$arg" || true)"
[[ -n "${d:-}" ]] || die "not found by path or name: $arg"
umount_path "$d"
UMNT
chmod +x "$PREFIX/umnt"

# ---------------- mnt-ls (with --verbose) ----------------
cat > "$PREFIX/mnt-ls" <<'LS'
#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/mnt-lib.sh"

verbose=0
if [[ "${1:-}" == "-v" || "${1:-}" == "--verbose" ]]; then
  verbose=1
fi

echo "# ssh"
list_mounts ssh "$verbose" || true
echo
echo "# sqfs"
list_mounts sqfs "$verbose" || true
echo
echo "# ext4"
list_mounts ext4 "$verbose" || true
echo
echo "# arc"
list_mounts arc "$verbose" || true
LS
chmod +x "$PREFIX/mnt-ls"

# ---------------- mnt-open ----------------
cat > "$PREFIX/mnt-open" <<'OPEN'
#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/mnt-lib.sh"

usage(){ cat <<EOF
Usage:
  mnt-open <name-or-path>
Prints the resolved, currently-mounted path (for use in command substitution):
  cd "\$(mnt-open NAME)"
EOF
}

[[ $# -ge 1 ]] || { usage; exit 2; }
p="$(resolve_mount_path "$1" || true)"
[[ -n "${p:-}" ]] || die "not found by path or name: $1"
if ! is_mounted "$p"; then die "not mounted: $p"; fi
echo "$p"
OPEN
chmod +x "$PREFIX/mnt-open"

# ---------------- mnt-clean ----------------
cat > "$PREFIX/mnt-clean" <<'CLEAN'
#!/usr/bin/env bash
set -euo pipefail
. "$(dirname "$0")/mnt-lib.sh"

usage(){ cat <<EOF
Usage:
  mnt-clean
Removes EMPTY and NOT-MOUNTED leaf directories under:
  \$MNT_BASE/{ssh,sqfs,ext4,arc}
EOF
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }

removed=0
for sub in ssh sqfs ext4 arc; do
  root="${MNT_BASE}/${sub}"
  [[ -d "$root" ]] || continue
  shopt -s nullglob
  for d in "$root"/*/; do
    d="${d%/}"
    if ! is_mounted "$d"; then
      if [ -z "$(ls -A "$d" 2>/dev/null)" ]; then
        rmdir "$d" && { echo "✂ removed $d"; removed=$((removed+1)); }
      fi
    fi
  done
  shopt -u nullglob
done

echo "Done. Removed $removed empty unmounted dirs."
CLEAN
chmod +x "$PREFIX/mnt-clean"

# --------- Post-install notes ----------
echo
if [[ "${MISSING}" == "1" ]]; then
  echo "Some optional dependencies are missing. Install what you need, e.g.:"
  if [[ "${OS}" == "Linux" ]]; then
    echo "  Debian/Ubuntu: sudo apt install sshfs squashfuse archivemount ratarmount fuse-zip"
    echo "  Fedora:        sudo dnf install  sshfs squashfuse archivemount ratarmount fuse-zip"
  else
    echo "  macOS:"
    echo "    brew install macfuse"
    echo "    brew install gromgit/fuse/sshfs-mac gromgit/fuse/squashfuse-mac gromgit/fuse/ext4fuse-mac"
    echo "    brew install gromgit/fuse/archivemount-mac gromgit/fuse/ratarmount-mac"
    echo "    brew install gromgit/fuse/fuse-zip-mac"
  fi
fi

case ":$PATH:" in
  *:"$HOME/.local/bin":*) ;;
  *) echo 'Add to your shell rc: export PATH="$HOME/.local/bin:$PATH"';;
esac

echo "Done. Try:"
echo "  mnt-sshfs user@host:/dir"
echo "  mnt-sqfs ~/images/data.sqfs"
echo "  mnt-ext4 ~/images/disk.ext4"
echo "  mnt-arc  ~/archives/backup.tar.zst"
echo "  mnt-ls --verbose"
echo '  cd "$(mnt-open NAME)"'
echo "  mnt-clean"
