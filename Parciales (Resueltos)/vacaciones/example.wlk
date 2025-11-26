/*
¡Vacaciones!

¡Ah! ¡Qué lindo es estar de vacaciones! Bueno, mientras viajamos mentalmente, nos pidieron modelar e implementar los siguientes requerimientos utilizando los 
conceptos del paradigma de objetos.

Punto 1: Lugares (3 puntos)
Existen diferentes tipos de lugares:
ciudades: tienen una cierta cantidad de habitantes, atracciones turísticas (ej: "Obelisco", "Cabildo", "Rosedal", "Caminito") y sabemos la cantidad de 
decibeles promedio que tiene.
pueblos: nos interesa la extensión en km2, cuándo se fundó y en qué provincia se ubica.
balnearios: son una categoría especial, conocemos los metros de playa promedio que tienen, si el mar es peligroso y si tiene peatonal.

Queremos saber qué lugares son divertidos. Para todos los lugares, esto se da si tiene una cantidad par de letras. Además, para las ciudades, si tienen más de 
3 atracciones turísticas y más de 100.000 habitantes. En el caso de los pueblos, debemos considerar además si se fundaron antes de 1800 o si son del Litoral 
("Entre Ríos", "Corrientes" o "Misiones"). Y en el caso de los balnearios habrá que considerar si tiene más de 300 metros de playa y si el mar es peligroso.

Punto 2: Personas (4 puntos)
Las personas tienen preferencias para irse de vacaciones:
algunos quieren tranquilidad, entonces el lugar al que se van debe ser tranquilo: para una ciudad esto significa que tenga menos de 20 decibeles, para un 
pueblo que esté en la provincia de La Pampa y para un balneario que no tenga peatonal
otros quieren diversión, así que el lugar al que se van debe ser divertido
están los que quieren irse a lugares raros: son aquellos cuyo nombre tiene más de 10 letras (por ejemplo "Saldungaray")
y por último aquellos que combinan varios criterios (con que alguno de los criterios acepte entonces decide ir a ese lugar)
Nos interesa que una persona pueda cambiar su preferencia en forma simple, así como agregar nuevas preferencias a futuro.

Queremos saber si una persona se iría de vacaciones a un lugar en base a su preferencia.

Punto 3: Tour (4 puntos)
Queremos establecer el siguiente flujo para un tour:
Inicialmente definimos una fecha de salida, la cantidad de personas requerida, una lista de lugares a recorrer y el monto a pagar por persona
Luego agregamos a una persona, para lo cual
el monto a pagar debe ser adecuado para la persona: cada persona define un presupuesto máximo para irse de vacaciones
todos los lugares deben ser adecuados para la persona, según lo definido en el punto anterior
en caso contrario, la persona no puede incorporarse al tour
cuando llegamos a la cantidad de personas requerida, el tour se confirma y no se permite incorporar más gente, a menos de que alguna persona se quiera bajar 
(ud. debe implementar la forma de lograr ésto)

Punto 4: Reportes (3 puntos)
Queremos saber:
Qué tours están pendientes de confirmación: son los que tienen menos cantidad de personas anotadas de las que el tour requiere.
Cuál es el total de los tours que salen este año, considerando el monto por persona * la cantidad de personas.
Se considerará explícitamente la delegación y la implementación de soluciones declarativas.
*/

class Lugar {
  const nombre
  method esDivertido() = self.tieneCantidadParDeLetras() && self.esDivertidoEspecifico()
  method tieneCantidadParDeLetras() = nombre.length().even()
  method esDivertidoEspecifico()
  method esTranquilo()
  method esRaro() = nombre.length() > 10
}

class Ciudad inherits Lugar {
  const habitantes
  const atraccionesTuristicas = []
  const decibelesPromedio

  override method esDivertidoEspecifico() = atraccionesTuristicas.size() > 3 && habitantes > 100000
  override method esTranquilo() = decibelesPromedio < 20
}

class Pueblo inherits Lugar {
  const extension
  const fechaFundacion
  const provincia

  override method esDivertidoEspecifico() = fechaFundacion.year() < 1800 || self.esDelLitoral()
  method esDelLitoral() = ["Entre Ríos", "Corrientes", "Misiones"].includes(provincia)
  override method esTranquilo() = provincia == "La Pampa"
}

class Balneario inherits Lugar {
  const metrosDePlayaPromedio
  const marEsPeligroso
  const tienePeatonal

  override method esDivertidoEspecifico() = metrosDePlayaPromedio > 300 && marEsPeligroso
  override method esTranquilo() = !tienePeatonal
}

class Persona {
  var preferencia
  const montoMaximoParaVacaciones

  method quiereIrseDeVacacionesA(lugar) = preferencia.aceptaIrA(lugar)
}

object tranquilo {
  method aceptaIrA(lugar) = lugar.esTranquilo()
}

object divertido {
  method aceptaIrA(lugar) = lugar.esDivertido()
}

object raro {
  method aceptaIrA(lugar) = lugar.esRaro()
}

class Combinado {
  const criterios = []

  method aceptaIrA(lugar) = criterios.any({criterio => criterio.aceptaIrA(lugar)})
}

class Tour {
  const fechaDeSalida
  const cantidadDePersonasRequeridas
  const lugaresARecorrer = []
  const montoAPagarPorPersona
  const personasAnotadas = []

  method validarIncorporacionAlTour(persona) {
    self.validarCantidadDePersonasRequeridas()
    self.validarMontoAPagar(persona)
    self.validarLugaresAdecuados(persona)
  }

  method validarCantidadDePersonasRequeridas() {
    if (personasAnotadas.size() >= cantidadDePersonasRequeridas)
      throw new DomainException(message = "Ya se alcanzó la cantidad de personas requeridas, no puede incorporarse al tour")
  }

  method validarMontoAPagar(persona) {
    if (montoAPagarPorPersona > persona.montoMaximoParaVacaciones())
      throw new DomainException(message = "El monto a pagar es mayor al presupuesto de la persona, no puede incorporarse al tour")
  }

  method validarLugaresAdecuados(persona) {
    if (!lugaresARecorrer.all({lugar => persona.quiereIrseDeVacacionesA(lugar)}))
      throw new DomainException(message = "No todos los lugares son adecuados para la persona, no puede incorporarse al tour")
  }

  method incorporarseAlTour(persona) {
    self.validarIncorporacionAlTour(persona)
    self.agregarPersonaAlTour(persona)
  }

  method agregarPersonaAlTour(persona) {
    personasAnotadas.add(persona)
  }

  method bajarPersonaDelTour(persona) {
    personasAnotadas.remove(persona)
  }

  method estaPendienteDeConfirmacion() = personasAnotadas.size() < cantidadDePersonasRequeridas

  method totalDelTour() = montoAPagarPorPersona * personasAnotadas.size()
}