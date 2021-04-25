import UIKit

protocol CursorDelegate:AnyObject {
    func didColorChanged(hsv:HSVColor?)
}
internal class BrightnessCursor: UIView {
    
    weak var delegate:CursorDelegate?
    
    private let textField = HexTextField()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
        layer.borderWidth = 1
        addSubview(textField)
        isUserInteractionEnabled = true
        self.textField.delegate = self
        self.textField.addTarget(self, action: #selector(self.didHexChanged), for: .editingChanged)
    }
    
    @objc private func didHexChanged(){
        if let text = self.textField.text?.addPrefixIfNeeded("#"){
            self.textField.text = text
            self.delegate?.didColorChanged(hsv: text.toHSV)
        }
    }
    
    func set(hsv: HSVColor) {
        backgroundColor = hsv.uiColor
        let borderColor = hsv.borderColor
        layer.borderColor = borderColor.cgColor
        textField.textColor = borderColor
        textField.text = hsv.rgbColor.hexString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 6
        textField.frame = bounds
    }
}

extension BrightnessCursor: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.didHexChanged()
        textField.resignFirstResponder()
        return true
    }
}

extension RGBColor {
    var hexString: String {
        return String(format: "#%02x%02x%02x", red, green, blue)
    }
}

extension String{
    var toHSV:HSVColor?{
        if let color = UIColor(hex: self){
            return HSVColor(color: color, colorSpace: .sRGB)
        } else{
            return nil
        }
    }
    
    @discardableResult
    func addPrefixIfNeeded(_ prefix: String) -> String {
        guard !self.hasPrefix(prefix) else { return  self}
        return prefix + self
    }
}
extension UIColor {
    
    convenience init?(hex: String) {
        var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")

        // Helpers
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexNormalized.count

        // Create Scanner
        Scanner(string: hexNormalized).scanHexInt32(&rgb)

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
