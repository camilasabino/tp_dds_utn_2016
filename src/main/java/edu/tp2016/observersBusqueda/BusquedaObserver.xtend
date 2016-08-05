package edu.tp2016.observersBusqueda

import java.util.List
import edu.tp2016.pois.POI
import edu.tp2016.usuarios.Usuario
import edu.tp2016.buscador.Buscador

interface BusquedaObserver {

	def void registrarBusqueda(String texto, List<POI> poisDevueltos, long demora,
		Usuario usuario, Buscador buscador)

}
