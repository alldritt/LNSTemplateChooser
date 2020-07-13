//
//  LNSDocumentCell.swift
//
//  Created by Mark Alldritt on 2016-11-28.
//  Copyright © 2016 Late Night Software Ltd. All rights reserved.
//

import UIKit
import QuickLookThumbnailing


extension UIImage {
    
    func lnsResize(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }

}

protocol LNSTemplateCellChooser: class {
    
    var thumbnailSize: CGFloat { get }
    var collectionView: UICollectionView! { get }
    
}


class LNSTemplateCell: UICollectionViewCell {

    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    weak var templateChooser: LNSTemplateCellChooser?
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }

            configureCellAdornments()

            if isSelected {
                activityIndicator.startAnimating()
            }
            else {
                activityIndicator.stopAnimating()
            }
        }
    }
    override var isHighlighted: Bool {
        didSet {
            configureCellAdornments()
        }
    }
    
    func configureCellAdornments() {
        #if DEBUG
        previewImage.backgroundColor = .blue // debugging
        #endif
        
        previewImage.layer.borderColor = isSelected ? tintColor.cgColor : UIColor.darkGray.cgColor
        previewImage.layer.borderWidth = isSelected ? 3.0 : 0.6
        previewImage.layer.cornerRadius = isSelected ? 6 : 4
        previewImage.layer.masksToBounds = true

        previewImage.superview?.layer.shadowRadius = isSelected ? 0 : 2.0
        previewImage.superview?.layer.shadowOpacity = isSelected ? 0 : 0.3
        previewImage.superview?.layer.shadowColor = isSelected ? nil : UIColor.black.cgColor
        previewImage.superview?.layer.shadowOffset = isSelected ? CGSize(width: 0, height: 0) : CGSize(width: 0.75, height: 1.5)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        configureCellAdornments()
    }
        
    override func prepareForReuse() {
        isSelected = false
        isHighlighted = false
        previewImage.image = nil
        nameLabel.text = "Template Name"
    }
    
    func configure(for template: LNSTemplate) {
        guard let templateChooser = templateChooser else { fatalError("collectionView not set") }
        let thumbnailSize = CGSize(width: templateChooser.thumbnailSize,
                                   height: templateChooser.thumbnailSize)

        tintColor = templateChooser.collectionView.tintColor
        heightConstraint.constant = 8 + templateChooser.thumbnailSize

        let request1 = QLThumbnailGenerator.Request(fileAt: template.fileURL,
                                                   size: thumbnailSize,
                                                   scale: UIScreen.main.scale,
                                                   representationTypes: .icon)

        QLThumbnailGenerator.shared.generateBestRepresentation(for: request1) { (thumbnail, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let thumb = thumbnail {
                
                DispatchQueue.main.async {
                    //  Unlike thumbnail images which are scaled to match the specified size, icon images are a fixed size.  We
                    //  scale them here to fir the specified thumbnail size.
                    let imageSize = thumb.uiImage.size
                    let scale = templateChooser.thumbnailSize / max(imageSize.width, imageSize.height)
                    let image = thumb.uiImage.lnsResize(percentage: scale)

                    self.previewImage.image = image
                    templateChooser.collectionView.collectionViewLayout.invalidateLayout()
                }
            }
        }

        let request2 = QLThumbnailGenerator.Request(fileAt: template.fileURL,
                                                   size: thumbnailSize,
                                                   scale: UIScreen.main.scale,
                                                   representationTypes: .thumbnail)

        QLThumbnailGenerator.shared.generateBestRepresentation(for: request2) { (thumbnail, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let thumb = thumbnail {
                DispatchQueue.main.async {
                    #if true
                    let imageSize = thumb.uiImage.size
                    let scale = max(thumbnailSize.height, thumbnailSize.width) / max(imageSize.width, imageSize.height)
                    let image = thumb.uiImage.lnsResize(percentage: scale)

                    self.previewImage.image = image
                    #else
                    self.previewImage.image = thumb.uiImage
                    #endif
                    templateChooser.collectionView.collectionViewLayout.invalidateLayout()
                }
            }
        }

        nameLabel.text = template.name
    }
    
}

