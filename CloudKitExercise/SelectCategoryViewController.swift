//
//  SelectCategoryViewController.swift
//  CloudKitExercise
//
//  Created by Wismin Effendi on 7/5/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit

class SelectCategoryViewController: UITableViewController {
    
    static var shopCategories = ["Membership WholeSale", "Grocery store", "Hardware store", "Furniture store", "Computer and Electronics", "Clothes shop", "Shoe store", "Pharmacy", "Hobby shop", "Others"]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select Shop Category"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Category", style: .plain, target: nil, action: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectCategoryViewController.shopCategories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = SelectCategoryViewController.shopCategories[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let shopCategory = cell.textLabel?.text ?? SelectCategoryViewController.shopCategories.last!
            let vc = AddShopInformationViewController()
            vc.shopCategory = shopCategory
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    

}
