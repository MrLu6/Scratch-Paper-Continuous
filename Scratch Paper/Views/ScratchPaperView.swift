//
//  ScratchPaperView.swift
//  Scratch Paper
//
//  Created by CHENGJUN LU on 7/1/18.
//  Copyright © 2018 CHENGJUN LU. All rights reserved.
//

import UIKit
import CoreData

/**
    This class perfrom handles user drawing
    such as save and load user drawing and perfrom undo/redo.
 */
class ScratchPaperView: UIView{
    
    /// Some constans that use in this class
    struct Constants {
        static let UNDO = "undo"
        static let REDO = "redo"
        static let numUndoRedoArrayKey = "NumUndoRedoArray"
    }
    
    /// This drawContextArray store all properties of the drawing content: color startPoint midPoint EndPoint numBrush and numOpacity.
    var drawContextArray  = [DrawContext]()
    
    /// The undoRedoContextStack store all undo and redo user drawing content.
    var undoRedoContextStack = [DrawContext]()

    /// Use UserDefault to store number of times undo and redo.
    var defaults = UserDefaults.standard
    
    /// The startPoint of user drawing cotent.
    var previousPoint1: CGPoint?
    
    /// The endPoint of user drawing content.
    var previousPoint2: CGPoint?
    
    /// The current point location of user drawing content.
    var currentPoint: CGPoint?
    
    /// Store all properties of each touch begin point.
    var touchBeginPointArray = [TouchBeginPoint]()
    
    /// Stor touch begin point that remove from the touchBeginPointArra during the uno step and use later in the undo step.
    var undoTouchBeginPointArray = [TouchBeginPoint]()
    
    /// Store all properties of each touch end point.
    var touchEndPointArray = [TouchEndPoint]()
    
    /// Store touch end point that remov from the touchEndPointArray during uno step and use later in the rodo step.
    var redoTouchEndPointArray = [TouchEndPoint]()
    
    /// Keep track of the order of undo and redo (use to recovert the sate which before app is terminated).
    var numUndoRedoArray = [String]()
    
    /// Representative of all data in core data frame work of this app
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /**
     
        ## Import Notes ##
        1. Stop sorlling when recieve input from apple pencil.
        2. Store begin touch point as previousPoint1 into the core data framework.
        3. Store each touch begin point into touchBeginArray.
     
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
           
            let superView = self.superview as! UIScrollView
            if  Attributes.instance.PAENL_IS_ON == false {
                
                superView.isScrollEnabled = true

            }
            
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
    
    /**
     
        ## Import Notes ##
        1. Pass each point during the touchMoved step into the pointsInPath function
        2. Add DrawContext that created by pointsInpath function into the drawContextArray
        3. Store all drwcontext infromation into core data
     
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            if touch.type == UITouchType.stylus {
                
                   let newDrawingContext = pointsInPath(touches, with: event)
                
                   if !Attributes.instance.PAENL_IS_ON {
                    
                        drawContextArray.append(newDrawingContext)
                        save()
                        self.setNeedsDisplay()
                   }
            }
            
        }

    }
    
    /**
     
        ## Import Notes ##
        1. Stop sorlling when recieve input from apple pencil.
        2. Store touch end point as previousPoint1 into the core data framework.
        3. Store each touch end point into touchEndArray.
        4. Store all drwcontext infromation into core data
     
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let superView = self.superview as! UIScrollView
            superView.isScrollEnabled = false
            
            if touch.type == UITouchType.stylus {
                
                let newDrawingContext = pointsInPath(touches, with: event)
                if !Attributes.instance.PAENL_IS_ON {
                    
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
    
    /**
       This function uses the current touch point and the previous touch point to calculate the midpoint.
       And, store information of all properties into DrawContext: previousPoint1 previousPoint2 midPoint
       color lineWidth and Alpah.
     
       - Parameter touches: A set of UITouch instances that represent the touches for the ending phase
                           of the event represented by event. For touches in a view, this set contains
                           only one touch by default. To receive multiple touches, you must set the view's
                           is Multiple TouchEnabled property to true.
     
       - Parameter event: The event to which the touches belong.
     
       - Returns: DrawContext with all properties listed in the core data.
     
     */
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
        setContextLineWidth(newDrawingContext: newDrawingContext)
        setContextAlpah(newDrawingContext: newDrawingContext)
        
