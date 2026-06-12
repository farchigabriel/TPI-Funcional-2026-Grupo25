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