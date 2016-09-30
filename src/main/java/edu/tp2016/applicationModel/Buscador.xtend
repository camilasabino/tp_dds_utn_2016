package edu.tp2016.applicationModel

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.List
import edu.tp2016.pois.POI
import org.joda.time.LocalDateTime
import java.util.ArrayList
import com.google.common.collect.Lists
import org.joda.time.Duration
import edu.tp2016.serviciosExternos.ExternalServiceAdapter
import edu.tp2016.repositorio.Repositorio
import edu.tp2016.observersBusqueda.Busqueda
import java.util.HashMap
import edu.tp2016.usuarios.Administrador
import edu.tp2016.usuarios.Usuario
import org.joda.time.LocalDate
import edu.tp2016.serviciosExternos.MailSender
import org.uqbar.commons.utils.Observable
import edu.tp2016.builder.ParadaBuilder
import java.util.Arrays
import edu.tp2016.mod.DiaDeAtencion
import org.uqbar.geodds.Point
import edu.tp2016.builder.ComercioBuilder
import edu.tp2016.mod.Rubro
import org.uqbar.commons.model.IModel
import java.util.HashSet
import java.util.Set
import edu.tp2016.builder.CGPBuilder
import org.uqbar.geodds.Polygon
import edu.tp2016.mod.Comuna
import edu.tp2016.mod.Servicio
import edu.tp2016.builder.BancoBuilder

@Observable
@Accessors
class Buscador implements IModel<Buscador>{
	List<POI> resultados = new ArrayList<POI>
	public POI poiSeleccionado
	String nuevoCriterio = ""
	List<String> criteriosBusqueda = new ArrayList<String>
	boolean initStatus = false 
	String mensajeInvalido
	String criterioSeleccionado
	/*-----------------------------------------------------------------------------------*/
	List<ExternalServiceAdapter> interfacesExternas = new ArrayList<ExternalServiceAdapter>
	public Repositorio repo = Repositorio.getInstance
	List<Busqueda> busquedas = new ArrayList<Busqueda>
	List<Administrador> administradores = new ArrayList<Administrador>
	Usuario usuarioActual
	LocalDateTime fechaActual
	MailSender mailSender
	Point ubicacion = new Point(-34.6596291, -58.4681825) //Bartolome Mitre y Callao: (-34.607984, -58.392070) 
	
	new(){
		fechaActual = new LocalDateTime()
	}
	
	new(Usuario usuario){
		this.usuarioActual = usuario
		this.usuarioActual.ubicacionActual = ubicacion
	}
	
	override Buscador getSource(){
		this
	}
	
	def init(){
		if(!initStatus){
			resultados.clear
			mensajeInvalido = ""
			if (repo.isEmpty) repo.agregarVariosPois(crearJuegoDeDatos)
			initStatus = true
		}
	}

// CONSULTAS:
	def boolean consultarCercania(POI unPoi, POI otroPoi) {
		unPoi.estaCercaA(otroPoi.ubicacion)
	}

	def boolean consultarDisponibilidad(POI unPoi, String texto) {
		unPoi.estaDisponible(fechaActual, texto)
	}
	
// BÚSQUEDA EN EL REPOSITORIO:
	def List<POI> buscar(String texto){
		val t1 = new LocalDateTime()
		
		val listaDePoisDevueltos = buscarPor(texto).toList
		
		val t2 = new LocalDateTime()
		val demora = (new Duration(t1.toDateTime, t2.toDateTime)).standardSeconds
		usuarioActual.registrarBusqueda(Arrays.asList(texto), listaDePoisDevueltos, demora, this)

		listaDePoisDevueltos
	}

	def void obtenerPoisDeInterfacesExternas(String texto, List<POI> poisBusqueda) {
		interfacesExternas.forEach [ unaInterfaz |
			poisBusqueda.addAll(unaInterfaz.buscar(texto))
		]
	}
	
	def Iterable<POI> buscarPor(String texto) {
		val poisBusqueda = new ArrayList<POI>
		poisBusqueda.addAll(repo.allInstances)

		obtenerPoisDeInterfacesExternas(texto, poisBusqueda)

		poisBusqueda.filter [ poi | texto != null && !texto.isEmpty &&
			(poi.tienePalabraClave(texto) || poi.coincide(texto))
		]
	}
	
