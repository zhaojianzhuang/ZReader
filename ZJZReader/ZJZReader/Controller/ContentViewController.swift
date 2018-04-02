//
//  ContentViewController.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/16.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit
@objc protocol ContentViewControllerDelegate {
    @objc optional
    func tap(viewController:ContentViewController, view:UIView) -> Void
}



class ContentViewController: UIViewController {
//    代理
    var delegate:ContentViewControllerDelegate?
    //    menu
    let menuController = UIMenuController.shared
    //    展示文字的view
    var readerView:ReaderView
    //    内容
    var content:String
    //   放大镜view
    var magnifyingView:ZMagnifyingView?
    
    init(content:String ) {
        self.content = content
        let frameRef = ZParserUtilties.parser(content: content, config: ZReaderConfig.default, bounds:ZReaderConfig.default.effectiveBounds() )
        self.readerView = ReaderView(frame: ZReaderConfig.default.effectiveFrame(), frameR: frameRef, content: content)
        
        super.init(nibName:  nil, bundle: nil)
        readerView.delegate = self
        view.addSubview(readerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}


fileprivate extension ContentViewController {
    //    show放大镜
    func showMagnifyingView() -> Void {
        guard let view = magnifyingView else {
            
            magnifyingView = ZMagnifyingView(renderView: readerView)
            magnifyingView?.removeFromSuperview()
            readerView.addSubview(magnifyingView!)
            return
        }
        view.removeFromSuperview()
        readerView.addSubview(view)
    }
    
    //     show放大镜 touchpoint
    func showMagnifyingView(touchPoint:CGPoint) -> Void {
        showMagnifyingView()
        magnifyingView?.touchPoint = touchPoint
    }
    
    //    隐藏放大镜
    func hideMagnifyingView() -> Void {
        magnifyingView?.removeFromSuperview()
        magnifyingView = nil
    }
    
    //    menu标签显示
    func showMenu() -> Void {
        
        if readerView.becomeFirstResponder() {
            menuController.setMenuVisible(false, animated: false)
            let copyItem = UIMenuItem(title: "复制", action: #selector(copy(item:)))
            menuController.menuItems = [copyItem]
            
            menuController.setTargetRect(CGRect(x: readerView.menuRect.midX - readerView.menuRect.width,
                                                y: readerView.frame.size.height - readerView.menuRect.midY - 10,
                                                width: readerView.menuRect.width,
                                                height: readerView.menuRect.height) , in: readerView)
            menuController.setMenuVisible(true, animated: true)
        }
    }
    
    //     menu隐藏
    func hidenMenu() -> Void {
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    @objc func copy(item:UIMenuItem) -> Void {
        hidenMenu()
        let str = readerView.selected()
        let pastedBoard = UIPasteboard.general
        pastedBoard.string = str
        UIAlertView(title: "", message: str, delegate: nil, cancelButtonTitle: "我知道了").show()
    }
}

extension ContentViewController:ReaderViewDelegate{
    func tap(tap: UITapGestureRecognizer, view: UIView) {
        readerView.clear()
        delegate?.tap?(viewController: self, view: view)
    }
    
    func pan(pan: UIPanGestureRecognizer, view: UIView) {
        let locationPoint = pan.location(in: view)
        let transportPoint = pan.translation(in: view)
        hideMagnifyingView()
        
        if pan.state == .began || pan.state == .changed {
            showMagnifyingView(touchPoint: locationPoint)
            readerView.drawSelected(transportPoint: transportPoint, locationPoint: locationPoint)
        } else if pan.state == .ended {
            hideMagnifyingView()
            showMenu()
        }
        
    }
    
    func longPress(longPress: UILongPressGestureRecognizer, view: UIView) {
        let location = longPress.location(in: view)
        
        if longPress.state == .began || longPress.state == .changed {
            readerView.drawSelected(longPressPoint: location)
        } else if longPress.state == .ended {
            if !readerView.menuRect.equalTo(CGRect.zero) {
                showMenu()
            }
        }
        
    }
    
}



