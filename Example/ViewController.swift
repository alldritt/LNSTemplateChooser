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
        
        navigationItem.rightBarButtonItem = LNSBarButtonItem(title: "Modal Test",
                                                             style: .plain,
                                                             actionHandler: modalTest)
                
        completion = { [unowned self] (template) in
            let alertController = UIAlertController(title: "Template Chosen",
                                                    message: "The '\(template.name)' template was selected.\n\n\(template.fileURL.path)",
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.clearOpeningIndication()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        
        if let templateURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Templates") {
            templates = templateURLs.map({ (templateURL) in
                return LNSTemplate(url: templateURL, name: templateURL.displayName)
            })
        }
        
        // Do any additional setup after loading the view.
    }

    func modalTest(_: LNSBarButtonItem) {
        let viewController = LNSSimpleTemplateChooser()
        let navController = UINavigationController(rootViewController: viewController)
        let cancelButton = LNSBarButtonItem(barButtonSystemItem: .cancel,
                                            actionHandler: { (_) in
                                            self.dismiss(animated: true, completion: {
                                                print("cancelled!")
                                            })
        })
        
        viewController.navigationItem.leftBarButtonItem = cancelButton
        if let templateURLs = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Templates") {
            viewController.templates = templateURLs.map({ (templateURL) in
                return LNSTemplate(url: templateURL, name: templateURL.displayName)
            })
        }
        viewController.completion = { (template) in
            let alertController = UIAlertController(title: "Template Chosen",
                                                    message: "The '\(template.name)' template was selected.\n\n\(template.fileURL.path)",
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            viewController.present(alertController, animated: true, completion: nil)
        }

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

