/*
 * generated by Xtext
 */
package org.franca.compdeploymodel.dsl;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class FDeployStandaloneSetup extends FDeployStandaloneSetupGenerated{

	public static void doSetup() {
		new FDeployStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

