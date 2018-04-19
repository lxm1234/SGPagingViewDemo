//
//  SGPageTitleView.swift
//  SGPagingViewDemo
//
//  Created by Apple on 2018/4/10.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

class SGPageTitleButton: UIButton {
}

protocol  SGPageTitleViewDelegate {
    /**
     *  联动 pageContent 的方法
     *
     *  @param pageTitleView      SGPageTitleView
     *  @param selectedIndex      选中按钮的下标
     */
    func pageTitleView(pageTitleView: SGPageTitleView,selectedIndex: Int)
}

class SGPageTitleView: UIView {
    /** SGPageTitleView 是否需要弹性效果，默认为 YES */
    var isNeedBounces: Bool = true
    /** 选中标题按钮下标，默认为 0 */
    var selectedIndex: Int = 0
    /** 重置选中标题按钮下标（用于子控制器内的点击事件改变标题的选中下标）*/
    var resetSelectedIndex: Int = 0
    /** 是否让标题按钮文字有渐变效果，默认为 YES */
    var isTitleGradientEffect: Bool = true
    /** 是否开启标题按钮文字缩放效果，默认为 NO */
    var isOpenTitleTextZoom: Bool = false
    /** 标题文字缩放比，默认为 0.1f，取值范围 0 ～ 0.3f */
    var titleTextScaling: CGFloat = 0.1
    /** 是否显示指示器，默认为 YES */
    var isShowIndicator: Bool = true
    /** 是否显示底部分割线，默认为 YES */
    var isShowBottomSeparator: Bool = true
    /// SGPageTitleViewDelegate
    private var delegatePageTitleView: SGPageTitleViewDelegate?
    /// SGPageTitleView 配置信息
    private var configure: SGPageTitleViewConfigure!
    /// scrollView
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.frame = CGRect(x: 0, y:0, width: self.SG_width(), height: self.SG_height())
        return scrollView
    }()
    /// 指示器
    private lazy var indicatorView: UIView = {
        let indicatorView = UIView()
        if self.configure.indicatorStyle == .cover {
            let tempIndicatorViewH = self.SG_heightWithString(string: self.btnMArr[0].currentTitle ?? "", font: self.configure.titleFont)
            if self.configure.indicatorHeight > self.SG_height() {
                indicatorView.setSG_y(SG_y: 0)
                indicatorView.setSG_height(SG_height: self.SG_height())
            } else if self.configure.indicatorHeight < tempIndicatorViewH {
                indicatorView.setSG_y(SG_y: 0.5 * (self.SG_height() - tempIndicatorViewH))
                indicatorView.setSG_height(SG_height: tempIndicatorViewH)
            } else {
                indicatorView.setSG_y(SG_y: 0.5 * self.SG_height() - self.configure.indicatorHeight)
                indicatorView.setSG_height(SG_height: self.configure.indicatorHeight)
            }
            //圆角处理
            if self.configure.indicatorCornerRadius > 0.5 * indicatorView.SG_height() {
                indicatorView.layer.cornerRadius = 0.5 * indicatorView.SG_height()
            } else {
                indicatorView.layer.cornerRadius = self.configure.indicatorCornerRadius
            }
            indicatorView.layer.masksToBounds = true
            // 边框宽度及边框颜色
            indicatorView.layer.borderWidth = self.configure.indicatorBorderWidth
            indicatorView.layer.borderColor = self.configure.indicatorBorderColor.cgColor
        } else {
            let indicatorViewH = self.configure.indicatorHeight
            indicatorView.setSG_height(SG_height: indicatorViewH)
            indicatorView.setSG_y(SG_y: self.SG_height() - indicatorViewH)
        }
        indicatorView.backgroundColor = self.configure.indicatorColor
        return indicatorView
    }()
    
    /// 底部分割线
    private lazy var bottomSeparator: UIView = {
        let view = UIView()
        let bottomSeparatorW :CGFloat = self.SG_width()
        let bottomSeparatorH :CGFloat = 0.5
        let bottomSeparatorX :CGFloat = 0
        let bottomSeparatorY :CGFloat = self.SG_height() - bottomSeparatorH
        view.frame = CGRect.init(x: bottomSeparatorX, y: bottomSeparatorY, width: bottomSeparatorW, height: bottomSeparatorH)
        view.backgroundColor = self.configure.bottomSeparatorColor
        return view
    }()
    /// 保存外界传递过来的标题数组
    private var titleArr:[String] = []
    /// 存储标题按钮的数组
    private var btnMArr:[SGPageTitleButton] = []
    /// tempBtn
    private var tempBtn: UIButton?
    /// 记录所有按钮文字宽度
    private var allBtnTextWidth: CGFloat = 0
    /// 记录所有子控件的宽度
    private var allBtnWidth: CGFloat = 0
    /// 标记按钮下标
    private var signBtnIndex: Int = 0
    /// 开始颜色, 取值范围 0~1
    private var startR: CGFloat = 0
    private var startG: CGFloat = 0
    private var startB: CGFloat = 0
    /// 完成颜色, 取值范围 0~1
    private var endR: CGFloat = 0
    private var endG: CGFloat = 0
    private var endB: CGFloat = 0
    
    init(frame: CGRect,delegate: SGPageTitleViewDelegate,titleNames:[String],configure: SGPageTitleViewConfigure) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white.withAlphaComponent(0.77)
        self.delegatePageTitleView = delegate
        self.titleArr = titleNames
        self.configure = configure
        self.setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews()  {
        // 0、处理偏移量
        let tempView = UIView(frame: CGRect.zero)
        self.addSubview(tempView)
        // 1、添加 UIScrollView
        self.addSubview(self.scrollView)
        // 2、添加标题按钮
        self.setupTitleButtons()
        // 3、添加底部分割线
        self.addSubview(self.bottomSeparator)
        // 4、添加指示器
        self.scrollView.insertSubview(self.indicatorView, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let lastBtn = self.btnMArr.last
        if let tag = lastBtn?.tag, tag >= selectedIndex && selectedIndex >= 0 {
            self.P_btn_action(button: self.btnMArr[selectedIndex])
        } else {
            return
        }
    }
    
    func setupTitleButtons() {
        // 计算所有按钮的文字宽度
        self.titleArr.forEach { (title) in
            self.allBtnTextWidth += SG_widthWithString(string: title, font: self.configure.titleFont)
        }
        // 所有按钮文字宽度 ＋ 按钮之间的间隔
        self.allBtnWidth = self.configure.spacingBetweenButtons * CGFloat(self.titleArr.count + 1) + self.allBtnTextWidth
        self.allBtnWidth = CGFloat(ceilf(Float(self.allBtnWidth)))
        let titleCount = self.titleArr.count
        if self.allBtnWidth <= self.bounds.size.width {// SGPageTitleView 静止样式
            let btnY: CGFloat = 0
            let btnW: CGFloat = self.SG_width() / CGFloat(self.titleArr.count)
            var btnH: CGFloat = 0
            if self.configure.indicatorStyle == .deflt {
                btnH = self.SG_height() - self.configure.indicatorHeight
            } else {
                btnH = self.SG_height()
            }
            for index in 0..<titleCount {
                let btn = SGPageTitleButton()
                let btnX = btnW * CGFloat(index)
                btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
                btn.tag = index
                btn.titleLabel?.font = self.configure.titleFont
                btn.setTitle(self.titleArr[index], for: .normal)
                btn.setTitleColor(self.configure.titleColor, for: .normal)
                btn.setTitleColor(self.configure.titleSelectedColor, for: .selected)
                btn.addTarget(self, action: #selector(P_btn_action(button:)), for: .touchUpInside)
                self.btnMArr.append(btn)
                self.scrollView.addSubview(btn)
                self.setupStartColor(color: self.configure.titleColor)
                self.setupEndColor(color: self.configure.titleSelectedColor)
            }
            self.scrollView.contentSize = CGSize(width: self.SG_width(), height: self.SG_height())
        } else {// SGPageTitleView 滚动样式
            var btnX: CGFloat = 0
            let btnY: CGFloat = 0
            var btnH: CGFloat = 0
            if self.configure.indicatorStyle == .deflt {
                btnH = self.SG_height() - self.configure.indicatorHeight
            } else {
                btnH = self.SG_height()
            }
            for index in 0..<titleCount {
                let btn = SGPageTitleButton()
                let btnW = self.SG_widthWithString(string: self.titleArr[index], font: self.configure.titleFont) + self.configure.spacingBetweenButtons
                btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
                btnX = btnX + btnW
                btn.tag = index
                btn.titleLabel?.font = self.configure.titleFont
                btn.setTitle(self.titleArr[index], for: .normal)
                btn.setTitleColor(self.configure.titleColor, for: .normal)
                btn.setTitleColor(self.configure.titleSelectedColor, for: .selected)
                btn.addTarget(self, action: #selector(P_btn_action(button:)), for: .touchUpInside)
                self.btnMArr.append(btn)
                self.scrollView.addSubview(btn)
                self.setupStartColor(color: self.configure.titleColor)
                self.setupEndColor(color: self.configure.titleSelectedColor)
            }
            let scrollViewWidth = self.scrollView.subviews.last?.frame.maxX
            self.scrollView.contentSize = CGSize(width: scrollViewWidth ?? 0, height: self.SG_height())
        }
    }
    
    //pragma mark - - - 计算字符串高度
    func SG_heightWithString(string: String, font: UIFont) -> CGFloat {
        let attrDic = [NSAttributedStringKey.font: font]
        let attrString = NSAttributedString(string: string, attributes: attrDic)
        return attrString.boundingRect(with: CGSize(width: 0, height: 0), options: .usesLineFragmentOrigin, context: nil).integral.size.height
    }
    
    //pragma mark - - - 计算字符串宽度
    func SG_widthWithString(string: String, font: UIFont) -> CGFloat {
        let attrDic = [NSAttributedStringKey.font: font]
        let attrString = NSAttributedString(string: string, attributes: attrDic)
        return attrString.boundingRect(with: CGSize(width: 0, height: 0), options: .usesLineFragmentOrigin, context: nil).integral.size.width
    }
    
    //pragma mark - - - 颜色设置的计算
    /// 开始颜色设置
    func setupStartColor(color: UIColor)  {
        let components = self.getRGBComponents(color: color)
        self.startR = components[0]
        self.startG = components[1]
        self.startB = components[2]
    }
    /// 结束颜色设置
    func setupEndColor(color: UIColor) {
        let components = self.getRGBComponents(color: color)
        self.endR = components[0]
        self.endG = components[1]
        self.endB = components[2]
    }

    /**
     *  指定颜色，获取颜色的RGB值
     *
     *  @param components RGB数组
     *  @param color      颜色
     */
    func getRGBComponents(color: UIColor) -> [CGFloat] {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let data = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let context = CGContext(data: data, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: rgbColorSpace, bitmapInfo: 1)
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect.init(x: 0, y: 0, width: 1, height: 1))
        var components:[CGFloat] = []
        for i in 0..<3 {
            components.append(CGFloat(data[i])/255.0)
        }
        return components
    }
    //pragma mark - - - 标题按钮的点击事件
    @objc func P_btn_action(button: UIButton) {
        // 1、改变按钮的选择状态
        self.p_changeSelectedButton(button)
        // 2、滚动标题选中按钮居中
        if self.allBtnWidth > self.SG_width() {
            self.P_selectedBtnCenter(button)
        }
        // 3、改变指示器的位置以及指示器宽度样式
        self.P_changeIndicatorViewLocationWithButton(button)
        // 4、pageTitleViewDelegate
        self.delegatePageTitleView?.pageTitleView(pageTitleView: self, selectedIndex: button.tag)
        // 5、标记按钮下标
        self.signBtnIndex = button.tag
    }
    //改变按钮的选择状态
    func p_changeSelectedButton(_ button: UIButton) {
        if self.tempBtn == nil {
            button.isSelected =  true
            self.tempBtn = button
        } else if self.tempBtn != nil && self.tempBtn == button {
            button.isSelected = true
        } else if self.tempBtn != nil && self.tempBtn != button {
            self.tempBtn!.isSelected = false
            button.isSelected = true
            self.tempBtn = button
        }
        
        // 此处作用：避免滚动内容视图时手指不离开屏幕的前提下点击按钮后再次滚动内容视图图导致按钮文字由于文字渐变导致未选中按钮文字的不标准化处理
        if self.isTitleGradientEffect == true {
            self.btnMArr.forEach({ (button) in
                button.titleLabel?.textColor = self.configure.titleColor
            })
        }
        // 标题文字缩放属性
        if (self.isOpenTitleTextZoom) {
            self.btnMArr.forEach({ (button) in
                button.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
            button.transform = CGAffineTransform(scaleX: 1 + self.titleTextScaling, y: 1 + self.titleTextScaling)
        }
    }
    //滚动标题选中按钮居中
    func P_selectedBtnCenter(_ button: UIButton) {
        // 计算偏移量
        var offsetX = button.center.x - self.SG_width() * 0.5
        if offsetX < 0 {
            offsetX = 0
        }
        // 获取最大滚动范围
        let maxOffsetX = self.scrollView.contentSize.width - self.SG_width()
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        // 滚动标题滚动条
        self.scrollView.setContentOffset(CGPoint(x:offsetX,y:0), animated: true)
    }
    
    //改变指示器的位置以及指示器宽度样式
    func P_changeIndicatorViewLocationWithButton(_ button: UIButton) {
        UIView.animate(withDuration: TimeInterval(self.configure.indicatorAnimationTime)) {
            if self.configure.indicatorStyle == .fixed {
                self.indicatorView.setSG_width(SG_width: self.configure.indicatorFixedWidth)
                self.indicatorView.setSG_centerX(SG_centerX: button.SG_centerX())
            } else if self.configure.indicatorStyle == .dynamic{
                self.indicatorView.setSG_width(SG_width: self.configure.indicatorDynamicWidth)
                self.indicatorView.setSG_centerX(SG_centerX: button.SG_centerX())
            } else {
                var tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: button.currentTitle ?? "", font: self.configure.titleFont)
                if tempIndicatorWidth > button.SG_width() {
                    tempIndicatorWidth = button.SG_width()
                }
                self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                self.indicatorView.setSG_centerX(SG_centerX: button.SG_centerX())
            }
        }
    }
}
//提供给外界的方法
extension SGPageTitleView {
    /**
     *  根据下标重置标题文字
     *
     *  @param index 标题所对应的下标
     *  @param title 新标题名
     */
    func resetTitle(with index: Int, newTitle title: String) {
        if index < self.btnMArr.count {
            let button = self.btnMArr[index]
            button.setTitle(title, for: .normal)
            if self.signBtnIndex == index {
                if configure.indicatorStyle == .deflt || configure.indicatorStyle == .cover {
                    var tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: button.currentTitle ?? "", font: self.configure.titleFont)
                    if tempIndicatorWidth > button.SG_width() {
                        tempIndicatorWidth = button.SG_width()
                    }
                    self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                    self.indicatorView.setSG_centerX(SG_centerX: button.SG_centerX())
                }
            }
        }
    }

    func setPageTitleView(progress: CGFloat, originalIndex:Int, targetIndex:Int) {
        // 1、取出 originalBtn／targetBtn
        let originalButton = self.btnMArr[originalIndex]
        let targetButton = self.btnMArr[targetIndex]
        self.signBtnIndex = targetButton.tag
        // 2、 滚动标题选中居中
        self.P_selectedBtnCenter(targetButton)
        // 3、处理指示器的逻辑
        if self.allBtnWidth <= self.bounds.size.width {/// SGPageTitleView 不可滚动
            if self.configure.indicatorScrollStyle == .deflt {
                self.P_smallIndicatorScrollStyleDefault(progress: progress, originalBtn : originalButton, targetBtn: targetButton)
            } else {
                self.P_smallIndicatorScrollStyleHalfEnd(progress: progress, originalBtn: originalButton, targetBtn: targetButton)
            }
        } else {/// SGPageTitleView 可滚动
            if self.configure.indicatorScrollStyle == .deflt {
                self.P_indicatorScrollStyleDefault(progress: progress, originalBtn: originalButton, targetBtn: targetButton)
            } else {
                self.P_indicatorScrollStyleHalfEnd(progress: progress, originalBtn: originalButton, targetBtn: targetButton)
            }
        }
        // 4、颜色的渐变(复杂)
        if self.isTitleGradientEffect {
            self.P_isTitleGradientEffect(progress: progress, originalBtn: originalButton, targetBtn: targetButton)
        }
        // 5 、标题文字缩放属性
        if self.isOpenTitleTextZoom {
            //左边缩放
            originalButton.transform = CGAffineTransform.init(scaleX: (1 - progress) * self.titleTextScaling + 1, y: (1 - progress) * self.titleTextScaling + 1)
            //右边缩放
            targetButton.transform = CGAffineTransform.init(scaleX: progress * self.titleTextScaling + 1, y: progress * self.titleTextScaling + 1)
        }
    }
    
    
    func P_smallIndicatorScrollStyleHalfEnd(progress: CGFloat, originalBtn:UIButton, targetBtn:UIButton) {
        if self.configure.indicatorScrollStyle == .half {
            if self.configure.indicatorStyle == .fixed {
                if progress >= 0.5 {
                    UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                        self.indicatorView.setSG_centerX(SG_centerX: targetBtn.SG_centerX())
                        self.p_changeSelectedButton(targetBtn)
                    })
                } else {
                    UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                        self.indicatorView.setSG_centerX(SG_centerX: originalBtn.SG_centerX())
                        self.p_changeSelectedButton(originalBtn)
                    })
                }
                return
            }
            /// 指示器默认样式以及遮盖样式处理
            if progress >= 0.5 {
                let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: targetBtn.currentTitle ?? "", font: self.configure.titleFont)
                UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                    if tempIndicatorWidth >= targetBtn.SG_width() {
                        self.indicatorView.setSG_width(SG_width: targetBtn.SG_width())
                    } else {
                        self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                    }
                    self.indicatorView.setSG_centerX(SG_centerX: targetBtn.SG_centerX())
                    self.p_changeSelectedButton(targetBtn)
                })
            } else {
                let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: originalBtn.currentTitle ?? "", font: self.configure.titleFont)
                UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                    if tempIndicatorWidth >= targetBtn.SG_width() {
                        self.indicatorView.setSG_width(SG_width: originalBtn.SG_width())
                    } else {
                        self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                    }
                    self.indicatorView.setSG_centerX(SG_centerX: originalBtn.SG_centerX())
                    self.p_changeSelectedButton(originalBtn)
                })
            }
            return
        }
        /// 滚动内容结束指示器处理 ____ 指示器默认样式以及遮盖样式处理
        if self.configure.indicatorStyle == .fixed {
            if progress == 1.0 {
                UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                    self.indicatorView.setSG_centerX(SG_centerX: targetBtn.SG_centerX())
                    self.p_changeSelectedButton(targetBtn)
                })
            } else {
                UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                    self.indicatorView.setSG_centerX(SG_centerX: originalBtn.SG_centerX())
                    self.p_changeSelectedButton(originalBtn)
                })
            }
            return
        }
        if progress == 1.0 {
            let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: targetBtn.currentTitle ?? "", font: self.configure.titleFont)
            UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                if tempIndicatorWidth >= targetBtn.SG_width() {
                    self.indicatorView.setSG_width(SG_width: targetBtn.SG_width())
                } else {
                    self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                }
                self.indicatorView.setSG_centerX(SG_centerX: targetBtn.SG_centerX())
                self.p_changeSelectedButton(targetBtn)
            })
        } else {
            let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: originalBtn.currentTitle ?? "", font: self.configure.titleFont)
            UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                if tempIndicatorWidth >= targetBtn.SG_width() {
                    self.indicatorView.setSG_width(SG_width: originalBtn.SG_width())
                } else {
                    self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                }
                self.indicatorView.setSG_centerX(SG_centerX: originalBtn.SG_centerX())
                self.p_changeSelectedButton(originalBtn)
            })
        }
    }
    
    func P_smallIndicatorScrollStyleDefault(progress: CGFloat, originalBtn:UIButton, targetBtn:UIButton) {
        // 1、改变按钮的选择状态
        if progress >= 0.8 {/// 此处取 >= 0.8 而不是 1.0 为的是防止用户滚动过快而按钮的选中状态并没有改变
            self.p_changeSelectedButton(targetBtn)
        }
        if self.configure.indicatorStyle == .dynamic {
            let originalBtnTag = originalBtn.tag
            let targetBtnTag = targetBtn.tag
            // 按钮之间的距离
            let distance = self.SG_width() / CGFloat(self.titleArr.count)
            if originalBtnTag <= targetBtnTag {// 往左滑
                if progress <= 0.5 {
                    self.indicatorView.setSG_width(SG_width: self.configure.indicatorDynamicWidth + 2 * progress * distance)
                } else {
                    let targetBtnIndicatorX = targetBtn.frame.maxX - 0.5 * (distance - self.configure.indicatorDynamicWidth) - self.configure.indicatorDynamicWidth
                    self.indicatorView.setSG_x(SG_x: targetBtnIndicatorX + 2 * (progress - 1) * distance)
                    self.indicatorView.setSG_width(SG_width: self.configure.indicatorDynamicWidth + 2 * (1-progress)*distance)
                }
            } else {
                if progress <= 0.5 {
                    let originalBtnIndicatorX = originalBtn.frame.maxX - 0.5 * (distance - self.configure.indicatorDynamicWidth) - self.configure.indicatorDynamicWidth
                    self.indicatorView.setSG_x(SG_x: originalBtnIndicatorX - 2 * progress * distance)
                    self.indicatorView.setSG_width(SG_width: self.configure.indicatorDynamicWidth + 2 * progress * distance)
                } else {
                    let targetBtnIndicatorX = targetBtn.frame.maxX - self.configure.indicatorDynamicWidth - 0.5 * (distance - self.configure.indicatorDynamicWidth)
                    self.indicatorView.setSG_x(SG_x: targetBtnIndicatorX)// 这句代码必须写，防止滚动结束之后指示器位置存在偏差，这里的偏差是由于 progress >= 0.8 导致的
                    self.indicatorView.setSG_width(SG_width: self.configure.indicatorDynamicWidth + 2 * (1 - progress)*distance)
                }
            }
        } else if self.configure.indicatorStyle == .fixed{
            let targetBtnIndicatorX = targetBtn.frame.maxX - 0.5 * (self.SG_width()/CGFloat(self.titleArr.count) - self.configure.indicatorFixedWidth) - self.configure.indicatorFixedWidth
            let originalBtnIndicatorX = originalBtn.frame.maxX - 0.5 * (self.SG_width()/CGFloat(self.titleArr.count) - self.configure.indicatorFixedWidth) - self.configure.indicatorFixedWidth
            let totalOffsetX = targetBtnIndicatorX - originalBtnIndicatorX
            self.indicatorView.setSG_x(SG_x: originalBtnIndicatorX + progress * totalOffsetX)
        } else {
            //1.计算indicator 偏移量
            //targetBtn 文字宽度
            let targetBtnTextWidth = self.SG_widthWithString(string: targetBtn.currentTitle ?? "", font: self.configure.titleFont)
            let targetBtnIndicatorX = targetBtn.frame.maxX - targetBtnTextWidth - 0.5 * (self.SG_width()/CGFloat(self.titleArr.count) - targetBtnTextWidth + self.configure.indicatorAdditionalWidth)
            // originBtn 文字宽度
            let originalBtnTextWidth = self.SG_widthWithString(string: originalBtn.currentTitle ?? "", font: self.configure.titleFont)
            let originalBtnIndicatorX = originalBtn.frame.maxX - originalBtnTextWidth - 0.5 * (self.SG_width()/CGFloat(self.titleArr.count) - originalBtnTextWidth + self.configure.indicatorAdditionalWidth)
            let totalOffsetX = targetBtnIndicatorX - originalBtnIndicatorX
            ///2.计算文字之间的差值
            //按钮宽度的距离
            let btnWidth = self.SG_width() / CGFloat(self.titleArr.count)
            //targetBtn 文字右边的 x 值
            let targetBtnRightTextX = targetBtn.frame.maxX - 0.5 * (btnWidth - targetBtnTextWidth)
            //targetBtn 文字右边的 x 值
            let originalBtnRightTextX = originalBtn.frame.maxX - 0.5 * (btnWidth - originalBtnTextWidth)
            let totalRightTextDistance = targetBtnRightTextX - originalBtnRightTextX
            // 计算 indicatorView 滚动时 x 的偏移量
            let offsetX = totalOffsetX * progress
            // 计算 indicatorView 滚动时文字宽度的偏移量
            let distance = progress * (totalRightTextDistance - totalOffsetX)
            /// 3、计算 indicatorView 新的 frame
            self.indicatorView.setSG_x(SG_x: originalBtnIndicatorX + offsetX)
            
            let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + originalBtnTextWidth + distance
            
            if tempIndicatorWidth >= targetBtn.SG_width() {
                let moveTotalX = targetBtn.SG_origin().x - originalBtn.SG_origin().x
                let moveX = moveTotalX * progress
                self.indicatorView.setSG_centerX(SG_centerX: originalBtn.SG_centerX() + moveX)
            } else {
                self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
            }
        }
    }
    
    func P_indicatorScrollStyleDefault(progress: CGFloat, originalBtn:UIButton, targetBtn:UIButton) {
        /// 改变按钮的选择状态
        if progress >= 0.8 {/// 此处取 >= 0.8 而不是 1.0 为的是防止用户滚动过快而按钮的选中状态并没有改变
            self.p_changeSelectedButton(targetBtn)
        }
        if self.configure.indicatorStyle == .dynamic {
            let originalBtnTag = originalBtn.tag
            let targetBtnTag = targetBtn.tag
            if originalBtnTag <= targetBtnTag {// 往左滑
                // targetBtn 与 originalBtn 中心点之间的距离
                let btnCenterXDistance = targetBtn.SG_centerX() - originalBtn.SG_centerX()
                if progress <= 0.5 {
                    self.indicatorView.setSG_width(SG_width: 2 * progress * btnCenterXDistance + self.configure.indicatorDynamicWidth)
                } else {
                    let targetBtnX = targetBtn.frame.maxX - self.configure.indicatorDynamicWidth - 0.5 * (targetBtn.SG_width() - self.configure.indicatorDynamicWidth)
                    self.indicatorView.setSG_x(SG_x: targetBtnX + 2 * (progress - 1) * btnCenterXDistance)
                    self.indicatorView.setSG_width(SG_width: 2 * (1 - progress) * btnCenterXDistance + self.configure.indicatorDynamicWidth)
                }
            } else {
                // originalBtn 与 targetBtn 中心点之间的距离
                let btnCenterXDistance = originalBtn.SG_centerX() - targetBtn.SG_centerX()
                if progress <= 0.5 {
                    let originalBtnX = originalBtn.frame.maxX - self.configure.indicatorDynamicWidth - 0.5 * (originalBtn.SG_width() - self.configure.indicatorDynamicWidth)
                    self.indicatorView.setSG_x(SG_x: originalBtnX - 2 * progress * btnCenterXDistance)
                    self.indicatorView.setSG_width(SG_width: 2 * progress * btnCenterXDistance + self.configure.indicatorDynamicWidth )
                } else {
                    let targetBtnX = targetBtn.frame.maxX - self.configure.indicatorDynamicWidth - 0.5 * (targetBtn.SG_width() - self.configure.indicatorDynamicWidth)
                    self.indicatorView.setSG_x(SG_x: targetBtnX)
                    self.indicatorView.setSG_width(SG_width: 2 * (1 - progress) * btnCenterXDistance + self.configure.indicatorDynamicWidth)
                }
            }
        } else if self.configure.indicatorStyle == .fixed {
            let targetBtnIndicatorX = targetBtn.frame.maxX - 0.5 * (targetBtn.SG_width() - self.configure.indicatorFixedWidth) - self.configure.indicatorFixedWidth
            let originalBtnIndicatorX = originalBtn.frame.maxX - self.configure.indicatorFixedWidth - 0.5 * (originalBtn.SG_width() - self.configure.indicatorFixedWidth)
            let totalOffsetX = targetBtnIndicatorX - originalBtnIndicatorX
            let offsetX = totalOffsetX * progress
            self.indicatorView.setSG_x(SG_x: originalBtnIndicatorX + offsetX)
        } else {
            // 1、计算 targetBtn／originalBtn 之间的 x 差值
            let totalOffsetX = targetBtn.SG_origin().x - originalBtn.SG_origin().x
            // 2、计算 targetBtn／originalBtn 之间的差值
            let totalDistance = targetBtn.frame.maxX - originalBtn.frame.maxX
            /// 计算 indicatorView 滚动时 x 的偏移量
            var offsetX :CGFloat = 0.0
            /// 计算 indicatorView 滚动时宽度的偏移量
            var distance :CGFloat = 0.0
            
            let targetBtnTextWidth = self.SG_widthWithString(string: targetBtn.currentTitle ?? "", font: self.configure.titleFont)
            let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + targetBtnTextWidth
            if tempIndicatorWidth >= targetBtn.SG_width() {
                offsetX = totalOffsetX * progress
                distance = progress * (totalDistance - totalOffsetX)
                self.indicatorView.setSG_x(SG_x: originalBtn.SG_origin().x + offsetX)
                self.indicatorView.setSG_width(SG_width: originalBtn.SG_width() + distance)
            } else {
                offsetX = totalOffsetX * progress + 0.5 * self.configure.spacingBetweenButtons - 0.5 * self.configure.indicatorAdditionalWidth
                distance = progress * (totalDistance - totalOffsetX) - self.configure.spacingBetweenButtons
                self.indicatorView.setSG_x(SG_x: originalBtn.SG_origin().x + offsetX)
                self.indicatorView.setSG_width(SG_width: originalBtn.SG_width() + distance + self.configure.indicatorAdditionalWidth)
            }
        }
    }
    
    func P_indicatorScrollStyleHalfEnd(progress: CGFloat, originalBtn:UIButton, targetBtn:UIButton)  {
        if self.configure.indicatorScrollStyle == .half {
            if self.configure.indicatorStyle == .fixed {
                if progress >= 0.5 {
                    UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                        self.indicatorView.setSG_centerX(SG_centerX: targetBtn.SG_centerX())
                        self.p_changeSelectedButton(targetBtn)
                    })
                } else {
                    UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                        self.indicatorView.setSG_centerX(SG_centerX: originalBtn.SG_centerX())
                        self.p_changeSelectedButton(originalBtn)
                    })
                }
                return
            }
            /// 指示器默认样式以及遮盖样式处理
            if progress >= 0.5 {
                let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: targetBtn.currentTitle ?? "", font: self.configure.titleFont)
                UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                    if tempIndicatorWidth >= targetBtn.SG_width() {
                        self.indicatorView.setSG_width(SG_width: targetBtn.SG_width())
                    } else {
                        self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                    }
                    self.indicatorView.setSG_centerX(SG_centerX: targetBtn.SG_centerX())
                    self.p_changeSelectedButton(targetBtn)
                })
            } else {
                let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: originalBtn.currentTitle ?? "", font: self.configure.titleFont)
                UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                    if tempIndicatorWidth >= targetBtn.SG_width() {
                        self.indicatorView.setSG_width(SG_width: originalBtn.SG_width())
                    } else {
                        self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                    }
                    self.indicatorView.setSG_centerX(SG_centerX: originalBtn.SG_centerX())
                    self.p_changeSelectedButton(originalBtn)
                })
            }
            return
        }
        /// 滚动内容结束指示器处理 ____ 指示器默认样式以及遮盖样式处理
        if self.configure.indicatorStyle == .fixed {
            if progress == 1.0 {
                UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                    self.indicatorView.setSG_centerX(SG_centerX: targetBtn.SG_centerX())
                    self.p_changeSelectedButton(targetBtn)
                })
            } else {
                UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                    self.indicatorView.setSG_centerX(SG_centerX: originalBtn.SG_centerX())
                    self.p_changeSelectedButton(originalBtn)
                })
            }
            return
        }
        if progress == 1.0 {
            let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: targetBtn.currentTitle ?? "", font: self.configure.titleFont)
            UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                if tempIndicatorWidth >= targetBtn.SG_width() {
                    self.indicatorView.setSG_width(SG_width: targetBtn.SG_width())
                } else {
                    self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                }
                self.indicatorView.setSG_centerX(SG_centerX: targetBtn.SG_centerX())
                self.p_changeSelectedButton(targetBtn)
            })
        } else {
            let tempIndicatorWidth = self.configure.indicatorAdditionalWidth + self.SG_widthWithString(string: originalBtn.currentTitle ?? "", font: self.configure.titleFont)
            UIView.animate(withDuration: self.configure.indicatorAnimationTime, animations: {
                if tempIndicatorWidth >= targetBtn.SG_width() {
                    self.indicatorView.setSG_width(SG_width: originalBtn.SG_width())
                } else {
                    self.indicatorView.setSG_width(SG_width: tempIndicatorWidth)
                }
                self.indicatorView.setSG_centerX(SG_centerX: originalBtn.SG_centerX())
                self.p_changeSelectedButton(originalBtn)
            })
        }
    }
    
    func P_isTitleGradientEffect(progress: CGFloat, originalBtn:UIButton, targetBtn:UIButton) {
        // 获取 targetProgress
        let targetProgress = progress;
        // 获取 originalProgress
        let originalProgress = 1 - targetProgress;
            
        let r = self.endR - self.startR
        let g = self.endG - self.startG
        let b = self.endB - self.startB
        let originalColor = UIColor.init(red: self.startR + r * originalProgress, green: self.startG + g * originalProgress, blue: self.startB + b * originalProgress, alpha: 1)
        let targetColor = UIColor.init(red: self.startR + r * targetProgress, green: self.startG + g * targetProgress, blue: self.startB + b * targetProgress, alpha: 1)
            
        // 设置文字颜色渐变
        originalBtn.titleLabel?.textColor = originalColor
        targetBtn.titleLabel?.textColor = targetColor
    }
}
