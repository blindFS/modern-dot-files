get_icon_by_app_name() {
  local name="$1"

  # If no argument is passed, read from stdin (pipeline support)
  if [[ -z "$name" && ! -t 0 ]]; then
    name=$(cat)
  fi

  # Trim leading/trailing whitespace and convert to lowercase
  name=$(echo "$name" | xargs | tr '[:upper:]' '[:lower:]')

  case "$name" in
  "app store") echo "" ;;
  "arc") echo "󰣇" ;;
  "betterdisplay") echo "󰍺" ;;
  "blender") echo "" ;;
  "books") echo "" ;;
  "calculator") echo "" ;;
  "calendar") echo "" ;;
  "dictionary") echo "" ;;
  "discord") echo "󰙯" ;;
  "emacs") echo "" ;;
  "finder") echo "󰀶" ;;
  "ghostty") echo "" ;;
  "gimp") echo "" ;;
  "google chrome") echo "" ;;
  "kicad") echo "" ;;
  "mail") echo "" ;;
  "maps") echo "" ;;
  "music") echo "" ;;
  "neovide") echo "" ;;
  "notes") echo "󰎚" ;;
  "openscad") echo "" ;;
  "photos") echo "" ;;
  "podcasts") echo "" ;;
  "preview") echo "" ;;
  "safari") echo "󰀹" ;;
  "shadowrocket") echo "" ;;
  "steam helper") echo "󰓓" ;;
  "ryujinx") echo "󱎓" ;;
  "system settings") echo "󰒓" ;;
  "wechat") echo "" ;;
  "zed") echo "󰬡" ;;
  "telegram") echo "" ;;
  *) echo "" ;;
  esac
}
