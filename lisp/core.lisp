;; ============================================================
;; TPI Funcional 2026 - Grupo 25
;; Sistema de Semaforos Inteligentes
;; Integrantes: Mario Daniel Rodas, Juan Gabriel Farchi, Horacio Acevedo, Valentina Barrientos.
;; ============================================================
;;
;; CONVENCION DEL CONFIG DE TIEMPOS:
;; Lista plana de 3 enteros en orden fijo:
;;   (car      tiempos) -> tiempo ROJO     (90 s)
;;   (cadr     tiempos) -> tiempo VERDE    (120 s)
;;   (caddr    tiempos) -> tiempo AMARILLO (6 s)
;;
;; CICLO: rojo -> verde -> amarillo -> rojo  (duracion total 216 s)
;; ============================================================

;; Fase 2: cargamos la libreria local-time via Quicklisp
;; usada para convertir timestamps Unix a fechas legibles en informe e informe-archivo
(ql:quickload "local-time")


;; ============================================================
;; FUNCION: duracion-ciclo
;; NATURALEZA: pura
;; ESTRATEGIA: funcion
;; IMPACTO: no destructiva
;; ============================================================

(defun duracion-ciclo (tiempos)
    (+ (car tiempos) (cadr tiempos) (caddr tiempos)))

;; ============================================================
;; FUNCION: transicion
;; NATURALEZA: pura
;; ESTRATEGIA: funcion
;; IMPACTO: no destructiva
;; ============================================================

