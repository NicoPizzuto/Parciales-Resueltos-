/*
Mi sueño es...

Cada persona tiene una serie de sueños que quiere cumplir. Todas las personas tienen edad, carreras que quieren estudiar, saben la plata que quieren ganar y 
los lugares a los que quieren viajar. Algunos tienen hijos y otros no.
Las personas tienen una serie de sueños que quieren cumplir, por ejemplo:
1.	Recibirse de una carrera: por ejemplo de “Ingeniero en Sistemas de Información”, “Odontólogo” o “Licenciado en Psicología”.
2.	Tener un hijo.
3.	Adoptar una cantidad x de hijos.
4.	Viajar a un lugar, como “Chapadmalal” o “Tahití”. 
5.	Conseguir un laburo donde se gane una cantidad x de plata.
Nos interesa poder modelar nuevos sueños a futuro. Cada sueño brinda a la persona que lo cumple un nivel de felicidad o “felicidonios”.

Punto 1 | 4 puntos
Hacer que una persona cumpla un sueño, lo que implica pasar algunas validaciones previas:
●	tratar de recibirse de una carrera que no quiere estudiar una persona no es correcto
●	tampoco es válido recibirse de una carrera en la que ya se recibió dicha persona
●	conseguir un trabajo donde la plata que se gana es menos de lo que quiere ganar no es correcto
●	si uno tiene un hijo no se puede adoptar otro (así lo pidió el usuario)

En el caso en que no se pueda cumplir un sueño, utilizar la técnica que considere adecuada para implementarlo. Una vez cumplido el sueño, debe quedar en claro 
la lista de sueños cumplidos vs. la de pendientes. Diseñarlo de la forma que crea más conveniente.

Punto 2 | 2 puntos
Modelar un sueño múltiple, que permite unir varios sueños:
●	viajar a Cataratas
●	tener 1 hijo
●	conseguir un trabajo de $ 10,000

Esto hace que se cumplan los 3 sueños. Si alguno de los 3 no se pueden cumplir debería tirar error y no cumplir ninguno, ej:
●	viajar a Cataratas
●	tener 1 hijo
●	conseguir un trabajo de $ 200 (la persona quiere ganar $ 7.000)
Esto produce un error. No hace falta considerar el estado en el que queda la persona al ir cumpliendo sueños (ej: tener 1 hijo, adoptar 1 hijo podría tirar 
error por separado pero no si participan de un sueño múltiple)

Punto 3 | 4 puntos
Hemos clasificado diferentes tipos de personas. Los realistas cumplen la meta más importante para ellos , los alocados quieren cumplir un sueño cualquiera al 
azar, los obsesivos cumplen el primer sueño de la lista. Pueden aparecer a futuro nuevos tipos de persona. Resolver el requerimiento que pide que una persona 
cumpla su sueño más preciado, teniendo en cuenta que queremos que una persona realista pueda pasar de alocado a realista o de realista a obsesivo.

Punto 4 | 2 puntos
Queremos saber si una persona es feliz, esto se da si el nivel de felicidad que tiene es mayor a los felicidonios que suman los sueños pendientes.

Punto 5 | 2 puntos
Queremos saber si una persona es ambiciosa, esto se da si tiene más de 3 sueños (pendientes o cumplidos) con más de 100 felicidonios.
*/

class Persona {
  const edad
  const plataDeseada
  const sueniosQueQuiereCumplir = []
  const carrerasQueQuiereEstudiar = []
  const carrerasDeLasQueSeRecibio = []
  const lugaresQueQuiereViajar = []
  const laburosConseguidos = []
  var cantidadDeHijos
  var tipoPersona
  var felicidad

  method cumplirSuenio(suenio) {
    if (!self.sueniosPendientes().contains(suenio)) {
      throw new DomainException(message = "El sueño " + suenio + " no está pendiente")
    }
    suenio.cumplirSuenio(self)
  }

  method sueniosPendientes() = sueniosQueQuiereCumplir.filter {suenio => suenio.estaPendiente()}

