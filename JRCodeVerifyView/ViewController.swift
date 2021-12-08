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
        
        let btn = UIButton(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
        btn.setTitle("展示", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.center = view.center
        btn.addTarget(self, action: #selector(showCode), for: .touchUpInside)
        view.addSubview(btn)
        
    }
    
    @objc func showCode() {
        let codeView = JRCodeVerifyView()
        codeView.joiningTogetherSuccessfully = {
            print("拼接成功", "x轴偏移量：\($0)")
        }
        codeView.show()
    }

}

