alias gst="git status"
alias gadd="git add"
alias tasklist="nvim ~/tasklist"
# tmux
alias t="tmux "
alias ta="tmux attach -t "
alias tl="tmux ls"
alias tc="tmux new-session -s "
tdir() {
  local session_name
  session_name=$(basename "$PWD" | tr '[:upper:]' '[:lower:]')
  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
  else
    tmux new-session -s "$session_name"
  fi
}
kns() {
  local ns
  ns=$(kubectl config view --minify -o jsonpath='{..namespace}')
  ns="${ns:-default}"
  echo "== Namespace: $ns =="
  kubectl get deploy,sts,ds,pods,svc,ingress,gateway,httproute -o wide
  echo
  echo "== Recent events =="
  kubectl get events --sort-by='.lastTimestamp' | tail -15
}
alias kx="kubectx"
