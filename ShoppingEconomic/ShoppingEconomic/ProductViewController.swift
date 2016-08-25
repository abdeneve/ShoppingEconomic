//
//  ViewController.swift
//  ShoppingEconomic
//
//  Created by Diego Alejandro Orellana Lopez on 8/22/16.
//  Copyright © 2016 Alex Salazar. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseStorage

class ProductViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var mapLocation: MKMapView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    var product: Product?
    
    let productsRef = FIRDatabase.database().reference().child("products")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        imgPhoto.image = selectedImage
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
        
        print("--> Click Image")
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            // Hide the keyboard.
            txtName.resignFirstResponder()
            
            // UIImagePickerController is a view controller that lets a user pick media from their photo library.
            let imagePickerController = UIImagePickerController()
            
            // Make sure ViewController is notified when the user picks an image.
            imagePickerController.delegate = self
            
            // Only allow photos to be picked, not taken.
            imagePickerController.sourceType = .PhotoLibrary
            
            imagePickerController.allowsEditing = true
            
            self.presentViewController(imagePickerController, animated: true, completion: nil)
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("--> prepareForSegue")
        
        if btnSave === sender {
            let name = txtName.text ?? ""
            let price = txtPrice.text ?? ""
            
            product = Product()
            product?.id = NSUUID().UUIDString
            product?.name = name
            product?.price = NSNumber(integer: Int(price)!)
            
            guard let id = product?.id else {
                return
            }
            
            print("--> id: \(id)")
            
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child("profile_images/\(imageName).jpg")
            
            if let profileImage = self.imgPhoto.image, uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
                let uploadTask = storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        let values = ["name": name, "price": price, "photoUrl": profileImageUrl]
                        
                        self.registerProductIntoDatabaseWithId(id, values: values)
                    }
                })
                
                uploadTask.observeStatus(.Progress) { snapshot in
                    print("=====================================")
                    // Upload reported progress
                    if let progress = snapshot.progress {
                        let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                        print("--> \(percentComplete)")
                    }
                }
                
                uploadTask.observeStatus(.Success) { snapshot in
                    // Upload completed successfully
                    print("=====================================")
                    print("UPLOAD SUCCESSFULLY")
                }
                
                // Errors only occur in the "Failure" case
                uploadTask.observeStatus(.Failure) { snapshot in
                    guard let storageError = snapshot.error else { return }
                    guard let errorCode = FIRStorageErrorCode(rawValue: storageError.code) else { return }
                    
                    switch errorCode {
                        
                    case .ObjectNotFound:
                        // File doesn't exist
                        print("***********************************")
                        break
                        
                    case .Unauthorized:
                        // User doesn't have permission to access file
                        print("***********************************")
                        break
                    case .Cancelled:
                        // User canceled the upload
                        print("***********************************")
                        break
                        
                    case .Unknown:
                        // Unknown error occurred, inspect the server response
                        print("***********************************")
                        break
                        
                    default:
                        print("***********************************")
                        break
                        
                    }
                    
                }
                
                //uploadTask.resume()
                
            }
            
        }
    }
    
    private func registerProductIntoDatabaseWithId(id: String, values: [String: AnyObject]){
        
        print("--> ToSave: \(values)")
        
        let productRefCreate = productsRef.child(id)
        
        productRefCreate.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print("--> Error: \(err)")
                return
            }
            
            let product = Product()
            
            //this setter potentially crashes if keys don't match
            product.setValuesForKeysWithDictionary(values)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }

    @IBAction func Cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

