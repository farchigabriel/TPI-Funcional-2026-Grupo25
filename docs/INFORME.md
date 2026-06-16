# Informe Tecnico Analitico — TPI Funcional 2026
## Grupo 25

**Fecha de entrega:** 16 de junio de 2026

**Integrantes:**
- 
- Juan Gabriel Farchi — Github: `farchigabriel` 
- Mario Daniel Rodas — GitHub: `mariorodas1804`
- Acevedo Horacio — GitHub: `acevedoHoracio2026`
- Barrientos Valentina — GitHub: `valentinabarrientoss06`

**Tema investigado:** Sistema de Semaforos Inteligentes y Analisis Comparativo de Paradigmas.

**Repositorio:** https://github.com/farchigabriel/TPI-Funcional-2026-Grupo25

---------------------------------------------------------------------------------------------------

## 1. Fundamentos del diseño funcional adoptado
### 1.1 Entorno de desarrollo

Se utilizo CLISP 2.49 como implementacion de referencia de Common Lisp y Sublime Text 3 como editor, ambos utilizados por la catedra.

### 1.2 Principios aplicados

El diseno respeta estrictamente las tres restricciones de diseno e implementacion impuestas por la consigna:

**Inmutabilidad absoluta.** No se utilizaron operadores destructivos (`setq`, `setf`, `nconc`, `rplaca`, `pop`, `push` destructivos) ni variables globales mutables (`defparameter`, `defvar`). El estado del sistema (color actual, timestamp, configuracion de tiempos) viaja unicamente como argumento entre funciones.

**Cero bucles imperativos.** Ninguna funcion utiliza `loop`, `dolist`, `dotimes` ni `while`. Las operaciones que conceptualmente serian iterativas (calculo de distribucion, suma de tiempos) se resuelven con funciones de orden superior o calculo aritmetico directo.

**Composicion funcional.** Funciones de alto nivel (ej. `ciclos-por-tiempo`, `timer`) reutilizan funciones mas simples (`duracion-ciclo`) mediante composicion, sin estado intermedio.

### 1.3 Arquitectura del nucleo

Se adopto el patron **"nucleo puro / borde impuro"**:

|               Tipo                  |          Funciones            |
|-------------------------------------|-------------------------------|
| **Puras** (sin efectos colaterales) | `transicion`, `timer`, `duracion-ciclo`, `recomendacion-ciclo`, `ciclos-por-tiempo`, `distribucion-porcentual` |
| **Impuras** (I/O)                   | `informe` (logging a pantalla), `informe-archivo` (escritura a archivo) |

Toda lectura del reloj del sistema (`get-universal-time`) ocurre **en el borde** (driver/REPL) y el valor se pasa como argumento a `timer`. Esto preserva la pureza de `timer`: dado un mismo timestamp, siempre devuelve el mismo color, independientemente de cuando se ejecute.

### 1.4 Decisiones de diseno y por que tomamos cada una

Antes de escribir una sola linea cerramos algunas decisiones que despues no tocamos mas. Las dejo aca porque la mayoria no son obvias y queremos poder defenderlas.

Arrancamos por el **ciclo del semaforo**. Optamos por `rojo → verde → amarillo → rojo`. Que segun el enunciado: 90 segundos en rojo, 120 en verde y 6 en amarillo. Suma 216 segundos exactos por vuelta completa, numero que aparece en todas las funciones porque es la base para los calculos modulares.

Lo que si nos costo mas fue **como representar la configuracion de tiempos**. La primera idea fue una lista punteada tipo `((rojo . 90) (verde . 120) (amarillo . 6))`, que es auto-documentada y se lee mejor. El problema es que investigamos que para acceder a los valores hay que usar `assoc`, y en el curso ya habiamos experimentado el acceso a listas a `car`, `cdr` y combinaciones. ademas de que `assoc`es una funcion no tan utilizada por nosotros preferimos aferrarnos a nuestros conocimientos. Asi que pasamos a una lista `'(90 120 6)` con un orden fijo (rojo, verde, amarillo) documentado en el encabezado del archivo. Mas simple, suficiente para lo que necesitamos, y compatible con la restriccion.

Para los **colores** seguimos al pie de la letra el ejemplo del Requerimiento 1: el estado actual lleva prefijo (`'en-rojo`, `'en-verde`, `'en-amarillo`), el destino al que se quiere ir no (`'rojo`, `'verde`, `'amarillo`). En el que entendimos la diferencia conceptual entre "estoy en rojo" y "quiero pasar a verde". Y nos obligo a tener dos vocabularios distintos pero coherentes y logicos a lo largo de todo el codigo.

