

app_user="${APP_USER:-$(test -f "${APP_USER_FILE}" && cat ${APP_USER_FILE} || echo "ergonode")}"
app_password="${APP_USER_PASSWORD:-$(test -f "${APP_USER_PASSWORD_FILE}" && cat ${APP_USER_PASSWORD_FILE})}"
app_db="${APP_DB:-$(test -f "${APP_DB_FILE}" && cat ${APP_DB_FILE} || echo "ergonode")}"
app_test_db="${APP_DB_TEST:-$(test -f "${APP_TEST_DB_FILE}" && cat ${APP_TEST_DB_FILE} || echo "")}"

user="${POSTGRES_USER:-$(test -f "${POSTGRES_USER_FILE}" && cat ${POSTGRES_USER_FILE} || echo "postgres")}"
db="${POSTGRES_DB:-$(test -f "${POSTGRES_DB_FILE}" && cat ${POSTGRES_DB_FILE} || echo $user)}"
password="${POSTGRES_PASSWORD:-$(test -f "${POSTGRES_PASSWORD_FILE}" && cat ${POSTGRES_PASSWORD_FILE})}"

host="$(hostname -i || echo '127.0.0.1')"