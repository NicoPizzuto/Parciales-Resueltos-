/*
Espacios urbanos

Contenido a evaluar
●	Composición / Correcta delegación
●	Polimorfismo
●	Herencia / Redefinición
●	Template method o correcto uso de super 
●	Composite / Strategy
●	Diferenciar clases e instancias
●	Manejo de errores

La secretaría de Infraestructura y Mantenimiento de Espacios Verdes de un municipio nos solicita que generemos un modelo para representar su dominio, que 
consiste en hacer un seguimiento a los trabajos de mejora de cada uno de los diferentes espacios urbanos:
●	plazas: tienen un espacio específico dedicado al esparcimiento, además sabemos cuántas canchas tienen
●	plazoletas: delimitan un pequeño espacio medido en metros cuadrados donde no hay césped y rinden homenaje a algún prócer
●	anfiteatros: tienen una capacidad (ej: 1.000 personas), un escenario con un tamaño medido en metros cuadrados
●	multiespacio: está conformado por una serie de plazas, plazoletas, anfiteatros o multiespacios.
Todos los espacios urbanos son activos del municipio, por lo tanto tienen una valuación en pesos, tienen una superficie medida en metros cuadrados, llevan un 
nombre: “Plaza Ciudad de Banff”, “Anfiteatro Parque Centenario”, y sabemos si tienen vallado que se cierra de noche. Periódicamente hay personas que hacen 
diferentes trabajos a cualquiera de estos espacios urbanos, como veremos más adelante. 

1- Espacios urbanos grandes (3 puntos)
Queremos saber si un espacio urbano es grande, esto se da
a.	para todos los espacios urbanos si la superficie total supera los 50 metros cuadrados y además
b.	para las plazas, si tienen más de 2 canchas
c.	para las plazoletas, si el prócer es “San Martín” y de noche se cierra con llave
d.	para los anfiteatros, si la capacidad supera las 500 personas
e.	para los multiespacios, si cumplen todas las condiciones de los espacios urbanos que contienen (ej, si tienen una plaza y una plazoleta, deben satisfacer 
ambas restricciones a la vez)
No debe repetir código ni ideas de diseño. 

2- Trabajadores (5 puntos)
Todas las personas tienen una profesión en algún momento. Queremos que esa profesión pueda cambiar a lo largo del tiempo. Las profesiones determinan varias 
cosas:
1.	Los cerrajeros pueden trabajar con cualquier espacio urbano que no tenga vallado. Una vez cumplido el trabajo el espacio urbano queda con un vallado que 
se cierra de noche. La duración del trabajo de cerrajero es de 5 horas si el espacio es grande o 3 en caso contrario. 
2.	Los jardineros trabajan con espacios urbanos verdes, que son únicamente las plazas que no tienen canchas o los multiespacios que contienen más de 3 
espacios urbanos. Una vez cumplido su trabajo el césped se ve “más lindo”, lo que aumenta la valuación del espacio urbano un 10%. La duración de su trabajo es 
1 hora cada 10 metros cuadrados. Si tenemos 85 metros cuadrados, está bien considerar 8,5 (no es importante la exactitud en el parcial, estamos evaluando 
conocimientos del paradigma). 
3.	Los encargados de limpieza traen una hidrolavadora gigante, trabajan con espacios urbanos “limpiables”, que son los anfiteatros grandes y las plazas (no 
con plazoletas ni con multiespacios). Una vez cumplido su trabajo el espacio urbano se valúa en $ 5.000 más. La duración de su trabajo es 8 horas fijo (un día 
de trabajo).
4.	El costo de cada trabajador se estima en $ 100 la hora para todos los trabajadores, menos para los jardineros que siempre cobran $ 2.500 por trabajo 
realizado. El valor hora del trabajador puede cambiar.
Muestre cómo haría en la consola REPL para que una persona llamada Tito comience siendo cerrajero y luego pase a ser jardinero.

3- Registro de trabajo realizado (4 puntos)
Queremos registrar un trabajo, para lo cual 
●	queremos validar que la persona pueda hacer dicho trabajo (según lo definido en el punto 2), en caso de no pasar dicha validación debe informar de la manera 
que cree más conveniente al usuario
●	a partir de aquí asumimos que pasó la validación para lo cual, debe producir efecto en el espacio urbano (el efecto que causa el trabajo de dicha persona)
●	por último debemos registrar la fecha y asociar la persona que realizó el trabajo con el espacio urbano involucrado, además de la duración y el costo a ese 
momento.

4- Espacios urbanos de “uso intensivo” (3 puntos)
Queremos detectar los espacios urbanos “de uso intensivo”, que son aquellos en los que en el último mes se le hicieron más de 5 trabajos “heavies”. Un trabajo 
heavy depende de la profesión:
●	para los cerrajeros si tardó más de 5 horas o costó más de $ 10.000
●	para los encargados de limpieza si costó más de $ 10.000
●	para los jardineros si costó más de $ 10.000
No debe repetir código ni ideas de diseño.
*/

