#!/bin/bash
# AO486 Boot Switcher Modificado (3 opciones)

set -euo pipefail

# ========= OPTIONS ==================
SCRIPT_VERSION="0.2"
BASE_PATH="/media/fat/games/ao486"

# Archivo 1: Original
ORIGINAL_ROM_FILENAME="boot1_orig.bin"
ORIGINAL_ROM_REMOTE="https://github.com/sethgregory/ao486_boot_switcher/raw/main/boot1-orig.bin"

# Archivo 2: Trident
TRIDENT_ROM_FILENAME="boot1_trident.bin"
TRIDENT_ROM_REMOTE="https://github.com/sethgregory/ao486_boot_switcher/raw/main/boot1-trident.bin"

# Archivo 3: Tseng ET4000
TSENG_ROM_FILENAME="boot1_tseng.bin"
TSENG_ROM_REMOTE="https://github.com/Kreeblah/ao486_Drivers/blob/master/Video/Tseng_ET4000/BIOS/boot1.rom"

COUNTDOWN_TIME=15
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5 --silent --show-error"
ALLOW_INSECURE_SSL="true"

if [[ "${ALLOW_INSECURE_SSL}" == "true" ]]; then
    SSL_SECURITY_OPTION="--insecure"
else
    echo "Error de certificados SSL"; exit 2
fi

# Colores y formato
red="\e[0;91m"
green="\e[0;92m"
red_bg="\e[0;101m"
reset="\e[0m"
BOLD_IN="$(tput bold)"
BOLD_OUT="$(tput sgr0)"

fetch_if_not_exists() { 
    local FILE_NAME="${1}"
    local FILE_PATH="${BASE_PATH}/${FILE_NAME}"
    local FILE_URL="${2}"
    
    if [ ! -f "${FILE_PATH}" ] ; then
        echo "... ${FILE_NAME} no encontrado. Descargando..."
        if curl ${CURL_RETRY} --silent --show-error ${SSL_SECURITY_OPTION} --fail --location -o "${FILE_PATH}" "${FILE_URL}" ; then return ; fi
        echo "Error de red al descargar: ${FILE_NAME}"; exit 1
    else
        echo "... ${FILE_NAME} encontrado."
    fi
}

echo -en "\ec"
echo -e "${red_bg}${reset}"
echo -e "${BOLD_IN}AO486 core boot1 switcher:${BOLD_OUT} Selecciona la BIOS ROM para boot1.rom."
echo -e "${green}Script version ${SCRIPT_VERSION}${reset}\n"

# Asegurar que existen los tres archivos
fetch_if_not_exists "${ORIGINAL_ROM_FILENAME}" "${ORIGINAL_ROM_REMOTE}"
fetch_if_not_exists "${TRIDENT_ROM_FILENAME}" "${TRIDENT_ROM_REMOTE}"
fetch_if_not_exists "${TSENG_ROM_FILENAME}" "${TSENG_ROM_REMOTE}"

echo
echo " ${BOLD_IN}1)${BOLD_OUT} Arriba    - Usar BIOS ${BOLD_IN}Trident${BOLD_OUT}"
echo " ${BOLD_IN}2)${BOLD_OUT} Abajo     - Usar BIOS ${BOLD_IN}Original${BOLD_OUT}"
echo " ${BOLD_IN}3)${BOLD_OUT} Izquierda - Usar BIOS ${BOLD_IN}Tseng${BOLD_OUT}"

COUNTDOWN_SELECTION="original"

set +e
for (( i=0; i <= COUNTDOWN_TIME ; i++)); do
    SECONDS_LEFT=$(( COUNTDOWN_TIME - i ))
    printf "\rDefaulting to original en %2d segundos..." "${SECONDS_LEFT}"
    
    read -r -s -N 1 -t 1 key
    # Detección de teclas (1, 2, 3 o Flechas)
    if [[ "${key}" == "1" || "${key}" == "A" ]]; then
            COUNTDOWN_SELECTION="trident"
            break
    elif [[ "${key}" == "2" || "${key}" == "B" ]]; then
            COUNTDOWN_SELECTION="original"
            break
    elif [[ "${key}" == "3" || "${key}" == "D" ]]; then
            COUNTDOWN_SELECTION="tseng"
            break
    fi
done
set -e

echo -e "\n"

case "${COUNTDOWN_SELECTION}" in
    "trident")
        cp "${BASE_PATH}/${TRIDENT_ROM_FILENAME}" "${BASE_PATH}/boot1.rom"
        echo "... Reemplazado por ${TRIDENT_ROM_FILENAME}" ;;
    "original")
        cp "${BASE_PATH}/${ORIGINAL_ROM_FILENAME}" "${BASE_PATH}/boot1.rom"
        echo "... Reemplazado por ${ORIGINAL_ROM_FILENAME}" ;;
    "tseng")
        cp "${BASE_PATH}/${TSENG_ROM_FILENAME}" "${BASE_PATH}/boot1.rom"
        echo "... Reemplazado por ${TSENG_ROM_FILENAME}" ;;
esac

echo
read -s -n 1 -p "Presiona cualquier tecla para finalizar."
echo