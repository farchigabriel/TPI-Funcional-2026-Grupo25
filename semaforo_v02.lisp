
;;------------------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------------------

;;FUNCION:intermitente
;;NATURALEZA:pura
;;ESTRATEGIA: devuelve t si esta dentro del parametro
;;IMPACTO:no destructivo
;;----------------------------------------------------------------------------------------------
(DEFUN INTERMITENTE (SEG)
    ( <= SEG 3))

;;------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------

;;FUNCION:prox_est
;;NATURALEZA:pura
;;ESTRATEGIA:recibe el actual y devuelve el siguiente
;;IMPACTO:destructivo
;;--------------------------------------------------------------------------------------------------
(defun prox_est(est_act)
     (let (aux)
      (setq aux (pop est_act))
      (append est_act (cons aux nil))))
;;-----------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------

;;;FUNCION:espear
;;;NATURALEZA:no pura
;;;ESTRATEGIA: espera que se cumpla el tiempo para cada estado del semaforo y 
;;;            controla la seguridad mediante intermitencia de 3 seg.
;;;IMPACTO:no destructiva
;;;---------------------------------------------------------------------------------------------

(defun esperar(seg)

   (let (t_inicio band)

       (setq t_inicio (tiempo_en_segundos) band 0)
       
       (loop 
        
       (cond ( ( = (+ t_inicio seg) (tiempo_en_segundos)) (return) )
             ( (and (intermitente (- (+ t_inicio seg) (tiempo_en_segundoS))) (= band 0))
                                (progn (format t  "INTERMITENTE-cambia a ")
                                       (setq band 1)))
        )
       )

      )
 
)
;;-------------------------------------------------------------------------------------------  
;;---------------------------------------------------------------------------------------------
;; funcion controla la transicion de los estados del semaforo 
;; devuelve el proximo estado
;; x defecto devuelve el estado actual
;;FUNCION: transicion
;;NATURALEZA:pura
;;ESTRATEGIA:controla si al estado actual le corresponde su estado siguiente
;;IMPACTO:no destructiva
;;---------------------------------------------------------------------------------------
(defun transicion(est_actual proxEst)
       
       (COND ((and(= 1 (NTH 0 est_actual))(= 1 (nth 2 proxEst))) '(0 0 1))
             ((and(= 1 (NTH 1 est_actual))(= 1 (nth 0 proxEst))) '(1 0 0)) 
             ((and(= 1 (NTH 2 est_actual))(= 1 (nth 1 proxEst))) '(0 1 0)) 
             ( t est_actual)
       ))
;;---------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;;FUNCION:semaf
;;;NATURALEZA:no pura
;;;ESTRATEGIA:recibe parametros una lista con los estado,duracion y requerimiento del semaforo
;;;           recursion simple
;;;IMPACTO: destructivo
;;-------------------------------------------------------------------------------------
 
(defun semaf(reque) 

     (let (est_act t_ciclo min)
      (setq est_act (nth 0 reque) t_ciclo (nth 1 reque) min (nth 2 reque)) 
                                                   ;;condicon arranca a las 06:00:00 am
      (cond ((>= (tiempo_en_segundos) 21600)(progn
                        
               (format t "Fecha ~A/~A/~A Tiempo ~A:~A:~A LUZ-> ~A " (dia)(mes)(anio)(hora)(minuto)(segundos) (color_act est_act))
               (esperar(t_est_act est_act t_ciclo))
               (format t "~A  ~%" (color_act (prox_est est_act )))      
              (semaf (list (transicion est_act (prox_est est_act)) t_ciclo  min))
            ))
            ( t  (semaf '((0 1 0)(0 3 0) 0))) ;; entre las 00 hs y las 06 am intermitente

               )))

;;-----------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------
;;FUNCION:t_est_act
;;NATURALEZA:pura
;;ESTRATEGIA:devuelve la duracion en segundos del estado actual
;;IMPACTO:no destructiva

(defun t_est_act(est tiempo)
   (cond ( (= (nth 0 est) 1) (nth 0 tiempo))
         ( (= (nth 1 est) 1) (nth 1 tiempo))
         ( (= (nth 2 est) 1) (nth 2 tiempo))
    )
)
;;-----------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------
;;FUNCION:cal_ciclo
;;NATURALEZA:pura
;;ESTRATEGIA:devuelve el tiempo total del ciclo en seg
;;IMPACTO:no destructiva
;;-----------
 (defun cal_ciclo(tiempo)
                (reduce #'+ tiempo)  
    )
;;-----------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------
;;FUNCION:recomenda
;;NATURALEZA:pura
;;ESTRATEGIA: funcion predicado controla que la duracion del ciclo este dentro de los parametros
;;IMPACTO:no destructiva
;;-----------
(defun recomendar (dura_ciclo)
   ( and (>= dura_ciclo 35) (<= dura_ciclo 150)))
;;-----------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------
;;FUNCION:color_act
;;NATURALEZA:pura
;;ESTRATEGIA:devueve el nombre del color del estado actual del semaforo
;;IMPACTO:no destructivo
;;-----------
(defun color_act(estado)
   (cond ((= (nth 0 estado) 1) 'ROJO)
         ((= (nth 1 estado) 1) 'AMARILLO)
         ((= (NTH 2 estado) 1) 'VERDE)
         )
   )
;;-----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;FUNCION:msj_opt_ciclo
;;NATURALEZA:no pura
;;ESTRATEGIA:mediante una condicion muestra en pantalla el msj
;;IMPACTO:no destructiva
;;-----------
(defun msj_opt_ciclo (opt)
   (cond ( (not opt)  (format t "CICLO NO OPTIMO"))
         ( opt  (format t "CICLO OPTIMO"))
         )
   )
;;--------------------------------------------------------------------------------------
;;--------------------------------------------------------------------------------------
;;FUNCION:ciclo_xminutos
;;NATURALEZA:pura
;;ESTRATEGIA:recibe dos parametros devuelve el calculo cantidad de ciclos
;;IMPACTO:no destructiva
;;-----------
(defun ciclo_xminutos (min t_ciclo)
    (truncate(float(/ (* min 60) t_ciclo)))
    )
;;------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------
;;FUNCION:porcen_tiempo_color
;;NATURALEZA:pura
;;ESTRATEGIA:calcula y devuelve el porcentaje de tiempo de cada color
;;IMPACTO:no destructiva
;;-----------
(defun porcen_tiemp_color (tmp)

   (let (porcen_rojo porcen_amarillo porcen_verde)
      
      (setq porcen_rojo (truncate(float(* 100 (/ (nth 0 tmp) (cal_ciclo tmp))))))
      (setq porcen_amarillo (truncate(float(* 100 (/ (nth 1 tmp) (cal_ciclo tmp))))))
      (setq porcen_verde (truncate(float(* 100 (/ (nth 2 tmp) (cal_ciclo tmp))))))
      (list porcen_rojo porcen_amarillo porcen_verde)
      
   ))
;;------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------
;;;FUNCION:ing_parametros
;;;NATURALEZA:no pura
;;;ESTRATEGIA: se ingresa datos parametros del semaforo y llama a funciones de proces
;;;IMPACTO:
;;-----------
(defun ing_datos_procesos()

   (let (estados t_estados min inf_porc )
        (print "ing.tiempo duracion (rojo amarillo verde)")
        (print "formato lista (ss ss ss)->")
        (setq t_estados (read))
        (setq estados '(1 0 0))
        (setq min 0)
        (print "ing.cant.minutos p/informar cant.ciclos x-min->")
        (setq min (read))
      ;;--------procesos ------------------------------------  
         (msj_opt_ciclo (recomendar(cal_ciclo t_estados)))
         (plan_temp min t_estados)
         (info_distr_temp t_estados)
      ;;----------------------------------------------------
        (list estados t_estados min)) 

       )
;;----------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------
;;FUNCION:Princ_Semaforo
;;NATURALEZA:pura
;;ESTRATEGIA:iniciar el funcionamiento del semaforo
;;IMPACTO:no destructiva
;;--------------------------------------------------------------------------------
(defun princ_semaforo()
  (semaf(ing_datos_procesos))

   )
;;---------------------------------------------------------------------------------
;;FUNCION:plan_temp
;;NATURALEZA:NO PURA
;;ESTRATEGIA:MUESTRA EL NRO DE CICLOS EN CANTIDAD DE MINUTOS DADOS
;;IMPACTO:NO DESTRUCTIVA
;;---------------------PLANIFICACION TEMPORAL------------------------------------------------------
 (defun plan_temp (min tmp)
   (format t " Cant.de ciclos en ~A minutos es ~A ciclos ~%" min (ciclo_xminutos min (cal_ciclo tmp)))
   )
;;---------------------------------------------------------------------------------
;;FUNCION:info_distr_temp
;;NATURALEZA:NO PURA
;;ESTRATEGIA:MOSTRA EN PANTALLA INFORME DE LOS PORCENTAJE DE TIEMPO DE CADA ESTADO DEL SEMAFORO
;;IMPACTO:
;;-------------------------------INFORME DE LA DISTRIBUCION TEMPORAL-------------------------------
(defun info_distr_temp (t_ciclo)
   (format t "% tiempo rojo-> ~A" (nth 0 (porcen_tiemp_color t_ciclo)))
    (format t "% tiempo amarillo-> ~A" (nth 1 (porcen_tiemp_color t_ciclo)))
    (format t "% tiempo verde-> ~A ~%" (nth 2 (porcen_tiemp_color t_ciclo)))
   )
;;-------------------------------------------------------------------------------------------