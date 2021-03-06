//
//  ViewController.swift
//  Scratch Paper
//
//  Created by CHENGJUN LU on 7/1/18.
//  Copyright © 2018 CHENGJUN LU. All rights reserved.
//


import UIKit

/**
 This class handles all user interactions of ScratchPaperViewController
 such as color choices, bursh and opacity level, redo and button pressed ect...
 */
class ScratchPaperViewController:UIViewController {

    ///Link to panelButton
    @IBOutlet weak var panelButton: UIButton!

    ///Link to eraserButton
    @IBOutlet weak var eraserButton: UIButton!
    
    ///scollerView which handes scroll
    @IBOutlet weak var scroller: UIScrollView!
    
    ///The darwing area
    @IBOutlet weak var paperView: ScratchPaperView!
    
    ///The Panel which inculding color,bursh and opcity option
    @IBOutlet weak var ColorBrushOpcityPanel: UIView!
    
    ///Display the size of drawing point in text
    @IBOutlet weak var BrushLabel: UILabel!
    
    ///Display display the transparency of drawing point in text
    @IBOutlet weak var OpacityLabel: UILabel!
    
    ///Change the size of drawing point
    @IBOutlet weak var brushSlider: UISlider!
    
    ///Change the transparency of drawing point
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
        
    /**
     This function hands when View is initally load
     1.Hide the panel
     2.Disable scroll view
     3.Set up the size of its subview
     4.Reload the user draw content
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorBrushOpcityPanel.isHidden = true
        scroller.isScrollEnabled = false
        
        paperView.frame.size.height = Attributes.instance.PAPER_HEIGHT
        scroller.contentSize.height = Attributes.instance.SCROLLER_CONTENT_HEIGHT
        
        paperView.loadDrawingContext()
        paperView.loadTochBeginPoint()
        paperView.loadTochEndPoint()
        
        paperView.resetDrawContextBeforeTerminated()
        
        
    }
    
    /**
     This function handles the event which panel button gets pressed.
     It will store the panel information such that if it is enable.
     Also, eraserEnable to set to false and change pictures icons
     based on the status of panel button and eraser button.
     
     */
    @IBAction func panelButtomPressed(_ sender: UIButton) {
        
        ColorBrushOpcityPanel.isHidden = !ColorBrushOpcityPanel.isHidden
    
        Attributes.instance.PAENL_IS_ON = !Attributes.instance.PAENL_IS_ON
        
        if Attributes.instance.PAENL_IS_ON {
            Attributes.instance.ERASER_IS_ON = false
            sender.setImage(UIImage(named: "PANEL_ON"), for: .normal)
            eraserButton.setImage(UIImage(named: "ERASER_OFF"), for: .normal)
        }else{
            
            sender.setImage(UIImage(named: "PANEL_OFF"), for: .normal)
        }
        
    }
    
    /**
     This function handles the event which undo button gets pressed.
     undo function in paperView will get call to perfrom the undo step
     Also,highlighted the button if pressed
     
     */
    @IBAction func unDoButtomPressed(_ sender: UIButton) {
        
        sender.showsTouchWhenHighlighted = true
        paperView.undo()
        delayPanelClose()
        
    }
    
    /**
     This function handles the event which redo button gets pressed.
     redo function in paperView will get call to perfrom the redo step
     Also,highlighted the button if pressed
     
     */
    @IBAction func redoButtonPressed(_ sender: UIButton) {
        
        sender.showsTouchWhenHighlighted = true
        paperView.redo()
        delayPanelClose()
        
    }
    
    /**
     This function handles the event which eraser button gets pressed.
     It will store the eraser information such that if it is enable and change
     pictures icons based on the status of eraser button.
     
    */
    @IBAction func eraserButtonPressed(_ sender: UIButton) {
        
        delayPanelClose()
        Attributes.instance.ERASER_IS_ON = !Attributes.instance.ERASER_IS_ON
        
        if Attributes.instance.ERASER_IS_ON {
            sender.setImage(UIImage(named: "ERASER_ON"), for: .normal)
        }else{
            sender.setImage(UIImage(named: "ERASER_OFF"), for: .normal)
        }
        
        
        
    }
    
    /**
     This function handles the event which clear button get pressed.
     It will display the alert to ask if user want to delete all drawing
     context. Also,highlighted the button if pressed
     
     ## Import Notes ##
     1. Undo will not be able to recover to the previous state
     
     */
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        
        sender.showsTouchWhenHighlighted = true
        
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
     It will store the color information based on user selection.
     Also,highlighted the button if pressed
    
     */
    @IBAction func colorButtonPressed(_ sender: UIButton) {
        
        sender.showsTouchWhenHighlighted = true
        
        Attributes.instance.COLOR_INDEX = sender.tag
        delayPanelClose()
        
        
    }
    
  
    /**
        This function handle the event which share button get pressed.
        It will first covert the paperView to an image.Then, image can
        be shared in apps, send to email or print.
        Also,highlighted the button if pressed
    */
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        sender.showsTouchWhenHighlighted = true
        
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
        
        Attributes.instance.NUM_BRUSH = Int16(brushSlider.value)
        
        BrushLabel.text = "Brush: \(Int(brushSlider.value))"
        
    }
    
    /**
     This function set attribute numOpacity based on the current opacitySlider
     value which user selected. Also, change will display in text.
     
     */
    func opacityPropertiesChange() {
        
        Attributes.instance.NUM_OPACITY = opacitySlider.value
        
        OpacityLabel.text = "Opacity: " + String(format: "%.1f", opacitySlider.value)
        
    }
    
    /**
     This function aims to close the colorPanel with 0.1s delay time.
     
    */
    func delayPanelClose() {
        
        Attributes.instance.PAENL_IS_ON = false
        panelButton.setImage(UIImage(named:"PANEL_OFF"), for: .normal )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.ColorBrushOpcityPanel.isHidden = true
        }
        
    }
    
}



