// ============================================================
// Fase 3: Estudio Comparativo - Scala
// Reimplementacion de las funciones: transicion y timer
// Modelo coherente con la version Common Lisp del grupo
// (estados simbolicos con prefijo "en-", colores destino sin prefijo)
// ============================================================

object Semaforo {

  // ============================================================
  // Modelo de datos
  // ------------------------------------------------------------
  // En Lisp usamos simbolos ('en-rojo, 'verde, etc) que son
  // dinamicos. En Scala, al ser tipado estatico, los modelamos
  // como Algebraic Data Types con sealed trait + case object.
  // Esto le permite al compilador chequear que solo existan los
  // valores que declaramos.
  // ============================================================

  // Estados actuales del semaforo (equivalentes a 'en-rojo, 'en-verde, 'en-amarillo en Lisp)
  sealed trait EstadoActual
  case object EnRojo extends EstadoActual
  case object EnVerde extends EstadoActual
  case object EnAmarillo extends EstadoActual

  // Colores destino al que se quiere ir (equivalentes a 'rojo, 'verde, 'amarillo en Lisp)
  sealed trait Color
  case object Rojo extends Color
  case object Verde extends Color
  case object Amarillo extends Color

  // Accion especial cuando la transicion no es valida (equivalente a 'accion-por-defecto)
  case object AccionPorDefecto

  // ============================================================
  // FUNCION: transicion
  // NATURALEZA: Pura -- mismas entradas garantizan misma salida,
  //             sin efectos secundarios ni mutaciones.
  // ESTRATEGIA: Pattern Matching (equivalente al cond de Lisp).
  // IMPACTO: No destructiva -- devuelve una nueva tupla sin
  //          modificar los argumentos recibidos.
  // ============================================================
  def transicion(colorActual: EstadoActual, cambiarA: Color): (EstadoActual, Any) = {
    (colorActual, cambiarA) match {
      case (EnRojo, Verde)        => (EnRojo, "cambiar-a-verde")
      case (EnVerde, Amarillo)    => (EnVerde, "cambiar-a-amarillo")
      case (EnAmarillo, Rojo)     => (EnAmarillo, "cambiar-a-rojo")
      case _                      => (colorActual, AccionPorDefecto)
    }
  }

  // ============================================================
  // FUNCION: timer
  // NATURALEZA: Pura -- dado un timestamp y una lista de tiempos
  //             siempre devuelve el mismo color, no consulta el
  //             reloj internamente.
  // ESTRATEGIA: Aplicacion Directa -- aritmetica modular sobre el
  //             ciclo, mas un if/else sobre los tramos.
  // IMPACTO: No destructiva -- no modifica la lista de tiempos.
  // ============================================================
  // tiempos llega en el mismo orden que en Lisp: (rojo, verde, amarillo)
  def timer(timestamp: Int, tiempos: List[Int]): Color = {
    val total = tiempos.sum
    val pos = ((timestamp % total) + total) % total  // soporta timestamps negativos
    if (pos < tiempos(0)) Rojo
    else if (pos < tiempos(0) + tiempos(1)) Verde
    else Amarillo
  }

  // ============================================================
  // Ejemplos de uso (equivalentes a los ejemplos R7 de Lisp)
  // ============================================================
  def main(args: Array[String]): Unit = {
    // transicion - casos validos
    println(transicion(EnRojo, Verde))        // (EnRojo,cambiar-a-verde)
    println(transicion(EnVerde, Amarillo))    // (EnVerde,cambiar-a-amarillo)
    println(transicion(EnAmarillo, Rojo))     // (EnAmarillo,cambiar-a-rojo)
    // transicion - caso invalido
    println(transicion(EnRojo, Amarillo))     // (EnRojo,AccionPorDefecto)

    // timer - bordes del ciclo
    val tiempos = List(90, 120, 6)
    println(timer(0, tiempos))     // Rojo
    println(timer(89, tiempos))    // Rojo
    println(timer(90, tiempos))    // Verde
    println(timer(209, tiempos))   // Verde
    println(timer(210, tiempos))   // Amarillo
    println(timer(215, tiempos))   // Amarillo
    println(timer(216, tiempos))   // Rojo (vuelve a empezar)
  }

}
