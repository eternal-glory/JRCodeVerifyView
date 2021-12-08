//
//  JRCodeVerifyView.swift
//  JRCodeVerifyView
//
//  Created by wenhao lei on 2021/12/7.
//

import UIKit

enum JRContentMode {
    case aspectFit
    case aspectFill
    case fill
}

let margin: CGFloat = 10
let codeSize: CGFloat = 50
let offset: CGFloat = 9

let imageHeight: CGFloat = 200


class JRCodeVerifyView: UIView {
    
    var joiningTogetherSuccessfully: ((_ offsetX: CGFloat)->())?
    
    private var randomPoint: CGPoint = .zero
    
    private var config: JRCodeVerifyConfig?
        
    init(config: JRCodeVerifyConfig? = nil) {
        self.config = config
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = .black.withAlphaComponent(0.3)
        codeTypeImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var contentView: UIView = {
        let _contenView = UIView(frame: .init(origin: .init(x: margin, y: margin), size: .init(width: frame.width - margin * 2, height: 0)))
        _contenView.backgroundColor = .white
        return _contenView
    }()
    
    private lazy var tipLabel: UILabel = {
        let _label = UILabel(frame: .init(x: margin, y: margin, width: contentView.frame.width - 2 * margin, height: 30))
        _label.text = "拖动下方滑块完成拼图"
        _label.textAlignment = .center
        _label.font = .systemFont(ofSize: 14)
        return _label
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let _img = UIImageView(frame: .init(x: margin, y: tipLabel.frame.maxY + margin, width: tipLabel.frame.width, height: imageHeight))
        _img.contentMode = .scaleAspectFill
        _img.clipsToBounds = true
        return _img
    }()
    
    private lazy var slider: JRSlider = {
        let _slider = JRSlider(frame: .init(x: margin, y: backgroundImageView.frame.maxY + margin, width: tipLabel.frame.width, height: 30))
//        _slider.layer.masksToBounds = true
//        _slider.layer.cornerRadius = 15
        _slider.minimumTrackTintColor = .clear
        _slider.maximumTrackTintColor = .clear
        _slider.thumbTintColor = .gray
        _slider.addTarget(self, action: #selector(slideAction(_:_:)), for: .allTouchEvents)
        return _slider
    }()
    
    private lazy var shadeView: UIView = {
        let _shadeView = UIView()
        _shadeView.alpha = 0.5
        return _shadeView
    }()
    
    private lazy var clipImageView: UIImageView = {
        let _img = UIImageView()
        return _img
    }()
}

extension JRCodeVerifyView {
    private func codeTypeImageView() {
        addSubview(contentView)
        contentView.addSubview(tipLabel)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(slider)
        contentView.addSubview(slider.titleLabel)
        var rect = contentView.frame
        rect.size.height = slider.frame.maxY + margin
        contentView.frame = rect
        contentView.center = .init(x: center.x, y: center.y * 0.75)
        resetView()
    }
}

extension JRCodeVerifyView {
    
    func show(in superView: UIView) {
        superView.addSubview(self)
    }
    
    func show() {
        guard let windows = UIApplication.shared.keyWindow else { return }
        windows.addSubview(self)
    }
    
    private func resetView() {
        if let config = config {
            let normalImage = config.backgroundImage?.wh_rescaleImageToSize(size: .init(width: frame.width - margin * 2, height: imageHeight))
            backgroundImageView.image = normalImage
            
            clipImageView.frame = CGRect.init(origin: config.point!, size: .init(width: codeSize, height: codeSize))
            backgroundImageView.addSubview(clipImageView)
            clipImageView.image = config.clipImage
        } else {
            // 模拟服务器随机位置
            getRandomPoint()
            addClipImage()
        }
        defalutSlider()
    }
    
    @objc private func slideAction(_ slider: UISlider, _ event: UIEvent) {
        guard let phase = event.allTouches?.first?.phase else {
            return
        }
        if phase == .began {
            
        } else if phase == .ended {
            let x = shadeView.frame.origin.x
            if abs(clipImageView.frame.origin.x - x) <= 5.0 {
                layer.add(successAnimal(), forKey: "successAnimal")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.removeFromSuperview()
                }
                successShow(CGFloat(slider.value))
            } else {
                layer.add(failureAnimal(), forKey: "failureAnimal")
                defalutSlider()
            }
        } else if phase == .moved {
            if CGFloat(slider.value) > frame.width - margin * 2 - codeSize {
                slider.value = Float(frame.width - margin * 2 - codeSize)
                return
            }
            changeSlider(to: CGFloat(slider.value))
        }
        
        slider.minimumTrackTintColor = .red
    }
    
    private func successShow(_ offsetX: CGFloat) {
        joiningTogetherSuccessfully?(offsetX)
    }
    
    private func defalutSlider() {
        self.slider.value = 0
        changeSlider(to: CGFloat(slider.value))
    }
    
    private func changeSlider(to value: CGFloat) {
        var rect = clipImageView.frame
        let x = value * backgroundImageView.frame.width - value * codeSize
        rect.origin.x = x
        clipImageView.frame = rect
    }
    
    private func addClipImage() {
        let normalImage = UIImage(named: "icon_b")?.wh_rescaleImageToSize(size: .init(width: frame.width - margin * 2, height: imageHeight))
        backgroundImageView.image = normalImage
        
        shadeView.frame = .init(origin: self.randomPoint, size: .init(width: codeSize, height: codeSize))
        backgroundImageView.addSubview(shadeView)
        clipImageView.frame = .init(x: 0, y: randomPoint.y - offset, width: codeSize + offset, height: codeSize + offset)
        backgroundImageView.addSubview(clipImageView)
        
        let path = getCodePath()
        let thumbImage = backgroundImageView.image?.wh_subImage(rect: shadeView.frame)
        clipImageView.image = thumbImage?.wh_clipImage(path: path, mode: .fill)
        
        var rect = shadeView.frame
        rect.origin.x -= offset
        shadeView.frame = rect
        
        let shadeViewLayer = CAShapeLayer()
        shadeViewLayer.frame = .init(origin: .zero, size: .init(width: codeSize, height: codeSize))
        shadeViewLayer.path = path.cgPath
        shadeViewLayer.strokeColor = UIColor.white.cgColor
        shadeView.layer.addSublayer(shadeViewLayer)
    }
}

extension JRCodeVerifyView {
    
