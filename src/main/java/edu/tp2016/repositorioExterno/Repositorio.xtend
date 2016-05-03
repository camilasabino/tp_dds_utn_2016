package edu.tp2016.repositorioExterno

import org.uqbar.commons.model.CollectionBasedRepo
import edu.tp2016.pois.POI
import org.apache.commons.collections15.Predicate
import org.apache.commons.collections15.functors.AndPredicate

abstract class Repositorio extends CollectionBasedRepo<POI> {
		
	override def createExample() {
//		throw new UnsupportedOperationException("TODO: auto-generated method stub")
//		new POI
	}
	
	override def getEntityType() {
		typeof(POI)
	}
	
	override def Predicate<POI> getCriterio(POI unPoi) {
		var result = this.criterioTodas
		if(unPoi.nombre != null){
			result = new AndPredicate(result,this.getCriterioPorNombre(unPoi.nombre))
		}
		result
	}
	
	override getCriterioTodas(){
		[POI poi | true] as Predicate<POI>
	}

	def getCriterioPorNombre(String nombre){
		[POI poi | poi.tienePalabraClave(nombre) || poi.coincide(nombre)] as Predicate<POI>
	}
	
}

