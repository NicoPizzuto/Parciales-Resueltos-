/*
El Asadito
 
Es un día precioso. Alrededor de la mesa, varios amigos entre los que se destacan Facu, Moni, Osky y Vero están dispuestos a compartir un asado entre amigos. 
Te pedimos que ayudes a modelar esta situación a través del paradigma OO.

Punto 1) ¿Me pasás la sal? - 3 puntos
Cada persona sabe su posición y qué elementos cerca tiene: sal, aceite, vinagre, aceto, oliva, cuchillo que corta bien, etc.
Queremos modelar que un comensal le pida a otro si le pasa una cosa.

Si la otra persona no tiene el elemento, la operaclassción no puede realizarse.

Lo que ocurre depende del criterio de cada persona tiene:
●	algunos son sordos, le pasan el primer elemento que tienen a mano
●	otros le pasan todos los elementos, “así me dejás comer tranquilo”
●	otros le piden que cambien la posición en la mesa, “así de paso charlo con otras personas” (ambos intercambian posiciones, A debe ir a la posición de B y 
viceversa)
●	y finalmente están las personas que le pasan el bendito elemento al otro comensal

Nos interesa que se puedan agregar nuevos criterios a futuro y que sea posible que una persona cambie de criterio dinámicamente (que pase de darle todos los 
elementos a sordo, por ejemplo). Cuando una persona le pasa un elemento a otro éste (el elemento) deja de estar cerca del comensal original para pasar a estar 
cerca del comensal que pidió el elemento.

Punto 2) A comerrrrrrr - 4 puntos
Cada tanto se pasa una bandeja con una comida, que te dice cuántas calorías tiene y si es carne, por ejemplo: “Pechito de cerdo”, sí es carne e insume 270 
calorías. Cada persona decide si quiere comer, en caso afirmativo registra lo que come. La decisión de comer o no depende de cómo elige la comida, que puede 
ser
●	vegetariano: solo come lo que no sea carne
●	dietético: come lo que insuma menos de 500 calorías, queremos poder configurarlo para todos los que elijan esta estrategia en base a lo que recomiende la 
OMS (Organización Mundial de la Salud)
●	alternado: acepta y rechaza alternativamente cada comida
●	una combinación de condiciones, donde todas deben cumplirse para aceptar la comida

Queremos que cada comensal pueda cambiar su criterio en cualquier momento y queremos que sea fácil incorporar nuevos criterios de elección de comida, así como 
evitar repetir la misma idea una y otra vez.

Punto 3) Pipón - 2 puntos
Queremos saber si un comensal está pipón, esto ocurre si alguna de las comidas que ingirió es pesada (insume más de 500 calorias).

Punto 4) ¡Qué bien la estoy pasando! - 3 puntos
Queremos saber si un comensal la está pasando bien en el asado, esto ocurre en general si esa persona comió algo y
●	Osky no pone objeciones, siempre la pasa bien
●	Moni si se sentó en la mesa en la posición 1@1
●	Facu si comió carne
●	Vero si no tiene más de 3 elementos cerca
*/

class Persona {
    var property posicion = game.at(0, 0)
    const property elementosCercanos = []
    var property criterioParaDarElemento = sordo
    const property comidas = []
    var property criterioDeComida = vegetariano

    method tieneElementoCercano(elemento) = elementosCercanos.contains(elemento)

    method pedirElementoA(elemento, otraPersona) {
        if(!otraPersona.tieneElementoCercano(elemento)) {
            throw new DomainException(message = "La otra persona no tiene el elemento " + elemento)
        }
        criterioParaDarElemento.manejarPedido(self, elemento, otraPersona)
    }

    method primerElemento() = elementosCercanos.first()

    method darElemento(elemento, otraPersona) {
      elementosCercanos.remove(elemento)
      otraPersona.recibirElemento(elemento)
    }

    method recibirElemento(elemento) {
      elementosCercanos.add(elemento)
    }

    method darTodosLosElementosA(otraPersona) {
      elementosCercanos.forEach({elemento => self.darElemento(elemento, otraPersona)})
    }

    method intercambiarPosicionCon(otraPersona) {
      const posicionTemp = posicion
      posicion = otraPersona.posicion()
      otraPersona.posicion(posicionTemp)
    }

