//
//  AddViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 22/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit
import Parse

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
        
        //Hide barcode label when you load the VC
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
        
        //Check if barcode is in Parse DB - set boolean if it needs to be uploaded (deosn't exist already)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = productName.text!
            let weight = Int(productWeight.text! )!
            let unit = pickerData[productUnit.selectedRowInComponent(0)]
            let dateExpiration = dateExpirationPicker.date
            
            product = Product(name: name, weight: weight, unit: unit, dateExpires: dateExpiration)
            
            //Send product data to Parse if barcode is read (label is not hidden)
            if barcodeLabel.hidden == false {
                let testObject = PFObject(className: "Barcodes")
                testObject["EAN"] = barcodeLabel.text
                testObject["name"] = name
                testObject["weight"] = String(weight)
                testObject["unit"] = unit.rawValue
                testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    print("Object has been saved.")
                }
            }
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
    
    
    //MARK: Parse Datase methods
    func updateLabelsWithInfoFor(barcode: String) -> Bool {
        var foundObject = false

        let query = PFQuery(className:"Barcodes")
        //query.whereKey("playerName", equalTo:"Sean Plott")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in

            if error == nil {
                //Unrwrap optional valus
                if let objects = objects {
                    for object in objects {
                        if object["EAN"] as! String == barcode {
                            self.productName.text = object["name"] as? String
                            self.productWeight.text = object["weight"] as? String
                            
                            let unitString = object["unit"] as! String
                            if let indexOfString = self.pickerData.indexOf(Unit(rawValue: unitString)!) {
                                self.productUnit.selectRow(indexOfString, inComponent: 0, animated: true)
                            }
                            foundObject = true
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        return foundObject
    }
}
