//
//  attribute.swift
//  Scratch Paper
//
//  Created by CHENGJUN LU on 7/4/18.
//  Copyright © 2018 CHENGJUN LU. All rights reserved.
//


import UIKit

class Attributes{
    
    var COLOR_INDEX  = 0
    
    let COLOR_RGB_ARRAY: [(Float,Float,Float)] = [(0,0,0), (127/255,127/255,127/255), (1,0,0),(1,1,0), (0,0,1), (127/255, 0, 127/255), (127/255,127/255,0), (0,1,0), (127/255,127/255,1),(1, 127/255, 0), (127/255, 1, 127/255),(0, 127/255, 127/255), (1, 127/255, 127/255),(1,0,1), (0,1,1), (1,176/255, 59/255) ]
    
    var NUM_BRUSH: Int16 = 5
    
    var NUM_OPACITY: Float = 1
    
    var PAENL_IS_ON = false
    
    var ERASER_IS_ON = false
    
    var SHARE_IS_ON = false
    
    var HANDF_MODE_IS_ON = false

    ///Singleton
    static let instance = Attributes()
    
    
    func enableColorPanel(){
        
        Attributes.instance.ERASER_IS_ON = false
        Attributes.instance.SHARE_IS_ON = false
        Attributes.instance.HANDF_MODE_IS_ON = false
        
    }
    
    func enableHandMode(){
        
        Attributes.instance.ERASER_IS_ON = false
        Attributes.instance.SHARE_IS_ON = false
        Attributes.instance.PAENL_IS_ON = false
        
    }
    
    
}