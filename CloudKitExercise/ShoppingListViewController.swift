//
//  ShoppingListViewController.swift
//  CloudKitExercise
//
//  Created by Wismin Effendi on 7/5/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit
import CloudKit

class ShoppingListViewController: UITableViewController {
    
    var shopping: Shopping!
    var shoppingItems = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "\(shopping.shopCategory!)"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let reference = CKReference(recordID: shopping.recordID, action: .deleteSelf)
        let pred = NSPredicate(format: "owningShopping == %@", reference)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "ShoppingItems", predicate: pred)
        query.sortDescriptors = [sort]
        
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] (results, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let results = results {
                    self.parseResults(records: results)
                }
            }
        }
    }

    func parseResults(records: [CKRecord]) {
        var newShoppingItems = [String]()
        
        for record in records {
            newShoppingItems.append(record["text"] as! String)
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.shoppingItems = newShoppingItems
            self.tableView.reloadData()
        }
    }
    
    // MARK: Helper
    func add(shopItem: String) {
        let shoppingRecord = CKRecord(recordType: "ShoppingItems")
        let reference = CKReference(recordID: shopping.recordID, action: .deleteSelf)
        shoppingRecord["text"] = shopItem as CKRecordValue
        shoppingRecord["owningShopping"] = reference as CKRecordValue
        
        // second part
        CKContainer.default().publicCloudDatabase.save(shoppingRecord) { [unowned self] (record, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.shoppingItems.append(shopItem)
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(
                        title: "Error",
                        message: "There was a problem submitting your shop item: \(error!.localizedDescription)",
                        preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Shopping items"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return shoppingItems.count + 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.section == 0 {
            
            // the user's comments about this whistle
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
            
            cell.textLabel?.text = shopping.shopInformation
        
        } else {
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            
            if indexPath.row == shoppingItems.count {
                // this is our extra row
                cell.textLabel?.text = "Add item"
                cell.selectionStyle = .gray
            } else {
                cell.textLabel?.text = shoppingItems[indexPath.row]
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 && indexPath.row == shoppingItems.count else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ac = UIAlertController(title: "Shopping item...", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default)  {[unowned self, ac] (action) in
            if let textField = ac.textFields?[0] {
                if textField.text!.characters.count > 0 {
                    self.add(shopItem: textField.text!)
                }
            }
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }

}
