//
//  ZPrsentViewController.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/26.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit

class ZPrsentViewController: UIViewController {
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
        
    }
}
private extension ZPrsentViewController {
    
    func navControllerInit() -> Void {
        navController = UINavigationController(rootViewController: self)
        navController?.navigationBar.isTranslucent = false
        navController?.setNavigationBarHidden(true, animated: false)
        navController?.view.frame = self.originFrame
    }
    
    func backViewInit() -> Void {
        backView = UIView(frame: UIScreen.main.bounds)
        backView?.backgroundColor = UIColor.red
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
        backView?.addGestureRecognizer(tap)
    }
    
   @objc func tap(tap:UITapGestureRecognizer) -> Void {
        hideen()
    }
    
}


extension ZPrsentViewController {
    
    func hideen() -> Void {
        UIView.animate(withDuration: 0.2, animations: {
            self.navigationController?.view.frame = self.originFrame
            
        }) { (completion) in
            self.backView?.removeFromSuperview()
            self.navController?.view.removeFromSuperview()
            self.navController?.removeFromParentViewController()
        }
    }
    
    func show() -> Void {
        sponsorVC.navigationController?.view.addSubview(backView!)
        sponsorVC.navigationController?.addChildViewController(navController!)
        sponsorVC.navigationController?.view.addSubview(view)
        backView?.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.sponsorVC.view.frame = self.finallFrame
        }) { (completion) in
            
        }
        
    }
}





