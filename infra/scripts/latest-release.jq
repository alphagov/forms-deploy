.
| sort_by(.published_at | fromdate)
| reverse
| map(select((.draft | not) and (.prerelease|not)))
| .[0].name