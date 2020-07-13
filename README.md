# LNSTemplateChooser

A recreation of the document template chooser found in Apple's iWork apps (Pages, Numbers &amp; Keynote) in iOS.

## iWork as a Starting Point

Apple's iOS iWork apps (circa iOS 13) have quite complex template choosers because of the wide range of templates they offer.  The initial template view is a "grouped" arragement of templates targetting different tasks.  Each group has a Show All action which takes you to a simpler view displaying the templates available for a particular group.

![iWOrk Template Chooser](Assets/iWorkTemplateChooser.png)

## Phase I

I've begin with the simpler "Show All" template chooser view.  This is a farily simple UICollectionView displaying a thumbnail and title for each template.  I've focised on mimicing the iWork look and functionality as much as I can.

My goal is to create a view controller you can easily integrate into a iOS document-based application to create new documents.

Here's where I am so far.

![LNSTemplateChooser Simple](Assets/LNSTemplateChooser.png)

### Installation

Copy the contents of the `LNSTemplateChooser` folder to your Xcode project.  

### Usage

You can look at the [`ViewController.swift`](https://github.com/alldritt/LNSTemplateChooser/blob/master/Example/ViewController.swift) file in the Example project for an illustration of how to use the LNSTemplateChooser from a sotryboard and in code.

## Phase II

_TO BE DONE_

The second phase of development will be to recreate the iWork "grouped" template chooser.