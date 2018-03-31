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

@objc protocol ReaderViewDelegate {
    @objc optional
    func longPress(longPress:UILongPressGestureRecognizer, view:UIView) -> Void
    @objc optional
    func tap(tap:UITapGestureRecognizer, view:UIView) -> Void
    @objc optional
    func pan(pan:UIPanGestureRecognizer, view:UIView) -> Void
}


class ReaderView: UIView {
//    绘制的frameR
    private var frameR:CTFrame
//    展示的内容
    private var content = ""
//    选中的frame的数组
    private var frameArray = [CGRect]()
//    手势
    private var pan:UIPanGestureRecognizer?
    private var longPress:UILongPressGestureRecognizer?
    private var tap:UITapGestureRecognizer?
//    左边的rect
    private var leftRect = CGRect.zero
//    右边的rect
    private var rightRect = CGRect.zero
//    选中的range
    private var selectRange = NSMakeRange(0, 0)
    
//    menu应该显示的位置
    private var _menuRect = CGRect.zero
    var menuRect:CGRect {
        get {
            return _menuRect
        }
    }
//    代理
    var delegate:ReaderViewDelegate?
    
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
        addTap()
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
        draw(leftRect: leftDot, rightRect: rightDot)
    }
    
    //    能够成为第一响应者
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

//MARK:- interface
extension ReaderView {
    //    绘制pan手势经过的选中的颜色
    func drawSelected(transportPoint:CGPoint, locationPoint:CGPoint) -> Void {
        let dir = direction(transportPoint: transportPoint, locationPoint: locationPoint, leftRect: self.leftRect, rightRect: self.rightRect)
        let paths = ZParserUtilties.parser(point: locationPoint, range: &selectRange, frameR: frameR, path: frameArray, direction: dir)
        frameArray = paths
        setNeedsDisplay()
    }
    //    清除所有选中的颜色
    func clear() -> Void {
        frameArray.removeAll()
        setNeedsDisplay()
        pan?.isEnabled = false
    }
    //    选中的文字
    func selected() -> String {
        return content.z_range(nsRange: selectRange)
    }
    //    绘制长按点选中的颜色
    func drawSelected(longPressPoint:CGPoint) -> Void {
        let rect = ZParserUtilties.parser(point: longPressPoint, selectRange: &selectRange, frameR: frameR)
        if !rect.equalTo(CGRect.zero) {
            frameArray.removeAll()
            frameArray.append(rect)
            setNeedsDisplay()
        }
        pan?.isEnabled = true
    }
}

private extension ReaderView {
    //    长按的手势添加
    func addLongPress() -> Void {
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(press:)))
        addGestureRecognizer(longPress!)
        self.isUserInteractionEnabled = true
    }
    //    添加pan手势
    func addPan() -> Void {
        pan = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        pan?.isEnabled = false
        addGestureRecognizer(pan!)
        
    }
    
    //     添加点击手势
    func addTap() -> Void {
        tap = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
        addGestureRecognizer(tap!)
    }
    
    //    绘制选中的区域
    func draw(frameArray:[CGRect], leftDot:inout CGRect, rightDot:inout CGRect) -> Void {
        
        if frameArray.count == 0 {
            pan?.isEnabled = false
            return
        }
        pan?.isEnabled = true
        let path = CGMutablePath.init()
        for (offset, frame) in frameArray.enumerated() {
            path.addRect(frame)
            if offset == 0 {
                leftDot = frame
                _menuRect = frame
            }
            if offset == frameArray.count - 1 {
                rightDot = frame
            }
        }
        draw(path: path, color: UIColor.green)
    }
    
    //    绘制右边跟左边
    func draw(leftRect:CGRect, rightRect:CGRect) -> Void {
        if CGRect.zero.equalTo(leftRect) || CGRect.zero.equalTo(rightRect) {
            return
        }
        
        let path = CGMutablePath.init()
        path.addRect(CGRect(x: leftRect.minX - 2,
                            y: leftRect.minY,
                            width: 2,
                            height:leftRect.height))
        path.addRect(CGRect(x: rightRect.maxX,
                            y: rightRect.minY,
                            width: 2,
                            height: rightRect.height))
        draw(path: path, color: UIColor.black)
        
        let ctx = UIGraphicsGetCurrentContext()
        let dotSize:CGFloat = 15
        
        self.leftRect = CGRect(x: leftRect.minX - dotSize / 2 - 10,
                               y:frame.size.height - (leftRect.maxY - dotSize / 2 - 10.0) - (dotSize + 20.0),
                               width: dotSize + 20.0,
                               height: dotSize + 20.0)
        self.rightRect = CGRect(x: rightRect.maxX - dotSize / 2  - 10,
                                y: frame.size.height - (rightRect.minY - dotSize / 2 - 10) - dotSize - 20,
                                width: dotSize + 20,
                                height: dotSize + 20)
        
        ctx?.draw((UIImage(named: "r_drag-dot")?.cgImage)!, in: CGRect(x: leftRect.minX - dotSize / 2 ,
                                                                       y: leftRect.maxY - dotSize / 2,
                                                                       width: dotSize,
                                                                       height: dotSize))
        
        ctx?.draw((UIImage(named: "r_drag-dot")?.cgImage)!, in: CGRect(x: rightRect.maxX - dotSize / 2 ,
                                                                       y: rightRect.minY - dotSize / 2,
                                                                       width: dotSize,
                                                                       height: dotSize))
    }
    //    绘制一条贝塞尔曲线
    func draw(path:CGPath, color:UIColor) -> Void {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.addPath(path)
        color.setFill()
        ctx?.fillPath()
    }
    
    //     选中范围移动的方向
    func direction(transportPoint:CGPoint, locationPoint:CGPoint, leftRect:CGRect, rightRect:CGRect) -> ZPanDirection {
        var direction = ZPanDirection.right
        //   不考虑x y 为零的情况, 以y轴偏移为主, x轴偏移为辅
        if transportPoint.y > 0 {
            direction = ZPanDirection.right
        } else if transportPoint.y < 0 {
            direction = ZPanDirection.left
        } else if transportPoint.x < 0 {
            direction = ZPanDirection.left
        } else if transportPoint.x > 0 {
            direction = ZPanDirection.right
        }
        //       最终以实际是否包含在判断一次
        if leftRect.contains(locationPoint) {
            direction = ZPanDirection.left
        } else if rightRect.contains(locationPoint) {
            direction = ZPanDirection.right
        }
        return direction
    }
    
    
    //    pan手势
    @objc func pan(pan:UIPanGestureRecognizer) -> Void {
        delegate?.pan?(pan: pan, view: self)
    }
    
    //    长按手势
    @objc func longPress(press:UILongPressGestureRecognizer) -> Void {
        delegate?.longPress?(longPress: press, view: self)
    }
    
    //    点击手势
    @objc func tap(tap:UITapGestureRecognizer) -> Void {
        delegate?.tap?(tap: tap, view: self)
    }
}

