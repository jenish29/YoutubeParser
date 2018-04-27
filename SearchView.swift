//
//  SearchView.swift
//  Youtube
//
//  Created by Jenish on 8/1/17.
//  Copyright © 2017 pc. All rights reserved.
//

import UIKit

class SearchView: UIView,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet var searchTextField : UITextField!
    @IBOutlet var heightConstraint : NSLayoutConstraint!
    @IBOutlet var topConstraint : NSLayoutConstraint!

    private var originalConstraint : CGFloat!
    private var tableView : UITableView!
    private var suggestions = [String]()
    private var keyboardHeight : CGFloat = 0
    @IBOutlet var delegate : SearchViewDelegate?


    override func awakeFromNib() {
       NotificationCenter.default.addObserver(self, selector: "keyboardWillShow:", name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        searchTextField.delegate = self
        self.originalConstraint = heightConstraint.constant

        let tableView = UITableView()
        addSubview(tableView)
        tableView.separatorStyle = .none

        addConstraintsWithFormat("H:|[v0]|", views: tableView)
        addConstraintsWithFormat("V:|[v0]|", views: tableView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        self.tableView = tableView
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        topConstraint.constant = originalConstraint
        heightConstraint.constant = 100
        alpha = 1
        layoutIfNeeded()

    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (_) in
            self.heightConstraint.constant = self.originalConstraint
        }

    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = textField.text else {suggestions.removeAll(); self.tableView.reloadData(); return true}
        if string == "" && textField.text?.characters.count == 1 {
            self.suggestions.removeAll()
            self.tableView.reloadData()
            return true
        }

        let netText = text.addingPercentEncoding(withAllowedCharacters: CharacterSet())!
        let url = URL.init(string: "https://api.bing.com/osjson.aspx?query=\(netText)")!

        let _ = URLSession.shared.dataTask(with: url) { [weak self] (data, response, err) in
            guard let weakSelf = self else {
                return
            }
            if err == nil {
                if let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) {
                    let data = json as! [Any]
                    DispatchQueue.main.async {
                        weakSelf.suggestions = data[1] as! [String]
                        if weakSelf.suggestions.count > 0 {
                            weakSelf.tableView.reloadData()
                            weakSelf.tableView.isHidden = false
                        } else {
                            weakSelf.tableView.isHidden = true
                        }
                    }
                }
            }
        }.resume()

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.searchVideo(textField.text!)
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if suggestions.count > 8 {return 8}
        else {return suggestions.count}
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = suggestions[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        searchTextField.text = cell?.textLabel?.text!
        _ = textFieldShouldReturn(searchTextField)

    }

    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        let constant :CGFloat = UIScreen.main.bounds.height - keyboardHeight
        heightConstraint.constant = constant
    }

}

@objc protocol SearchViewDelegate {
    func searchVideo(_: String)
}
