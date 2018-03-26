//
//  ZMagnifyingView.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/26.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit

//放大镜view
class ZMagnifyingView: UIView {
    private let readerView:ReaderView
    private var _touchPoint:CGPoint = CGPoint.zero
    
    var touchPoint:CGPoint {
        set{
             _touchPoint = newValue
             print(newValue)
             center = CGPoint(x: newValue.x, y: newValue.y - 80)
//             center = CGPoint(x: _touchPoint.x, y: _touchPoint.y - 70.0)
            setNeedsDisplay()
        }
        get {
            return _touchPoint
        }
    }
    
    init(readerView:ReaderView) {
        self.readerView = readerView
        super.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 40
        layer.masksToBounds = true
        self.backgroundColor = ZReaderConfig.default.themeColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: frame.width / 2 , y: frame.height / 2)
        context?.scaleBy(x: 1.5, y: 1.5)
        context?.translateBy(x: -1 * _touchPoint.x, y: -1 * touchPoint.y)
        guard let contexts = context else {
            return
        }
        readerView.layer.render(in: contexts)
    }
    
}
