/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * Author: Manfred Bathelt (manfred.bathelt@bmw.de)
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.ui.labeling

import com.google.inject.Inject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.jface.resource.JFaceResources
import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.ui.editor.utils.TextStyle
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider
import org.eclipse.xtext.ui.label.StylerFactory
import org.franca.compmodel.dsl.fcomp.FCAnnotation
import org.franca.compmodel.dsl.fcomp.FCAnnotationBlock
import org.franca.compmodel.dsl.fcomp.FCAnnotationType
import org.franca.compmodel.dsl.fcomp.FCAssemblyConnector
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCDelegateConnector
import org.franca.compmodel.dsl.fcomp.FCDevice
import org.franca.compmodel.dsl.fcomp.FCInjectedPrototype
import org.franca.compmodel.dsl.fcomp.FCInstance
import org.franca.compmodel.dsl.fcomp.FCInstanceCreator
import org.franca.compmodel.dsl.fcomp.FCPartitionedInstance
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPrototype
import org.franca.compmodel.dsl.fcomp.FCPrototypeInjection
import org.franca.compmodel.dsl.fcomp.FCProvidedPort
import org.franca.compmodel.dsl.fcomp.FCRequiredPort
import org.franca.compmodel.dsl.fcomp.FCVersion
import org.franca.compmodel.dsl.fcomp.Import

/**
 * Provides labels for EObjects.
 * 
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#label-provider
 */
class FCompLabelProvider extends DefaultEObjectLabelProvider {

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}
	
	@Inject 
	StylerFactory stylerFactory

	// ********** labels ***********
	public def String text(FCInstance element) {
		if (element.name === null)
			element.component.name
		else
			element.name.split('\\.').last
	}
		
	public def text(FCPort element) {
		val styledString = element.name.convertToStyledString
		if (element.name != element.interface.name) {
			val TextStyle textStyle = new TextStyle()
			val fontData= JFaceResources.getDialogFont().getFontData
			fontData.get(0).style = SWT.ITALIC
			textStyle.setFontData(fontData)
			// textStyle.color = new RGB(63, 72, 204)
			textStyle.color = new RGB(0, 0, 0)
			styledString.append(' [')
			styledString.append(stylerFactory.createFromXtextStyle(element.interface.name, textStyle))
			styledString.append(']')
		}
		styledString	
	}
	
	public def text(FCPartitionedInstance partition) {
		partition.instance.name
	}
	
	public def text (FCInstanceCreator creator) {
		creator.component.name
	}
	
	public def String text(FCComponent element) {
		var String text = ''
		if (element.abstract)
			text += "\u00ABabstract\u00BB "
		if (element.service)
			text += "\u00ABservice\u00BB "
		if (element.root)
			text += "\u00ABroot\u00BB "
		if (element.singleton)
			text += "\u00ABroot\u00BB "
		
		text + element.name.split('\\.').last
	}

	public def String text(FCAssemblyConnector element) {
		element.from.port.name + " to " + element.to.port.name // + ' \u221E ' + element.to.port.name + "." + element.to.port.name 
	}

	public def String text(FCDelegateConnector element) {
		element.inner.port.name + " to " + element.outer.port.name // + ' \u221E ' + element.outer.port.name
	}
	
	public def String text(FCAnnotationBlock element) {
		"annotations"
	}
	
	public def String text(FCInjectedPrototype inject) {
		inject.component.name.split('\\.').last + " into " + inject.ref.name.split('\\.').last
	}
	
	public def String text(FCPrototypeInjection inject) {
		inject.ref.name.split('\\.').last +" by " + inject.name.split('\\.').last  
	}
	
	public def String text(FCAnnotation element) {
		var String name 
		if (element.kind == FCAnnotationType.CUSTOM) 
			name = element.tag.name.substring(1) 
		else 
			name = element.kind.literal.substring(1) 
			
		if (element.value === null)
			name
		else 
			name + element.value	
	}
	
	
	public def String text(FCVersion element) {
		"v" + element.major + "." + element.minor
	}
	
	public def String text(Import element) {
		var String imported = null
		if (element.importedNamespace !== null)
			imported = element.importedNamespace
		else 
			imported = '*' 
		imported + " \u2192 " + element.importURI
	}      
	
	// ******** icons *********
	
	public def String image(FCAnnotation element) {
		if (element.kind == FCAnnotationType.CUSTOM)
			"bluelabel.png"
		else
			"@.png"
			
	}
	
    public def String image(FCAnnotationBlock element) {
		"annotation.png"
	}

	val static datags = #["@framework", "@cluster", "@dienst" ]
	public def String image(FCComponent element) {
		
		if (element.comment !== null ) {
			var tags = element.comment.elements
				.filter(FCAnnotation).filterNull()
				.filter[kind == FCAnnotationType.CUSTOM]
				.map[tag.name]
			
			// TODO: test if label is present in file system	
			val found = tags.findFirst[datags.contains(it)]
			if (found != null)
				return found + ".png"			
		}
		"component.png"
	}

	public def String image(FCPrototype element) {
		"prototype.png"
	}

	public def String image(FCPartitionedInstance element) {
		"instance.png"
	}
	
	public def String image(FCInstanceCreator element) {
		"creator.png"
	}

	public def String image(FCRequiredPort element) {
		"requires.png"
	}

	public def String image(FCProvidedPort element) {
		"provides.png"
	}

	public def String image(FCAssemblyConnector element) {
		"connector.png"
	}

	public def String image(FCDelegateConnector element) {
		"delegate.png"
	}
	
	public def String image(FCInjectedPrototype element) {
		"inject.png"
	}
	
	public def String image(FCPrototypeInjection element) {
		"inject.png"
	}

	public def String image(Import element) {
		"import.gif"
	}

	public def String image(FCDevice element) {
		"device.png"
	}

	public def String image(FCVersion element) {
		"version.gif"
	}
}
