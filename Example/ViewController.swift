//
//  ViewController.swift
//  LNSTemplateChooser
//
//  Created by Mark Alldritt on 2020-07-12.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import UIKit


class ViewController: LNSSimpleTemplateChooser, UIAdaptivePresentationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  Display an LNSTemplateChooser from a storyboard.
        //
        //  1.  set the template documents to display.  This sample code just gets the samples files from the
        //      Templates folder within the app bundle's Resources folder (see the Copy Templates build phase
        //      to see how these files are copied into th app bundle).
        if let templateURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Templates") {
            templates = templateURLs.map({ (templateURL) in
                return LNSTemplate(url: templateURL, name: templateURL.displayName)
            })
        }

        //  2.  configure a completion handler to call when a template is selected.  In this example I display
        //      an alert and then dismiss the template chooser.
        completion = { [unowned self] (template) in
            let alertController = UIAlertController(title: "Template Chosen",
                                                    message: "The '\(template.name)' template was selected.\n\n\(template.fileURL.path)",
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                //  LNSTemplateChooser indicates the chosen template by highlighting it with the navigation view controller's
                //  tint color and an activity indicator.  If the act of instanciating a template takes some time you can leave
                //  this up to indicate a lengthy action is underway.  The clearOpeningIndication() restores the
                //  LNSTemplateChooser to its normal active state.
                self.clearOpeningIndication()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        
        //  For the purposes of this demo app I add a button to demonsterate displaying a modal template chooser
        //  built in code.
        navigationItem.rightBarButtonItem = LNSBarButtonItem(title: "Modal Test",
                                                             style: .plain,
                                                             actionHandler: modalTest)
    }

    func modalTest(_: LNSBarButtonItem) {
        //  Creating an LNSSimpleTemplateChooser in code:
        
        //  1. create in instance of the LNSSimpleTemplateChooser view controller
        let viewController = LNSSimpleTemplateChooser()
        
        //  2. configure the view controller for presentation within a UINavigationController
        //
        //  2a. add a Cancel button to escape the modal view controller
        let cancelButton = LNSBarButtonItem(barButtonSystemItem: .cancel,
                                            actionHandler: { (_) in
                                            self.dismiss(animated: true, completion: {
                                                print("cancelled!")
                                            })
        })
        viewController.navigationItem.leftBarButtonItem = cancelButton
        
        //  2b. configure the view controller's title
        viewController.navigationItem.title = UIDevice.current.appName()
        
        //  2b. set the template documents to display.  This sample code just gets the samples files from the
        //      Templates folder within the app bundle's Resources folder (see the Copy Templates build phase
        //      to see how these files are copied into th app bundle).
        if let templateURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Templates") {
            viewController.templates = templateURLs.map({ (templateURL) in
                return LNSTemplate(url: templateURL, name: templateURL.displayName)
            })
        }
        
        //  2c. configure a completion handler to call when a template is selected.  In this example I display
        //      an alert and then dismiss the template chooser.
        viewController.completion = { (template) in
            let alertController = UIAlertController(title: "Template Chosen",
                                                    message: "The '\(template.name)' template was selected.\n\n\(template.fileURL.path)",
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            viewController.present(alertController, animated: true, completion: nil)
        }
        
        //  3.  display the template chooser as a model Page Sheet
        let navController = UINavigationController(rootViewController: viewController)
        navController.presentationController?.delegate = self
        navController.modalTransitionStyle = .crossDissolve
        presentModalPageSheet(controller: navController,
                              sender: self,
                              animated: true)
    }
    
    //  MARK: - UIAdaptivePresentationControllerDelegate
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("cancelled!")
    }
}

