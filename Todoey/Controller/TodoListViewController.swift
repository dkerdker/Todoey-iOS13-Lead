//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit


class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    
//    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 0.6902, blue: 0.9882, alpha: 1.0)
        title = "Todoey"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: C.titleFont, size: 25)!
        ]
        navigationItem.hidesBackButton = true
        
        print(dataFilePath as Any)
        
          //LOAD ITEM (using array and UserDefaults)
//        if let items = defaults.array(forKey: C.todoListArray) as? [String] {
//            itemArray = items
//        }
        
/*        let newItem = Item()
        newItem.title = "Buy Eggs"
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem2.title = "Buy Nuts"
        itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "Buy Vege"
        itemArray.append(newItem3)      */
        
        loadItems()
    }
    
    //MARK: - Tableview Datasource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: C.toDoItemCell, for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none     //TERNARY OPERATOR
        
//        if item.done == true {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveItems()
        
//        if itemArray[indexPath.row].done == false {
//           itemArray[indexPath.row].done = true
//        } else {
//            itemArray[indexPath.row].done = false
//        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add New Items Button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let actionAdd = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on the UIAlert
            
            let newItem = Item()
            newItem.title = textField.text!
            
            if textField.text != "" {
                self.itemArray.append(newItem)
            } else  {
                newItem.title = "New Item"
                self.itemArray.append(newItem)
            }
                
            //self.defaults.set(self.itemArray, forKey: C.todoListArray)
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            
            textField = alertTextField
        }
        
        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
        alert.addAction(actionAdd)
        alert.preferredAction = actionAdd
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error)")
        }

        self.tableView.reloadData()
    }
    
    func loadItems() {
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding item array, \(error)")
            }
        }
    }

}

