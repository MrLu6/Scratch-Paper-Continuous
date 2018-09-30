//
//  attribute.swift
//  Scratch Paper
//
//  Created by CHENGJUN LU on 7/4/18.
//  Copyright © 2018 CHENGJUN LU. All rights reserved.
//


import UIKit

class attribute{
    
    var colorIndex  = 0
    
    
    let colorRGB: [(Float,Float,Float)] = [(0,0,0), (127/255,127/255,127/255), (1,0,0),(1,1,0), (0,0,1), (127/255, 0, 127/255), (127/255,127/255,0), (0,1,0), (127/255,127/255,1),(1, 127/255, 0), (127/255, 1, 127/255),(0, 127/255, 127/255), (1, 127/255, 127/255),(1,0,1), (0,1,1), (1,176/255, 59/255) ]
    
    var numBrush: Int16 = 5
    
    var numOpacity: Float = 1
    
    var colorPanelIsEnable = false
    
    var numClikedWhenColorPanelIsEnable = 0
    
    var eraserEnable = false

    ///Singleton
    static let instance = attribute()
    
}
