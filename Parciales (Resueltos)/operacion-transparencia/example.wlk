/*
Operación Transparencia - 2025

Tema 2

Que placer vivir en este país: tenemos un frontend (paisajes) que es una maravilla visual y una comunidad (la gente) que es 100% open source, siempre
colaborando y ayudando al que tiene al lado. El problema, claro está, es el backend: nuestro sistema político. Es ese proyecto legacy que tiene muchísimos
años, escrito en un lenguaje que en ninguna otra parte parte del mundo entienden, lleno de bugs críticos y con modelados implementados sin un solo test que
lo respalde.
Lo peor, es que los devs a cargo insisten en que "en sus máquinas funciona perfecto".
Como no nos dejan hacer el refactor completo que necesitamos, ¡al menos vamos vamos a modelar este caos!

Punto 1 - ¿Estamos en problemas?
Se necesita modelar las causas que investiga la Oficina Anticorrupción. Estas tienen una carátula (un título) y deben poder calcular su perjuicio económico
total al Estado. Toda causa puede ser tratada por una serie de jueces, algunos de ellos muy conocidos como "Dr. Rodolfo Kometa", el "Dr. Armando U. Nacausa",
el "Dr. Jorge Garantis". Todo cálculo monetario está expresado en millones de dólares. El cálculo del perjuicio se calculará de la siguiente manera:

- Para las causas de desvío de fondos que es el monto base de la causa que se le suma un millón y medio por cada año que lleva pendiente la causa.
- La causa de cripto delito tiene un monton base de 5 millones de dólares con carátula "estafa", los jueces que tratan esta causa siempre son los mismos y el
perjuicio económico es el monto base de la causa que se le suman 30% del monto base.
- Las causas complejas están formadas por sub-causas que pueden ser de cualquier tipo (incluso otras causas complejas). El perjuicio económico es el monto
base + la sumatoria de los montos extra que tiene cada sub-causa.

Punto 2 - Ñoqui al pesto
El sistema también debe gestionar a los Funcionarios Públicos. Cualquiera de estos personajes puede tener causas y conocemos su patrimonio actual. Para
comerse una causa en primer lugar tiene que tener patrimonio (no se puede comer una causa alguien que no tiene un mango) y además:

- Los legisladores tienen que tener pocas causas, esto quiere decir que tenga 3 o menos causas.
- Los jefes de gobierno aceptan causas que tienen montos base normales (son impares). Si tiene montos bases raris (pares) no las aceptan.

Queremos que incorpore esta funcionalidad tomando en cuenta las validaciones pedidas por el negocio y en caso de no cumplir alguna regla defina de qué manera
debe responder. Claramente los funcionarios pueden pasar de un puesto a otro en diferentes momentos. La solución debe ser flexible.

Punto 3 - Si Neustadt te viera...
Nos interesa analizar el arco político de nuestro hermoso país. Para ello...

- Nos interesa conocer las carátulas de las causas que tienen montos raris
- Todo funcionario puede salir en medios. Cada vez que sale en medios, aumentan todas las causas que se comieron en 0,1 millones más al monto base.

Punto 4 - Se acerca la campaña 
Se acercan las campañas y como siempre, todos los funcionarios prometen el oro y el moro. Toda la población pide propuestas que luego las transforman en
promesas que tienen (JA!) que cumplir. Estos pedidos tienen una descripción y una fecha de presentación y una fecha que deberían dar cumplimiento. Todas las
propuestas que escuchan a veces las aceptan como están o de lo contrario las toman pero con fecha de cumplimiento 4 años adelante (cuando terminan su
mandato .. XD)

- Los legisladores tienen que mostrar que están conectados con la realidad del pueblo, entonces aceptan tal cual los pedidos que son del año vigente
- A los jefes de gobierno no les gusta leer mucho, por lo tanto aceptan tal cual los pedidos tranquis, que son los que tienen menos de 15 letras.
*/

class Causa {
  var property caratula
  const jueces = []
  var property montoBase
  method montoExtra()
  method perjuicioEconomico() = montoBase + self.montoExtra()
  method tieneMontoBaseRari() = montoBase.even()
  method tieneMontoBaseNormal() = montoBase.odd()
}

class DesvioDeFondos inherits Causa {
  const aniosPendientes

  override method montoExtra() = aniosPendientes * 1.5
}

object criptoDelito inherits Causa (montoBase = 5, caratula = "estafa") {
  override method montoExtra() = montoBase * 0.3
}

class CausaComplejas inherits Causa {
  const subCausas = []

  override method montoExtra() = subCausas.sum({causa => causa.montoExtra()})
}

class FuncionarioPublico {
  var patrimonioActual
  const causas = []
  var puesto
  const propuestas = []

  method tienePatrimonio() = patrimonioActual > 0

  method tienePocasCausas() = causas.size() <= 3

  method seComeUnaCausa(causa) {
    if (!self.tienePatrimonio()) {
      throw new DomainException(message = "No se puede comer una causa sin patrimonio")
    }
    if (puesto.aceptaCausa(causa, self)) {
      causas.add(causa)
    }
  }

  method caratulasConMontosRaris() = causas.filter({causa => causa.tieneMontoBaseRari()}).map({causa => causa.caratula()})

  method saleEnMedios() {
    causas.forEach({causa => causa.montoBase(causa.montoBase() + 0.1)})
  }

  method escucharPropuesta(pedido) {
    if (!puesto.aceptaPedido(pedido)) {
      pedido.postergarFechaDeCumplimiento()
    }
    propuestas.add(pedido)
  }
}

object legislador {
  method aceptaCausa(causa, funcionario) = funcionario.tienePocasCausas()

  method aceptaPedido(pedido) = pedido.esDelAnioVigente()
}

object jefeDeGobierno {
  method aceptaCausa(causa, funcionario) = causa.tieneMontoBaseNormal()

  method aceptaPedido(pedido) = pedido.esTranqui()
}

class Pedido {
  const descripcion
  const fechaPresentacion
  var fechaCumplimiento

  method esDelAnioVigente() = fechaPresentacion.year() == new Date().year()

  method esTranqui() = descripcion.length() < 15

  method postergarFechaDeCumplimiento() = fechaCumplimiento.plusYears(4)
}