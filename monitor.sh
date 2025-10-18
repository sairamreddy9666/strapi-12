LOG_FILE="/var/log/nginx-monitor.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://nginx-service:80)

if [ "$STATUS_CODE" -eq 200 ]; then
    echo "$TIMESTAMP - ✅ NGINX is UP (Status: $STATUS_CODE)" | tee -a $LOG_FILE
else
    echo "$TIMESTAMP - ❌ NGINX is DOWN (Status: $STATUS_CODE)" | tee -a $LOG_FILE
fi
