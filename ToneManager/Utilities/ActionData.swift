import UIKit

public struct ActionData {
    
    public fileprivate(set) var title: String?
    public fileprivate(set) var subtitle: String?
    public fileprivate(set) var image: UIImage?
    
    public init(title: String) {
        self.title = title
    }
    
    public init(title: String, subtitle: String) {
        self.init(title: title)
        self.subtitle = subtitle
    }
    
    public init(title: String, subtitle: String, image: UIImage) {
        self.init(title: title, subtitle: subtitle)
        self.image = image
    }
    
    public init(title: String, image: UIImage) {
        self.init(title: title)
        self.image = image
    }
}