    private func getRandomPoint() {
        let widthMax = backgroundImageView.frame.width - margin - codeSize
        let heightMax = backgroundImageView.frame.height - codeSize * 2
        let randomX = getRandomNumber(from: margin + codeSize * 2, to: widthMax)
        let randomY = getRandomNumber(from: offset * 2, to: heightMax)
        randomPoint = .init(x: randomX, y: randomY)
    }
    
    private func getRandomNumber(from: CGFloat, to: CGFloat) -> CGFloat {
        return from + CGFloat(arc4random() % (UInt32(to - from) + 1))
    }
    
    /// 配置滑块贝塞尔曲线
    /// - Returns: UIBezierPath
    private func getCodePath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: .zero)
        
        path.addLine(to: .init(x: codeSize * 0.5 - offset, y: 0))
        path.addQuadCurve(to: .init(x: codeSize * 0.5 + offset, y: 0), controlPoint: .init(x: codeSize * 0.5, y: -offset * 2))
        path.addLine(to: .init(x: codeSize, y: 0))
        
        path.addLine(to: .init(x: codeSize, y: codeSize * 0.5 - offset))
        path.addQuadCurve(to: .init(x: codeSize, y: codeSize * 0.5 + offset), controlPoint: .init(x: codeSize + offset * 2, y: codeSize * 0.5))
        path.addLine(to: .init(x: codeSize, y: codeSize))
        
