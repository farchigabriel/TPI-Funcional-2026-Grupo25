;;-----------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------
(defun tiempo_actual()
   (multiple-value-bind (segundo minuto hora dia mes año)(get-decoded-time)
   (list hora minuto segundo dia mes año))
)
;;------------------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------------------
;;funcion predicado devuelve TRUE si seg es <= 3

(DEFUN INTERMITENTE (SEG)
    ( <= SEG 3))

;;-------------------------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------------------------
;;funcion recibe como entrada estado del semadoro y devuelve los segundo de espera que le corresponde
(defun tiempoEsp(estado)
     (cond ((= 1 (nth 0 estado)) 27)
           ((= 1 (nth 1 estado)) 3)
           ((= 1 (nth 2 estado)) 36)))
;;------------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------
;; funcion recibe el estado actual del semaforo y devuelve el proximo estado
(defun prox_est(est_act)
     (let (aux)
      (setq aux (pop est_act))
      (append est_act (cons aux nil))))
;;-----------------------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------------------
;; funcion recibe los el tiempo en segundos que debe espear cada color del semaforo para cambiar 
;; mientras tanto realiza otras funciones requeridas
;; devuelte el estado actual finalizado

(defun esperar(seg)

   (let (t_inicio band estado)

       (setq t_inicio (tiempo_en_segundos) band 0)
       
       (loop 
        
       (cond ( ( = (+ t_inicio seg) (tiempo_en_segundos)) (return) )
             ( (and (intermitente (- (+ t_inicio seg) (tiempo_en_segundoS))) (= band 0))
                                (progn (print "INTERMITENTE")
                                       (setq band 1)))
        )
       )

      )
 (est_seg_tmp seg)
)
;;-------------------------------------------------------------------------------------------  
;;---------------------------------------------------------------------------------------------
;; funcion controla la transicion de los estados del semaforo 
;; devuelve el proximo estado
;; x defecto devuelve el estado actual

(defun transicion(est_actual proxEst)
       
       (COND ((and(= 1 (NTH 0 est_actual))(= 1 (nth 2 proxEst))) '(0 0 1))
             ((and(= 1 (NTH 1 est_actual))(= 1 (nth 0 proxEst))) '(1 0 0)) 
             ((and(= 1 (NTH 2 est_actual))(= 1 (nth 1 proxEst))) '(0 1 0)) 
             ( t est_actual)
       ))
;;---------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;FUNCION PRINCIPAL --> (SEMAF '(ESTADO QUE DESEA QUE ARRANQUE EL SEMAFORO))
;; EJEMPLO---> (SEMAF '(1 0 0)) ...Rojo 
(defun semaf(est_act) 
     
      (cond ((= (tiempo_en_segundos) 0) '(0 0 0))
 
            ((>= (tiempo_en_segundos) 60)(progn
                        (print "R A V")
                        (print est_act)
                        (semaf (transicion est_act (prox_est (esperar(tiempoEsp est_act)))))
                        ))
            ( t  "FUERA DE SERVICIO")

               ))

;;-----------------------------------------------------------------------------------------
;;-----------------------------------------------------------------------------------------
(defun est_seg_tmp()

      (cond ( (= seg 27) '(1 0 0))
              ( (= seg 3) '(0 1 0))
              ( (= seg 36) '(0 0 1))
         )
      )
;;------------------------------------------------------------------------------------------
;;------------------------------------------------------------------------------------------
(defun duracion_ciclo(seg)


