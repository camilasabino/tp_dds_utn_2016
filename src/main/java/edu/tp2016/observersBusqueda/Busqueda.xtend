package edu.tp2016.observersBusqueda

import org.joda.time.LocalDateTime
import org.eclipse.xtend.lib.annotations.Accessors

@ Accessors
class Busqueda {

	LocalDateTime fecha
	String nombreUsuario
	String textoBuscado
	int cantidadDeResultados
	long demoraConsulta
	
}
