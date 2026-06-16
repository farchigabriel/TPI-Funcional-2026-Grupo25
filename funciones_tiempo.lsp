

;;;------------------------------------------------------------------------------------------------
;;;NATURALEZA:pura
;;;FUNCION:tiempo_actual
;;;NATURALEZA:pura
;;;ESTRATEGIA:deuelve la fecha y hora del sistema en forma de lista
;;;IMPACTO:no destructiva
;;-----------
(defun tiempo_actual()
   (multiple-value-bind (segundo minuto hora dia mes año)(get-decoded-time)
   (list hora minuto segundo dia mes año)))
;;;-----------------------------------------------------------------------------------------------
;;;----------------------------------------------------------------------------------------------
;;;FUNCION:hora
;;;NATURALEZA:pura
;;;ESTRATEGIA:devuelve en 1 o 2 digito sola hora del sistema
;;;IMPACTO:no destructivo
;;;-----------
(defun hora ()
      (nth 0 (tiempo_actual)))
;;----------------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------------
;;;FUNCION:minuto
;;;NATURALEZA:pura
;;;ESTRATEGIA:devuelve en 1 o 2 digitos el minuto actual del sitema
;;;IMPACTO:no destructivo
;;-----------
(defun minuto()
      (nth 1 (tiempo_actual)))
;;----------------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------------
;;;FUNCION:segundos
;;;NATURALEZA:pura
;;;ESTRATEGIA:devuelve en 1 o 2 digitos el segundo de la hora actual del sistema
;;;IMPACTO:no destructivo
;;-----------
(defun segundos()
    (nth 2 (tiempo_actual)))
;;----------------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------------
;;;FUNCION:mes
;;;NATURALEZA:pura
;;;ESTRATEGIA:devuelve el mes de la fecha del sistema
;;;IMPACTO:no destructivo
;;-----------
(defun mes()
    (nth 4 (tiempo_actual)))
;;----------------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------------
;;;FUNCION:dia
;;;NATURALEZA:pura
;;;ESTRATEGIA:devuelve el dia de la fecha del sistema
;;;IMPACTO:no destructivo
;;-----------
(defun dia()
    (nth 3 (tiempo_actual))
)
;;----------------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------------
;;;FUNCION:La_hora_es
;;;NATURALEZA:no pura
;;;ESTRATEGIA:muestra en pantalla la hora en formato completo hh:mm:ss
;;;IMPACTO:no destructiva
;;-----------
(defun La_hora_es()
    (princ (hora))
    (princ (minuto))
    (princ (segundos))
   ) 
;;---------------------------------------------------------------------------------------------
;;---------------------------------------------------------------------------------------------
;;;FUNCION:anio
;;;NATURALEZA:pura
;;;ESTRATEGIA:devuelve el año de la fecha del sistema
;;;IMPACTO:no destructiva
;;-----------
(defun anio()
    (nth 5 (tiempo_actual))
)
;;--------------------------------------------------------------------------------------------
;;--------------------------------------------------------------------------------------------
;;;FUNCION:tiempo_en_segundos
;;;NATURALEZA:pura
;;;ESTRATEGIA:devuelve el tiempo en segundo desde el inicio del dia
;;;IMPACTO:no destructivo
;;-----------
(defun tiempo_en_segundos()
    (+(*(hora)3600)(* (minuto)60)(segundos))
)
;;--------------------------------------------------------------------------------------------
;;---------------------------------------------------------------------------------------------
