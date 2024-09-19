import UIKit

protocol Reusable: AnyObject {
    static var reuseIdentifier: String { get }
}

extension Reusable where Self: UIView {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

extension UICollectionViewCell: Reusable {
}

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type) where T: Reusable {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
}
