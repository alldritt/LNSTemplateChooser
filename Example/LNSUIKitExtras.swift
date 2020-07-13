//
//  LNSUIKitExtras.swift
//  LNSShared
//
//  Created by Mark Alldritt on 2016-12-17.
//  Copyright © 2016 Late Night Software Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices


public extension UIImage {
    var circleMask: UIImage {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        //imageView.layer.borderColor = UIColor.white.cgColor
        //imageView.layer.borderWidth = 5
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    func resizeWith(percentage: CGFloat) -> UIImage? {
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
    
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero,
                                                  size: CGSize(width: width,
                                                               height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func fixImageOrientation() -> UIImage? {
        
        guard imageOrientation != UIImage.Orientation.up else {
            //This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil //Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        default:
            break
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        default:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}


public extension UIColor {
    private func rgba() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let components = self.cgColor.components
        let numberOfComponents = self.cgColor.numberOfComponents
        
        switch numberOfComponents {
        case 4:
            return (components![0], components![1], components![2], components![3])
        case 2:
            return (components![0], components![0], components![0], components![1])
        default:
            // FIXME: Fallback to black
            return (0, 0, 0, 1)
        }
    }

    func blackOrWhiteContrastingColor() -> UIColor {
        let rgbaT = rgba()
        let value = 1 - ((0.299 * rgbaT.r) + (0.587 * rgbaT.g) + (0.114 * rgbaT.b));
        return value < 0.65 ? UIColor.black : UIColor.white
    }
    
    func blackOrGrayContrastingColor() -> UIColor {
        let rgbaT = rgba()
        let value = 1 - ((0.299 * rgbaT.r) + (0.587 * rgbaT.g) + (0.114 * rgbaT.b));
        return value < 0.75 ? UIColor.black : UIColor.lightGray
    }
    
    func desaturate(_ percentage: CGFloat) -> UIColor {
        var colorHueComponent: CGFloat = 1
        var colorSaturationComponent: CGFloat = 1
        var colorBrightnessComponent: CGFloat = 1
        
        getHue(&colorHueComponent, saturation: &colorSaturationComponent, brightness: &colorBrightnessComponent, alpha: nil)
        
        return UIColor(hue: colorHueComponent, saturation: 0.05, brightness: colorBrightnessComponent, alpha: cgColor.alpha)
    }
    
    func highlight(_ percentage: CGFloat) -> UIColor {
        var colorRedComponent: CGFloat = 1
        var colorGreenComponent: CGFloat = 1
        var colorBlueComponent: CGFloat = 1
        
        getRed(&colorRedComponent, green: &colorGreenComponent, blue: &colorBlueComponent, alpha: nil)
        
        return UIColor(red: (colorRedComponent * 0.1 + 0.9), green: (colorGreenComponent * 0.1 + 0.9), blue: (colorBlueComponent * 0.1 + 0.9), alpha: (cgColor.alpha * 0.1 + 0.9))
    }

}

public extension UIDevice {
    func deviceFreeSpaceInBytes() -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
            else {
                // something failed
                return nil
        }
        return freeSize.int64Value
    }
    
    func deviceFreeSpaceInKBytes() -> Int64? {
        if let bytes = deviceFreeSpaceInBytes() {
            return bytes / 1024
        }
        return nil
    }
    
    func deviceFreeSpaceInMBytes() -> Int? {
        if let kBytes = deviceFreeSpaceInKBytes() {
            return Int(kBytes / 1024)
        }
        return nil
    }
    
    func isRunningOniPhone() -> Bool {
        return userInterfaceIdiom == .phone
    }
    
    func isRunningOniPad() -> Bool {
        return userInterfaceIdiom == .pad
    }
    
    func hasCellularCapabilites() -> Bool {
        //  NOTE: #import <ifaddrs.h> must be added to the app's bridging header
        var addrs: UnsafeMutablePointer<ifaddrs>?
        var cursor: UnsafeMutablePointer<ifaddrs>?
        
        defer { freeifaddrs(addrs) }
        
        guard getifaddrs(&addrs) == 0 else { return false }
        cursor = addrs
        
        while cursor != nil {
            guard
                let utf8String = cursor?.pointee.ifa_name,
                let name = NSString(utf8String: utf8String),
                name == "pdp_ip0"
                else {
                    cursor = cursor?.pointee.ifa_next
                    continue
            }
            return true
        }
        return false
    }

    func appName() -> String {
        let appName = (Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String) ??
            Bundle.main.infoDictionary!["CFBundleName"] as? String

        return appName ?? "APP NAME"
    }
}




public extension UIApplication {
    var visibleViewController: UIViewController? {
        return delegate?.window??.visibleViewController
    }
}

public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            if let topViewController = nc.topViewController {
                return UIWindow.getVisibleViewControllerFrom(topViewController)
            }
            else {
                return nc
            }
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        //} else if let sc = vc as? UISplitViewController {
        //    //  is one of the split views displaying a modal view controller.  Just not sure how to accomplish this.
        //
        } else {
            //  Is vc displaying a modal view controller
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}


extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return viewControllers.last?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return viewControllers.last?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }

