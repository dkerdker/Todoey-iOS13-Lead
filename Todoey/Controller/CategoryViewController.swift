//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Dee Ker Khoo on 17/04/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

//MARK: - CategoryViewController

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70.0
        tableView.separatorStyle = .none
        
        self.tableView.backgroundColor = UIColor(hexString: "1D9BF6")
        
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: "1D9BF6") //cyan
        
        title = "Todoey"
        
        navigationItem.hidesBackButton = true
        
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(hexString: "1D9BF6")!, UIColor(hexString: "1D9BF6")!], startPoint: .topLeft, endPoint: .bottomRight)
        
        tableView.reloadData()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.colour)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: category.colour)!, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let actionAdd = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on the UIAlert
            
            let newCat = Category()
            newCat.name = textField.text!
            newCat.colour = UIColor(randomFlatColorOf: .dark).hexValue()
            
//            if textField.text != "" {
//                self.categoryArray.append(newCat)
//            } else {
//                newCat.name = "New Category"
//                self.categoryArray.append(newCat)
//            }

            self.save(category: newCat)
            
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
    
    //MARK: - Data Manipulation Methods
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving Category to context \(error)")
        }

        tableView.reloadData()
    }
    
    func loadCategories() {
   
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let _ = categories {
            performSegue(withIdentifier: C.itemSegue, sender: self)
        }
            
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.itemSegue {
            let destinationVC = segue.destination as! TodoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
}
