package edu.tp2016

import org.uqbar.geodds.Point
import org.eclipse.xtend.lib.annotations.Accessors


@Accessors
class Comercio extends POI{
	Rubro rubro
	
	override boolean estaCercaA(Point ubicacionDispositivo){
		 distanciaA(ubicacionDispositivo) < rubro.radioDeCercania
	}
	
	override boolean estaDisponible(FechaCompleta fecha, String nombre){
		
		(this.rubro.nombre).equals(nombre) && this.tieneRangoDeAtencionDisponibleEn(fecha.dia,fecha.hora)
	}
	
	override boolean coincide(String texto){
		 (super.coincide(texto)) || (texto.equalsIgnoreCase(rubro.nombre))
	}
}