    method comer(comida) {
      if(criterioDeComida.aceptaComida(comida)) {
        comidas.add(comida)
      }
    }

    method estaPipon() = comidas.any({comida => comida.esPesada()})

    method comioAlgo() = !comidas.isEmpty()

    method laPasaBienPersonalmente()

    method laPasaBien() = self.comioAlgo() && self.laPasaBienPersonalmente()
}

object sordo {
  method manejarPedido(personaQuePide, elemento, personaQueTiene) {
    personaQueTiene.darElemento(personaQueTiene.primerElemento(), personaQuePide)
  }
}

object daTodo {
  method manejarPedido(personaQuePide, elemento, personaQueTiene) {
    personaQueTiene.darTodosLosElementosA(personaQuePide)
  }
}

object cambiaPosicion {
  method manejarPedido(personaQuePide, elemento, personaQueTiene) {
    personaQuePide.intercambiarPosicionCon(personaQueTiene)
  }
}

object daElemento {
  method manejarPedido(personaQuePide, elemento, personaQueTiene) {
    personaQueTiene.darElemento(elemento, personaQuePide)
  }
}

class Comida {
  const property calorias
  const property esCarne

  method esPesada() = calorias > 500
}

object vegetariano {
  method aceptaComida(comida) = !comida.esCarne()
}

object dietetico {
  var property limiteCalorias = 500
  method aceptaComida(comida) = comida.calorias() < limiteCalorias
}

class Alternado {
	var quiero = false

	method aceptaComida(comida) {
		quiero = !quiero
		return not quiero
	}
}

class Combinado {
  const property criteriosDeAceptacion = []

  method agregarCriterios(criterios) = criteriosDeAceptacion.addAll(criterios)

  method aceptaComida(comida) = criteriosDeAceptacion.all({criterio => criterio.aceptaComida(comida)})
}

object osky inherits Persona {
  override method laPasaBienPersonalmente() = true
}

object moni inherits Persona {
  override method laPasaBienPersonalmente() = posicion == game.at(1, 1)
}

object facu inherits Persona {
  override method laPasaBienPersonalmente() = comidas.any({comida => comida.esCarne()})
}

object vero inherits Persona {
  override method laPasaBienPersonalmente() = elementosCercanos.size() <= 3
}

/*
Punto 5) En teoría... - 2 puntos
indicar un lugar donde utilizó
●	polimorfismo
●	herencia
●	composición
Justificar por qué y qué ventajas le dio.

Polimorfismo

Dónde se utilizó:
- Los objetos sordo, daTodo, cambiaPosicion y daElemento son polimórficos porque todos entienden el mensaje 
manejarPedido(personaQuePide, elemento, personaQueTiene)
- Los objetos vegetariano, dietetico y las instancias de Alternado y Combinado son polimórficos porque todos entienden el mensaje aceptaComida(comida)

Justificación:
La clase Persona puede trabajar con cualquier criterio sin conocer su implementación específica

Ventajas:
- Se pueden agregar nuevos criterios sin modificar la clase Persona
- Cambio dinámico de comportamiento en tiempo de ejecución
- Código más flexible y extensible

Herencia

Dónde se utilizó:
Los objetos osky, moni, facu y vero heredan de la clase Persona

Justificación:
Cada persona comparte el comportamiento común (pedir elementos, comer, estar pipón) pero tiene su propia forma de evaluar si la pasa bien personalmente.

Ventajas:
- Evita duplicar código común en cada persona
- Permite especializar comportamiento mediante override
- Mantiene la consistencia de la interfaz entre todas las personas

Composición

Dónde se utilizó:
La clase Persona tiene como atributos objetos de tipo criterio

Justificación:
En lugar de usar herencia para cada combinación de criterios (PersonaSordaVegetariana, PersonaNormalDietetica, etc.), se delega el comportamiento a objetos 
externos que pueden cambiarse dinámicamente.

Ventajas:

- Evita explosión combinatoria de subclases (4 criterios de dar × 4 criterios de comer = 16 clases)
- Permite cambiar el comportamiento en tiempo de ejecución: facu.criterioDeComida(dietetico)
- Mayor flexibilidad: "favorece composición sobre herencia"
- Cada criterio es independiente y reutilizable
*/
