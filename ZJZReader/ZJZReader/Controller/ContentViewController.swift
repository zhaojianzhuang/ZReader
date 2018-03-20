//
//  ContentViewController.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/16.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    var readerView:ReaderView?
    var content:String
    init(content:String ) {
        self.content = content
        super.init(nibName:  nil, bundle: nil)
        let frameRef = ZParserUtilties.parser(content: content, config: ZReaderConfig.default, bounds:ZReaderConfig.default.effectiveBounds() )
        
        readerView = ReaderView(frame: ZReaderConfig.default.effectiveFrame(), frameR: frameRef, content: content)
        
        guard let _ = readerView else {
            return
        }
        view.addSubview(readerView!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