;;cond cubre 3 casos de pruebas + la transicion no es valida (consigna)
;;utilizacion de apostrofe para el simbolo y comillas dobles para el string
;;utilizacion del cond y dentro un and para realizar la comparaciones (color actual y color destino) color-actual y cambiar-a son los parametros, 
;;se utilizan como comparacion contra los literales (simbolos), list para armar la lista de salida
;;cuando: color-actual = 'en-rojo Y cambiar-a = 'verde  devolviendo: (list 'en-rojo "cambiar-a-verde")
;;si todos fallan caemos en la ultima rama

(defun transicion (color-actual cambiar-a)
    (cond ((and (eq color-actual 'en-rojo) (eq cambiar-a 'verde)) (list 'en-rojo "cambiar-a-verde"))
         ((and (eq color-actual 'en-verde) (eq cambiar-a 'amarillo)) (list 'en-verde "cambiar-a-amarillo"))
         ((and (eq color-actual 'en-amarillo) (eq cambiar-a 'rojo)) (list 'en-amarillo "cambiar-a-rojo"))
         (t (list color-actual 'accion-por-defecto))
    ))

;; ============================================================
;; FUNCION: timer
;; NATURALEZA: pura
;; ESTRATEGIA: funcion
;; IMPACTO: no destructiva
;; ============================================================

;;reglas: rojo es 90s, verde 120s y amarillo 6s (ciclo completo 216s (duracion-ciclo))
;;condicion con 3 tramos: rojo (0,90), verde (90,210) y amarillo (210,216)
;;comparacion con tramos (el mod del timestamp con duracion-ciclo como parametro deberia dar un numero entre 0 y 215)
;;pos < 90 entonces es rojo ; pos < 90(rojo) + 120(verde) entonces es verde; pos >= 210 entonces es amarillo --operaciones aritmeticas--

(defun timer (timestamp tiempos)
    (let ((pos (mod timestamp (duracion-ciclo tiempos))))
        (cond ((< pos (car tiempos)) 'rojo)
              ((< pos (+ (car tiempos) (cadr tiempos))) 'verde)
              (t 'amarillo))))

;;let para guardar pos como variable local (el mod entre timestamp y la duracion-ciclo) para no calcularlo 3 veces
;;Cambio: no utilizacion del 'caddr tiempos = 6' como tercer comparativo porque por logica si no es verde o rojo es amarillo porque la comparacion abarca todo el ciclo
;;let es un binding asigna un nombre a un valor inmutable. Ademas es funcion pura porque recibe timestamp, no toca el reloj

;; ============================================================
;; FUNCION: informe
;; NATURALEZA: Impura (escribe en pantalla con format)
;; ESTRATEGIA: Aplicacion Directa (sin recursion ni iteracion)
;; IMPACTO: No destructiva
;; ============================================================

;; recibe los parametros del timestamp (Unix epoch), color anterior y color nuevo
;; Fase 2: en lugar de imprimir el epoch crudo usamos local-time para mostrar fecha legible
;; local-time:unix-to-timestamp convierte el entero a tipo timestamp interno
;; local-time:format-timestring lo formatea segun el patron yyyy-mm-dd hh:mm:ss
;; ~A imprime el valor (el string ya formateado), ~% es salto de linea al final
;; cumple R3 + Fase 2 simultaneamente

(defun informe (timestamp color-anterior color-nuevo)
    (format t "Tiempo ~A: la luz ha cambiado de ~A a ~A~%"
        (local-time:format-timestring nil
            (local-time:unix-to-timestamp timestamp)
            :format '((:year 4) "-" (:month 2) "-" (:day 2) " "
                      (:hour 2) ":" (:min 2) ":" (:sec 2)))
        color-anterior
        color-nuevo))

;; ============================================================
;; FUNCION: recomendacion-ciclo
;; NATURALEZA: pura
;; ESTRATEGIA: funcion predicado (evalua si esta dentro del rango)
;; IMPACTO: no destructiva
;; ============================================================

;; recibe la duracion del ciclo (entero, en segundos)
;; evalua si esta dentro del rango optimo (35-150s)
;; devuelve una lista con simbolo + mensaje explicativo

(defun recomendacion-ciclo (duracion)
    (cond ((and (>= duracion 35) (<= duracion 150))
           (list 'ciclo-optimo "Duracion optimo"))
          (t
           (list 'ciclo-no-optimo "Duracion no optima"))))

;; ============================================================
;; FUNCION: ciclos-por-tiempo
;; NATURALEZA: pura
;; ESTRATEGIA: composicion funcional (usa duracion-ciclo)
;; IMPACTO: no destructiva
;; ============================================================

;; recibe los minutos + la lista de tiempos del ciclo
;; convierte minutos a segundos (* minutos 60) y divide por la duracion del ciclo
;; truncate corta decimales para devolver ciclos COMPLETOS
;; ejemplo: 15 minutos = 900 seg, 900/216 = 4.16, truncate -> 4 ciclos completos

(defun ciclos-por-tiempo (minutos tiempos)
    (truncate (/ (* minutos 60) (duracion-ciclo tiempos))))

;; ============================================================
;; FUNCION: distribucion-porcentual
;; NATURALEZA: pura
;; ESTRATEGIA: composicion funcional (usa duracion-ciclo)
;; IMPACTO: no destructiva
;; ============================================================

;; recibe la lista de tiempos del ciclo
;; devuelve lista plana de 3 porcentajes en orden fijo: (rojo verde amarillo)
;; usa car/cadr/caddr para extraer cada tiempo y dividir por la duracion total
;; (* 100.0 ...) usa float para tener decimales (sin el .0 daria racionales)
;; ejemplo con (90 120 6): (41.66 55.55 2.77)

(defun distribucion-porcentual (tiempos)
    (let ((total (duracion-ciclo tiempos)))
        (list (/ (* 100.0 (car tiempos)) total)
              (/ (* 100.0 (cadr tiempos)) total)
              (/ (* 100.0 (caddr tiempos)) total))))

;; ============================================================
;; R7 - ASEGURAMIENTO DE LA CALIDAD
;; ============================================================
;; Ejemplos copy-paste para verificar cada funcion.
;; Casos: normal / alternativo / error.
;; Cada bloque incluye llamada + resultado esperado en comentario.
;; ============================================================

;; ---- R1: transicion -----------------------------------------
;; Normal: transiciones validas del ciclo rojo->verde->amarillo->rojo
;; (transicion 'en-rojo 'verde)        -> (EN-ROJO "cambiar-a-verde")
;; (transicion 'en-verde 'amarillo)    -> (EN-VERDE "cambiar-a-amarillo")
;; (transicion 'en-amarillo 'rojo)     -> (EN-AMARILLO "cambiar-a-rojo")
;;
;; Alternativo: transiciones invalidas (no estan en el ciclo)
;; (transicion 'en-rojo 'amarillo)     -> (EN-ROJO ACCION-POR-DEFECTO)
;; (transicion 'en-verde 'rojo)        -> (EN-VERDE ACCION-POR-DEFECTO)
;; (transicion 'en-amarillo 'verde)    -> (EN-AMARILLO ACCION-POR-DEFECTO)
;;
;; Error: simbolos invalidos -> cae en default
;; (transicion 'en-azul 'verde)        -> (EN-AZUL ACCION-POR-DEFECTO)
;; (transicion 'en-rojo 'cualquier)    -> (EN-ROJO ACCION-POR-DEFECTO)

;; ---- R2: timer ----------------------------------------------
;; Normal: instantes dentro del ciclo
;; (timer 0   '(90 120 6))     -> ROJO       (inicio del ciclo)
;; (timer 45  '(90 120 6))     -> ROJO       (medio del rojo)
;; (timer 150 '(90 120 6))     -> VERDE      (medio del verde)
;; (timer 213 '(90 120 6))     -> AMARILLO   (medio del amarillo)
;;
;; Alternativo: bordes exactos de cada tramo
;; (timer 89  '(90 120 6))     -> ROJO       (ultimo seg rojo)
;; (timer 90  '(90 120 6))     -> VERDE      (primer seg verde)
;; (timer 209 '(90 120 6))     -> VERDE      (ultimo seg verde)
;; (timer 210 '(90 120 6))     -> AMARILLO   (primer seg amarillo)
;; (timer 215 '(90 120 6))     -> AMARILLO   (ultimo seg amarillo)
;; (timer 216 '(90 120 6))     -> ROJO       (vuelve a empezar)
;;
;; Alternativo: multiples ciclos completos
;; (timer 432 '(90 120 6))     -> ROJO       (2 ciclos despues)
;; (timer 1000 '(90 120 6))    -> VERDE      (1000 mod 216 = 136)
;;
;; Alternativo: timestamp negativo (CL maneja mod negativo)
;; (timer -1 '(90 120 6))      -> AMARILLO   (mod -1 216 = 215)

;; ---- R3: informe --------------------------------------------
;; Normal: cambios validos del ciclo
;; (informe 1718208600 'rojo 'verde)
;; -> Tiempo 1718208600: la luz ha cambiado de ROJO a VERDE
;; (informe 1718208690 'verde 'amarillo)
;; -> Tiempo 1718208690: la luz ha cambiado de VERDE a AMARILLO
;; (informe 1718208696 'amarillo 'rojo)
;; -> Tiempo 1718208696: la luz ha cambiado de AMARILLO a ROJO
;;
;; Alternativo: timestamp 0
;; (informe 0 'verde 'rojo)
;; -> Tiempo 0: la luz ha cambiado de VERDE a ROJO
;;
;; Alternativo: mismo color (caso degenerado)
;; (informe 1718208700 'rojo 'rojo)
;; -> Tiempo 1718208700: la luz ha cambiado de ROJO a ROJO

;; ---- R4a: duracion-ciclo ------------------------------------
;; Normal: reglas actuales
;; (duracion-ciclo '(90 120 6))      -> 216
;;
;; Alternativo: otros valores de configuracion
;; (duracion-ciclo '(60 100 4))      -> 164
;; (duracion-ciclo '(30 30 30))      -> 90
;; (duracion-ciclo '(0 0 0))         -> 0    (caso borde, ciclo vacio)
;; (duracion-ciclo '(1 1 1))         -> 3

;; ---- R4b: recomendacion-ciclo -------------------------------
;; Normal: nuestras reglas (cae fuera del rango optimo)
;; (recomendacion-ciclo 216)
;; -> (CICLO-NO-OPTIMO "Duracion fuera del rango ideal (35-150s)")
;;
;; Alternativo: dentro del rango optimo
;; (recomendacion-ciclo 100)
;; -> (CICLO-OPTIMO "Duracion dentro del rango ideal (35-150s)")
;;
;; Alternativo: bordes inclusivos del rango
;; (recomendacion-ciclo 35)          -> (CICLO-OPTIMO ...)
;; (recomendacion-ciclo 150)         -> (CICLO-OPTIMO ...)
;;
;; Alternativo: justo fuera del rango
;; (recomendacion-ciclo 34)          -> (CICLO-NO-OPTIMO ...)
;; (recomendacion-ciclo 151)         -> (CICLO-NO-OPTIMO ...)
;;
;; Composicion con duracion-ciclo
;; (recomendacion-ciclo (duracion-ciclo '(90 120 6)))
;; -> (CICLO-NO-OPTIMO ...)

;; ---- R5: ciclos-por-tiempo ----------------------------------
;; Normal: con reglas actuales
;; (ciclos-por-tiempo 15 '(90 120 6))   -> 4    (900s / 216 = 4.16, truncado a 4)
;; (ciclos-por-tiempo 60 '(90 120 6))   -> 16   (1 hora = 3600s / 216 = 16.66, truncado)
;; (ciclos-por-tiempo 1 '(90 120 6))    -> 0    (60s no alcanza para 1 ciclo)
;;
;; Alternativo: borde 0 minutos
;; (ciclos-por-tiempo 0 '(90 120 6))    -> 0
;;
;; Alternativo: cambio de configuracion
;; (ciclos-por-tiempo 5 '(10 20 5))     -> 8    (300s / 35 = 8.57)

;; ---- R6: distribucion-porcentual ----------------------------
;; Normal: nuestras reglas
;; (distribucion-porcentual '(90 120 6))
;; -> (41.666668 55.555557 2.7777777)
;;    rojo 41.66% / verde 55.55% / amarillo 2.77%
;;
;; Alternativo: configuracion uniforme
;; (distribucion-porcentual '(30 30 30))
;; -> (33.333332 33.333332 33.333332)
;;
;; Alternativo: configuracion distinta
;; (distribucion-porcentual '(60 100 4))
;; -> (36.585365 60.97561 2.4390244)
;;
;; Verificacion: la suma deberia dar ~100
;; (reduce #'+ (distribucion-porcentual '(90 120 6)))   -> 100.00001 (error float)


;; ============================================================
;; ITERACION 2 - EXTENSIONES
;; ============================================================
;; Extensiones opcionales pedidas en la consigna:
;;   Ext 1: Intermitencia de seguridad (3 segundos entre cambios)
;;   Ext 2: Persistencia del log en archivo de texto
;;
;; Convencion para Iteracion 2:
;;   tiempos extendidos = (rojo verde amarillo intermitente)
;;   Ejemplo: (90 120 6 3)
;;   El intermitente se agrega entre cada par de cambios -> 3 veces por ciclo
;; ============================================================


;; ============================================================
;; FUNCION: intermitente
;; NATURALEZA: pura
;; ESTRATEGIA: funcion predicado
;; IMPACTO: no destructiva
;; ============================================================

;; predicado que indica si los segundos restantes son del rango de intermitencia
;; reciclamos esta idea del codigo del compañero, dejando t si seg es menor o igual a 3
;; util para detectar la "fase amarillo intermitente" de una transicion

(defun intermitente (seg)
    (<= seg 3))


;; ============================================================
;; FUNCION: duracion-ciclo-v2
;; NATURALEZA: pura
;; ESTRATEGIA: aplicacion directa (suma con intermitencia x3)
;; IMPACTO: no destructiva
;; ============================================================

;; recibe lista extendida de tiempos (rojo verde amarillo intermitente)
;; suma todos los tramos del ciclo: cada color + 3 intermitencias entre cambios
;; ejemplo con (90 120 6 3): 90 + 120 + 6 + 3*3 = 225s

(defun duracion-ciclo-v2 (tiempos)
    (+ (car tiempos)
       (cadr tiempos)
       (caddr tiempos)
       (* 3 (cadddr tiempos))))


;; ============================================================
;; FUNCION: timer-v2
;; NATURALEZA: pura
;; ESTRATEGIA: aplicacion directa (aritmetica modular con tramos extendidos)
;; IMPACTO: no destructiva
;; ============================================================

;; igual que timer pero con tramos intermitentes intercalados

(defun timer-v2 (timestamp tiempos)
    (let ((pos (mod timestamp (duracion-ciclo-v2 tiempos)))
          (r (car tiempos))
          (v (cadr tiempos))
          (a (caddr tiempos))
          (i (cadddr tiempos)))
        (cond ((< pos r)                 'rojo)
              ((< pos (+ r i))           'amarillo-intermitente)
              ((< pos (+ r i v))         'verde)
              ((< pos (+ r i v i))       'amarillo-intermitente)
              ((< pos (+ r i v i a))     'amarillo)
              (t                         'amarillo-intermitente))))


;; ============================================================
;; FUNCION: transicion-v2
;; NATURALEZA: pura
;; ESTRATEGIA: decision multiple (cond)
;; IMPACTO: no destructiva
;; ============================================================

;; extiende transicion para incluir el estado amarillo-intermitente
;; cubre el ciclo completo con 6 transiciones validas + default
;; el estado amarillo-intermitente actua como paso obligatorio entre cualquier cambio
;; secuencia logica: rojo -> int -> verde -> int -> amarillo -> int -> rojo

(defun transicion-v2 (color-actual cambiar-a)
    (cond ((and (eq color-actual 'en-rojo) (eq cambiar-a 'amarillo-intermitente))
           (list 'en-rojo "cambiar-a-amarillo-intermitente"))
          ((and (eq color-actual 'en-amarillo-intermitente) (eq cambiar-a 'verde))
           (list 'en-amarillo-intermitente "cambiar-a-verde"))
          ((and (eq color-actual 'en-verde) (eq cambiar-a 'amarillo-intermitente))
           (list 'en-verde "cambiar-a-amarillo-intermitente"))
          ((and (eq color-actual 'en-amarillo-intermitente) (eq cambiar-a 'amarillo))
           (list 'en-amarillo-intermitente "cambiar-a-amarillo"))
          ((and (eq color-actual 'en-amarillo) (eq cambiar-a 'amarillo-intermitente))
           (list 'en-amarillo "cambiar-a-amarillo-intermitente"))
          ((and (eq color-actual 'en-amarillo-intermitente) (eq cambiar-a 'rojo))
           (list 'en-amarillo-intermitente "cambiar-a-rojo"))
          (t (list color-actual 'accion-por-defecto))))


;; ============================================================
;; FUNCION: informe-archivo
;; NATURALEZA: impura (escribe en archivo)
;; ESTRATEGIA: orden superior (mapcar sobre datos)
;; IMPACTO: no destructiva (no modifica la lista de datos)
;; ============================================================

;; Extension 2 de Iteracion 2: persistencia del log en archivo
;; recibe una lista de eventos: ((timestamp color-ant color-nuevo) ...)
;; abre el archivo informe-ejecucion-semaforo.txt y vuelca el log con formato
;; usa mapcar (no loop) para iterar sobre los eventos
;; usa local-time para que las fechas queden legibles en el archivo
;; if-exists :supersede sobrescribe el archivo si ya existe

(defun informe-archivo (datos)
    (with-open-file (stream "informe-ejecucion-semaforo.txt"
                            :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
        (format stream "Informe de Ejecucion del Sistema Semaforico~%")
        (format stream "===========================================~%")
        (mapcar (lambda (evento)
                    (format stream "~A - Transicion: ~A -> ~A~%"
                        (local-time:format-timestring nil
                            (local-time:unix-to-timestamp (car evento))
                            :format '((:year 4) "-" (:month 2) "-" (:day 2) " "
                                      (:hour 2) ":" (:min 2) ":" (:sec 2)))
                        (cadr evento)
                        (caddr evento)))
                datos)
        (format stream "~%--- Fin del Informe ---~%")))


;; ============================================================
;; R7 - EJEMPLOS QA PARA ITERACION 2
;; ============================================================

;; ---- Ext 1: intermitente ------------------------------------
;; (intermitente 1)   -> T
;; (intermitente 3)   -> T   (borde)
;; (intermitente 4)   -> NIL
;; (intermitente 0)   -> T

;; ---- Ext 1: duracion-ciclo-v2 -------------------------------
;; (duracion-ciclo-v2 '(90 120 6 3))   -> 225   (90+120+6+9)
;; (duracion-ciclo-v2 '(60 100 4 5))   -> 179   (60+100+4+15)
;; (duracion-ciclo-v2 '(0 0 0 3))      -> 9     (solo intermitencias)

;; ---- Ext 1: timer-v2 ----------------------------------------
;; Con tiempos (90 120 6 3):
;; (timer-v2 0   '(90 120 6 3))   -> ROJO
;; (timer-v2 89  '(90 120 6 3))   -> ROJO
;; (timer-v2 90  '(90 120 6 3))   -> AMARILLO-INTERMITENTE
;; (timer-v2 92  '(90 120 6 3))   -> AMARILLO-INTERMITENTE
;; (timer-v2 93  '(90 120 6 3))   -> VERDE
;; (timer-v2 212 '(90 120 6 3))   -> VERDE
;; (timer-v2 213 '(90 120 6 3))   -> AMARILLO-INTERMITENTE
;; (timer-v2 216 '(90 120 6 3))   -> AMARILLO
;; (timer-v2 221 '(90 120 6 3))   -> AMARILLO
;; (timer-v2 222 '(90 120 6 3))   -> AMARILLO-INTERMITENTE
;; (timer-v2 225 '(90 120 6 3))   -> ROJO     (vuelve al inicio)

;; ---- Ext 1: transicion-v2 -----------------------------------
;; Validas:
;; (transicion-v2 'en-rojo 'amarillo-intermitente)
;; -> (EN-ROJO "cambiar-a-amarillo-intermitente")
;; (transicion-v2 'en-amarillo-intermitente 'verde)
;; -> (EN-AMARILLO-INTERMITENTE "cambiar-a-verde")
;; (transicion-v2 'en-amarillo 'amarillo-intermitente)
;; -> (EN-AMARILLO "cambiar-a-amarillo-intermitente")
;;
;; Invalida (cae en default):
;; (transicion-v2 'en-rojo 'verde)
;; -> (EN-ROJO ACCION-POR-DEFECTO)

;; ---- Ext 2: informe-archivo ---------------------------------
;; (informe-archivo '((1718208600 rojo verde)
;;                    (1718208690 verde amarillo)
;;                    (1718208696 amarillo rojo)))
;; -> escribe en disco "informe-ejecucion-semaforo.txt" con todos los eventos formateados
