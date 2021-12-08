//
//  JRCodeVerifyConfig.swift
//  JRCodeVerifyView
//
//  Created by wenhao lei on 2021/12/8.
//

import UIKit

struct JRCodeVerifyConfig {

    var backgroundUrl: String = ""
    var clipUrl: String = ""
    
    var x: CGFloat = 0
    var y: CGFloat = 0
    
    var backgroundImage: UIImage? { .wh_image(url: backgroundUrl) }
    var clipImage: UIImage? { .wh_image(url: clipUrl) }
    
    var point: CGPoint? { .init(x: x, y: y) }
    
}
