has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

setup_sudo() {
  SUDO=''
  if [ "${EUID:-$(id -u)}" -ne 0 ] && has_cmd sudo; then
    SUDO='sudo'
  fi
}

detect_pkg_manager() {
  if has_cmd brew; then
    PKG_MANAGER='brew'
  elif has_cmd apt-get; then
    PKG_MANAGER='apt'
  elif has_cmd dnf; then
    PKG_MANAGER='dnf'
  elif has_cmd yum; then
    PKG_MANAGER='yum'
  elif has_cmd pacman; then
    PKG_MANAGER='pacman'
  elif has_cmd zypper; then
    PKG_MANAGER='zypper'
  elif has_cmd apk; then
    PKG_MANAGER='apk'
  else
    PKG_MANAGER=''
  fi
}

install_pkgs() {
  if [ "$#" -eq 0 ]; then
    return 0
  fi

  case "$PKG_MANAGER" in
    brew)
      brew install "$@"
      ;;
    apt)
      $SUDO apt-get update -y
      $SUDO apt-get install -y "$@"
      ;;
    dnf)
      $SUDO dnf install -y "$@"
      ;;
    yum)
      $SUDO yum install -y "$@"
      ;;
    pacman)
      $SUDO pacman -Sy --noconfirm "$@"
      ;;
    zypper)
      $SUDO zypper --non-interactive install "$@"
      ;;
    apk)
      $SUDO apk add --no-cache "$@"
      ;;
    *)
      return 1
      ;;
  esac
}

ensure_symlink() {
  local target="$1"
  local link_path="$2"

  if [ -e "$link_path" ]; then
    return 0
  fi

  mkdir -p "$(dirname "$link_path")"
  ln -s "$target" "$link_path"
}
