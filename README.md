# Calculadora Interactiva en Asembly (x86-64)

## 📌 Problematica

El proyecto busca implementar una calculadora interactiva en bajo nivel utilizando Asembly x86-64 sobre Linux. La problemática principal es demostrar cómo se pueden manejar entradas de usuario, parsear números y operadores, ejecutar operaciones aritméticas y manejar errores, todo sin depender de lenguajes de alto nivel. Se requiere un bucle interactivo que permita al usuario introducir expresiones simples y obtener resultados inmediatos.

## ⚙️ Algoritmos

- Máquina de estados para parsing:
    - Estado 0: esperando primer número.
    - Estado 1: esperando operador.
    - Estado >=2: esperando operandos adicionales.

- Conversión de cadenas a enteros (parse_int): 
    - Maneja signos opcionales (+, -).
    - Valida que todos los caracteres sean dígitos.
    - Devuelve el número en rax y error en rcx.

- Ejecución de operaciones (control_calculate): 
    - Recibe puntero a array de números (rdi), cantidad (rsi), y operador (rdx)
    - Aplica la operación aritmética.
    - Devuelve resultado en eax y error en rcx.

- Impresión de resultados (ui_print_int):
    - Convierte el entero en ASCII y lo muestra en stdout.

- Impresión de errores (ui_print_error):
    - Muestra mensajes de error según código recibido.

## 🧪 Casos de prueba y resultados

### Operaciones básicas correctas

| Entrada | Resultado |
|---------|-----------|
| 12 + 34 |   46      |
|  7 - 2  |    5      |
|  8 * 9  |   72      |
| 20 / 4  |    5      |

### Manejo de errores de formato

| Entrada |           Resultado           |
|---------|-------------------------------|
|   12    | ````Error: invalidformat````  |
|  +34    | ````Error: invalid format```` |
|  12 +   | ````Error: invalid format```` |
| abc + 5 | ````Error: invalid format```` |

### Manejo de errores de cálculo

|         Entrada        |           Resultado             |
|------------------------|---------------------------------|
|         5 / 0          | ````Error: division by zero```` | 
| 999999999 * 999999999  | ````Error: overflow````         |

### Signos y espacios
| Entrada | Resultado |
|---------|-----------|
| -12 + 5 |   -7      |
|  +7 +3  |   10      |
|  15 - 4 |   11      |


### Comando especial

|     Entrada   |       Resultado     |
|---------------|---------------------|
| ````exit````  | Termina el programa |


## 🗂️ Registros empleados

|  Registro | Uso     |
|-----------|--------------------------------------------|
|    rdi    | Puntero al buffer / argumento de funciones |
|    rsi    | Longitud / segundo argumento               |
|    rdx    | Operador o tercer argumento                |
|    r8d    | Estado del parser                          |
|    r9     | Contador de números                        |
|    r12b   | Operador guardado                          |
|    r13b   | Puntero al array de números                |
|    r15b   | Fin del número actual                      |
|    rax    |Acumulador / resultado de funciones         |
|    rcx    | Código de error                            |


## 🚀 Ejecución

Para compilar, limpiar y ejecutar usando el Makefile, utiliza los siguientes comandos:

``` 
    make        # Compila el programa
    make clean  # Limpia archivos generados
    ./calc      # Ejecuta la calculadora
```

El programa mostrará el prompt calc> y permitirá introducir operaciones. Para salir, se debe escribir exit.