class EspacioUrbano {
  const superficieTotal
  var property tieneValladoQueSeCierraDeNoche
  var valuacion
  const nombre
  method esGrande() = superficieTotal > 50 && self.esGrandeEspecifico()
  method esGrandeEspecifico()
  method esVerde()
  method aumentarValuacionEn(porcentaje) {
    valuacion = valuacion * (1 + porcentaje / 100)
  }
  method esLimpiable()
  method aumentarValuacionFijaEn(monto) {
    valuacion += monto
  }
  method deUsoIntensivo(trabajosRealizados, profesion) = trabajosRealizados.filter {trabajo => trabajo.esReciente() && trabajo.esHeavy(profesion)}.size() > 5
}

class Plaza inherits EspacioUrbano {
  const property canchas
  override method esGrandeEspecifico() = canchas > 2
  override method esVerde() = canchas == 0
  override method esLimpiable() = true
}

class Plazoleta inherits EspacioUrbano {
  const procer
  override method esGrandeEspecifico() = procer == "San Martín" && tieneValladoQueSeCierraDeNoche
}

class Anfiteatro inherits EspacioUrbano {
  const capacidad
  override method esGrandeEspecifico() = capacidad > 500
  override method esLimpiable() = self.esGrande()
}

class Multiespacio inherits EspacioUrbano {
  const espaciosUrbanos = []
  override method esGrandeEspecifico() = espaciosUrbanos.all {espacioUrbano => espacioUrbano.esGrande()}
  override method esVerde() = espaciosUrbanos.size() > 3
}

class Trabajador {
  var profesion
  var property valorHora = 100

  method puedeTrabajarEn(espacioUrbano) = profesion.puedeTrabajar(espacioUrbano)

  method realizaTrabajoEn(espacioUrbano) = profesion.realizaTrabajo(espacioUrbano)

  method duracionDelTrabajoEn(espacioUrbano) = profesion.duracionDelTrabajo(espacioUrbano)
}

class Profesion {
  method costoDelTrabajo(trabajador, espacioUrbano) = trabajador.duracionDelTrabajo(espacioUrbano) * trabajador.valorHora()

  method esHeavyParaTrabajo(trabajador, espacioUrbano) = trabajador.costoDelTrabajoMasDe(10000, espacioUrbano)
}

object cerrajero inherits Profesion {
  method puedeTrabajar(espacioUrbano) = !espacioUrbano.tieneValladoQueSeCierraDeNoche()

  method realizaTrabajo(espacioUrbano) = espacioUrbano.tieneValladoQueSeCierraDeNoche(true)

  method duracionDelTrabajo(espacioUrbano) = if (espacioUrbano.esGrande()) 5 else 3

  override method esHeavyParaTrabajo(trabajador, espacioUrbano) = trabajador.duracionDelTrabajo(espacioUrbano) > 5 || super(trabajador, espacioUrbano) 
}

object jardinero inherits Profesion {
  method puedeTrabajar(espacioUrbano) = espacioUrbano.esVerde()

  method realizaTrabajo(espacioUrbano) = espacioUrbano.aumentarValuacionEn(10)

  method duracionDelTrabajo(espacioUrbano) = espacioUrbano.superficieTotal() / 10

  override method costoDelTrabajo(trabajador, espacioUrbano) = 2500
}

object encargadoDeLimpieza inherits Profesion {
  method puedeTrabajar(espacioUrbano) = espacioUrbano.esLimpiable()

  method realizaTrabajo(espacioUrbano) = espacioUrbano.aumentarValuacionFijaEn(5000)

  method duracionDelTrabajo(espacioUrbano) = 8
}

/*
const tito = new Trabajador(profesion = cerrajero)
tito.profesion(jardinero)
*/

class Trabajo {
  const fecha
  const duracion
  const costo
  const trabajador
  const espacioUrbano

  method registrar() {
    if (!trabajador.puedeTrabajarEn(espacioUrbano)) {
      throw new DomainException(message = "El trabajador no puede realizar este trabajo en el espacio urbano")
    }
    trabajador.realizaTrabajoEn(espacioUrbano)
  }

  method esHeavy(profesion) = profesion.esHeavyParaTrabajo(trabajador, espacioUrbano)

  method cuestaMasDe(monto, profesion) = profesion.costoDelTrabajo(trabajador, espacioUrbano) > monto

  method esReciente() = new Date() - fecha < 30
}