La decision mas interesante (y la que mas nos hizo pensar el paradigma) fue la **firma de `timer`**. La tentacion natural era hacer `(timer)` sin argumentos y que adentro llamara a `get-universal-time`. Pero ahi `timer` entendimos que deja de ser pura: depende del reloj del sistema, mismo input no garantiza mismo output. Decidimos pasarle el timestamp como argumento: `(timer timestamp tiempos)`. La lectura del reloj queda afuera, en el codigo que coordina la ejecucion. La funcion en si, dado el mismo numero, siempre devuelve el mismo color.

En `transicion` optamos por `cond` sobre `if` anidado o `case`. Tres ramas validas mas una rama default `(t ...)`. Con tres condiciones y una clausula por defecto, `cond` se lee mejor que un `if` dentro de otro `if`.

### 1.5 Clasificacion de funciones

La consigna pide que cada funcion abra con un encabezado clasificandola. El formato que usamos es:
```
;;============================================================
;; FUNCION: <nombre>
;; NATURALEZA: Pura / Impura
;; ESTRATEGIA: Recursiva Simple / Cola / Orden Superior / Predicado / Aplicacion Directa
;; IMPACTO: Destructiva / No destructiva
```

Sobre las etiquetas, vale la pena aclarar un par de cosas. La de **Naturaleza** es la mas clara: o la funcion produce efectos visibles afuera (imprime, lee, depende del reloj) y es impura, o no, y es pura.

La de **Estrategia** tiene un problema: las cuatro categorias que da la consigna (recursiva simple, recursiva de cola, orden superior, predicado) no cubren bien el caso de las funciones que solo hacen un calculo aritmetico sin iterar. `duracion-ciclo` es basicamente una suma. `recomendacion-ciclo` es un `cond` sobre un rango. Aca usamos la etiqueta **"Aplicacion Directa"** y lo explicamos en el comentario, porque forzar una de las cuatro originales seria deshonesto. (Esto esta pensado para defenderlo en oral, si nos preguntan por que inventamos una categoria, decimos que las cuatro propuestas son las tecnicas funcionales no triviales, y que cuando la funcion es calculo puro y directo, la etiqueta que mas acorde es, es esa.)

El **Impacto** en todo nuestro codigo es "no destructiva". No usamos nada que mute estructuras. Las listas que armamos las creamos con `list` y `cons`, que devuelven listas nuevas sin tocar las que reciben.

------------------------------------------------------------------------------------------------------

## 2. Justificacion de la libreria seleccionada en Fase 2

Entre `local-time` y `cl-json` nos quedamos con `local-time`. Lo decidimos porque encaja directo con la motivacion del Requerimiento 3.

El R3 plantea un caso de uso forense: alguien necesita saber que color tenia el semaforo en un instante especifico del pasado. Si lo que ese alguien recibe es un epoch Unix crudo (`1718208600`), la verdad es que no le sirve de nada a primera vista. Deberia hacer una convercion o en este caso podriamos hacer una conversion dentro de la funcion (menos optimo). La libreria `local-time` resuelve esto en una linea: convierte el epoch a `[2026-06-12 14:30:00]`, que es lo que un humano realmente puede leer.

La alternativa, `cl-json`, tambien es valida pero el problema es que en nuestro diseno los tiempos ya viajan como argumento desde el punto de entrada del programa, alguien que quiera cambiarlos solo cambia el `'(90 120 6)` que pasa al llamar las funciones. Meter un archivo JSON solo agrega un paso intermedio sin ganancia clara.

Otro punto a favor de `local-time`: introduce el tipo `timestamp` propio, que es bastante robusto. Si en algun momento el sistema se extiende a manejar zonas horarias o formatos distintos, la libreria ya lo cubre sin tener que cambiar el resto del codigo. No es algo que necesitamos hoy, pero es buen seguro a futuro. (Lo investigamos y cubrimos los casos con Claude)

La integracion con la libreria se hace via Quicklisp, que es el gestor de paquetes estandar del ecosistema Common Lisp. En el codigo se carga al inicio del archivo con `(ql:quickload "local-time")` y se utiliza dentro de `informe` para convertir el epoch a fecha legible. La modificacion final fue:

