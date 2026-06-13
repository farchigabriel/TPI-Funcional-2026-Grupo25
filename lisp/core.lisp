;; ============================================================
;; TPI Funcional 2026 - Grupo 25
;; Sistema de Semáforos Inteligentes
;; Integrantes: Mario Daniel Rodas
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
;;utilizacion del cond y dentro un and para realizar la comparaciones (color actual y color destino) color-actual y cambiar-a son los parametros, se utilizan como comparacion contra los literales (simbolos), list para armar la lista de salida
;;cuando: color-actual = 'en-rojo Y cambiar-a = 'verde  devolviendo: (list 'en-rojo "cambiar-a-verde")
;;si todos fallan caemos en la ultima rama
;;opciones: utilizar 'format', pero cond mas legible e entendible

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

;;lista de tiempos como parametro, para que resulte mas funcional
;;reglas: rojo es 90s, verde 120s y amarillo 6s (ciclo completo 216s (duracion-ciclo))
;;condicion con 3 tramos: rojo (0,90), verder (90,210) y amarillo (210,216)
;;comparacion con tramos (el mod del timestamp con duracion-ciclo como parametro deberia dar un numero entre 0 y 215)
;;pos < 90 entonces es rojo ; pos < 90(rojo) + 120(verde) entonces es verde; pos >= 210 entonces es amarillo --operaciones aritmeticas--
;;utilizar let para no recalcular?

(defun timer (timestamp tiempos)
    (let ((pos (mod timestamp (duracion-ciclo tiempos))))
        (cond ((< pos (car tiempos)) 'rojo)
              ((< pos (+ (car tiempos) (cadr tiempos))) 'verde)
              (t 'amarillo))))

;;let para guardar pos de manera local (el mod entre timestamp y la duracion-ciclo) para no calcularlo 3 veces
;;Cambio: no utilizacion del 'caddr tiempos = 6' como tercer comparativo porque por logica si no es verde o rojo es amarillo porque la comparacion abarca todo el ciclo
;;let es un binding asigna un nombre a un valor inmutable. Ademas es funcion puta porque recibe timestamp, no toca el reloj
;;Bug: Paréntesis mal cerrados en cond de timer, causa: olvidé cerrar el paréntesis del < antes del valor de retorno. SBCL interpretó 'verde como tercer argumento del < en lugar de como resultado de la rama. La función habría devuelto NIL o un error de tipo en runtime.
;;Solución: cerrar el < después de la operación, antes del símbolo de resultado.