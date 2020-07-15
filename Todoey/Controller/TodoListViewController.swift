import UIKit
import RealmSwift
import ChameleonFramework

//MARK: - TodoListViewController

class TodoListViewController: SwipeTableViewController {

    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet {                         //call loadItems() only after selectedCategory has a value
            loadItems()                  //NO NEED TO pass PARAMETER, due to Default Value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70.0
        tableView.separatorStyle = .none
        
        self.becomeFirstResponder()
            
        title = selectedCategory?.name
        navigationItem.hidesBackButton = false
        
        self.tableView.backgroundColor = UIColor(hexString: selectedCategory!.colour)?.lighten(byPercentage: 0.2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let colourHex = selectedCategory?.colour {
            let catColour = UIColor(hexString: colourHex)?.lighten(byPercentage: 0.2)
            navigationController?.navigationBar.backgroundColor = catColour
            navigationController?.navigationBar.setGradientBackground(colors: [catColour!, catColour!], startPoint: .topLeft, endPoint: .bottomRight)
            searchBar.barTintColor = catColour
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("shake")
            
            if let newColouredCat = selectedCategory {
                do {
                    try realm.write {
                        newColouredCat.colour = UIColor(randomFlatColorOf: .dark).hexValue()
                    }
                } catch {
                    print("Error saving new Cat colour by shake, \(error)")
                }
            }
            
            if let colourHex = selectedCategory?.colour {
                if let newCatColour = UIColor(hexString: colourHex)?.lighten(byPercentage: 0.2) {
                    navigationController?.navigationBar.backgroundColor = newCatColour
                    
                    navigationController?.navigationBar.setGradientBackground(colors: [newCatColour, newCatColour], startPoint: .topLeft, endPoint: .bottomRight)
                    
                    tableView.backgroundColor = newCatColour.lighten(byPercentage: 0.2)
                    
                    searchBar.barTintColor = newCatColour
                }
            }
            
            tableView.reloadData()
        }
    }
    
    //MARK: - Tableview Datasource Method
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(todoItems!.count)) / 4) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                    //realm.delete(item)
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add New Items Button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let actionAdd = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on the UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving todoItem to Realm \(error)")
                }
            }
            
            self.tableView.reloadData()
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
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        self.tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }

}

//MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        self.tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}

