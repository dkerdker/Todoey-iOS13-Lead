//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Dee Ker Khoo on 17/04/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

//MARK: - CategoryViewController

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 0.6902, blue: 0.9882, alpha: 1.0)
        title = "Todoey"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: C.titleFont, size: 25)!
        ]
        navigationItem.hidesBackButton = true
        
        loadItems()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return categoryArray.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: C.categoryCell, for: indexPath)

            let category = categoryArray[indexPath.row]
            cell.textLabel?.text = category.name

            return cell
        }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let actionAdd = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on the UIAlert
            
            let newCat = Category(context: self.context)
            newCat.name = textField.text!
            
            if textField.text != "" {
                self.categoryArray.append(newCat)
            } else {
                newCat.name = "New Category"
                self.categoryArray.append(newCat)
            }

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
    
    //MARK: - Data Manipulation Methods
    func saveItems() {
        
        do {
            try self.context.save()
        } catch {
            print("Error saving Category to context \(error)")
        }

        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) {  //functions with DEFAULT VALUE
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching Category data from context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        performSegue(withIdentifier: C.itemSegue, sender: self)
            
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.itemSegue {
            let destinationVC = segue.destination as! TodoListViewController
                        
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryArray[indexPath.row]
            }
        }
    }
    
}
