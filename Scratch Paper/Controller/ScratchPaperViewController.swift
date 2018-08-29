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
    
    @IBOutlet weak var ColorBrushOpcityPanel: UIView!
    
    @IBOutlet weak var BrushLabel: UILabel!
    
    @IBOutlet weak var OpacityLabel: UILabel!
    
    @IBOutlet weak var brushSlider: UISlider!
    
    @IBOutlet weak var opacitySlider: UISlider!
    
    
    @IBAction func BrushSlider(_ sender: UISlider) {
       
       brushPropertiesChange()
        
    }
    
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
    
   
    @IBAction func penButtomPressed(_ sender: UIButton) {
        
        ColorBrushOpcityPanel.isHidden = !ColorBrushOpcityPanel.isHidden
    
        attribute.instance.colorPanelIsEnable = !attribute.instance.colorPanelIsEnable
        
        attribute.instance.eraserEnable = false
    }
    
    
    @IBAction func unDoButtomPressed(_ sender: UIButton) {
        
        paperView.undo()
        delayPanelClose()
        
    }
    
   
    @IBAction func reDoButtomPrssed(_ sender: Any) {
        
        paperView.redo()
        delayPanelClose()
        
    }
    
 
    @IBAction func eraserButtonPressed(_ sender: Any) {
        
        attribute.instance.eraserEnable = !attribute.instance.eraserEnable
        
        delayPanelClose()
        
    }
    
    
    
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
    
    
    
    @IBAction func colorButtonPressed(_ sender: UIButton) {
        
        attribute.instance.colorIndex = sender.tag
        
        delayPanelClose()
        
    }
  
  
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        delayPanelClose()
        
        let currentDrawContextImage = paperView.asImage()
        let activityVC = UIActivityViewController(activityItems: [currentDrawContextImage], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = paperView
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    
    func brushPropertiesChange() {
        
        attribute.instance.numBrush = Int16(brushSlider.value)
        BrushLabel.text = "Brush: \(Int(brushSlider.value))"
        
    }
    
    
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



