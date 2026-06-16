# TPI-Funcional-2026-Grupo25

Trabajo Practico Integrador de la materia Paradigmas de Programacion. Armamos un sistema de control de semaforos urbanos en Common Lisp usando paradigma funcional puro (sin variables mutables, sin bucles imperativos, todo se resuelve con composicion y argumentos).

## Integrantes

- Farchi Juan Gabriel - GitHub: `farchigabriel`
- [Integrante 2] - GitHub: `[usuario]`
- Mario Daniel Rodas - GitHub: `mariorodas1804`
- [Integrante 2] - GitHub: `[usuario]`


## Estructura

```
TPI-Funcional-2026-Grupo25/
├── lisp/
│   ├── core.lisp          Codigo Fase 1 y Fase 2 en Common Lisp
│   └── config.json        Configuracion (no la usamos, queda igual)
├── comparativa/
│   └── solucion.[ext]     Codigo Fase 3 (lenguaje asignado por la catedra)
├── docs/
│   ├── INFORME.md         Informe tecnico
│   ├── HONOR.md           Codigo de honor por integrante
│   └── Capturas.docx      Capturas de los bugs documentados en la bitacora
└── README.md
```

## Requisitos para correr el codigo

Hace falta Quicklisp (https://www.quicklisp.org/beta/) que es el gestor de paquetes. La libreria `local-time` se descarga sola la primera vez que cargues el archivo.

## Convenciones que usamos

Nos pusimos de acuerdo en algunas cosas al principio para que despues no hubiera lio:

**Lista de tiempos**: lista plana de tres enteros en orden fijo (rojo, verde, amarillo). Acceso con `car`, `cadr`, `caddr`. Ejemplo: `'(90 120 6)`.

**Simbolos de color**: el estado actual lleva prefijo `en-` (`'en-rojo`, `'en-verde`, `'en-amarillo`), y el color destino al que queremos ir va sin prefijo (`'rojo`, `'verde`, `'amarillo`). Esto sigue al pie de la letra el ejemplo del R1 de la consigna.

**Ciclo de transiciones**: rojo (90s) → verde (120s) → amarillo (6s) → rojo. Duracion total 216s.

## Notas tecnicas

- El codigo es ANSI Common Lisp puro, asi que es portable entre implementaciones.
- Las funciones puras no leen el reloj adentro: el timestamp viaja como argumento desde afuera. Esto preserva la pureza porque mismo input garantiza mismo output.
- Nada de variables globales mutables, nada de `loop`, `dolist`, `dotimes`, `while`, `setq` o `setf`. Todo se resuelve con `cond`, recursion donde hace falta, y composicion de funciones.

## Enlaces

- Repositorio: https://github.com/farchigabriel/TPI-Funcional-2026-Grupo25
- Video YouTube: [pendiente]
- Informe tecnico: [docs/INFORME.md](docs/INFORME.md)
