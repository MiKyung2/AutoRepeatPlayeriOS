//
//  GraphScrollView.swift
//  AutoRepeatPlayer
//
//  Created by jmk on 2017. 7. 28..
//  Copyright © 2017년 jmk. All rights reserved.
//

import UIKit

class GraphScrollView: UIScrollView, UIScrollViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
//    var scrollSnapHeight : CGFloat = self.contentSize.height/10
//    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        if scrollView.contentOffset.y > lastOffset + scrollSnapHeight {
//            scrollView.isScrollEnableded = false
//        } else if scrollView.contentOffset.y < lastOffset - scrollSnapHeight {
//            scrollView.isScrollEnabled = false
//        }
//    }
//    
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        
//        guard !decelerate else {
//            return
//        }
//        
//        setContentOffset(scrollView)
//    }
//    
//    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
//        
//        setContentOffset(scrollView)
//    }
//    
//    func setContentOffset(scrollView: UIScrollView) {
//        
//        let stopOver = scrollSnapHeight
//        var y = round(scrollView.contentOffset.y / stopOver) * stopOver
//        y = max(0, min(y, scrollView.contentSize.height - scrollView.frame.height))
//        lastOffset = y
//        
//        scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, y), animated: true)
//        
//        scrollView.isScrollEnabled = true
//    }
}
