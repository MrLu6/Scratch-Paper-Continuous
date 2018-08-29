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
    let colorRGB: [(Float,Float,Float)] = [(0,0,0), (153/255,76/255,0), (192/255,192/255,192/255),(0,1,0), (0,0,1), (1,153/255,51/255), (1,0,1), (1,1,0), (1,0,0), (1,153/255,204/255), (204/255,1,204/255), (204/255,1,1)]
    
    var numBrush: Int16 = 5
    var numOpacity: Float = 1
    var colorPanelIsEnable = false
    var numClikedWhenColorPanelIsEnable = 0
    var eraserEnable = false

    
    static let instance = attribute()
    
}