	/**
	 * Devuelve el POI cuyo id se pasó como parámetro de búsqueda.
	 * Obs.: Busca en el repopsitorio de pois
	 * 
	 * @params id de un POI
	 * @return un POI
	 */
	def List<POI> buscarPorId(int _id) {
		val repoDePois = new ArrayList<POI>
		repoDePois.addAll(repo.allInstances)
		
		Lists.newArrayList( repoDePois.filter [ poi | poi.id.equals(_id)] )
	}
	
	def void registrarBusqueda(Busqueda unaBusqueda){
		busquedas.add(unaBusqueda)
	}

// REPORTES DE BÚSQUEDAS:
	def generarReporteCantidadTotalDeBusquedasPorFecha() {
		val reporte = new HashMap<LocalDate, Integer>()

		busquedas.forEach [ busqueda |

			val date = busqueda.fecha.toLocalDate

			if (reporte.containsKey(date)) {
				reporte.put(date, reporte.get(date) + 1)
			} else {
				reporte.put(date, 1)
			}
		]
		reporte
	}

	def generarReporteCantidadDeResultadosParcialesPorTerminal() {
		val reporte = new HashMap<String, List<Integer>>()

		busquedas.forEach [ busqueda |

			if (!reporte.containsKey(busqueda.nombreUsuario)) {
				reporte.put(busqueda.nombreUsuario, new ArrayList<Integer>)
			}
			reporte.get(busqueda.nombreUsuario).add(busqueda.cantidadDeResultados)
		]
		reporte
	}

	def generarReporteCantidadDeResultadosParcialesDeUnaTerminalEspecifica(String nombreDeConsulta) {
		generarReporteCantidadDeResultadosParcialesPorTerminal().get(nombreDeConsulta)
	}