        path.addLine(to: .init(x: codeSize * 0.5 + offset, y: codeSize))
        path.addQuadCurve(to: .init(x: codeSize * 0.5 - offset, y: codeSize), controlPoint: .init(x: codeSize * 0.5, y: codeSize - offset * 2))
        path.addLine(to: .init(x: 0, y: codeSize))
        
        path.addLine(to: .init(x: 0, y: codeSize * 0.5 + offset))
        path.addQuadCurve(to: .init(x: 0, y: codeSize * 0.5 - offset), controlPoint: .init(x: offset * 2, y: codeSize * 0.5))
        path.addLine(to: .zero)
        
        path.stroke()
        return path
    }
    
    /// 成功动画
    /// - Returns: CABasicAnimation
    func successAnimal() -> CABasicAnimation {
        let animation = CABasicAnimation.init(keyPath: "opacity")
        animation.duration = 0.3
        animation.autoreverses = true
        animation.fromValue = 1
        animation.toValue = 0
        animation.isRemovedOnCompletion = true
        return animation
    }
    
    /// 失败动画
    /// - Returns: CABasicAnimation
    func failureAnimal() -> CABasicAnimation {
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.duration = 0.08
        animation.autoreverses = true
        animation.repeatCount = 2
        animation.fromValue = -M_1_PI/16
        animation.toValue = M_1_PI/16
        return animation
    }
}

class JRSlider: UISlider {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return .init(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    lazy var titleLabel: UILabel = {
        let _label = UILabel(frame: frame)
        _label.center = center
        _label.text = "按住滑块拖动完成拼图"
        _label.font = .systemFont(ofSize: 14)
        _label.textAlignment = .center
        _label.textColor = .init(named: "333333")
        _label.layer.borderWidth = 1
        _label.layer.borderColor = UIColor.init(named: "333333")?.cgColor
        _label.layer.masksToBounds = true
        return _label
    }()
}

extension UIImage {
    
    static func wh_image(url string: String) -> UIImage? {
        guard let url = URL(string: string) else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    /// 截取当前image对象rect区域内的图像
    /// - Parameter rect: 大小
    /// - Returns: 图片
    func wh_subImage(rect: CGRect) -> UIImage {
        let scale = scale
        let scaleRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.height * scale)
        let imageRef = self.cgImage!.cropping(to: scaleRect)
        let image = UIImage.init(cgImage: imageRef!).wh_rescaleImageToSize(size: rect.size)
        return image
    }
    
    /// 压缩图片至指定尺寸
    /// - Parameter size: 大小
    /// - Returns: 图片
    func wh_rescaleImageToSize(size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    /// 裁剪图片
    /// - Parameter size: 大小
    /// - Returns: 图片
    func wh_imageScaleToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        draw(in: .init(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - path: <#path description#>
    ///   - mode: <#mode description#>
    /// - Returns: <#description#>
    func wh_clipImage(path: UIBezierPath, mode: JRContentMode) -> UIImage {
        let originScale = size.width * 1.0 / size.height
        let boxBounds = path.bounds
        var width = boxBounds.width
        var height = width / originScale
        switch mode {
        case .aspectFit:
            if height > boxBounds.height {
                height = boxBounds.height
                width = height * originScale
            }
        case .aspectFill:
            if height < boxBounds.height {
                height = boxBounds.height
                width = height * originScale
            }
        case .fill:
            if height != boxBounds.height {
                height = boxBounds.height
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(boxBounds.size, false, UIScreen.main.scale)
        let bitmap = UIGraphicsGetCurrentContext()
        let newPath = path.copy() as! UIBezierPath
        let trans = CGAffineTransform.init(translationX: -path.bounds.origin.x, y: -path.bounds.origin.y)
        newPath.apply(trans)
        newPath.addClip()
        
        bitmap?.translateBy(x: boxBounds.size.width / 2.0, y: boxBounds.size.height / 2.0)
        bitmap?.scaleBy(x: 1.0, y: -1.0)
        bitmap?.draw(self.cgImage!, in: .init(x: -width / 2, y: -height / 2, width: width, height: height));
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
