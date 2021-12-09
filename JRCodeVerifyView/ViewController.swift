//
//  ViewController.swift
//  JRCodeVerifyView
//
//  Created by wenhao lei on 2021/12/7.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("展示", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.center = view.center
        btn.addTarget(self, action: #selector(showCode), for: .touchUpInside)
        btn.layer.cornerRadius = 20
        btn.backgroundColor = .red
        view.addSubview(btn)
        
        let widthConstraint = NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        btn.addConstraint(widthConstraint)

        let heightConstraint = NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        btn.addConstraint(heightConstraint)
        
        let xConstraint = NSLayoutConstraint(item: btn, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0)

        let yConstraint = NSLayoutConstraint(item: btn, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        btn.superview!.addConstraints([xConstraint, yConstraint])
    }
    
    @objc func showCode() {
        let codeView = JRCodeVerifyView()
        codeView.joiningTogetherSuccessfully = {
            print("拼接成功", "x轴偏移量：\($0)")
        }
        codeView.show()
    }

}

