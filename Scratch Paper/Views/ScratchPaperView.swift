//
//  ScratchPaperView.swift
//  Scratch Paper
//
//  Created by CHENGJUN LU on 7/1/18.
//  Copyright © 2018 CHENGJUN LU. All rights reserved.
//

import UIKit
import CoreData

class ScratchPaperView: UIView{
    
    var drawContextArray  = [DrawContext]()
    var undoRedoContextStack = [DrawContext]()

    var defaults = UserDefaults.standard
    
    var previousPoint1: CGPoint?
    var previousPoint2: CGPoint?
    var currentPoint: CGPoint?
    
    var touchBeginPointArray = [TouchBeginPoint]()
    var undoTouchBeginPointArray = [TouchBeginPoint]()
    
    var touchEndPointArray = [TouchEndPoint]()
    var redoTouchEndPointArray = [TouchEndPoint]()
    
    var numUndoRedoArray = [String]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
           
            let superView = self.superview as! UIScrollView
            superView.isScrollEnabled = true
            
            if touch.type == UITouchType.stylus {
                superView.isScrollEnabled = false
            
                previousPoint1 = touch.location(in: self)
                let newTouchBeginPoint = TouchBeginPoint(context:self.context)
                newTouchBeginPoint.x = Float ((previousPoint1?.x)!)
                newTouchBeginPoint.y = Float((previousPoint1?.y)!)
                touchBeginPointArray.append(newTouchBeginPoint)
                
                save()
            }
            
        }
        
    }
    
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            if touch.type == UITouchType.stylus {
                
                   let newDrawingContext = pointsInPath(touches, with: event)
                
                   if attribute.instance.colorPanelIsEnable == false {
                    
                        drawContextArray.append(newDrawingContext)
                        save()
                        self.setNeedsDisplay()
                   }
            }
            
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let superView = self.superview as! UIScrollView
            superView.isScrollEnabled = false
            
            if touch.type == UITouchType.stylus {
                
                let newDrawingContext = pointsInPath(touches, with: event)
                if attribute.instance.colorPanelIsEnable == false {
                    let newTouchEndPoint = TouchEndPoint(context: self.context)
                    newTouchEndPoint.x = newDrawingContext.previousPoint1X
                    newTouchEndPoint.y = newDrawingContext.previousPoint1Y
                    touchEndPointArray.append(newTouchEndPoint)
                    drawContextArray.append(newDrawingContext)
                    save()
                    self.setNeedsDisplay()
                }
            }
            
        }

    }
    
    
    func pointsInPath(_ touches: Set<UITouch>, with event: UIEvent?) -> DrawContext{
        
        guard let touch = touches.first else { return DrawContext()}
        
        let newDrawingContext = DrawContext(context: self.context)
        
        let previousPoint2 = previousPoint1
        previousPoint1 = touch.previousLocation(in: self)
        
        let currentPoint = touch.location(in: self)
        
        // calculate mid point
        let mid1 = midPoint(p1: previousPoint1!, p2: previousPoint2!)
        let mid2 = midPoint(p1: currentPoint, p2: previousPoint1!)
        
        newDrawingContext.mid1X = Float(mid1.x)
        newDrawingContext.mid1Y = Float(mid1.y)
        
        newDrawingContext.mid2X = Float(mid2.x)
        newDrawingContext.mid2Y = Float(mid2.y)
        
        newDrawingContext.previousPoint1X = Float((previousPoint1?.x)!)
        newDrawingContext.previousPoint1Y = Float((previousPoint1?.y)!)
        
        setContextColor(newDrawingContext: newDrawingContext)
        setContextLineWith(newDrawingContext: newDrawingContext)
        setContextAlpah(newDrawingContext: newDrawingContext)
        
        return  newDrawingContext
        
    }
    
    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
    }
    

    override func draw( _ rect: CGRect) {
       
        let context = UIGraphicsGetCurrentContext()
        
        context?.beginPath()
      
        for points in drawContextArray{
           
            let mid1X = CGFloat(points.mid1X)
            let mid1Y = CGFloat(points.mid1Y)
            let mid2X = CGFloat(points.mid2X)
            let mid2Y = CGFloat(points.mid2Y)
            let previousPoint1X = CGFloat(points.previousPoint1X)
            let previousPoint1Y = CGFloat(points.previousPoint1Y)
            
            context?.move(to: CGPoint(x:mid1X, y: mid1Y))
            context?.addQuadCurve(to: CGPoint(x: mid2X, y: mid2Y), control: CGPoint(x: previousPoint1X, y:previousPoint1Y ))
            context?.setLineCap(.round)
            context?.setStrokeColor(red:CGFloat(points.colorR), green: CGFloat(points.colorG), blue: CGFloat(points.colorB), alpha: CGFloat(points.numOpacity))
            context?.setLineWidth(CGFloat(points.numBrush))
            context?.strokePath()
            
        }
  
    }
    
    
    func setContextColor(newDrawingContext: DrawContext ){
       
        if attribute.instance.eraserEnable == true {
            
            newDrawingContext.colorR = Float(1)
            newDrawingContext.colorG = Float(1)
            newDrawingContext.colorB = Float(1)
            
        }else{
     
            newDrawingContext.colorR = attribute.instance.colorRGB[attribute.instance.colorIndex].0
            newDrawingContext.colorG = attribute.instance.colorRGB[attribute.instance.colorIndex].1
            newDrawingContext.colorB = attribute.instance.colorRGB[attribute.instance.colorIndex].2
            
        }

    }
    
    func setContextLineWith(newDrawingContext: DrawContext ){
        
        newDrawingContext.numBrush = attribute.instance.numBrush
        
    }
    
    func setContextAlpah(newDrawingContext: DrawContext){
        if attribute.instance.eraserEnable == true{
            newDrawingContext.numOpacity = Float(1)
        }else{
            newDrawingContext.numOpacity = attribute.instance.numOpacity
        }
        
    }
        

    func save(){
        
        do{
            try context.save()
        }catch{
            print("Error occurs when saving context\(error)")
        }
        
    }
    
    func loadDrawingContext(){
        
        let request: NSFetchRequest<DrawContext> = DrawContext.fetchRequest()
        
        do{
            
            drawContextArray = try context.fetch(request)

        }catch{
            print("Error occurs when loading context\(error)")
        }
        
        
    }
    
    func loadTochBeginPoint(){
        
        let request: NSFetchRequest<TouchBeginPoint> = TouchBeginPoint.fetchRequest()
        
        do{
            touchBeginPointArray = try context.fetch(request)
        }catch{
            print("Error occurs when loading context\(error)")
        }
    }
    
    func loadTochEndPoint(){
        
        let request: NSFetchRequest<TouchEndPoint> = TouchEndPoint.fetchRequest()
        
        do{
            touchEndPointArray = try context.fetch(request)
        }catch{
            print("Error occurs when loading context\(error)")
        }
    }
    
    
    func undo(){

        if !drawContextArray.isEmpty && !touchBeginPointArray.isEmpty {
            
            var currentContext = drawContextArray.removeLast()
            
            
            var currentPoint = (currentContext.previousPoint1X,currentContext.previousPoint1Y)
            
           
            //get last touchBegainPoint of touchBeginPointArray from the back
            let tempBeginPoint = touchBeginPointArray.removeLast()
            undoTouchBeginPointArray.append(tempBeginPoint)
            let lastBeginTouchPoint = (tempBeginPoint.x,tempBeginPoint.y)
            
            // get the last touchEndPoint
            let tempEndPoint = touchEndPointArray.removeLast()
            
            // use  to hold the pop element use later
            redoTouchEndPointArray.append(tempEndPoint)
            
            undoRedoContextStack.append(currentContext)
            
            while (lastBeginTouchPoint != currentPoint && !drawContextArray.isEmpty){
                currentContext = drawContextArray.removeLast()
                currentPoint = (currentContext.mid1X,currentContext.mid1Y)
                undoRedoContextStack.append(currentContext)
                
            }
        
            numUndoRedoArray.append("undo")
            defaults.set(numUndoRedoArray, forKey: "NumUndoRedoArray")
  
            save()
            self.setNeedsDisplay()
            
        }
        
    }
    
    func redo(){
        
        if !undoRedoContextStack.isEmpty && !redoTouchEndPointArray.isEmpty {
            
            var currentContext = undoRedoContextStack.removeLast()
           
            var currentPoint = (currentContext.previousPoint1X,currentContext.previousPoint1Y)
            drawContextArray.append(currentContext)
  
            if !undoTouchBeginPointArray.isEmpty {
                touchBeginPointArray.append(undoTouchBeginPointArray.removeLast())
            }
        
            
            if !redoTouchEndPointArray.isEmpty {
                
                let tempEndPoint = redoTouchEndPointArray.removeLast()
                touchEndPointArray.append(tempEndPoint)
                
                let lastEndTouchPoint = (tempEndPoint.x, tempEndPoint.y)
                
                while (lastEndTouchPoint != currentPoint && !undoRedoContextStack.isEmpty ){
                    currentContext = undoRedoContextStack.removeLast()
                    currentPoint =  (currentContext.previousPoint1X,currentContext.previousPoint1Y)
                    drawContextArray.append(currentContext)
                }
                
                numUndoRedoArray.append("redo")
                defaults.set(numUndoRedoArray, forKey: "NumUndoRedoArray")
                
                save()
                self.setNeedsDisplay()
                
            }
            
        }
        

    }
    
    
    func deleteDrawingContext(){
        
        
        for drawContext in drawContextArray{
            
            
            context.delete(drawContext)
            drawContextArray.removeFirst()
            
        }
        
        for drawContext in undoRedoContextStack {
            
            context.delete(drawContext)
            undoRedoContextStack.removeFirst()
    
        }
        
        for points in touchBeginPointArray {
            
            context.delete(points)
            touchBeginPointArray.removeFirst()
            
        }
        
        for points in touchEndPointArray {
            
            context.delete(points)
            touchEndPointArray.removeFirst()
            
        }
        
        for points in undoTouchBeginPointArray {
            
            context.delete(points)
            undoTouchBeginPointArray.removeFirst()
            
        }
        
        for points in redoTouchEndPointArray {
            
            context.delete(points)
            redoTouchEndPointArray.removeFirst()
            
        }
        
        numUndoRedoArray.removeAll()
        defaults.set(numUndoRedoArray, forKey: "NumUndoRedoArray")
        
        save()
        self.setNeedsDisplay()
        
    }
    
    func resetDrawContextBeforeTerminated() {
        
        if var numArray = defaults.array(forKey: "NumUndoRedoArray") {
        
            while !(numArray.isEmpty) {
                
                let element = numArray.removeFirst() as! String
                
                element == "undo" ? undo() : redo()
                
            }
            
            defaults.set(numArray, forKey:"NumUndoRedoArray" )
        }
        
    }
    

    override var canBecomeFirstResponder: Bool{
        return true
    }
}

extension ScratchPaperView {
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        return renderer.image { _ in
            self.drawHierarchy(in: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), afterScreenUpdates: false)
        }
    }
    
}