```lisp
(defun informe (timestamp color-anterior color-nuevo)
    (format t "Tiempo ~A: la luz ha cambiado de ~A a ~A~%"
        (local-time:format-timestring nil
            (local-time:unix-to-timestamp timestamp)
            :format '((:year 4) "-" (:month 2) "-" (:day 2) " "
                      (:hour 2) ":" (:min 2) ":" (:sec 2)))
        color-anterior
        color-nuevo))
```

El cambio queda quirurgico: solo `informe` se ve afectada, el resto del nucleo funcional no toca una linea.

------------------------------------------------------------------------------------------------------

## 3. Iteracion 2 (extensiones)

Tomamos la decision de abordar las dos extensiones que propone la consigna en la seccion "Iteracion 2", aunque no son estrictamente obligatorias para aprobar. Lo hicimos para reforzar la defensa oral y mostrar que entendimos a fondo el modelo.

Para no romper el codigo de Fase 1 (que el evaluador puede correr con los ejemplos QA del R7), agregamos las extensiones como funciones paralelas con sufijo `-v2`. Conviven con las originales en el mismo archivo.

### Extension 1 — Intermitencia de seguridad

Reciclamos la idea del predicado `intermitente` del codigo del companero (que devuelve t si los segundos son menores o iguales a 3) y la incorporamos como funcion aparte. Despues extendimos el modelo de `timer` para incluir el estado `'amarillo-intermitente` entre cada par de cambios:

```
rojo (90s) → amarillo-intermitente (3s) → verde (120s) → amarillo-intermitente (3s) → amarillo (6s) → amarillo-intermitente (3s) → rojo
```

Duracion total del ciclo extendido: 90 + 120 + 6 + 3*3 = **225 segundos**.

Las funciones nuevas son:
- `intermitente`: predicado puro reciclado del codigo del companero.
- `duracion-ciclo-v2`: suma los tres colores mas tres veces el intermitente.
- `timer-v2`: identica filosofia que `timer` pero con seis tramos en lugar de tres.
- `transicion-v2`: incluye seis transiciones validas que incluyen el paso por amarillo-intermitente.

### Extension 2 — Persistencia del log en archivo

La consigna propone modificar `informe` para que guarde el log en un archivo de texto plano. Para no perder la version de pantalla (que es lo que usamos en la demo R7), creamos `informe-archivo` como funcion paralela. Recibe una lista de eventos `((timestamp color-ant color-nuevo) ...)` y los vuelca al archivo `informe-ejecucion-semaforo.txt`.

Lo interesante es como iteramos sobre la lista sin usar `loop` (prohibido). Usamos `mapcar` con una `lambda` para aplicar el `format` a cada evento. Esto cumple la consigna y demuestra orden superior real:

```lisp
(mapcar (lambda (evento)
            (format stream "~A - Transicion: ~A -> ~A~%"
                (local-time:format-timestring nil
                    (local-time:unix-to-timestamp (car evento))
                    :format '((:year 4) "-" (:month 2) "-" (:day 2) " "
                              (:hour 2) ":" (:min 2) ":" (:sec 2)))
                (cadr evento)
                (caddr evento)))
        datos)
```

Tambien reusamos `local-time` (la libreria de Fase 2) para que las fechas queden legibles en el archivo. Asi la Fase 2 y la Iteracion 2 se conectan en una sola pieza de codigo.

------------------------------------------------------------------------------------------------------

## 4. Bitacora de bugs de depuracion

Esta seccion reune los cuatro errores que enfrentamos mientras armabamos el codigo. Los dejamos contados con cierto detalle porque, en cada caso, lo que aprendimos al resolverlos nos termino cambiando la forma de escribir el resto.

### Bug #1 — `get-universal-time` no es Unix epoch

Cuando empezamos a pensar `timer`, lo recomendado que nos salio fue utilizarla con `(get-universal-time)`. La funcion `timer` recibe un timestamp Unix segun la consigna, asi que tenia sentido sacar el "tiempo actual" del reloj del sistema. Sintaxis simple, funciona.

El problema lo descubrimos buscando en la documentacion de Common Lisp: `get-universal-time` no devuelve epoch Unix, devuelve segundos desde el 1° de enero de 1900, no desde 1970 como el estandar Unix. La diferencia entre ambas referencias es de 2.208.988.800 segundos exactos (segun Claude), una constante fija que separa los dos sistemas de medicion.

Para nuestro `timer` esto en la practica no rompia nada visible: como adentro hacemos `(mod timestamp 216)`, lo unico que cambia con el offset es la "fase" del ciclo, no su logica. Pero la consigna decia literalmente "Tiempo Unix actual (entero)" y nosotros estabamos pasando otra cosa.

