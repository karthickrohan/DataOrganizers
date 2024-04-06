//
//  FolderPreViewCollectionViewCell.swift
//  DataOrganizer
//
//  Created by VC on 02/04/24.
//

import UIKit

protocol PssingTextFieldName {
    func passingTextFieldName(folderName: String,folderID: String)
}

class FolderPreViewCollectionViewCell: UICollectionViewCell,UITextFieldDelegate {
    
    @IBOutlet var superView: UIView!
    @IBOutlet var folderImageView: UIImageView!
    @IBOutlet var nameTextFIield: UITextField!
    
    var folderID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextFIield.delegate = self
        nameTextFIield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameTextFIield.textAlignment = .center
        nameTextFIield.borderStyle = .none
    }
    var textFieldDelegate : PssingTextFieldName?
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextFIield.borderStyle = .roundedRect
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameTextFIield.borderStyle = .none
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == nameTextFIield {
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameTextFIield {
            guard let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return false }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == nameTextFIield {
            guard let folderName = textField.text, !folderName.isEmpty else { return true }
            guard let folderID = folderID else { return true }
            FolderViewViewModel().updateFolderName(folderID: folderID, newName: folderName)
        }
        return true
    }
    
}
