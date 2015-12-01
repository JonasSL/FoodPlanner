//
//  AddProductTableViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 01/12/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit
import Parse

class AddProductTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productWeight: UITextField!
    @IBOutlet weak var barcodeLabel: UILabel!
    
    let pickerData = Unit.allUnits
    var product: Product?
    var isInDatabase = false
    var barcode = ""
    let productUnit = UIPickerView()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set delegates
        productName.delegate = self
        productWeight.delegate = self
        
        productUnit.delegate = self
        unitTextField.inputView = productUnit
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor.blackColor()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Færdig", style: UIBarButtonItemStyle.Bordered, target: self, action: "donePicking")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true

        unitTextField.inputAccessoryView = toolBar
    }
    
    func donePicking() {
        unitTextField.endEditing(true)
    }
    
    //MARK: Navigation
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didReceiveBarCode(segue: UIStoryboardSegue) {
        let barcodeVC = segue.sourceViewController as! ScannerViewController
        barcode = barcodeVC.barcode
        barcodeLabel.hidden = false
        
        //Check if barcode is in Parse DB - set boolean if it needs to be uploaded (deosn't exist already)
        updateLabelsWithInfoFor(barcode)
        
        if !isInDatabase {
            barcodeLabel.text = "Produkt er ikke fundet - vil blive tilføjet!"
            barcodeLabel.textColor = UIColor(red: 1.00, green: 0.00, blue: 0.00, alpha: 1.0)
        }
    }
    
    //Start "save"-segue if input is valid
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if checkValidInput() {
            performSegueWithIdentifier("SaveProduct", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SaveProduct" {
            let name = productName.text!
            let weight = Int(productWeight.text! )!
            let unit = pickerData[productUnit.selectedRowInComponent(0)]
            //let dateExpiration = dateExpirationPicker.date
            let dateExpiration = NSDate.init()

            product = Product(name: name, weight: weight, unit: unit, dateExpires: dateExpiration)
            
            //Send product data to Parse if barcode is read (label is not hidden)
            if !isInDatabase && barcodeLabel.hidden == false {
                let testObject = PFObject(className: "Barcodes")
                testObject["EAN"] = barcode
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
    func checkValidInput() -> Bool{
        let textName = productName.text
        let textWeight = productWeight.text
        
        var errorString = ""
        if textName == "" {
            errorString = "Varenavn må ikke være tomt"
        } else if textWeight == "" {
            errorString = "Vægt må ikke være tom"
        } else if Int(textWeight!) == nil {
            errorString = "Vægt skal være et tal"
        }
        
        if errorString != "" {
            let alert = UIAlertController(title: "Fejl", message: errorString, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    //MARK: UIPickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].rawValue
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        unitTextField.text = pickerData[row].rawValue
    }
    
    //MARK: Parse Datase methods
    func updateLabelsWithInfoFor(barcode: String) {
        let query = PFQuery(className:"Barcodes")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                //Unrwrap optional valus
                if let objects = objects {
                    for object in objects {
                        if object["EAN"] as! String == barcode {
                            self.isInDatabase = true
                            
                            self.productName.text = object["name"] as? String
                            self.productWeight.text = object["weight"] as? String
                            
                            let unitString = object["unit"] as! String
                            if let indexOfString = self.pickerData.indexOf(Unit(rawValue: unitString)!) {
                                self.productUnit.selectRow(indexOfString, inComponent: 0, animated: true)
                            }
                            
                            self.barcodeLabel.text = "Produkt fundet!"
                            self.barcodeLabel.textColor = UIColor(red: 0.08, green: 0.93, blue: 0.08, alpha: 1.0)
                        }
                    }
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    
    

}
