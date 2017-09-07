#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

/* Código de la regla del trapecio
 * Codificado por: Danny Múnera
 * se toma el tiempo con las funciones proporcionadas por OpenMP
 * Imprime en pantalla los resultados:
 * <area_calculada>   <wall_time>
 */

double f(double x);
void trap_f (double a, double b, int n, double * global_result_p);

int main(int argc, char* argv[]){
    double global_result = 0.0; /* Resultado global */
    double a, b;                /* Límites */

    int n;                      /* número de trapecios */
    int thread_count;           /* número de hilos */

    int switch_t_r = atoi(argv[5]);

    double elapsed_time;
    if (argc < 5) {
      printf("Error: ingrese solo 4 argumentos: a, b, n y tc\n");

      return 1;
    }

    a = atof(argv[1]);
    b = atof(argv[2]);
    n = atoi(argv[3]);
    thread_count = atoi(argv[4]);

    //taking time from here ...
    elapsed_time = omp_get_wtime();

    #pragma omp parallel num_threads(thread_count)
    trap_f(a, b, n, &global_result);

    //...to here
    elapsed_time = omp_get_wtime() - elapsed_time;
    // Human readable output

    // Print conditions:s
    // This is only to help us to save the time or the result in script_trap.sh
    // But we can print both at the same time.
    if (switch_t_r  == 1 && argc == 6) {
        printf("%8.20f\n", global_result);
    } else if (switch_t_r  == 0 && argc == 6) {
        printf("%7.10f\n", elapsed_time);
    } else {
        printf("%8.4f\t%7.4f\n", global_result, elapsed_time);
    }

    return 0;
    } /* main */

void trap_f (double a, double b, int n, double* global_result_p){
    double h, x_i, my_result;
    double local_a, local_b;
    int i, local_n;
    int my_rank = omp_get_thread_num();
    int thread_count = omp_get_num_threads();

    h = (b-a)/n;
    local_n = n / thread_count;
    local_a = a + my_rank*local_n*h;
    local_b = local_a + local_n*h;
    my_result = (f(local_a) + f(local_b))/2.0;
    for (i = 1; i <= local_n - 1; i++){
        x_i = local_a + i*h;
        my_result += f(x_i);
    }
    my_result = my_result*h;

    #pragma omp critical
    *global_result_p += my_result;
} /* trap_f */

double f(double x){
    return x*x*x;
}
