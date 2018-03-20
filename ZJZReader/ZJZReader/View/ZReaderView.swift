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
    var content = ""
    var frameArray = [CGRect]()
    

    var pan:UIPanGestureRecognizer?
    var longPress:UILongPressGestureRecognizer?
    
    //    初始化
    //    frmeRef为绘制需要展示的frameRef
    //    conten为内容
    init(frame:CGRect, frameR:CTFrame, content:String) {
        self.frameR = frameR
        self.content = content
  
        super.init(frame: frame)
        self.backgroundColor = ZReaderConfig.default.themeColor
        addLongPress()
        addPan()
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

private extension ReaderView {
    //    长按的手势添加
    func addLongPress() -> Void {
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(tap(press:)))
        addGestureRecognizer(longPress!)
        self.isUserInteractionEnabled = true
    }
    //    添加pan手势
    func addPan() -> Void {
        pan = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        pan?.isEnabled = false
        addGestureRecognizer(pan!)
        
    }
    
    func draw(frameArray:[CGRect], leftDot:inout CGFloat, rightDot:inout CGFloat) -> Void {
        var path = CGMutablePath.init()
//        #今天不写了, 明天做这个 绘制蓝边 
        
    }
    
    
    
    
    
    
    @objc func pan(pan:UIPanGestureRecognizer) -> Void {
        print("pan")
    }
    
    @objc func tap(press:UILongPressGestureRecognizer) -> Void {
        let location = press.location(in: self)
        if press.state == .began || press.state == .changed {
            var range = NSMakeRange(0, 0)
            let rect = ZParserUtilties.parser(point: location, selectRange: &range, frameR: frameR)
            if !rect.equalTo(CGRect.zero) {
                print(rect)
                frameArray.removeAll()
                frameArray.append(rect)
                setNeedsDisplay()
            }
            pan?.isEnabled = true
        }
    }
}