Lo resolvimos de dos formas. Primero, mantuvimos `timer` recibiendo el timestamp como argumento puro, sin que mire el reloj adentro: eso preserva la pureza de la funcion y desacopla la decision de "que tiempo le paso" de la funcion misma.

La leccion que nos llevamos: nunca dar por sentado que dos sistemas que parecen iguales usan la misma referencia. Y mas importante, validar contra el texto exacto de la consigna, no contra la interpretacion de la primera funcion que parece funcionar.

### Bug #2 — Parentesis mal cerrados en `cond` de `timer`

Mientras escribiamos `timer`, en la rama del `cond` que devuelve `'verde` cometimos un error de los que solo encuentra Lisp. La linea quedo asi:

```lisp
((< pos (+ (car tiempos) (cadr tiempos)) 'verde)
```

A simple vista parece OK, pero faltaba cerrar el parentesis del `<` antes del `'verde`. Lo que Lisp leyo no es "si `pos < tiempo-rojo + tiempo-verde`, devolve verde". Lo que leyo es "si `pos < tiempo-rojo + tiempo-verde < 'verde`, devolve el resultado de esa comparacion". Es decir, interpreto `'verde` como el tercer operando de una comparacion encadenada de tres elementos, no como el valor de retorno de la rama del `cond`.

El error fue que al cargar el archivo, `timer` no devolvia `'verde` cuando le tocaba. Devolvia cualquier otra cosa (NIL), porque el parentesis fuera de lugar le habia cambiado completamente el sentido a la expresion.

La correccion es encontrar y agregar un parentesis donde faltaba...

La leccion es importante: en Lisp los parentesis son **semanticos y necesarios**. Cada par de parentesis define la forma del arbol sintactico que el evaluador va a recorrer. Un parentesis de mas o de menos no te tira un error de sintaxis evidente, te cambia el significado del programa entero. Esto es por lo que vale la pena indentar con cuidado...

### Bug #3 — Confusion entre apostrofe `'` y comilla doble `"` para simbolos vs strings

Cuando implementamos `transicion`, en una de las primeras pasadas escribimos `''cambiar-a-verde''` donde tendria que decir `"cambiar-a-verde"`. Lo curioso es que el editor mostraba las dos versiones de forma muy parecida (la fuente monoespaciada no diferencia bien el apostrofe simple del comilla doble), y nosotros no veiamos el error visualmente.

El problema es que en Common Lisp esos dos signos son completamente distintos. El apostrofe `'` es sintactico para `(quote ...)` y sirve para citar simbolos: `'verde` es el simbolo `verde`, no la palabra "verde". La comilla doble `"` por su lado delimita strings, que son cadenas de caracteres. Son tipos de datos distintos: un simbolo y un string no son intercambiables, aunque visualmente se parezcan.

Cuando escribimos `''cambiar-a-verde''`, Lisp leyo dos veces `quote`, lo que dio una expresion semanticamente vacia. Lo que necesitabamos era el string `"cambiar-a-verde"`, porque la consigna pide explicitamente "el literal `cambiar-a-<color>`" — un literal con comillas dobles, no un simbolo.

La correccion es trivial cuando uno la entiende: usar `"cambiar-a-verde"` (un solo caracter `"` al inicio y otro al final). El editor mostro la diferencia recien cuando hicimos zoom y comparamos caracter por caracter.

### Bug #4 (personal de Mario Rodas) — `Win32 error 267 (ERROR_DIRECTORY)` con paths que contienen espacios

Este fue el bug mas raro de los que se me presento, y me/nos costo un buen rato de diagnostico porque no era un bug del codigo sino del entorno.