	def generarReporteCantidadTotalDeResultadosPorTerminal() {
		val reporte = new HashMap<String, Integer>()

		busquedas.forEach [ busqueda |

			val cantResultados = busqueda.cantidadDeResultados

			if (reporte.containsKey(busqueda.nombreUsuario)) {
				val cantidadAcumulada = reporte.get(busqueda.nombreUsuario) + cantResultados

				reporte.put(busqueda.nombreUsuario, cantidadAcumulada)
			} else {
				reporte.put(busqueda.nombreUsuario, cantResultados)
			}
		]
		reporte
	}
	
// VISTA - USER INTERFACE:	
	def crearJuegoDeDatos(){
		val rangoX = new ArrayList<DiaDeAtencion>
		rangoX.addAll(new DiaDeAtencion(2,10,19,0,0), new DiaDeAtencion(3,10,19,0,0))		
		val ubicacionParadasUTN= new Point(-34.659705, -58.468103)
		
		val utn7parada = new ParadaBuilder().nombre("7_utn").lineaColectivo("7").
		ubicacion(ubicacionParadasUTN).direccion("Mozart 2300").
		claves( Arrays.asList("utn", "campus", "colectivo", "parada")).build
		
		val ubicacionColectivoOnce=new Point(-34.653570, -58.549873)
		val miserere7parada = new ParadaBuilder().nombre("7_once").lineaColectivo("7").
		ubicacion(ubicacionColectivoOnce).direccion("Pueyrredón 1600").
		claves(Arrays.asList("plaza miserere", "once", "colectivo", "parada")).build

		val utn114parada = new ParadaBuilder().nombre("114_utn").lineaColectivo("114").
		ubicacion(ubicacionParadasUTN).direccion("Mozart 2300").
		claves(Arrays.asList("utn", "campus", "colectivo", "parada")).build

		val rubroFarmacia = new Rubro("Farmacia", 1)
		val rubroLibreria = new Rubro("Libreria", 2)
	
		val ubicacionFarmacity=new Point(-34.600319, -58.437463)
	    val comercioFarmacity = new ComercioBuilder().nombre("Farmacity").direccion("Corrientes 5081").
		ubicacion(ubicacionFarmacity).
		claves(Arrays.asList("comercio","medicamentos", "salud", "farmacia")).
		rubro(rubroFarmacia).
		rango(rangoX).build

		val ubicacionLoDeJuan=new Point(-34.600171, -58.420530)
		val comercioLoDeJuan = new ComercioBuilder().nombre("Libreria Juan").direccion("Medrano 850").
		ubicacion(ubicacionLoDeJuan).
		claves(Arrays.asList("comercio","fotocopias", "utiles", "libros")).
		rubro(rubroLibreria).
		rango(rangoX).build
		
		val cultura = new Servicio("Cultura", Lists.newArrayList(new DiaDeAtencion(2,8,16,0,0)))
		val deportes = new Servicio("Deportes", Lists.newArrayList(
			new DiaDeAtencion(2,10,12,0,0), new DiaDeAtencion(4,14,19,30,0),new DiaDeAtencion(6,15,20,30,0)))
        val asesoramientoLegal = new Servicio("Asesoramiento legal", rangoX)
	 
	    val comunaX = new Comuna => [
			poligono = new Polygon()
			poligono.add(new Point(-1, 1))
			poligono.add(new Point(-2, 2))
			poligono.add(new Point(-3, 3))
			poligono.add(new Point(-4, 4))
		]
	
		val ubicacionCGPComuna1 = new Point(-34.608365, -58.370973)
	    val CGPComuna1 = new CGPBuilder().nombre("CGP Comuna 1").
	    	ubicacion(ubicacionCGPComuna1).direccion("Balcarce 52").zonasIncluidas("Puerto Madero-Retiro-San Nicolás").claves(
			Arrays.asList("CGP", "centro de atención", "servicios sociales", "comuna 1")).comuna(comunaX).servicio(
			Arrays.asList(asesoramientoLegal, cultura, deportes)).nombreDirector("").telefono("").build
			
		val ubicacionBancoPatagonia=new Point (-34.657996, -58.471178)
		val BancoPatagonia = new BancoBuilder().nombre("Banco Patagonia").ubicacion(ubicacionBancoPatagonia).direccion("Mozart 2100").claves(
			Arrays.asList("Cobro cheques", "Cajero automático", "Seguros", "Créditos", "Depósitos","Extracciones")).nombreGerente("Armando Lopez").
			sucursal("Lugano").setearHorarios().build
	
	Lists.newArrayList(utn7parada, utn114parada, miserere7parada, comercioFarmacity,
						comercioLoDeJuan, CGPComuna1, BancoPatagonia)
	}
	
	def buscar(){
		init
		resultados.clear
		mensajeInvalido = ""
		val Set<POI> search = new HashSet<POI>(resultados)
		val t1 = new LocalDateTime()
		
		if(criteriosBusqueda.isEmpty) mensajeInvalido = "<< Debe ingresar un criterio de búsqueda >>"
		criteriosBusqueda.forEach [ criterio | search.addAll(buscarPor(criterio).toList) ]
		
		val t2 = new LocalDateTime()
		val demora = (new Duration(t1.toDateTime, t2.toDateTime)).standardSeconds
		usuarioActual.registrarBusqueda(criteriosBusqueda, new ArrayList(search), demora, this)
		
		if(search.isEmpty && !criteriosBusqueda.isEmpty) mensajeInvalido = "<< No se han encontrado resultados para su búsqueda >>"
		search.forEach[
			it.usuario = usuarioActual
			it.favorito = usuarioActual.tienePoiFavorito(it)
		]
		
		resultados.addAll(search)		
	} // Búsqueda adaptada para la UI
	
	def eliminarTodosLosCriterios(){
		criteriosBusqueda.clear()
		mensajeInvalido = ""
	}
	
	def agregarCriterio(){
		mensajeInvalido = ""
		if (nuevoCriterio != ""){
			criteriosBusqueda.add(nuevoCriterio)
			nuevoCriterio = ""
		}
		else{
			mensajeInvalido = "<< Debe ingresar un criterio de búsqueda >>"
		}
	}
	
	def eliminarCriterio(){
		criteriosBusqueda.remove(criterioSeleccionado)
	}
	
}