.
| sort_by(.published_at | fromdate)
| reverse
| map(select((.draft | not) and ($allow_prerelease or (.prerelease|not))))
| .[0].name