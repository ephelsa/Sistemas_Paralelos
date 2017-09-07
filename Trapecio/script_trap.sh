#!/bin/bash

# Script para la el reporte de Sistemas paralelos.
# Desarrollado por: Leonardo Andres Perez

##################################################
################ Funcionamiento ##################
##################################################

#	1-> El resultado se almacena en un archivo de texto llamado resultado.txt
# 	Es posible modificar el nombre pasando un argumento. Variable ARCHIVO_SALIDA.
# 	2-> A y B son los límites de integración.
#	3-> Si se modifican los límites de integración es OBLIGATORIO cambiar
#	el VALOR_REAL para obtener el valor del error relativo correcto.
#	4-> MUESTRAS, corresponde al número de repeticiones que se hará.
#	5-> Se calcula un T_MUESTRA promedio (T_PROMEDIO) después de ejecutar las
#	muestras.
#	6-> NUM_TRAP corresponde al número de trapecios.
#	7-> NUM_HILOS corresponde al número de hilos.
#	8-> T_MUESTRA corresponde al tiempo obtenido en cada muestra.
#	9-> VALOR_MEDIDO corresponde al valor obtenido en la prueba.

# Consideraciones: Se utiliza python para el algunos cálculos, dado que
# bash solo opera enteros. Además, se modificó el archivo C para que reciba
# un argumento de más, que imprima el tiempo (0) o resultado (1) según sea necesario.

while [[ true ]]; do
	printf "Buscando archivo trap: "
	if [ -e trap ]
	then
		printf "Encontrado -> Ejecutando script...\n\n"

		break
	else
		printf "No encontrado.\nBuscando trap.c: "

		if [ -e trap.c ]
		then
			printf "Encontrado -> Ejecutando gcc...\n"
			gcc -Wall -fopenmp -o trap trap.c
		else
			printf "No encontrado.\n"
			exit
		fi
	fi
done

if [ $# -eq 1 ]
then
	ARCHIVO_SALIDA=$1
else
	ARCHIVO_SALIDA=resultado.txt
fi

A=1
B=50

VALOR_REAL=1562500

MUESTRAS=5

# '>>' para seguir escribiendo. '>' para reescribir.
printf "INFORMACIÓN DE LA CPU\n\n$(lscpu | grep -E "CPU|Ar|Model name:|Cach| proc")\n\n\n" > $ARCHIVO_SALIDA

printf "RESULTADOS\n##################\n\n" >> $ARCHIVO_SALIDA

for i in 1000 10000 100000 1000000 10000000
do
	NUM_TRAP=$i

	echo "Trapecios: $NUM_TRAP"

	for j in 1 2 4 8 16
	do
		T_PROMEDIO=0

		NUM_HILOS=$j

		echo "Hilos: $NUM_HILOS"
		echo "#Hilos: $NUM_HILOS -- #Trapecios: $NUM_TRAP" >> $ARCHIVO_SALIDA

		for ((ITERACIONES = 0; ITERACIONES < MUESTRAS; ITERACIONES++))
		do

			T_MUESTRA=$(./trap $A $B $NUM_TRAP $NUM_HILOS 0)

			T_PROMEDIO=$(python -c "print $T_MUESTRA/$MUESTRAS + $T_PROMEDIO")

		 	echo $T_MUESTRA >> $ARCHIVO_SALIDA

			sleep 0.1	# Pequeño delay.
		done

		VALOR_MEDIDO=$(./trap $A $B $NUM_TRAP $NUM_HILOS 1 )

		ERROR_R=$(python -c "print ($VALOR_MEDIDO - $VALOR_REAL) / $VALOR_REAL")

		echo "Resultado: $VALOR_MEDIDO -- Error relativo: $ERROR_R" >> $ARCHIVO_SALIDA
		printf "Tiempo promedio: $T_PROMEDIO \n\n" >> $ARCHIVO_SALIDA
	done
done