  method quiereEstudiar(carrera) = carrerasQueQuiereEstudiar.contains(carrera)
  
  method yaSeRecibioDe(carrera) = carrerasDeLasQueSeRecibio.contains(carrera)

  method completarCarrera(carrera) {
    carrerasDeLasQueSeRecibio.add(carrera)
  }

  method tieneHijos() = cantidadDeHijos > 0

  method agregarHijo(cantidad) {
    cantidadDeHijos += cantidad
  }

  method viajaA(lugar) {
    lugaresQueQuiereViajar.add(lugar)
  }

  method consigueLaburo(plataOfrecida) {
    laburosConseguidos.add(plataOfrecida)
  }

  method cumpleSuenioMasPreciado() {
    const suenioACumplir = tipoPersona.elegirSuenio(self.sueniosPendientes())
    self.cumplirSuenio(suenioACumplir)
  }

  method sumarFelicidad(cantidad) {
    felicidad += cantidad
  }

  method esFeliz() = felicidad > self.sueniosPendientes().sum {suenio => suenio.felicidonios()} 

  method sueniosAmbiciosos() = sueniosQueQuiereCumplir.filter {suenio => suenio.esAmbicioso()}

  method esAmbiciosa() = self.sueniosAmbiciosos().size() > 3

}

class Suenio {
  var cumplido

  method estaPendiente() = !cumplido

  method cumplir(persona) {
    self.validar(persona)
    self.realizar(persona)
    self.marcarCumplido()
    persona.sumarFelicidad(self.felicidonios())
  }

  method felicidonios()

  method validar(persona)

  method realizar(persona)

  method marcarCumplido() {cumplido = true}

  method esAmbicioso() = self.felicidonios() > 100
}

class SuenioSimple {
  var felicidonios

  method felicidonios() = felicidonios
}

class SuenioMultiple inherits Suenio {
  const suenios = []

  override method felicidonios() = suenios.sum{sueno => sueno.felicidonios()}

  override method validar(persona) {
    suenios.forEach({suenio => suenio.validar(persona)})
  }

  override method realizar(persona) {
    suenios.forEach({suenio => suenio.realizar(persona)})
  }
}

class RecibirseDeCarrera inherits Suenio {
  const carrera
  
  override method validar(persona) {
    if (!persona.quiereEstudiar(carrera)) {
      throw new DomainException(message = "La persona no quiere estudiar la carrera " + carrera)
    }
    if (persona.yaSeRecibioDe(carrera)) {
      throw new DomainException(message = "La persona ya se recibió de la carrera " + carrera)
    }
  }

  override method realizar(persona) {
    persona.completarCarrera(carrera)
  }
}

class TenerUnHijo inherits Suenio {
  const hijosAAdoptar

  override method validar(persona) {
    if (persona.tieneHijos()) {
      throw new DomainException(message = "La persona ya tiene un hijo")
    }
  }

  override method realizar(persona) {
    persona.agregarHijo(hijosAAdoptar)
  }
}

class ViajarALugar inherits Suenio {
  const lugar

  override method validar(persona) {
    // No tiene validaciones específicas
  }

  override method realizar(persona) {
    persona.viajaA(lugar)
  }
}

class ConseguirLaburo inherits Suenio {
  const plataOfrecida

  override method validar(persona) {
    if (plataOfrecida < persona.plataDeseada()) {
      throw new DomainException(message = "La plata ofrecida " + plataOfrecida + " es menor a la deseada " + persona.plataDeseada())
    }
  }

  override method realizar(persona) {
    persona.consigueLaburo(plataOfrecida)
  }
}

object realista {
  method elegirSuenio(sueniosPendientes) {
    sueniosPendientes.max {suenio => suenio.felicidonios()}
  }
}

object alocado {
  method elegirSuenio(sueniosPendientes) {
    sueniosPendientes.anyOne()
  }
} 

object obsesivo {
  method elegirSuenio(sueniosPendientes) {
    sueniosPendientes.first()
  }
}
