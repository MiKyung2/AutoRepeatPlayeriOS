////
////  MyDrawView.swift
////  AutoRepeatPlayer
////
////  Created by jmk on 2017. 7. 5..
////  Copyright © 2017년 jmk. All rights reserved.
////
//
//import UIKit
//import QuartzCore
//
////@IBDesignable
//class MyDrawView: UIView {
//    // 1. mp3 -> dB
//    // 2. graph moveTo
//    // 3. graph drag delegator
//
//    let scrollView: UIScrollView!
//    
////    @IBInspectable var graphColor:UIColor = UIColor.yellow
////    @IBInspectable var graphRatio:Float = 0.8
////    @IBInspectable var graphLineWidth:CGFloat = 1.0
////    
////    @IBInspectable var verticalCenterBarColor:UIColor = UIColor.red
////    @IBInspectable var verticalCenterBarLineWidth:CGFloat = 1.0
////    
////    @IBInspectable var horizontalCenterBarColor:UIColor = UIColor.lightGray
////    @IBInspectable var horizontalCenterBarLineWidth:CGFloat = 1.0
//    
//     var graphColor:UIColor = UIColor.yellow
//     var graphRatio:Float = 0.8
//     var graphLineWidth:CGFloat = 1.0
//    
//     var verticalCenterBarColor:UIColor = UIColor.red
//     var verticalCenterBarLineWidth:CGFloat = 1.0
//    
//     var horizontalCenterBarColor:UIColor = UIColor.lightGray
//     var horizontalCenterBarLineWidth:CGFloat = 1.0
//    
//    var viewWidth = 0
//    var viewHeight = 0
//    var mp3length = 10000
////    var shapeLayers : [CAShapeLayer]
//    
//    required init?(coder aDecoder: NSCoder) {
//        scrollView = UIScrollView(coder: aDecoder)
//        super.init(coder: aDecoder)
////        self.autoresizesSubviews = true
////        scrollView.setNeedsDisplay()
//        
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        viewWidth = Int(self.frame.size.width)
//        viewHeight = Int(self.frame.size.height)
//
//        //for loop (shapeLayers)
////        shapeLayer.removeFromSuperlayer()
//
//        //가로 중앙선
//        drawLineFromPoint(start: CGPoint(x: 0, y: viewHeight/2), toPoint: CGPoint(x: viewWidth, y: viewHeight/2), ofColor : horizontalCenterBarColor, lineWidth : horizontalCenterBarLineWidth, inView: self)
//        
//        scrollView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
//        
//        //그래프
//        for i in (viewWidth/2)...mp3length {
//            
//            let randomNo: UInt32 = arc4random_uniform(UInt32(Float(viewHeight)*graphRatio));
//            let graphPadding = (viewHeight-Int(randomNo))/2
//            drawLineFromPoint(start: CGPoint(x: i, y: graphPadding), toPoint: CGPoint(x: i, y: graphPadding+Int(randomNo)), ofColor : graphColor, lineWidth : graphLineWidth, inView: scrollView)
//            
//        }
//        
//        scrollView.contentSize = CGSize(width: mp3length, height: viewHeight)
//        
//        //세로 중앙선
//        drawLineFromPoint(start: CGPoint(x: viewWidth/2, y: 0), toPoint: CGPoint(x: viewWidth/2, y: viewHeight), ofColor : verticalCenterBarColor, lineWidth : verticalCenterBarLineWidth, inView: self)
//    }
//    
//    override func draw(_ rect: CGRect){
//    }
//
//    func drawLineFromPoint( start: CGPoint, toPoint end: CGPoint, ofColor lineColor: UIColor, lineWidth : CGFloat, inView view: UIView) {
//        
//        //create a path
//        let path = UIBezierPath()
//        path.move(to: start)
//        path.addLine(to: end)
//        
//        //create a shape, and add the path to it
//        let shapeLayer = CAShapeLayer()
////        shapeLayers += shapeLayer
//
//        shapeLayer.path = path.cgPath
//        shapeLayer.strokeColor = lineColor.cgColor
//        shapeLayer.lineWidth = lineWidth
//        
//        //wait till there iss data to show, so we don't get a huge spike from 0.0
//        if (start != CGPoint.zero) {
//            view.layer.addSublayer(shapeLayer)
//        }
//    }
//}
