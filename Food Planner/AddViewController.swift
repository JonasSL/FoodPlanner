//
//  AddViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 22/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit
//import Parse

class AddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productWeight: UITextField!
    @IBOutlet weak var productUnit: UIPickerView!
    @IBOutlet weak var dateExpirationPicker: UIDatePicker!
    @IBOutlet weak var barcodeLabel: UILabel!
    
    var product: Product?
    let pickerData = Unit.allUnits

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productUnit.delegate = self
        productUnit.dataSource = self
        productName.delegate = self
        productWeight.delegate = self
        
        //Enable the save button only if input is valid
        checkValidInput()
        
        //Setup the date picker
        dateExpirationPicker.minimumDate = NSDate.init()
        
        //Hide barcode label
        barcodeLabel.hidden = true
    }
    
    //MARK: Navigation
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didReceiveBarCode(segue: UIStoryboardSegue) {
        let barcodeVC = segue.sourceViewController as! ScannerViewController
        let barcode = barcodeVC.barcode
        barcodeLabel.hidden = false
        barcodeLabel.text = barcode
        
        /*let testObject = PFObject(className: "Barcodes")
        testObject["EAN"] = barcode
        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Object has been saved.")
        }*/
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = productName.text!
            let weight = Int(productWeight.text! )!
            let unit = pickerData[productUnit.selectedRowInComponent(0)]
            let dateExpiration = dateExpirationPicker.date
            
            product = Product(name: name, weight: weight, unit: unit, dateExpires: dateExpiration)
        }
    }
    
    //MARK: UITextFieldDelegate
    func checkValidInput() {
        let textName = productName.text ?? ""
        let textWeight = productWeight.text ?? ""
        saveButton.enabled = !textName.isEmpty && !textWeight.isEmpty
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField === productWeight {
            saveButton.enabled = true
        }
    }
    
    
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].rawValue
    }
}
