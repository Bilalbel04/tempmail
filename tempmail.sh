#!/bin/bash

# 🏴‍☠️ TempMail By Bily 🚀

clear
function marca {
echo -e "\e[1;36m████████╗███████╗███╗   ███╗██████╗     ███╗   ███╗ █████╗ ██╗██╗       \e[0m"
echo -e "\e[1;36m╚══██╔══╝██╔════╝████╗ ████║██╔══██╗    ████╗ ████║██╔══██╗██║██║       \e[0m"
echo -e "\e[1;36m   ██║   █████╗  ██╔████╔██║██████╔╝    ██╔████╔██║███████║██║██║       \e[0m"
echo -e "\e[1;36m   ██║   ██╔══╝  ██║╚██╔╝██║██╔═══╝     ██║╚██╔╝██║██╔══██║██║██║       \e[0m"
echo -e "\e[1;36m   ██║   ███████╗██║ ╚═╝ ██║██║         ██║ ╚═╝ ██║██║  ██║██║███████║    \e[0m"
echo -e "\e[1;36m   ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝         ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚══════╝ \e[0m"
echo -e "\e[1;32m                     🚀 TempMail - By: Bily 🚀\e[0m\n"
}
marca

EMAIL_DIR="emails"
rm -rf "$EMAIL_DIR"
mkdir -p "$EMAIL_DIR"

# Iniciar servidor en segundo plano si no está corriendo
if ! pgrep -f "python3 -m http.server 5555" > /dev/null; then
    echo "🌍 Iniciando servidor web en localhost:5555..."
    python3 -m http.server 5555 --directory "$EMAIL_DIR" > /dev/null 2>&1 &
fi

# Obtener dominio válido
echo "🔍 Buscando dominios disponibles..."
DOMAIN=$(curl -s "https://api.mail.tm/domains" | jq -r '.["hydra:member"] | map(.domain) | .[]' | shuf -n 1)

if [[ -z "$DOMAIN" ]]; then
    echo "❌ Error: No se pudo obtener un dominio."
    exit 1
fi

EMAIL="user$RANDOM@$DOMAIN"
PASSWORD="password123"

echo -e "📩 Correo generado: \e[1;33m$EMAIL\e[0m"

# Crear cuenta y obtener token
echo "🔐 Registrando correo..."
curl -s -X POST "https://api.mail.tm/accounts" -H "Content-Type: application/json" -d "{\"address\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" > /dev/null

TOKEN=$(curl -s -X POST "https://api.mail.tm/token" -H "Content-Type: application/json" -d "{\"address\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | jq -r '.token')

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
    echo "❌ Error al obtener el token."
    exit 1
fi

echo "✅ Correo registrado y listo para recibir mensajes."

declare -A SEEN_MESSAGES  # Array asociativo para evitar duplicados rápidamente

function busca_correos {
    RESPONSE=$(curl -s -X GET "https://api.mail.tm/messages" -H "Authorization: Bearer $TOKEN")

    if [[ -z "$RESPONSE" || "$RESPONSE" == "null" ]]; then
        echo "❌ Error: No se pudo obtener mensajes."
        sleep 3
        return
    fi

    NEW_MESSAGES=$(echo "$RESPONSE" | jq -r '.["hydra:member"][]? | select(.id != null) | "\(.id) \(.from.address) \(.subject)"')

    if [[ -z "$NEW_MESSAGES" ]]; then
        echo -ne "\r⌛ No hay correos nuevos...     "
        sleep 3
        return
    fi

    while IFS= read -r MESSAGE; do
        MSG_ID=$(echo "$MESSAGE" | awk '{print $1}')

        if [[ -n "${SEEN_MESSAGES[$MSG_ID]}" ]]; then
            continue
        fi

        SEEN_MESSAGES[$MSG_ID]=1

        FROM=$(echo "$MESSAGE" | awk '{print $2}')
        SUBJECT=$(echo "$MESSAGE" | awk '{$1=$2=""; print $0}' | sed 's/^ *//')

        EMAIL_DATA=$(curl -s -X GET "https://api.mail.tm/messages/$MSG_ID" -H "Authorization: Bearer $TOKEN")

        HTML_CONTENT=$(echo "$EMAIL_DATA" | jq -r '.html // empty')
        TEXT_CONTENT=$(echo "$EMAIL_DATA" | jq -r '.text // empty')

        if [[ -n "$HTML_CONTENT" && "$HTML_CONTENT" != "null" ]]; then
            EMAIL_CONTENT="$HTML_CONTENT"
        elif [[ -n "$TEXT_CONTENT" && "$TEXT_CONTENT" != "null" ]]; then
            EMAIL_CONTENT="<html><body><pre>$(echo "$TEXT_CONTENT" | sed 's/\r//g')</pre></body></html>"
        else
            EMAIL_CONTENT="<html><body><p>No hay contenido en este mensaje.</p></body></html>"
        fi

        FILENAME="temp$RANDOM.html"
        FILEPATH="$EMAIL_DIR/$FILENAME"

        echo "$EMAIL_CONTENT" > "$FILEPATH" &  # Guardar en segundo plano

        echo -e "\n------------------------------------------"
        echo -e "🕒 HORA: $(date +"%H:%M:%S")"
        echo -e "\e[1;34m📧 De: $FROM\e[0m"
        echo -e "\e[1;33m📌 Asunto: $SUBJECT\e[0m"
        echo -e "\e[1;32m🌍 Ver aquí:\e[0m http://localhost:5555/$FILENAME"
        echo -e "------------------------------------------"
    done <<< "$NEW_MESSAGES"
}

while true; do
    busca_correos
    sleep 3
done
