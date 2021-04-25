import UIKit

class HexTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        if #available(iOS 13.0, *) {
            self.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .light)
        } else {
            self.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .light)
        }

        self.textAlignment = .center
        isUserInteractionEnabled = true
    }
}
