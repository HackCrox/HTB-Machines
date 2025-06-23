#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

# Ctrl + C
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Panel de ayuda:${endColour}\n"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por nombre de maquina${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por dificultad de maquina${endColour} (\"F\": ${greenColour}Fácil${endColour}, \"M\": ${yellowColour}Media${endColour}, \"D\": ${purpleColour}Difícil${endColour}, \"I\": ${redColour}Insane${endColour})"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por Direccion IP${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de resolucion de la maquina en Youtube${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por sistema operativo de maquina${endColour} (\"L\": ${yellowColour}Linux${endColour} ó \"W\": ${blueColour}Windows${endColour})"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}\n"
}

function updateFiles() {
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    sleep 1 
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Buscando actualizaciones...${endColour}"
    curl -s $main_url > bundle_temp.js

    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    
    sleep 2

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}No se han detectado actualizaciones, esta todo al dia.${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Actualizacion detectada${endColour}"
      sleep 1
      echo -e "\n${redColour}[+]${endColour} ${grayColour}Actualizando...${endColour}"  
      rm bundle.js && mv bundle_temp.js bundle.js
      sleep 2
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Actualizacion completa${endColour}"  
    fi
    tput cnorm
  fi
}

function searchMachine(){
  machineName="$1"
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku|resuelta" | tr -d '""|,' | sed 's/^ *//')"

  if [ "$machineName_checker" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la maquina${endColour} ${blueColour}${machineName}${endColour}${grayColour}:${endColour}\n"

    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku|resuelta" | tr -d '""|,' | sed 's/^ *//'
  else
    echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
  fi
}

function searchLevel() {
  levelMachine="${1^^}"

  case "$levelMachine" in
    F)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${greenColour}Fácil${endColour}\n"
      cat bundle.js | grep "dificultad: \"Fácil\"" -B 5 bundle.js | grep "name:" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
      ;;
    M)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${yellowColour}Media${endColour}\n"
      cat bundle.js | grep "dificultad: \"Media\"" -B 5 bundle.js | grep "name:" | awk '{print $2}' | tr -d '"|,' | sort | column 
      echo ""
      ;;
    D)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${purpleColour}Difícil${endColour}\n"
      cat bundle.js | grep "dificultad: \"Difícil\"" -B 5 bundle.js | grep "name:" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
      ;;
    I)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${redColour}Insane${endColour}\n"
      cat bundle.js | grep "dificultad: \"Insane\"" -B 5 bundle.js | grep "name:" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
      ;;
    *)
      echo -e "\n${redColour}[!]${endColour} ${grayColour}Opción no válida: usa${grayColour} ${greenColour}F${endColour}, ${yellowColour}M${endColour}, ${purpleColour}D${endColour} o ${redColour}I${endColour}"
      echo ""
      ;;
  esac
}

function searchIP() {
  ipAddress="$1" 
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$machineName" ]; then
   echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El nombre de la maquina correspondiente a la IP ${blueColour}${ipAddress}${endColour} es${endColour} ${purpleColour}${machineName}\n"
  else
    echo -e "\n${redColour}[!] La direccion IP proporcionada no existe${endColour}\n"
  fi

}

function getYoutubeLink() {
  machineName="$1"
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku|resuelta" | grep "youtube:" | tr -d '""|,' | sed 's/^ *//' | awk 'NF {print $NF}')"
  if [ "$youtubeLink" ]; then
   echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial de la resolucion de la maquina${endColour} ${blueColour}${machineName}${endColour} ${grayColour}se encuentra en el siguiente enlace:${endColour} ${greenColour}${youtubeLink}${endColour}\n"
    
  else
    echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
  fi

}

function getOSMachine() {
  os="${1^^}"

  case $os in
    L)
      echo -e "\n${yellowColour}[+]${endColour} Listando todas las máquinas con sistema operativo ${yellowColour}Linux${endColour}\n"
      cat bundle.js | grep "so: \"Linux\"" -B 5 bundle.js | grep "name:" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
      ;;
    W)
      echo -e "\n${yellowColour}[+]${endColour} Listando todas las máquinas con sistema operativo ${blueColour}Windows${endColour}\n"
      cat bundle.js | grep "so: \"Windows\"" -B 5 bundle.js | grep "name:" | awk '{print $2}' | tr -d '"|,' | sort | column
    ;;
    *)
      echo -e "${redColour}[!]${endColour} ${grayColour}Opción proporcionada no válida, usa${grayColour} ${yellowColour}L${endColour} ó ${blueColour}W${endColour}"
  esac
}

