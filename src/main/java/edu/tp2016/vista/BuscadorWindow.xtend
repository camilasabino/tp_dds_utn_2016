package edu.tp2016.vista

import org.uqbar.arena.widgets.Panel

import org.uqbar.arena.widgets.Label
import org.uqbar.arena.widgets.TextBox

import static extension org.uqbar.arena.xtend.ArenaXtendExtensions.*
import org.uqbar.arena.widgets.Button
import org.uqbar.arena.widgets.tables.Table
import edu.tp2016.pois.POI
import org.uqbar.arena.widgets.tables.Column
import org.uqbar.arena.layout.ColumnLayout
import org.uqbar.arena.bindings.NotNullObservable
import java.util.HashMap
import edu.tp2016.pois.Banco
import edu.tp2016.pois.CGP
import edu.tp2016.pois.Comercio
import edu.tp2016.pois.ParadaDeColectivo
import org.uqbar.arena.windows.Dialog
import org.uqbar.arena.windows.WindowOwner
import edu.tp2016.applicationModel.Buscador
import org.uqbar.arena.widgets.List

class BuscadorWindow extends Dialog<Buscador>{
	
	new(WindowOwner owner, Buscador model) {
		super(owner, model)
		this.delegate.errorViewer = this
		title = "Búsqueda de POIs"
	}
	
	override protected createFormPanel(Panel mainPanel) {

		new Panel(mainPanel) => [
			new Label(it) => [			
				text = "Criterios de búsqueda"
				fontSize = 10
			]
		]
		new Panel(mainPanel) => [
			
			it.layout = new ColumnLayout(2)
			new List<String>(it) => [
				items <=> "criteriosBusqueda"	
			]				
			new Panel(it)=> [
				new Label(it) => [			
					text = "Nombre:"
				]
				new TextBox(it) => [
					width = 200
					value <=> "nuevoCriterio"
				]
				new Button(it) => [
					caption = "Agregar criterio"	
					onClick[| modelObject.agregarCriterio ]		
				]
				new Button(it) => [
					caption = "Borrar criterios"	
					onClick[| modelObject.eliminarCriterios ]
				]
			]
				
			new Panel(it) => [
				it.layout = new ColumnLayout(3)
				new Label(it) => [ text = "" ] // (Dejarlos porque alinean)
				new Label(it) => [ text = "" ]
				new Label(it) => [ text = "" ]				
				new Button(it) => [
					caption = "Buscar"	
					onClick[| modelObject.buscar ]
				]
				new Button(it) => [
					caption = "Nuevo POI"	
					onClick[| this.openDialogEditar(new MenuNuevoPoiWindow(this, new POI(), model.getSource)) ]	
				]
			]
				
		]
		
		new Panel(mainPanel)=>[
			new Label(it) => [			
				text = "Resultado"
				fontSize = 10
			]
		]

		var table = new Table<POI>(mainPanel, typeof(POI)) => [
			items <=> "resultados"
			value <=> "poiSeleccionado"
		]
		new Column<POI>(table) => [
			title = "Nombre"
			fixedSize = 150
			bindContentsToProperty("nombre")
		]
		new Column<POI>(table) => [
			title = "Dirección"
			fixedSize = 150
			bindContentsToProperty("direccion")
		]
		new Button(mainPanel) => [
			caption = "Editar"	
			onClick[ | this.editarPoi ]
			bindEnabled(new NotNullObservable("poiSeleccionado"))
		]
		new Button(mainPanel)
			.setCaption("Salir")
			.onClick[ | this.cancel ]
	}
	
	def editarPoi(){
		val bloqueQueConstruyeVentana = mapaVentanas.get(modelObject.poiSeleccionado.class)
		this.openDialogEditar(bloqueQueConstruyeVentana.apply)
	}
	
	def getMapaVentanas() {
		return new HashMap<Class<? extends POI>, () => EditarPoiWindow> => [
			put(typeof(Banco), [ | new EditarBancoWindow(this, modelObject.poiSeleccionado) ] )
			put(typeof(CGP), [ | new EditarCGPWindow(this, modelObject.poiSeleccionado) ] )
			put(typeof(Comercio), [ | new EditarComercioWindow(this, modelObject.poiSeleccionado)] )
			put(typeof(ParadaDeColectivo), [ | new EditarParadaWindow(this, modelObject.poiSeleccionado)] )
		]
	}
	
	def openDialogEditar(Dialog<?> dialog) {
		dialog.onAccept[ | modelObject.buscar ]
		dialog.open
	}
	
	def openDialogAgregar(Dialog<?> dialog) {
		dialog.open
	}

}