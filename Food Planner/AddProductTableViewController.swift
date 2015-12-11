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
    @IBOutlet weak var scanBarcodeLabel: UILabel!
    @IBOutlet weak var arrowLabel: UIImageView!
    @IBOutlet weak var dateTextField: UITextField!
    
    let pickerData = Unit.allUnits
    var product: Product?
    var isInDatabase = false
    var barcode = ""
    let productUnit = UIPickerView()
    let dateExpirationPicker = UIDatePicker()

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
        
        let doneButton = UIBarButtonItem(title: "Færdig", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicking")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true

        unitTextField.inputAccessoryView = toolBar
        
        //Setup the date picker
        dateExpirationPicker.minimumDate = NSDate.init()
        dateTextField.inputView = dateExpirationPicker
        dateExpirationPicker.addTarget(self, action: "datePicked", forControlEvents: UIControlEvents.ValueChanged)
        dateExpirationPicker.datePickerMode = UIDatePickerMode.Date
        dateTextField.inputAccessoryView = toolBar
    }
    
    func donePicking() {
        unitTextField.endEditing(true)
        dateTextField.endEditing(true)
    }
    
    //MARK: Navigation
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didReceiveBarCode(segue: UIStoryboardSegue) {
        let barcodeVC = segue.sourceViewController as! ScannerViewController
        barcode = barcodeVC.barcode
        
        //Check if barcode is in Parse DB - set boolean if it needs to be uploaded (deosn't exist already)
        updateLabelsWithInfoFor(barcode)
        
        if !isInDatabase {
            scanBarcodeLabel.text = "Produkt er ikke fundet - vil blive tilføjet!"
            scanBarcodeLabel.textColor = UIColor(red: 1.00, green: 0.00, blue: 0.00, alpha: 1.0)
            
            //Hide arrow and make cell unclickable
            arrowLabel.hidden = true
            let cell = tableView.dequeueReusableCellWithIdentifier("scanButtonCell")
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
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
            let unit = Unit(rawValue: unitTextField.text!)!
            //let dateExpiration = dateExpirationPicker.date
            let dateExpiration = dateExpirationPicker.date

            product = Product(name: name, weight: weight, unit: unit, dateExpires: dateExpiration)
            
            //Send product data to Parse if barcode is read (label is not hidden)
            if !isInDatabase && arrowLabel.hidden == true {
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "ScanSegue" {
            //If the arrow label is hidden, it means that a barcode has been scanned. Then the user should not be able to scan again.
            if arrowLabel.hidden {
                return false
            }
        }
        return true
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
    
    //MARK: UIDatePicker
    func datePicked() {
        dateTextField.text = formatDate(dateExpirationPicker.date)
    }
    
    func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        let danishFormat = NSDateFormatter.dateFormatFromTemplate("MMMMddyyyy", options: 0, locale: NSLocale(localeIdentifier: "da-DK"))
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.dateFormat = danishFormat
        return formatter.stringFromDate(date)
    }
    
    
    //MARK: Parse Datase methods
    func updateLabelsWithInfoFor(barcode: String) {
        let query = PFQuery(className:"Barcodes")
        query.whereKey("EAN", equalTo: barcode)
        
        var objects = [PFObject]()
        
        do {
            objects = try query.findObjects()
        } catch {
            print("Couldn't get objects from Parse")
        }
        for object in objects {
            isInDatabase = true
            
            productName.text = object["name"] as? String
            productWeight.text = object["weight"] as? String
            
            let unitString = object["unit"] as! String
            unitTextField.text = unitString
            
            scanBarcodeLabel.text = "Produkt fundet!"
            scanBarcodeLabel.textColor = UIColor(red: 0.08, green: 0.93, blue: 0.08, alpha: 1.0)
            
            break
        }
    }
}
