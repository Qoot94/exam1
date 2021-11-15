////
////  gradiantview.swift
////  Habat-reeh
////
////  Created by Hamad Wasmi on 05/04/1443 AH.
////
//
//import UIKit
//
//class gradiantview: UIButton {
//
//
//        let gradientLayer = CAGradientLayer()
//        
//        @IBInspectable
//        var topGradientColor: UIColor? {
//            didSet {
//                setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
//            }
//        }
//        
//        @IBInspectable
//        var bottomGradientColor: UIColor? {
//            didSet {
//                setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
//            }
//        }
//        
//        private func setGradient(topGradientColor: UIColor?, bottomGradientColor: UIColor?) {
//            if let topGradientColor = topGradientColor, let bottomGradientColor = bottomGradientColor {
//                gradientLayer.frame = bounds
//                gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
//                gradientLayer.borderColor = layer.borderColor
//                gradientLayer.borderWidth = layer.borderWidth
//                gradientLayer.cornerRadius = layer.cornerRadius
//                layer.insertSublayer(gradientLayer, at: 0)
//            } else {
//                gradientLayer.removeFromSuperlayer()
//            }
//        }
//    
//
//
//}
