//
//  ProductTableViewController.swift
//  ShoppingEconomic
//
//  Created by Diego Alejandro Orellana Lopez on 8/23/16.
//  Copyright © 2016 Alex Salazar. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ProductTableViewController: UITableViewController {

    var products = [Product]()

    let productsRef = FIRDatabase.database().reference().child("products")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProduct()
    }
    
    func fetchProduct(){
        
        productsRef.observeEventType(.ChildAdded, withBlock:{(snapshot) in
            
            print("--> SNAPSHOT: \(snapshot)")
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let product = Product()
                product.id = snapshot.key
                product.setValuesForKeysWithDictionary(dictionary)
                
                
                
                self.products.append(product)
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            
        }, withCancelBlock: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProductCell", forIndexPath: indexPath) as! ProductTableViewCell
        let product = products[indexPath.row]
        cell.lblName.text = product.name
        cell.lblPrice.text = String(product.price)
        cell.imgPhoto.loadImageUsingCacheWithUrlString(product.photoUrl!)

        return cell
    }

    @IBAction func unwindToProductTable(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.sourceViewController as? ProductViewController, product = sourceViewController.product {
            
            if product.id != nil{
                tableView.reloadData()
            }
            
        }
    }

}
