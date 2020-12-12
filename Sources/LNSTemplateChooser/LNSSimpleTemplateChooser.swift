//
//  LNSSimpleTemplateChooser.swift
//  LNSTemplateChooser
//
//  Created by Mark Alldritt on 2020-07-12.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import UIKit


public class LNSSimpleTemplateChooser: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LNSTemplateCellChooser {

    public var templates: [LNSTemplate] = [] {
        didSet {
            if isViewLoaded {
                collectionView.reloadData()
            }
        }
    }
    public var completion: ((_ template: LNSTemplate) -> Void)?
    public var thumbnailSize = CGFloat(220) {
        didSet {
            if isViewLoaded {
                collectionView.reloadData()
            }
        }
    }

    private (set) var collectionView: UICollectionView!
    
    override public func loadView() {
        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.register(UINib(nibName: "LNSTemplateCell", bundle: .module), forCellWithReuseIdentifier: "LNSTemplateCell")
        collectionView.tintColor = navigationController?.navigationBar.tintColor ?? UIColor.blue
        view = collectionView

        navigationItem.title = "Choose a Template"
    }
    
    public func clearOpeningIndication() {
        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.deselectItem(at: selectedIndexPath, animated: true)            
        }
    }
    
    //  MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let template = templates[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LNSTemplateCell", for: indexPath) as! LNSTemplateCell
        
        cell.templateChooser = self
        cell.configure(for: template)
        return cell
    }
    
    //  MARK: - UICollectionViewDelete
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let template = templates[indexPath.row]

        completion?(template)
    }
    
    //  MARK: - UICollectionViewDelegateFlowLayout
        
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }

}


