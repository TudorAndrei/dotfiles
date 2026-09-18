#!/usr/bin/env bash
today=$(date -j -v0H -v0M -v0S +%s)

# Agent indicators (color-coded, fixed 2-column width incl. trailing space).
RUNNING=$'\033[38;5;39m◐\033[0m '   # blue  - actively working
WAITING=$'\033[38;5;220m▲\033[0m ' # yellow - needs input / approval
DONE=$'\033[38;5;42m●\033[0m '      # green - idle, finished
NONE='  '

# Classify one agent pane and print "<session>\t<state>" (waiting>running>done).
# A single capture-pane piped into a single perl does all the work: the title is
# prepended as line 1 so the Claude braille spinner (U+2800-U+28FF) is detected
# without an extra fork. Codex/pi have no title spinner, so they fall back to the
# "esc to interrupt" footer.
classify_pane() {
    { printf '%s\n' "$3"; tmux capture-pane -p -t "$2"; } |
    S="$1" perl -CS -ne '
        if ($. == 1) { $run = /^[\x{2800}-\x{28FF}]/; next }
        $wait ||= /❯ 1\.|requires approval|Do you want to (proceed|make|create|run)|Allow .*to run|\(y\/n\)|\[y\/N\]|Waiting for/;
        $run  ||= /esc to interrupt/;
        END { print "$ENV{S}\t", ($wait ? "waiting" : $run ? "running" : "done"), "\n" }'
}

# Emit "<session>\t<state>" for every agent pane, all classified in parallel.
agent_map() {
    while IFS='|' read -r session pane cmd title; do
        case "$cmd" in
            claude|codex*|pi) classify_pane "$session" "$pane" "$title" & ;;
        esac
    done < <(tmux list-panes -a -F '#{session_name}|#{pane_id}|#{pane_current_command}|#{pane_title}')
    wait
}

selected=$(
    awk -v today="$today" -v RUN="$RUNNING" -v WAIT="$WAITING" -v DONE="$DONE" -v NONE="$NONE" '
        FNR==NR {
            split($0, a, "\t"); s=a[1]; st=a[2]
            r=(st=="waiting")?3:(st=="running")?2:1
            if (r > rank[s]) rank[s]=r
            next
        }
        {
            if ($2 == "") next
            ind = (rank[$2]==3)?WAIT : (rank[$2]==2)?RUN : (rank[$2]==1)?DONE : NONE
            if ($1 + 0 >= today)
                printf "%s\033[38;5;208m%s\033[0m\n", ind, $2
            else
                printf "%s%s\n", ind, $2
        }
    ' <(agent_map) <(tmux list-sessions -F '#{session_last_attached} #{?session_attached,,#{session_name}}' | sort -rn) |
    fzf --reverse --header 'jump-to-session   ◐ running  ▲ waiting  ● done' --ansi \
        --preview 'tmux capture-pane -pt "$(printf "%s" {} | perl -pe '"'"'s/\e\[[0-9;]*m//g; s/^.*\s//'"'"')"'
)

[ -n "$selected" ] || exit
session=$(printf "%s" "$selected" | perl -pe 's/\e\[[0-9;]*m//g; s/^.*\s//')
tmux switch-client -t "$session"