    open override var shouldAutorotate: Bool {
        return viewControllers.last?.shouldAutorotate ?? super.shouldAutorotate
    }
}


extension UITabBarController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let selected = selectedViewController {
            return selected.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        if let selected = selectedViewController {
            return selected.preferredInterfaceOrientationForPresentation
        }
        return super.preferredInterfaceOrientationForPresentation
    }

    open override var shouldAutorotate: Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate
        }
        return super.shouldAutorotate
    }
}


public extension UIViewController {
    
    func presentModalFullScreen(controller: UIViewController, sender: Any, animated: Bool = true) {
        controller.modalPresentationStyle = .fullScreen
        if let cell = sender as? UITableViewCell {
            controller.popoverPresentationController?.sourceView = cell.contentView
            controller.popoverPresentationController?.sourceRect = cell.contentView.bounds
            controller.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
        else if let view = sender as? UIView {
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = view.bounds
        }
        else if let button = sender as? UIBarButtonItem {
            controller.popoverPresentationController?.barButtonItem = button
        }
        self.present(controller, animated: animated, completion: nil)
    }
    
    func presentModalFormSheet(controller: UIViewController, sender: Any, animated: Bool = true) {
        controller.modalPresentationStyle = .formSheet
        if let cell = sender as? UITableViewCell {
            controller.popoverPresentationController?.sourceView = cell.contentView
            controller.popoverPresentationController?.sourceRect = cell.contentView.bounds
            controller.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
        else if let view = sender as? UIView {
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = view.bounds
        }
        else if let button = sender as? UIBarButtonItem {
            controller.popoverPresentationController?.barButtonItem = button
        }
        self.present(controller, animated: animated, completion: nil)
    }

    func presentModalPageSheet(controller: UIViewController, sender: Any, animated: Bool = true) {
        controller.modalPresentationStyle = .pageSheet
        if let cell = sender as? UITableViewCell {
            controller.popoverPresentationController?.sourceView = cell.contentView
            controller.popoverPresentationController?.sourceRect = cell.contentView.bounds
            controller.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
        else if let view = sender as? UIView {
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = view.bounds
        }
        else if let button = sender as? UIBarButtonItem {
            controller.popoverPresentationController?.barButtonItem = button
        }
        self.present(controller, animated: animated, completion: nil)
    }

    func presentModalPopover(controller: UIViewController, sender: Any, animated: Bool = true) {
        controller.modalPresentationStyle = .popover
        if let cell = sender as? UITableViewCell {
            controller.popoverPresentationController?.sourceView = cell.contentView
            controller.popoverPresentationController?.sourceRect = cell.contentView.bounds
            controller.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
        else if let view = sender as? UIView {
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = view.bounds
        }
        else if let button = sender as? UIBarButtonItem {
            controller.popoverPresentationController?.barButtonItem = button
        }
        self.present(controller, animated: animated, completion: nil)
    }
    
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
}


extension UIView {
    
    func findSubview(ofType theClass: AnyClass) -> UIView? {
        for subview in self.subviews {
            if subview.isKind(of: theClass) {
                return subview
            }
            else if let subSubView = subview.findSubview(ofType: theClass) {
                return subSubView
            }
        }
        return nil
    }
    
    func findSubviews(ofType theClass: AnyClass) -> [UIView] {
        var foundViews = [UIView]()
        for subview in self.subviews {
            if subview.isKind(of: theClass) {
                foundViews.append(subview)
            }
            else {
                foundViews.append(contentsOf: subview.findSubviews(ofType: theClass))
            }
        }
        return foundViews
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

}


extension Collection where Iterator.Element:UIView {
    
    func commonParent() -> UIView? {
        
        // Must be at least 1 view
        guard let firstView = self.first else {
            return nil
        }
        
        // If only 1 view, return it's superview, or nil if already root
        guard self.count > 1 else {
            return firstView.superview
        }
        
        // All views must have a superview, otherwise return nil
        guard self.filter({ $0.superview == nil }).count == 0 else {
            return nil
        }
        
        // Find the common parent
        var superview = firstView.superview
        while superview != nil {
            if self.reduce(true, { $1.isDescendant(of: superview!) && $1 != superview! }) {
                // If all views are descendent of superview return common parent
                return superview
            } else {
                // else go to next superview and test that
                superview = superview?.superview
            }
        }
        // else, there is no common parent
        return nil
    }
}


public extension URL {
    func conformsTo(typeIdentifier: String) -> Bool {
        return UTTypeConformsTo(self.typeIdentifier as CFString, typeIdentifier as CFString)
    }
    
    var typeIdentifier: String {
        if let result = try? self.resourceValues(forKeys: [URLResourceKey.typeIdentifierKey]).typeIdentifier {
            return result
        }
        
        return ""
    }
    
    var displayName: String {
        if let result = try? resourceValues(forKeys: [URLResourceKey.localizedNameKey]).localizedName {
            return result
        }
        
        return deletingPathExtension().lastPathComponent
    }
    
    var fileSize: UInt64 {
        if isFileURL {
            var fileSize : UInt64 = 0

            do {
                let attr = try FileManager.default.attributesOfItem(atPath: path)
                fileSize = attr[FileAttributeKey.size] as! UInt64
            } catch {
                print("Error: \(error)")
            }
            
            return fileSize
        }
        else {
            if let result = try? resourceValues(forKeys: [URLResourceKey.fileSizeKey]).fileSize {
                return UInt64(result)
            }
            return 0
        }
    }

    var fileAllocatedSize: UInt64 {
        if let result = try? resourceValues(forKeys: [URLResourceKey.fileAllocatedSizeKey]).fileAllocatedSize {
            return UInt64(result)
        }
        return 0
    }
}


public extension Date {
    
    static var today : Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: Date())
        
        components.hour = 0
        components.minute = 0
        components.second = 0

        let today = calendar.date(from: components)
        
        return today!
    }
    
    static var yesterday : Date {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
        
        return yesterday!
    }

    static var tomorrow : Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)
        
        return tomorrow!
    }

    static var usecTimestamp : Int64 {
        return Int64(Date().timeIntervalSince1970 * Double(USEC_PER_SEC) /* convert to Microseconds */)
    }
    
    var zeroHour : Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: self)
        
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        return calendar.date(from: components)!
    }
    
    var nextDay : Date {
        let calendar = Calendar.current
        
        return calendar.date(byAdding: .day, value: 1, to: zeroHour)!
    }
}


func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    rhs.forEach{ result[$0] = $1 }
    return result
}

