//
//  DefaultStaticViewController.swift
//  SGPagingViewDemo
//
//  Created by Apple on 2018/4/11.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

class DefaultStaticViewController: UIViewController {

    private var pageTitleView :SGPageTitleView?
    private var pageContentView :SGPageContentView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.setupPageView()
    }
    
    func setupPageView() {
        let statusHeight = UIApplication.shared.statusBarFrame.height
        var pageTitleViewY: CGFloat = 0
        if statusHeight == 20 {
            pageTitleViewY = 64
        } else {
            pageTitleViewY = 88
        }
        let titleArr = ["精选", "请等待2s", "QQGroup", "429899752"]
        let configure = SGPageTitleViewConfigure()
        configure.indicatorScrollStyle = .deflt
        configure.indicatorStyle = .deflt
        configure.indicatorCornerRadius = 4
        configure.titleFont = UIFont.systemFont(ofSize: 15)
        self.pageTitleView = SGPageTitleView(frame: CGRect(x: 0, y: pageTitleViewY, width: self.view.frame.size.width, height: 44), delegate: self, titleNames: titleArr, configure: configure)
        self.pageTitleView?.isNeedBounces = false
        self.view.addSubview(pageTitleView!)
        self.pageTitleView!.isTitleGradientEffect = true
        self.pageTitleView!.selectedIndex = 1
        self.pageTitleView!.isNeedBounces = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            self?.pageTitleView!.resetTitle(with: 1, newTitle: "等待已结束")
        }
        let oneVC = OneChildViewController()
        let twoVC = TwoChildViewController()
        let threeVC = ThreeChildViewController()
        let fourVC = FourChildViewController()
        let childArr = [oneVC,twoVC,threeVC,fourVC]
        
        let contentViewHeight = self.view.frame.size.height - self.pageTitleView!.frame.maxY
        self.pageContentView = SGPageContentView.init(frame: CGRect.init(x: 0, y: self.pageTitleView!.frame.maxY, width: self.view.frame.size.width, height: contentViewHeight), parentVC: self, childVCs: childArr)
        self.pageContentView?.delegatePageContentView = self
        self.view.addSubview(pageContentView!)
    }
}

extension DefaultStaticViewController: SGPageTitleViewDelegate {
    func pageTitleView(pageTitleView: SGPageTitleView, selectedIndex: Int) {
        self.pageContentView!.setPageContentView(currentIndex: selectedIndex)
    }
}

extension DefaultStaticViewController: SGPageContentViewDelegate {
    func pageContentView(pageContentView: SGPageContentView, progress: CGFloat, originalIndex: Int, targetIndex: Int) {
        self.pageTitleView?.setPageTitleView(progress: progress, originalIndex: originalIndex, targetIndex: targetIndex)
    }
}
