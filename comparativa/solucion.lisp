// ============================================================
// Fase 3: Estudio Comparativo - Scala
// Reimplementacion de las funciones: transicion y timer
// ============================================================

object Semaforo {

  // ========================================================
  // FUNCIÓN: transicion
  // NATURALEZA: Pura — dados los mismos estados de entrada,
  //             siempre retorna el mismo estado de salida.
  //             No produce efectos secundarios ni modifica
  //             ninguna variable externa.
  // ESTRATEGIA: Orden Superior — utiliza pattern matching
  //             (match/case) para evaluar las combinaciones
  //             de estados, equivalente al cond de Lisp.
  // IMPACTO: No destructiva — devuelve una nueva Lista [Int]
  //          sin modificar las listas recibidas como parametro.
  // ========================================================
  def transicion(estActual: List[Int], proxEst: List[Int]): List[Int] = {
    (estActual, proxEst) match {
      case (List(1, 0, 0), List(_, _, 1)) => List(0, 0, 1)  // Rojo -> Verde
      case (List(0, 1, 0), List(1, _, _)) => List(1, 0, 0)  // Amarillo -> Rojo
      case (List(0, 0, 1), List(_, 1, _)) => List(0, 1, 0)  // Verde -> Amarillo
      case _                              => estActual        // sin transicion valida, queda igual
    }
  }

  // ========================================================
  // FUNCIÓN: timer
  // NATURALEZA: Pura — siempre devuelve el mismo tiempo
  //             para el mismo estado y lista de tiempos.
  //             Sin efectos secundarios.       
  // ESTRATEGIA: Orden Superior — utiliza pattern matching
  //             para seleccionar el tiempo segun el estado
  //             activo, equivalente al cond de Lisp.
  // IMPACTO: No destructiva — solo consulta la lista de
  //          tiempos, no la modifica.
  // ========================================================
  def timer(estado: List[Int], tiempos: List[Int]): Int = {
    (estado, tiempos) match {
      case (List(1, 0, 0), List(t, _, _)) => t  // estado rojo: devuelve tiempo rojo
      case (List(0, 1, 0), List(_, t, _)) => t  // estado amarillo: devuelve tiempo amarillo
      case (List(0, 0, 1), List(_, _, t)) => t  // estado verde: devuelve tiempo verde
      case _                              => 0   // estado no reconocido
    }
  }

}
