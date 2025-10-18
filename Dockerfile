FROM alpine:latest

RUN apk add --no-cache curl bash
COPY monitor.sh /monitor.sh
RUN chmod +x /monitor.sh

# Run the monitoring script every 5 minutes
CMD ["sh", "-c", "while true; do /monitor.sh; sleep 300; done"]

