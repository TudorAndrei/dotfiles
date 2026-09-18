#!/usr/bin/env bash

current_path="${CURRENT_PATH:-$PWD}"

# Collect all worktree paths for this repo (first entry is the main worktree)
worktree_roots=()
while IFS= read -r wt_path; do
    worktree_roots+=("$wt_path")
done < <(git -C "$current_path" worktree list --porcelain 2>/dev/null | awk '/^worktree / {print substr($0, 10)}')

if [ ${#worktree_roots[@]} -eq 0 ]; then
    worktree_roots=("$current_path")
fi

repo_name=$(basename "${worktree_roots[0]}")
today=$(date -j -v0H -v0M -v0S +%s)

filter_sessions() {
    while IFS='|' read -r win_active pane_active timestamp session path; do
        [ "$win_active" = "1" ] && [ "$pane_active" = "1" ] || continue
        for root in "${worktree_roots[@]}"; do
            case "$path" in
                "$root"|"$root"/*)
                    printf '%s %s\n' "$timestamp" "$session"
                    break
                    ;;
            esac
        done
    done
}

selected=$(
    tmux list-panes -a -F '#{window_active}|#{pane_active}|#{session_last_attached}|#{session_name}|#{pane_current_path}' |
    filter_sessions |
    sort -rn |
    awk -v today="$today" '{
        if ($2 == "") next
        if ($1 + 0 >= today) {
            printf "\033[38;5;208m%s\033[0m\n", $2
        } else {
            print $2
        }
    }' |
    fzf --reverse --header "sessions in $repo_name" --ansi \
        --preview 'tmux capture-pane -pt "$(printf "%s" {} | perl -pe '"'"'s/\e\[[0-9;]*m//g'"'"')"'
)

[ -n "$selected" ] || exit
session=$(printf "%s" "$selected" | perl -pe 's/\e\[[0-9;]*m//g')
tmux switch-client -t "$session"
