//
//  ViewController.swift
//  Scratch Paper
//
//  Created by CHENGJUN LU on 7/1/18.
//  Copyright © 2018 CHENGJUN LU. All rights reserved.
//

    // let colorArray = ["Black","Brown","Gray","Green","Blue","Orange","Purple","Yellow","Red","Pink","LGreen","LBlue"]

import UIKit

class ScratchPaperViewController:UIViewController {
    
    
    struct Constants {
        
        static let A4_HEIGHT = CGFloat(3507)
        static let PAPERHEIGHT = ABDAY_4 * 5
        static let SCROLLER_CONTENT_HEIGHT = CGFloat(2000)
        
    }
    

    @IBOutlet weak var scroller: UIScrollView!
    
    @IBOutlet weak var paperView: ScratchPaperView!
    
    @IBOutlet weak var toolBarView: UIView!
    
    ///Use to display 
    @IBOutlet weak var ColorBrushOpcityPanel: UIView!
    
    ///Use to display the size of drawing point in text
    @IBOutlet weak var BrushLabel: UILabel!
    
    ///Use to display display the transparency of drawing point in text
    @IBOutlet weak var OpacityLabel: UILabel!
    
    ///Use to change the size of drawing point
    @IBOutlet weak var brushSlider: UISlider!
    
    ///Use to change the transparency of drawing point
    @IBOutlet weak var opacitySlider: UISlider!
    
    /**
        This function hands when brushSlider is slided by user.
        It will change the brushProerties and display accordingly
     */
    @IBAction func BrushSlider(_ sender: UISlider) {
       
       brushPropertiesChange()
        
    }
    
    /**
         This function hands when OpacitySlider is slided by user.
         It will change the OpacityProerties and display accordingly
     */
    @IBAction func OpacitySlider(_ sender: UISlider) {
        
        opacityPropertiesChange()
        
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorBrushOpcityPanel.isHidden = true
        scroller.isScrollEnabled = false
        
        paperView.frame.size.height = Constants.A4_HEIGHT
        scroller.contentSize.height = Constants.SCROLLER_CONTENT_HEIGHT
        
        paperView.loadDrawingContext()
        paperView.loadTochBeginPoint()
        paperView.loadTochEndPoint()
        
        paperView.resetDrawContextBeforeTerminated()
        
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    /**
         This function handles the event which pen button gets pressed.
         It will store the panel information such that if it is enable.
         Also, eraserEnable to set to false
     
     */
    @IBAction func penButtomPressed(_ sender: UIButton) {
        
        ColorBrushOpcityPanel.isHidden = !ColorBrushOpcityPanel.isHidden
    
        attribute.instance.colorPanelIsEnable = !attribute.instance.colorPanelIsEnable
        
        attribute.instance.eraserEnable = false
    }
    
    /**
         This function handles the event which undo button gets pressed.
         undo function in paperView will get call to perfrom the undo step
     
     */
    @IBAction func unDoButtomPressed(_ sender: UIButton) {
        
        paperView.undo()
        delayPanelClose()
        
    }
    
    /**
        This function handles the event which redo button gets pressed.
        redo function in paperView will get call to perfrom the redo step
     
     */
    @IBAction func reDoButtomPrssed(_ sender: Any) {
        
        paperView.redo()
        delayPanelClose()
        
    }
    
    /**
        This function handles the event which eraser button gets pressed.
        It will store the eraser information such that if it is enable
     
    */
    @IBAction func eraserButtonPressed(_ sender: Any) {
        
        attribute.instance.eraserEnable = !attribute.instance.eraserEnable
        
        delayPanelClose()
        
    }
    
    
    /**
        This function handles the event which clear button get pressed.
        It will display the alert to ask if user want to delete all drawing
        context.
     
        ## Import Notes ##
        1. Undo will not be able to recover to the previous state
     */
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        
        if !paperView.drawContextArray.isEmpty {
        
            let alert = UIAlertController(title: "Do you want to clear all drawed Content?", message: "Your drwed coten will vanish and will not be go back to the preious state", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Yes", style: .default) { (action) in
                self.paperView.deleteDrawingContext()
            }
            alert.addAction(action)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
        delayPanelClose()
        
    }
    
    
    /**
         This function handle the event which color button get pressed.
         It will store the color information based on user selection
     
     */
    @IBAction func colorButtonPressed(_ sender: UIButton) {
        
        attribute.instance.colorIndex = sender.tag
        
        delayPanelClose()
        
    }
  
    /**
        This function handle the event which share button get pressed.
        It will first covert the paperView to an image.Then, image can
        be shared in apps, send to email or print.
 
    */
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        delayPanelClose()
        
        let currentDrawContextImage = paperView.asImage()
        let activityVC = UIActivityViewController(activityItems: [currentDrawContextImage], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = paperView
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    /**
        This function set attribute numBrush based on the current burshSlider
        value which user selected. Also, change will display in text.
     
     */
    func brushPropertiesChange() {
        
        attribute.instance.numBrush = Int16(brushSlider.value)
        BrushLabel.text = "Brush: \(Int(brushSlider.value))"
        
    }
    
    /**
        This function set attribute numOpacity based on the current opacitySlider
        value which user selected. Also, change will display in text.
     
     */
    func opacityPropertiesChange() {
        
        attribute.instance.numOpacity = opacitySlider.value
        OpacityLabel.text = "Opacity: " + String(format: "%.1f", opacitySlider.value)
        
    }
    
    /**
        This function aims to close the colorPanel with 0.1s delay time.
     
    */
    func delayPanelClose() {
        
        attribute.instance.colorPanelIsEnable = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.ColorBrushOpcityPanel.isHidden = true
        }
        
    }
    

}



