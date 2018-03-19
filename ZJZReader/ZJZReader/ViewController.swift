//
//  ViewController.swift
//  ZJZReader
//
//  Created by jianzhuangzhao on 2018/3/16.
//  Copyright © 2018年 ZJZ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
//    model
    var model = ZReadModel(url: Bundle.main.url(forResource: "mdjyml", withExtension: "txt")!)
//    当前的正在展示的view控制器
    var readView:ContentViewController?
//    分页
    let pageController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.pageCurl, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPageController()
    }
}

//MARK:- private
private extension ViewController {
//    pageController 设置
    func setPageController() -> Void {
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.view.frame = view.bounds
        pageController.delegate = self
        pageController.dataSource = self
        
        guard let vc = readView(parameter: model.currentPage) else { return }
        
        pageController.setViewControllers([vc], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
    }
//   通过章节获得内容控制器
    func readView(parameter:PageParameter) -> ContentViewController? {
        return readView(chapter: parameter.chapter, page: parameter.page)
    }
//    通过页码获得控制器
    func readView(chapter:Int, page:Int) -> ContentViewController? {
        guard let content = model.currentContent() else { return nil }
        let readerView = ContentViewController(content: content)
        return readerView
    }
}
//MARK: - delegate
extension ViewController:UIPageViewControllerDelegate, UIPageViewControllerDataSource {
//     UIPageViewControllerDataSource 必须遵守的两个代理
    
//    获取向后翻的控制器
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageParameter = model.parameterBefore()
        
        guard let parameter = pageParameter else {
            return nil
        }
        
        model.currentPage.set(parameter: parameter)
        return readView(parameter: model.currentPage)
    }
//    获取向前翻的控制器
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageParameter = model.parameterAfter()
        
        guard let parameter = pageParameter else {
            return nil
        }
        model.currentPage.set(parameter: parameter)
        return readView(parameter: model.currentPage)
    }
}

