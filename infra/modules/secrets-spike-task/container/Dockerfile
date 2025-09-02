FROM public.ecr.aws/docker/library/busybox:latest

# Simple container: logs first 8 chars of DUMMY_SECRET every 20s
CMD ["/bin/sh","-c","while true; do head=$(printf '%s' \"$DUMMY_SECRET\" | cut -c1-8); echo \"$(date) $ENVTYPE secret head: $head\"; sleep 20; done"]
