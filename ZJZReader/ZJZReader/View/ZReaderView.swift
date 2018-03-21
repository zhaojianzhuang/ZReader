//
//  ReaderView.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/17.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit


enum ZPanDirection {
    case left, right
}



class ReaderView: UIView {
    
    var frameR:CTFrame
    var content = ""
    var frameArray = [CGRect]()
    

    var pan:UIPanGestureRecognizer?
    var longPress:UILongPressGestureRecognizer?
    
    var leftRect = CGRect.zero
    var rightRect = CGRect.zero
    
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
        var leftDot = CGRect.zero
        var rightDot =  CGRect.zero
        
        draw(frameArray: frameArray, leftDot: &leftDot, rightDot: &rightDot)
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
    
    func draw(frameArray:[CGRect], leftDot:inout CGRect, rightDot:inout CGRect) -> Void {
        
        if frameArray.count == 0 {
            pan?.isEnabled = false
            return
        }
        pan?.isEnabled = true
        let path = CGMutablePath.init()
        UIColor.green.setFill()
        for (offset, frame) in frameArray.enumerated() {
            path.addRect(frame)
            if offset == 0 {
                leftDot = frame
            }
            if offset == frameArray.count - 1 {
                rightDot = frame
            }
        }
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.addPath(path)
        ctx?.fillPath()
    }
    
    
    func draw(leftRect:CGRect, rightRect:CGRect) -> Void {
        if CGRect.zero.equalTo(leftRect) || CGRect.zero.equalTo(rightRect) {
            return
        }
        let ctx = UIGraphicsGetCurrentContext()
        let path = CGMutablePath.init()
        UIColor.orange.setFill()
        path.addRect(CGRect(x: leftRect.minX - 2, y: leftRect.minY, width: 2, height:leftRect.height))
        path.addRect(CGRect(x: rightRect.maxX, y: rightRect.minY, width: 2, height: rightRect.height))
        ctx?.addPath(path)
        let dotSize:CGFloat = 15
        
        self.leftRect = CGRect(x: leftRect.minX - dotSize / 2 - 1, y:frame.size.height - (leftRect.maxY - dotSize / 2 - 10.0) - (dotSize + 20.0), width: dotSize + 20.0, height: dotSize + 20.0)
        self.rightRect = CGRect(x: rightRect.maxX - dotSize / 2  - 10, y: frame.size.height - (rightRect.minY - dotSize / 2 - 10) - dotSize - 20, width: dotSize + 20, height: dotSize + 20)
        
        ctx?.draw((UIImage(named: "r_drag-dot")?.cgImage)!, in: CGRect(x: leftRect.minX - dotSize / 2 , y: leftRect.maxY - dotSize / 2, width: dotSize, height: dotSize))
        ctx?.draw((UIImage(named: "r_drag-dot")?.cgImage)!, in: CGRect(x: rightRect.maxX - dotSize / 2 , y: rightRect.minY - dotSize / 2, width: dotSize, height: dotSize))
    }

    
    @objc func pan(pan:UIPanGestureRecognizer) -> Void {
        let point = pan.location(in: self)
        if pan.state == .began || pan.state == .changed {
            
        }
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





