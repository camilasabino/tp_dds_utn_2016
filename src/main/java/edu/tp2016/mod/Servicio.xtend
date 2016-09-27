package edu.tp2016.mod

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.joda.time.LocalDateTime
import java.util.ArrayList
import org.uqbar.commons.utils.Observable

@Observable
@Accessors
class Servicio {
	String nombre
	List<DiaDeAtencion> rangoDeAtencion = new ArrayList<DiaDeAtencion>
	
	new(String unNombre, List<DiaDeAtencion> unRango) {
        nombre = unNombre
        rangoDeAtencion = unRango
    }
	

	def boolean contieneEnSuNombre(String texto){
		nombre.contains(texto)
	}

	def boolean tieneRangoDeAtencionDisponibleEn(LocalDateTime fecha){
		rangoDeAtencion.exists[unRango | unRango.fechaEstaEnRango(fecha) ]			
	}
}