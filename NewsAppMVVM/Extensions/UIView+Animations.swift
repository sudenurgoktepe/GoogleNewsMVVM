import UIKit

extension UIView {
    func bounce(duration: TimeInterval = 0.5, scale: CGFloat = 1.1, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration / 2, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: duration / 2, animations: {
                self.transform = CGAffineTransform.identity
            }, completion: completion)
        }
    }
}
