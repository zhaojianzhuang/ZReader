//
//  ZPrsentViewController.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/26.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit

class PresentBaseViewController: UIViewController {
    fileprivate let sponsorVC:UIViewController
    fileprivate let originFrame:CGRect
    fileprivate let finallFrame:CGRect
    fileprivate var backView:UIView?
    fileprivate var navController:UINavigationController?
    
    init(sponsorVC:UIViewController, originFrame:CGRect, finallFrame:CGRect) {
        self.sponsorVC = sponsorVC
        self.originFrame = originFrame
        self.finallFrame = finallFrame
        guard let _ = sponsorVC.navigationController else {
            assert(true, "sponsorVC的navigationController不能为空")
            super.init(nibName: nil, bundle: nil)
            return
        }
        super.init(nibName: nil, bundle: nil)
        navControllerInit()
        backViewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .all
        
    }
}
private extension PresentBaseViewController {
    
    func navControllerInit() -> Void {
        navController = UINavigationController(rootViewController: self)
        navController?.navigationBar.isTranslucent = false
        navController?.setNavigationBarHidden(true, animated: false)
        navController?.view.frame = self.originFrame
    }
    
    func backViewInit() -> Void {
        backView = UIView(frame: UIScreen.main.bounds)
        backView?.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
        backView?.addGestureRecognizer(tap)
    }
    
    @objc func tap(tap:UITapGestureRecognizer) -> Void {
        hideen()
        
    }
    
}


extension PresentBaseViewController {
    //    隐藏
    func hideen() -> Void {
        UIView.animate(withDuration: 0.2, animations: {
            self.navigationController?.view.frame = self.originFrame
            
        }) { (completion) in
            self.backView?.removeFromSuperview()
            self.navController?.view.removeFromSuperview()
            self.navController?.removeFromParentViewController()
        }
    }
    //    出现
    func show() -> Void {
        sponsorVC.navigationController?.view.addSubview(backView!)
        sponsorVC.navigationController?.addChildViewController(navController!)
        sponsorVC.navigationController?.view.addSubview(navController!.view)
        backView?.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.navController?.view.frame = self.finallFrame
        }) { (completion) in
            
        }
        
    }
}






