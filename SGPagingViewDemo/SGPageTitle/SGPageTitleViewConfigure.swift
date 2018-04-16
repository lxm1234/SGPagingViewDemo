//
//  SGPageTitleViewConfigure.swift
//  SGPagingViewDemo
//
//  Created by Apple on 2018/4/10.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

enum SGIndicatorStyle {
    /// 下划线样式
    case deflt
    /// 遮盖样式
    case cover
    /// 固定样式
    case fixed
    /// 动态样式（仅在 SGIndicatorScrollStyleDefault 样式下支持）
    case dynamic
}

enum SGIndicatorScrollStyle {
    /// 指示器位置跟随内容滚动而改变
    case deflt
    /// 内容滚动一半时指示器位置改变
    case half
    /// 内容滚动结束时指示器位置改变
    case end
}

class SGPageTitleViewConfigure: NSObject {
    /* SGPageTitleView 底部分割线颜色，默认为 lightGrayColor */
    var bottomSeparatorColor: UIColor = UIColor.lightGray
    
    /** 普通状态下标题按钮文字的颜色，默认为黑色 */
    var titleColor: UIColor = UIColor.black
    /** 选中状态下标题按钮文字的颜色，默认为红色 */
    var titleSelectedColor: UIColor = UIColor.red
    /** 标题文字字号大小，默认 15 号字体 */
    var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    /** 按钮之间的间距，默认为 20.0f */
    var spacingBetweenButtons: CGFloat = 20.0
    /** 指示器高度，默认为 2.0f */
    var indicatorHeight: CGFloat = 2.0
    /** 指示器颜色，默认为红色 */
    var indicatorColor: UIColor = UIColor.red
    /** 指示器的额外宽度，介于按钮文字宽度与按钮宽度之间 */
    var indicatorAdditionalWidth: CGFloat = 0
    /** 指示器动画时间，默认为 0.1f，取值范围 0 ～ 0.3f */
    var indicatorAnimationTime: TimeInterval = 0.1
    /** 指示器样式，默认为 SGIndicatorStyleDefault */
    var indicatorStyle: SGIndicatorStyle = .deflt
    /** 指示器遮盖样式下的圆角大小，默认为 0.1f */
    var indicatorCornerRadius: CGFloat = 0.1
    /** 指示器遮盖样式下的边框宽度，默认为 0.0f */
    var indicatorBorderWidth: CGFloat = 0.0
    /** 指示器遮盖样式下的边框颜色，默认为 clearColor */
    var indicatorBorderColor: UIColor = UIColor.clear
    /** 指示器固定样式下宽度，默认为 20.0f；最大宽度并没有做限制，请根据实际情况妥善设置 */
    var indicatorFixedWidth: CGFloat = 20.0
    /** 指示器动态样式下宽度，默认为 20.0f；最大宽度并没有做限制，请根据实际情况妥善设置 */
    var indicatorDynamicWidth: CGFloat = 20.0
    /** 指示器滚动位置改变样式，默认为 SGIndicatorScrollStyleDefault */
    var indicatorScrollStyle: SGIndicatorScrollStyle = .deflt
}
