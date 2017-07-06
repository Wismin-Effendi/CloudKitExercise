//
//  ViewController.swift
//  CloudKitExercise
//
//  Created by Wismin Effendi on 7/5/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UITableViewController {

    static var isDirty = true
    
    var shoppings = [Shopping]()
    
    var refresh: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Where to Shop"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addShopping))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load message")
        refresh.addTarget(self, action: #selector(ViewController.loadShoppings), for: .valueChanged)
        tableView.addSubview(refresh)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if ViewController.isDirty {
            loadShoppings()
        }
    }

    @objc private func loadShoppings() {
        print("yes...we call loadShoppings.. here...")
        // first part
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Shopping", predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["shopCategory", "shopInformation"]
        operation.resultsLimit = 50
        
        var newShoppings = [Shopping]()
        
        // second part
        operation.recordFetchedBlock = { record in
            let shopping = Shopping()
            shopping.recordID = record.recordID
            shopping.shopCategory = record["shopCategory"] as! String
            shopping.shopInformation = record["shopInformation"] as! String
            newShoppings.append(shopping)
        }
        
        // third part
        operation.queryCompletionBlock = { [unowned self] (curson, error) in
            DispatchQueue.main.async {
                if error == nil {
                    ViewController.isDirty = false
                    self.shoppings = newShoppings
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(
                        title: "Fetch failed",
                        message: "There was a problem fetching the list of shopping; please try agin: \(error!.localizedDescription)",
                        preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
                self.refresh.endRefreshing()
            }
        }
        
        // last part
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    @objc private func addShopping() {
        let vc = SelectCategoryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline),
                               NSForegroundColorAttributeName: UIColor.purple]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)", attributes: titleAttributes)
        
        if subtitle.characters.count > 0 {
            let subtitleString = NSAttributedString(string: "\n\(subtitle)", attributes: subtitleAttributes)
            titleString.append(subtitleString)
        }
        
        return titleString
    }
    
    // MARK: UITableViewDataSource && Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shoppings.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.attributedText = makeAttributedString(title: shoppings[indexPath.row].shopCategory, subtitle: shoppings[indexPath.row].shopInformation)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ShoppingListViewController()
        vc.shopping = shoppings[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

