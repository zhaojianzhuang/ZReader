//
//  ReaderView.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/17.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit

class ReaderView: UIView {
    
    var frameR:CTFrame
    var content:String = ""
    
    //    初始化
    //    frmeRef为绘制需要展示的frameRef
    //    conten为内容
    init(frame:CGRect, frameR:CTFrame, content:String) {
        self.frameR = frameR
        self.content = content
        super.init(frame: frame)
        
        self.backgroundColor = ZReaderConfig.default.themeColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    重写draw, 用初始化的frameR进行绘制
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        guard let _ = ctx else {
            return
        }
        ctx?.textMatrix = CGAffineTransform.identity
        //       注意默认值为opengl坐标 需要翻转
        ctx?.translateBy(x: 0, y: self.bounds.size.height)
        ctx?.scaleBy(x: 1.0, y: -1.0)
        CTFrameDraw(self.frameR, ctx!)
    }
    
}

