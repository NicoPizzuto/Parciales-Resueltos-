/*
Noticias de ayer, extra! extra!

Una importante red multimedios quiere modernizar su diario digital, para lo cual luego de un relevamiento surgieron los siguientes requerimientos que deben 
implementar en el paradigma de objetos.

Punto 1) Chocolate por la noticia (4 puntos)
Toda noticia o artículo tiene una fecha de publicación, la persona que lo publica, su grado de importancia medido en un número que va de 1 a 10, el título y 
el desarrollo de la noticia. Hay tres estilos de noticia o artículo:
●	los artículos comunes pueden tener links a otras noticias
●	hay noticias que son en realidad publicidad encubierta (lo que en la jerga periodística se conoce como “chivo”). Promocionan un producto y sabemos la 
plata que se paga para que la noticia se publique.
●	los reportajes se hacen a alguien (ej: “María Becerra” o a “Los Auténticos Decadentes”)
●	y por último tenemos a una cobertura, que también incluye una serie de noticias que están relacionadas.

Queremos saber si una noticia es copada: en general tiene que ser una noticia importante (su grado de importancia debe ser >= 8), haberse publicado hace menos 
de 3 días y 
●	para los artículos comunes tener al menos 2 links a otras noticias
●	para los chivos, tiene que haberse pagado más de 2M
●	los reportajes son copados si a quien entrevistan tienen una cantidad de letra impar (ej: “Los Auténticos Decadentes” tiene 25 letras, es un reportaje 
copado)
●	y las coberturas son copadas si todas las noticias relacionadas son copadas

Punto 2) El informe pelícano (3 puntos)
Como dijimos antes, las noticias o artículos son publicadas por periodistas, del cual conocemos su fecha de ingreso y sus preferencias:
●	algunos quieren publicar noticias copadas
●	otros quieren publicar noticias que sean sensacionalistas: esto implica que tengan la palabra “espectacular”, “increíble”, o “grandioso” en el título y en 
el caso de los reportajes deben ser también a “Dibu Martínez”
●	están los vagos, que quieren publicar solo chivos o noticias cuyo desarrollo tenga menos de 100 palabras.
●	y está José De Zer, quien disfruta de publicar noticias cuyo título comience con la letra “T”

Punto 3) Primera plana (3 puntos)
Queremos publicar una noticia nueva, para lo cual
●	un periodista no puede publicar por día más de 2 noticias que no prefiere. Por ejemplo: si un periodista quiere publicar noticias copadas, solo puede 
publicar 2 noticias no copadas ese día.
●	una noticia bien escrita debe tener
○	un título que tenga 2 ó más palabras
○	debe tener desarrollo

Queremos que incorpore esta funcionalidad tomando en cuenta las validaciones pedidas por el negocio y en caso de no cumplir alguna regla defina de qué manera 
debe responder.

Punto 4) El cuarto poder (2 puntos)
Queremos poder determinar cuáles son los periodistas recientes que publicaron una noticia en la última semana. Los periodistas recientes ingresaron hace un 
año o menos al multimedio. Se considerará explícitamente la delegación y la implementación de soluciones declarativas.
*/

class Noticia {
    const property gradoDeImportancia
    const property fechaPublicacion
    const property titulo
    const property autor
    var property contenido

    method esCopada() = self.esImportante() && self.esReciente() && self.esCopadaEspecifica()
    method esCopadaEspecifica() //primitiva
    method esImportante() = gradoDeImportancia >= 8
    method esReciente() = new Date() - fechaPublicacion < 3
    method esSensacionalista() = self.tituloContiene(["espectacular", "increible", "grandioso"])
    method tituloContiene(palabras) = palabras.any({palabra => titulo.contiene(palabra)})
    method aptaParaVago() = contenido.words().length() < 100
    method tituloComienzaCon(letra) = titulo.startsWith(letra)
    method esPreferidaPorAutor() = autor.prefiere(self)
    method esDeLaFecha(fecha) = fecha == fechaPublicacion
    method validarBienEscrita() {
        self.validarTitulo()
        self.validarContenido()
    }
    method validarTitulo() {
        if (self.cantidadDePalabrasEnTitulo() < 2)
            throw new DomainException(message = "El titulo tiene mas de 2 palabras")
    }
    method cantidadDePalabrasEnTitulo() = titulo.words().size()
    method validarContenido() {
        if (contenido == "")
            throw new DomainException(message = "Debe tener un contenido")
    }
    method esNueva() = new Date() - fechaPublicacion < 6
    method tieneAutorReciente() = autor.esReciente()
}

class NoticiaComun inherits Noticia {
    const links = []
    override method esCopadaEspecifica() = links.size() > 2
}

class Chivo inherits Noticia {
    const property cantidadPagada
    override method esCopadaEspecifica() = cantidadPagada > 2000000
    override method aptaParaVago() = true
}

class Reportaje inherits Noticia {
    const property entrevistado
    override method esCopadaEspecifica() = entrevistado.length().odd()
    override method esSensacionalista() = super() && entrevistado == "Dibu Martinez"
}

class Cobertura inherits Noticia {
    const property noticias = []
     override method esCopadaEspecifica() = noticias.all{noticia => noticia.esCopada()}
}

class Periodista {
    var property preferencia
    const property fechaDeIngreso
    
    method prefiere(noticia) = preferencia.prefiere(noticia)
    method esReciente() = new Date() - fechaDeIngreso < 365
}

object noticiaCopada{
    method prefiere(noticia) = noticia.esCopada()
}

object noticiaSensacionalista {
    method prefiere(noticia) = noticia.esSensacionalista()
}

object vago{
    method prefiere(noticia) = noticia.aptaParaVago()
}

object joseDeZer{
    method prefiere(noticia) = noticia.tituloComienzaCon("T")
}

object medioDeComunicacion {
    const noticias = []
    
    method validarCantidadDeNoticiasQueNoPrefiere(noticia){
        if(!noticia.esPreferidaPorAutor() && self.limiteDeNoPreferidoPara(noticia.autor()))
            throw new DomainException(message = "ya publicaste 2 noticias que no preferis")
    }

    method agregarNoticia(noticia) {
        self.validarCantidadDeNoticiasQueNoPrefiere(noticia)
        noticia.validarBienEscrita()
        noticias.add(noticia)
    }

    method limiteDeNoPreferidoPara(autor) =
        noticias.count{noticia=>!autor.prefiere(noticia) && noticia.autor() == autor && noticia.esDeLaFecha(new Date())} >= 2

    method periodistasRecientesQuePublicaron() = self.noticiasNuevasPeriodistasRecientes().map{noticia=>noticia.autor()}.asSet()
    method noticiasNuevasPeriodistasRecientes() = noticias.filter{noticia=>noticia.esNueva() && noticia.tieneAutorReciente()}
}