package edu.tp2016.procesos

import org.eclipse.xtend.lib.annotations.Accessors
import edu.tp2016.usuarios.Administrador
import org.joda.time.LocalDateTime
import edu.tp2016.servidores.ServidorCentral

@Accessors
abstract class Proceso {
	
	Proceso accionEnCasoDeError = null
	int reintentos = 1
	LocalDateTime inicio = new LocalDateTime
	Administrador usuarioAdministrador
	ServidorCentral servidor
	
	def void iniciar(){
		if (reintentos == 0){
			registrarError(new Exception("Reintentos excedidos"))
		}
		reintentos --
		try{
			this.correr()
			registrarExito()
		}catch(Exception e){
			manejarError(e)
		}
	}
	
	/**
	 * Realiza la ejecución de un proceso y retorna su resultado (ok, error).
	 * 
	 * @param Ninguno
	 * @return String resultado de la ejecución
	 */
	def String correr(){
		
	}
	
	def void manejarError(Exception e){
		registrarError(e)
		if (accionEnCasoDeError != null){
			accionEnCasoDeError.iniciar()
		}		
	}
	
	def void registrarExito(){
		usuarioAdministrador.registrarResultado(new ResultadoDeProceso(inicio, new LocalDateTime, this, usuarioAdministrador, "exito"))
	}
	
	def void registrarError(Exception e){
		usuarioAdministrador.registrarResultado(new ResultadoDeProceso(inicio, new LocalDateTime, this, usuarioAdministrador, "error", e.message))
	}
}