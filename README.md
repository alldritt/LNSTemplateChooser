# LNSTemplateChooser

A document template chooser for use with UIDocumentBrowserViewController-based applciations that mimics the appearance of Apple's iWork apps.

## iWork as a Starting Point

Apple's iOS iWork (Pages, Numbers &amp; Keynote) apps (circa iOS 13) have quite complex template choosers because of the wide range of templates they offer.  The initial template view is a "grouped" arragement of templates targetting different tasks.  Each group has a Show All action which takes you to a simpler view displaying the templates available for a particular group.

![iWOrk Template Chooser](Assets/iWorkTemplateChooser.png)

## Phase I

I've begin with the simpler "Show All" template chooser view.  This is a farily simple UICollectionView displaying a thumbnail and title for each template.  I've focised on mimicing the iWork look and functionality as much as I can.

Here's where I am so far.

![LNSTemplateChooser Simple](Assets/LNSTemplateChooser.png)

### Installation

Copy the contents of the [`LNSTemplateChooser`](https://github.com/alldritt/LNSTemplateChooser/tree/master/LNSTemplateCooser) folder to your Xcode project.  

### Usage

You can look at the [`ViewController.swift`](https://github.com/alldritt/LNSTemplateChooser/blob/master/Example/ViewController.swift) file in the Example project for an illustration of how to use the LNSTemplateChooser from a sotryboard and in code.

### Integrating with UIDocumentBrowserViewController

My goal is to easily integrate a template chooser into a iOS UIDocumentBrowserViewController-based application.  Here's an example of how to use LNSSimpleTemplateChooser within a UIDocumentBrowserViewController-based application.  Add this code to the class within your app that implements the UIDocumentBrowserViewControllerDelegate protocol:

```
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        // 1. define the template documents you want to offer.
        let template1 = LNSTemplate(url: Bundle.main.url(forResource: "Blank", withExtension: "md", subdirectory: "Templates")!, name: "Blank")
        let template2 = LNSTemplate(url: Bundle.main.url(forResource: "Checklist", withExtension: "md", subdirectory: "Templates")!, name: "Checklist")
        
        // 2. create and configure an instance of LNSSimpleTemplateChooser
        let viewController = LNSSimpleTemplateChooser()
        viewController.templates = [template1, template2]
        viewController.completion = { (template) in
            self.dismiss(animated: true, completion: {
                importHandler(template.fileURL, .copy)
            })
        }

        // 3. add a Cancel button to escape the modal presentation
        let cancelButton = LNSBarButtonItem(barButtonSystemItem: .cancel,
                                            actionHandler: { (_) in
                                            self.dismiss(animated: true, completion: {
                                                importHandler(nil, .none)
                                            })
        })
        
        viewController.navigationItem.leftBarButtonItem = cancelButton

        // 4. present the LNSSimpleTemplateChooser as a full-screen modal presentation mimicing iWork
        let navController = UINavigationController(rootViewController: viewController)

        navController.modalTransitionStyle = .crossDissolve
        presentModalFullScreen(controller: navController,
                               sender: self,
                               animated: true)
    }
```

__NOTE__: This code depends on the [`LNSBarButtonItem.swift`](https://github.com/alldritt/LNSTemplateChooser/blob/master/Example/LNSBarButtonItem.swift) (for `LNSBarButtonItem`) and [`LNSUIKitExtras.swift`](https://github.com/alldritt/LNSTemplateChooser/blob/master/Example/LNSUIKitExtras.swift) (for `presentModalFullScreen`) files found in the Example application.

## Phase II

_TO BE DONE_

The second phase of development will be to recreate the iWork "grouped" template chooser.