Al tener problemas con mi Sublime 3, cuando intente hacer la carga `core.lisp` desde la ubicacion original del proyecto en la consola (`C:\Users\USUARIO\Documents\facultad\paradigma 1\TPI-Funcional-2026-Grupo25\`), CLISP 2.49 me tiro el error de:

```
*** - Win32 error 267 (ERROR_DIRECTORY): The directory name is invalid.
```

Lo confuso es que el error pasaba con `(load ...)` pero no con otras operaciones sobre el mismo archivo. A este punto recurri a la IA y probe distintos casos y intentos de arreglo como: `(probe-file "lisp/core.lisp")` y me devolvio la ruta completa correctamente — o sea, CLISP veia el archivo. probe `(with-open-file ... :direction :input ...)` para leerlo linea por linea y funciono perfecto. Solo `load` y otras operaciones de escritura rompian.

Luego de varios prompts nos dimos cuenta de que la causa eran dos cosas combinadas. La primera, el espacio en `paradigma 1` dentro del path. CLISP 2.49 es de 2010 y arrastra problemas conocidos con APIs modernas de Windows cuando los paths tienen espacios, particularmente cuando hay que escribir a disco. La segunda, una sutileza de la funcion `load` de CLISP: cuando carga un `.lisp`, intenta tambien compilarlo a un archivo `.fas` adyacente (FASL — Fast Loading File). Esa operacion de escritura es la que estaba fallando. La lectura del `.lisp` original si andaba, porque eso es lectura. La escritura del `.fas` no, porque el path con espacios la rompia.

La solucion que adopte fue que en caso de estar codeando por mi cuenta, mandar los archivos y que mis companeros utilizaran sus programas para realizar las pruebas.

La leccion tiene dos partes. La primera, tecnica: en Windows, las rutas con espacios pueden causar fallas silenciosas en herramientas viejas escritas para entornos Unix o pre-Windows 10. Conviene mantener proyectos de desarrollo en rutas cortas tipo `C:\dev\`, `C:\src\` o similares, especialmente si las herramientas que vamos a usar son antiguas. La segunda es aceptar y brindar ayuda siempre y cuando se pueda!

-----------------------------------------------------------------------------------------------------

## 5. Fase 3 — Reimplementacion en Scala

### 5.1 Presentacion del lenguaje

Scala es un lenguaje de programacion creado por Martin Odersky en 2003, que corre sobre la JVM (Java Virtual Machine). Su nombre viene de "Scalable Language", ya que fue disenado para crecer con las necesidades del programador. Una de sus caracteristicas mas importantes es que combina el paradigma orientado a objetos con el funcional en un mismo lenguaje, lo que lo hace muy flexible.

Scala usa tipado estatico, lo que significa que los tipos se verifican en tiempo de compilacion, ayudando a detectar errores antes de ejecutar el programa.

### 5.2 Industrias y areas donde se usa

- **Big Data y procesamiento de datos**: Apache Spark, la herramienta de procesamiento de datos mas usada del mundo, esta escrita en Scala.
- **Finanzas**: por su robustez y rendimiento en sistemas de alta concurrencia.
- **Backend y microservicios**: gracias al framework Akka y Play Framework.

### 5.3 Empresas que lo utilizan

- **Twitter/X**: uso Scala extensamente en su backend para manejar millones de tweets.
- **LinkedIn**: lo usa para procesamiento de datos a gran escala.
- **Netflix**: lo utiliza junto con Spark para analizar datos de usuarios.
- **Airbnb**: lo usa en su infraestructura de datos.

### 5.4 Reimplementacion de `transicion` y `timer`

Ver carpeta `/comparativa/solucion.scala`.

Decidimos mantener coherencia con el modelo simbolico de la version Lisp del grupo: en lugar de representar los estados como vectores binarios `List(1,0,0)`, los modelamos como Algebraic Data Types (ADT) con `sealed trait` + `case object`. Asi cada estado (`EnRojo`, `EnVerde`, `EnAmarillo`) es un valor unico chequeado por el compilador, equivalente a los simbolos `'en-rojo`, `'en-verde`, `'en-amarillo` de Lisp.

### 5.5 Preguntas teoricas

**¿Como estructuraron el semaforo? ¿Usaron una clase tradicional, un object (Singleton), o case classes? Justifiquen desde el diseno funcional.**

Usamos un `object Semaforo` (Singleton) como contenedor de las funciones puras, mas `sealed trait` con `case object` para modelar los estados y colores. En Scala, un `object` es una clase de instancia unica, similar a una clase con todos metodos estaticos en Java. Esto nos permite agrupar las funciones sin necesidad de instanciar nada:

```scala
object Semaforo {
   sealed trait EstadoActual
   case object EnRojo extends EstadoActual
   case object EnVerde extends EstadoActual
   case object EnAmarillo extends EstadoActual

   sealed trait Color
   case object Rojo extends Color
   case object Verde extends Color
   case object Amarillo extends Color

   def transicion(colorActual: EstadoActual, cambiarA: Color): (EstadoActual, Any) = ...
   def timer(timestamp: Int, tiempos: List[Int]): Color = ...
}
```

Elegimos el `object` porque nos da un contenedor para las funciones sin tener que instanciar nada. Las funciones `transicion` y `timer` son puras: reciben datos, devuelven datos, sin modificar nada.

Por que no usamos `case class`: las `case class` se usan cuando se necesitan estructuras de datos con campos. Los estados del semaforo no tienen campos internos (son simples etiquetas), asi que el `case object` es lo correcto. Es la equivalencia exacta a los simbolos de Lisp pero con la garantia de tipo estatico.

**Comparen la manipulacion de listas en Scala (metodos como .map o .filter) contra las funciones de orden superior de Common Lisp. ¿Cual resulta mas legible y por que?**

Tanto Scala como Common Lisp permiten trabajar con listas usando funciones de orden superior, es decir, funciones que reciben otras funciones como argumento. Sin embargo, la sintaxis y la forma de expresarlo es diferente.

En Common Lisp, las funciones de orden superior principales son `mapcar` y `reduce`. Por ejemplo, en nuestro codigo usamos `mapcar` con una lambda para volcar los eventos al archivo en la Iteracion 2:

```lisp
(mapcar (lambda (evento)
            (format stream "~A -> ~A~%" (car evento) (cadr evento)))
        datos)
```

En Scala, los metodos `.map`, `.filter` y `.reduce` son metodos de la propia lista, lo que hace la sintaxis mas fluida y encadenada. Por ejemplo, un equivalente conceptual seria:

```scala
datos.map(evento => s"${evento._1} -> ${evento._2}")
```

En nuestra opinion, Scala resulta mas legible para alguien que recien aprende, porque la sintaxis de punto (`lista.map(...)`) es mas parecida al lenguaje natural y a lo que ya conocemos de otros lenguajes. En Lisp, el anidamiento de parentesis puede dificultar la lectura cuando las expresiones se vuelven mas complejas. Pero hay un trade-off: cuando uno se acostumbra a la lectura prefija de Lisp, la regularidad de la sintaxis tambien tiene su belleza, porque todo es una llamada a funcion sin excepciones.

### 5.6 Conclusion del grupo

Estudiar Scala para este trabajo fue una experiencia interesante porque nos permitio ver como los conceptos del paradigma funcional que aprendimos en Lisp aparecen tambien en un lenguaje moderno y ampliamente usado en la industria.

Lo que mas nos llamo la atencion fue el pattern matching de Scala, que reemplaza al `cond` de Lisp de una forma muy expresiva y clara. Poder escribir `case (EnRojo, Verde) => ...` y que Scala entienda exactamente que estructura estamos comparando nos parecio muy poderoso. Ademas, el compilador chequea exhaustividad: si nos olvidamos un caso, nos avisa.

Tambien notamos que Scala es mas estricto en los tipos. Al declarar `sealed trait EstadoActual` y sus `case object`, el compilador garantiza que no podemos pasar un estado invalido. En Lisp eso solo se descubre en tiempo de ejecucion porque `'en-rojo` es un simbolo dinamico cualquiera.

La dificultad principal fue entender la sintaxis nueva y cuando usar `def`, `val`, `object`, `trait`, `sealed`. Pero una vez comprendido eso, traducir la logica desde Lisp fue bastante directo, lo que nos demuestra que los conceptos del paradigma funcional son universales y se aplican mas alla del lenguaje especifico.

------------------------------------------------------------------------------------------------------

## 6. Bibliografia

- ANSI Common Lisp HyperSpec — http://www.lispworks.com/documentation/HyperSpec/Front/index.htm
- GNU CLISP Implementation Notes — https://clisp.sourceforge.io/impnotes/
- Quicklisp Documentation — https://www.quicklisp.org/beta/
- `local-time` Library — https://common-lisp.net/project/local-time/
- Peter Seibel, *Practical Common Lisp*, Apress, 2005 — http://www.gigamonkeys.com/book/
- Paul Graham, *ANSI Common Lisp*, Prentice Hall, 1995
- Catedra Paradigmas de Programacion 2026 — Consigna TPI v2.2.1 y Enunciado Semaforos v2.1.2
- Scala Documentation — https://docs.scala-lang.org/
- ¿Que es SCALA y por que lo usan las grandes empresas? - https://youtu.be/3-iXJepXkyY?si=lp8gTlTNn3FqG7OS
- Scala 101: todo lo que necesitas saber para empezar - https://youtu.be/5Lc8ik9nnIk?si=cwTQxsO-yY19PPHi
