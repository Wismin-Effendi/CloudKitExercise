//
//  AddShopInformationViewController.swift
//  CloudKitExercise
//
//  Created by Wismin Effendi on 7/5/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit

class AddShopInformationViewController: UIViewController, UITextViewDelegate {

    var shopCategory: String!
 
    var shopInformation: UITextView!
    
    var submitButton: UIBarButtonItem!
    
    let placeholder = "Please enter the shop name, and related information here."
    
    override func loadView() {
        super.loadView()
        
        shopInformation = UITextView()
        shopInformation.translatesAutoresizingMaskIntoConstraints = false
        shopInformation.delegate = self
        shopInformation.font = UIFont.preferredFont(forTextStyle: .body)
        view.addSubview(shopInformation)
        
        shopInformation.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        shopInformation.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        shopInformation.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
        shopInformation.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Shop Information"
        submitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitTapped))
        navigationItem.rightBarButtonItem = submitButton
        shopInformation.text = placeholder
        
        // initially it's disabled until we enter some text
        submitButton.isEnabled = false
        
    }
    
    func submitTapped() {
        guard let shopTextInfo = shopInformation.text,
            shopTextInfo.trimmingCharacters(in: .whitespacesAndNewlines)  != "" else {
                shopInformation.text = placeholder
                submitButton.isEnabled = false
                return
        }
        
        let vc = SubmitViewController()
        vc.shopCategory = shopCategory
        vc.shopInformation = shopInformation.text
        
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
        }
    }
    
    // handling of Enter key
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            submitButton.isEnabled = true
            return false
        }
        return true
    }
}