        return  newDrawingContext
        
    }
    
    /**
        This function calculate the mid point of given two point.
     
        - Parameter p1: The first point that is given.
     
        - Parameter p2: The second point that is given.
     
        - Returns: The mid point of the given two points.
     
     */
    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
    }
    
    /**
     
        ## Import Notes ##
        1. Draw line across the mid1 point, mid2 point and the previousPoint1.
        2. Set line properties: cruve stytle, lineCap and color.
     
     */
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
    
    /**
        This function set eraser color to the background color if eraser is enable and
        newDrawingContext(touch point) color(RGB value) based on user selection.
     
        - Parameter newDrawingContext: touch point with all properties that store in core data.
     
        ## Import Notes ##
           1.attirbute is the singleton approch to save small amount of data
     
     */
    func setContextColor(newDrawingContext: DrawContext ){
       
        if Attributes.instance.ERASER_IS_ON == true {
            
            newDrawingContext.colorR = Float(1)
            newDrawingContext.colorG = Float(1)
            newDrawingContext.colorB = Float(1)
            
        }else{
     
            newDrawingContext.colorR = Attributes.instance.COLOR_RGB_ARRAY[Attributes.instance.COLOR_INDEX].0
            newDrawingContext.colorG = Attributes.instance.COLOR_RGB_ARRAY[Attributes.instance.COLOR_INDEX].1
            newDrawingContext.colorB = Attributes.instance.COLOR_RGB_ARRAY[Attributes.instance.COLOR_INDEX].2
            
        }

    }
    
    /**
         This function set lineWidth of newDrawingContext(touch point) based on user selection(numBrush).
     
         - Parameter newDrawingContext: touch point with all properties that store in core data.
     
         - SeeAlso: 'setContextColor(newDrawingContext: DrawContext )'.
     
     */
    func setContextLineWidth(newDrawingContext: DrawContext ){
        
        newDrawingContext.numBrush = Attributes.instance.NUM_BRUSH
        
    }
    
    /**
         This function set alpah of newDrawingContext(touch point) based on user selection(numOpacity).
         
         - Parameter newDrawingContext: touch point with all properties that store in core data.
         
         - SeeAlso: 'setContextColor(newDrawingContext: DrawContext )'.
     
     */
    func setContextAlpah(newDrawingContext: DrawContext){
       
            newDrawingContext.numOpacity = Attributes.instance.NUM_OPACITY
    }
        
    
        
    /**
        This function save all draw context(all points) into the core data.
     
    */
    func save(){
        
        do{
            try context.save()
        }catch{
            print("Error occurs when saving context\(error)")
        }
        
    }
    
    /**
        This function load all draw context(all points) to the drawContextArray.
     
     */
    func loadDrawingContext(){
        
        let request: NSFetchRequest<DrawContext> = DrawContext.fetchRequest()
        
        do{
            
            drawContextArray = try context.fetch(request)

        }catch{
            print("Error occurs when loading context\(error)")
        }
        
        
    }
    
    /**
        This function load all touch begin point to the touchBeginPointArray.
     
     */
    func loadTochBeginPoint(){
        
        let request: NSFetchRequest<TouchBeginPoint> = TouchBeginPoint.fetchRequest()
        
        do{
            touchBeginPointArray = try context.fetch(request)
        }catch{
            print("Error occurs when loading context\(error)")
        }
    }
    
    /**
     This function load all touch end point to the touchEndPointArray.
     
     */
    func loadTochEndPoint(){
        
        let request: NSFetchRequest<TouchEndPoint> = TouchEndPoint.fetchRequest()
        
        do{
            touchEndPointArray = try context.fetch(request)
        }catch{
            print("Error occurs when loading context\(error)")
        }
    }
    
    
    /**
        This function perform the undo step and record the total number of undo times
     
        ## Import Notes ##
        1. Perfrom undo only if there is still have draw context in drawContextArray and touchBeginPointArray
           is not empty(To make sure there is draw context in the page to perform undo)
        2. Constantly remove the last point of the drawContextArray until it meet the last touch begin point
           (Need to make sure drawContextArray is not empty)
        3. Save last touch end point which use later in redo step
     */
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
            
            redoTouchEndPointArray.append(tempEndPoint)
            
            undoRedoContextStack.append(currentContext)
            
            while (lastBeginTouchPoint != currentPoint && !drawContextArray.isEmpty){
                currentContext = drawContextArray.removeLast()
                currentPoint = (currentContext.mid1X,currentContext.mid1Y)
                undoRedoContextStack.append(currentContext)
                
            }
        
            //save total number of undo times in to the numUndoRedoArray
            numUndoRedoArray.append(Constants.UNDO)
            defaults.set(numUndoRedoArray, forKey: Constants.numUndoRedoArrayKey)
  
            save()
            self.setNeedsDisplay()
            
        }
        
    }
    
    /**
        This function perform the redo step and record the total number of redo times
     
         ## Import Notes ##
         1. Perfrom redo only if there is still have draw context in undoRedoContextStack(all draw context pop out from the
            undo step that save into this array) and redoTouchEndPointArray (touch end point)
            is not empty(To make sure there is draw context in the page to perform undo)
         2. Constantly remove the last point of the undoRedoContextStack until it meet the last touch end point
            (Need to make sure redoTouchEndPointArray is not empty)
     */
    func redo(){
        
        if !undoRedoContextStack.isEmpty && !redoTouchEndPointArray.isEmpty {
            
            var currentContext = undoRedoContextStack.removeLast()
           
            var currentPoint = (currentContext.previousPoint1X,currentContext.previousPoint1Y)
            drawContextArray.append(currentContext)
  
            // push back the touchBeginPoint that pop out from the undo step into the touchBeginPointArray during redo step
            if !undoTouchBeginPointArray.isEmpty {
                touchBeginPointArray.append(undoTouchBeginPointArray.removeLast())
            }
        
            // Make sure touch endPoint is not empty
            if !redoTouchEndPointArray.isEmpty {
                
                let tempEndPoint = redoTouchEndPointArray.removeLast()
                touchEndPointArray.append(tempEndPoint)
                
                let lastEndTouchPoint = (tempEndPoint.x, tempEndPoint.y)
                
                while (lastEndTouchPoint != currentPoint && !undoRedoContextStack.isEmpty ){
                    currentContext = undoRedoContextStack.removeLast()
                    currentPoint =  (currentContext.previousPoint1X,currentContext.previousPoint1Y)
                    drawContextArray.append(currentContext)
                }
                
                numUndoRedoArray.append(Constants.REDO)
                defaults.set(numUndoRedoArray, forKey: Constants.numUndoRedoArrayKey)
                
                save()
                self.setNeedsDisplay()
                
            }
            
        }
        

    }
    
    /**
        This function delete all the darw context including all touch begin point and end point and data store
        in the core data.
        
     */
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
        
        //Delete the total numbe of undo and redo times
        numUndoRedoArray.removeAll()
        defaults.set(numUndoRedoArray, forKey: Constants.numUndoRedoArrayKey)
        
        save()
        self.setNeedsDisplay()
        
    }
    
    /**
        This function save the current sate of drawing context before terminated
     
         ## Import Notes ##
         1. Core data save everything of user drawing.
         2. Need to perfrom all undo and redo again in order to comeback the latest state.
    */
    func resetDrawContextBeforeTerminated() {
        
        if var numArray = defaults.array(forKey: Constants.numUndoRedoArrayKey) {
        
            while !(numArray.isEmpty) {
                
                let element = numArray.removeFirst() as! String
                
                element == Constants.UNDO ? undo() : redo()
                
            }
            
            defaults.set(numArray, forKey:Constants.numUndoRedoArrayKey )
        }
        
    }
    
}

/**
    Extension to ScratchPaperView. More functionality may add into in the later version
 */
extension ScratchPaperView {
    
    /**
        This function convert the ScratchPaperView into Images
     
        - Returns: Images that contain all user drawing
     */
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        return renderer.image { _ in
            self.drawHierarchy(in: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), afterScreenUpdates: false)
        }
    }
    
}