function getOSDifficultyMachines() {
  levelMachine="${1^^}"
  os="${2^^}"
  
  if [ "$os" == "L" ]; then
    case $levelMachine in
    F)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${greenColour}Fácil${endColour} con sistema operativo ${yellowColour}Linux${endColour}\n"
      cat bundle.js | grep "dificultad: \"Fácil\"" -B 5 | grep "so: \"Linux\"" -B 4 | grep "name" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
    ;;
    M)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${yellowColour}Media${endColour} con sistema operativo ${yellowColour}Linux${endColour}\n"
      cat bundle.js | grep "dificultad: \"Media\"" -B 5 | grep "so: \"Linux\"" -B 4 | grep "name" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
    ;;
    D)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${purpleColour}Difícil${endColour} con sistema operativo ${yellowColour}Linux${endColour}\n"
    cat bundle.js | grep "dificultad: \"Difícil\"" -B 5 | grep "so: \"Linux\"" -B 4 | grep "name" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
    ;;
    I)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${redColour}Insane${endColour} con sistema operativo ${yellowColour}Linux${endColour}\n"
    cat bundle.js | grep "dificultad: \"Insane\"" -B 5 | grep "so: \"Linux\"" -B 4 | grep "name" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
    ;;
    *)
      echo -e "\n${redColour}[!]${endColour} ${grayColour}Opción no válida: usa${grayColour} ${greenColour}F${endColour}, ${yellowColour}M${endColour}, ${purpleColour}D${endColour} o ${redColour}I${endColour}"
      echo ""
    ;;
    esac

  elif [ "$os" == "W" ]; then
        case $levelMachine in
    F)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${greenColour}Fácil${endColour} con sistema operativo ${blueColour}Windows${endColour}\n"
      cat bundle.js | grep "dificultad: \"Fácil\"" -B 5 | grep "so: \"Windows\"" -B 4 | grep "name" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
    ;;
    M)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${yellowColour}Media${endColour} con sistema operativo ${blueColour}Windows${endColour}\n"
      cat bundle.js | grep "dificultad: \"Media\"" -B 5 | grep "so: \"Windows\"" -B 4 | grep "name" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
    ;;
    D)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${purpleColour}Difícil${endColour} con sistema operativo ${blueColour}Windows${endColour}\n"
    cat bundle.js | grep "dificultad: \"Difícil\"" -B 5 | grep "so: \"Windows\"" -B 4 | grep "name" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
    ;;
    I)
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${redColour}Insane${endColour} con sistema operativo ${blueColour}Windows${endColour}\n"
    cat bundle.js | grep "dificultad: \"Insane\"" -B 5 | grep "so: \"Windows\"" -B 4 | grep "name" | awk '{print $2}' | tr -d '"|,' | sort | column
      echo ""
    ;;
    *)
      echo -e "\n${redColour}[!]${endColour} ${grayColour}Opción no válida: usa${grayColour} ${greenColour}F${endColour}, ${yellowColour}M${endColour}, ${purpleColour}D${endColour} o ${redColour}I${endColour}"
      echo ""
    ;;
    esac

  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}Opción no válida: usa${grayColour} ${yellowColour}L${endColour} ó ${blueColour}W${endColour}\n"
  fi
}

# Indicadores
declare -i parameter_counter=0 # declare se utiliza para declarar variables, el parametro -i es para que sea de valor entero
declare -i difficulty=0
declare -i sistemOS=0


# Menu de opciones
while getopts "um:d:i:y:o:h" arg; do
  case $arg in
    u) let parameter_counter+=1;;
    m) machineName=$OPTARG; let parameter_counter+=2;; # let sirve para hacer operaciones aritmeticas
    d) levelMachine=$OPTARG; difficulty=1; let parameter_counter+=3;;
    i) ipAddress=$OPTARG; let parameter_counter+=4;;
    y) machineName=$OPTARG; let parameter_counter+=5;; # let sirve para hacer operaciones aritmeticas
    o) os=$OPTARG; sistemOS=1; let parameter_counter+=6;; # let sirve para hacer operaciones aritmeticas
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  updateFiles
elif [ $parameter_counter -eq 2 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 3 ]; then
  searchLevel $levelMachine
elif [ $parameter_counter -eq 4 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 5 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 6 ]; then
  getOSMachine $os
elif [ $difficulty -eq 1 ] && [ $sistemOS -eq 1 ]; then
  getOSDifficultyMachines $levelMachine $os
else
  helpPanel
fi
