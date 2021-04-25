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
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}
