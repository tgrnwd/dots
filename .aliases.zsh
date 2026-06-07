alias c="clear"
alias ls="ls --color"
alias grep='grep --color=auto'
alias get="curl -O -L" # Download file and save it with filename of remote file
alias ck8s="colima start --cpu 4 --memory 8 --kubernetes --network-address --port-forwarder grpc --k3s-arg=''"
alias dotfiles="cd $DOTFILES"
alias dev="cd $HOME/codes"

dotfilesinstall () {
    $DOTFILES_PATH/install.sh "$@"
}

gh() {
  command gh "$@"
  local exit_code=$?
  if [[ $exit_code -eq 0 && "$1" == "auth" && "$2" == "switch" ]]; then
    local user_json name gh_email email
    user_json="$(command gh api user)"
    name="$(echo "$user_json" | jq -r '.name')"
    gh_email="$(echo "$user_json" | jq -r '.email')"
    if [[ "$gh_email" != "null" && -n "$gh_email" ]]; then
      email="$gh_email"
    else
      local id login
      id="$(echo "$user_json" | jq -r '.id')"
      login="$(echo "$user_json" | jq -r '.login')"
      email="${id}+${login}@users.noreply.github.com"
    fi
    echo "** updating git config for $name <$email>"
    git config --global user.email "$email"
    git config --global user.name "$name"
    command gh auth setup-git
  fi
  return $exit_code
}

ghtoken() {
  if type gh &>/dev/null; then
    export GITHUB_TOKEN=$(gh auth token)
    echo "GITHUB_TOKEN exported"
  else
    echo "gh CLI not found" >&2
    return 1
  fi
}


update_zsh_plugins() {
  for d in "$ZSH_PLUGIN_DIR"/*/; do
    echo "Updating $(basename $d)..."
    git -C "$d" pull --ff-only
  done
}

tgdots() {
  local cmd="${1:-help}"
  local topic="${2:-}"

  case "$cmd" in
    help)
      case "$topic" in
        colima)
          cat <<'COLIMA_HELP'
Colima k8s Local Dev Cluster
=============================

The dotfiles bootstrap a Colima VM with k3s, Traefik (Gateway API),
trusted TLS, and wildcard DNS for *.k8s.local.

  Cluster info:
    HTTPS port ......... 8443
    HTTP port .......... 8080 (redirects to HTTPS)
    TLD ................ k8s.local
    URL pattern ........ https://<namespace>-<service>.k8s.local:8443
    Gateway ............ local-gateway (namespace: default)
    TLS secret ......... local-tls (namespace: default)

  Manage:
    colima status                    — check VM status
    brew services info colima        — check launchd service
    brew services restart colima     — restart the VM

  Re-bootstrap (idempotent):
    $DOTFILES_PATH/colima/colima-up.sh

  Expose a service via HTTPRoute:

    apiVersion: gateway.networking.k8s.io/v1
    kind: HTTPRoute
    metadata:
      name: <service>
      namespace: <namespace>
    spec:
      parentRefs:
      - name: local-gateway
        namespace: default
        sectionName: https-wildcard
      hostnames:
      - <namespace>-<service>.k8s.local
      rules:
      - matches:
        - path:
            type: PathPrefix
            value: /
        backendRefs:
        - name: <service>
          port: <port>

  That's it — the wildcard cert, DNS, and Gateway listener handle
  TLS termination and routing automatically.
COLIMA_HELP
          ;;
        *)
          cat <<'HELP'
tgdots — dotfiles helper

Usage: tgdots help <topic>

Topics:
  colima    Colima k8s cluster setup, HTTPRoute examples, management commands
HELP
          ;;
      esac
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      echo "Run 'tgdots help' for usage." >&2
      return 1
      ;;
  esac
}