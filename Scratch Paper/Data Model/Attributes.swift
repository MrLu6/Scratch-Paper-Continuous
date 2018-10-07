//
//  attribute.swift
//  Scratch Paper
//
//  Created by CHENGJUN LU on 7/4/18.
//  Copyright © 2018 CHENGJUN LU. All rights reserved.
//

import UIKit

/**
 This class hold all general attributes use in ScratchPaperViewController.swift
 and ScratchPaperView.swift
 
 */
class Attributes{
    
    ///The rgb value for all provided color
    let COLOR_RGB_ARRAY: [(Float,Float,Float)] = [(0,0,0), (127/255,127/255,127/255), (1,0,0),(1,1,0), (0,0,1), (127/255, 0, 127/255), (127/255,127/255,0), (0,1,0), (127/255,127/255,1),(1, 127/255, 0), (127/255, 1, 127/255),(0, 127/255, 127/255), (1, 127/255, 127/255),(1,0,1), (0,1,1), (1,176/255, 59/255) ]
    
    ////The index of COLOR_RGB_ARRAY
    var COLOR_INDEX  = 0
    
    ///The number of brush level
    var NUM_BRUSH: Int16 = 5
    
    ///The number of opacity level
    var NUM_OPACITY: Float = 1
    
    ///Panel On/Off indicator
    var PAENL_IS_ON = false
    
    ///Earser On/Off indicator
    var ERASER_IS_ON = false
    
    ///RGB value for background
    let BACKGROUND_COLOR : (Float,Float,Float) = (1,1,1)
   
    ///The height of the drawing area
    let PAPER_HEIGHT = CGFloat(3507) 
    
    ///The height of scorllView
    let SCROLLER_CONTENT_HEIGHT = CGFloat(2000)

    ///Singleton
    static let instance = Attributes()
    
}
