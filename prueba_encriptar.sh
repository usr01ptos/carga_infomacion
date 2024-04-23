#!/bin/bash
export V_FECHA=$1
export V_ARCHIVO=$2
STATUS=0
export FEC="`date +%b%d`"

# Define DIR_PROG para ejecución de procesos en forma manual y via Control-M
if [ -z ${DIR_PROG} ] ; then
   if [ "`echo $0|awk -F\/ '{print NF}'`" -gt 1 ] ; then
      export DIR_PROG="`echo $0|sed \"s/\/\`echo $0$|awk -F\/ '{print $NF}'\`//g\"`"
   fi
   if [ "${DIR_PROG}" = "./" -o "${DIR_PROG}" = "././" -o "${DIR_PROG}" = "."  ] ; then
      export DIR_PROG=`pwd`
   fi
   if [ -z "${DIR_PROG}" ] ; then
      export DIR_PROG=`pwd`
   fi
fi
# Asigna el nombre del proceso, eliminando el path.
if [ -z "${NOM_PROG}" ]; then
   export NOM_PROG="`echo $0|awk -F\/ '{print $NF}'`"
   if [ -z "${NOM_PROG}" ] ; then
      export NOM_PROG=$0
   fi
fi
# Se crea o define la ruta de los logs
if [ ! -d "${DIR_PROG}"/salidass ] ; then
   mkdir "${DIR_PROG}"/salidass 2>/dev/null
fi
#Se valida si existe la carpeta del shell en la ruta de salida, solo correra una vez
if [ ! -d ${DIR_PROG}/salidass/$FEC/${NOM_PROG} ]; then
   mkdir ${DIR_PROG}/salidass/$FEC/${NOM_PROG}
fi
#valida si existe un log para este shell para el mismo archivo y fecha
if [ -e ${DIR_PROG}/salidass/$FEC/${NOM_PROG}/${NOM_PROG}.log ]; then
   mv  ${DIR_PROG}/salidass/$FEC/${NOM_PROG}/${NOM_PROG}.log ${DIR_PROG}/salidass/$FEC/${NOM_PROG}/${NOM_PROG}_`date '+%H:%M:%S'`.log
fi
#Creacion de log archivos
export ARCH_LOG=${DIR_PROG}/salidass/$FEC/${NOM_PROG}/${NOM_PROG}.log
export ARCH_ERR=${DIR_PROG}/salidass/$FEC/${NOM_PROG}/${NOM_PROG}.err

R_MANUAL=${DIR_PROG}"/"manuales
R_INTERFACES=${DIR_PROG}"/"interfaces

#programa java para generar excel 
export PROGRAMA_JAR_ENCRIPTAR="rrencriptacion.jar"
ARCHIVO_ENC=Salida_Final_CtosND.xls
ARCHIVO_DENC=Salida_Final_CtosND.xls.enc

echo '*******Inicia proceso de Encriptado*******'
#llamado del JAR para encriptar
java -jar ${DIR_PROG}'/'${PROGRAMA_JAR_ENCRIPTAR} 0 ${R_MANUAL}'/'${ARCHIVO_ENC} >> ${ARCH_LOG} 2>>${ARCH_ERR}
started_code=$?
if [ $started_code -eq 0 ]; then
    mensaje 'Ejecucion correcta de encriptar' $PROGRAMA_JAR_ENCRIPTAR
    echo 'Se encripta correctamente el archivo: ' ${ARCHIVO_ENC}
    return $started_code
else
    mensaje 'ERROR al encriptar' $PROGRAMA_JAR_ENCRIPTAR
    echo 'No se encripta correctamente el archivo: ' ${ARCHIVO_ENC}
    return $started_code
fi

echo '*******Inicia proceso de Desencriptado*******'

#llamado del JAR para desencriptar
java -jar ${DIR_PROG}'/'${PROGRAMA_JAR_ENCRIPTAR} 1 ${R_MANUAL}'/'${ARCHIVO_DENC} >> ${ARCH_LOG} 2>>${ARCH_ERR}
started_code=$?
if [ $started_code -eq 0 ]; then
    mensaje 'Ejecucion correcta de desencriptar' $PROGRAMA_JAR_ENCRIPTAR
    return $started_code
else
    mensaje 'ERROR al desencriptar' $PROGRAMA_JAR_ENCRIPTAR
    return $started_code
fi


#########################
#    Funciones
#########################
mensaje () {
   echo "$(date +"%Y-%m-%d-%H:%M:%S") ${1}: ${2}" >> ${ARCH_LOG}
}

#########################
# Inicio de Shell
#########################
INICIA_EJEC=`date +"%y%m%d %T"`
INICIA_EJEC_S=`date +"%s"`
mensaje "INFO" "+---------------------------------------------------------+"
mensaje "INFO" "|-------- Inicia ejecución: $INICIA_EJEC ------------|"
mensaje "INFO" "+---------------------------------------------------------+"
#Cierre de Shell
TERMINA_EJEC=`date +"%y%m%d %T"`
TERMINA_EJEC_S=`date +"%s"`
mensaje "INFO" "+---------------------------------------------------------+"
mensaje "INFO" "|--------   Fin ejecución: $TERMINA_EJEC -------------|"
mensaje "INFO" "+---------------------------------------------------------+"
let DURACION_EJ_S=${TERMINA_EJEC_S}-${INICIA_EJEC_S}
let DURACION_EJE_M=${DURACION_EJ_S}/60
mensaje "INFO" "+---------------------------------------------------------+"
mensaje "INFO" "|---------- Duración de la ejecución: $DURACION_EJ_S seg. -------------|"
mensaje "INFO" "+---------------------------------------------------------+"
