//
//  ViewController.swift
//  HitList
//
//  Created by Metas Umsuwan on 4/11/2560 BE.
//  Copyright © 2560 Metas Umsuwan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //MARK: perperties
    @IBOutlet weak var tableView: UITableView!
//    var name:[String]=[]
    var people:[NSManagedObject]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title="The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard  let AppDelegate=UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext=AppDelegate.persistentContainer.viewContext
        
        let fetchRequest=NSFetchRequest<NSManagedObject>(entityName: "Person")
//        fetchRequest.predicate=NSPredicate(format: "name = %@","test")
        
        do{
            people=try managedContext.fetch(fetchRequest)
        }catch let error as NSError{
            print("colund not fetch \(error)")
        }
    }
    
    //MARK: action
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert=UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction=UIAlertAction(title: "Save", style: .default, handler:{
            action in
            guard let textField=alert.textFields?.first,let nameToSave=textField.text else{
                return
            }
            
//            self.name.append(nameToSave)
            self.save(name: nameToSave)
            self.tableView.reloadData()
        })
        
        let cancelAction=UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func save(name:String){
        guard let AppDelegate=UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext=AppDelegate.persistentContainer.viewContext
        
        let entity=NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person=NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        
        do{
            try managedContext.save()
            people.append(person)
        }catch let error as NSError{
            print("Could not save. \(error) , \(error.userInfo)")
        }
    
    }
    
    func getContext()->NSManagedObjectContext{
        let AppDelegate=UIApplication.shared.delegate as! AppDelegate
        return AppDelegate.persistentContainer.viewContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return name.count
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        cell.textLabel?.text=name[indexPath.row]
        let person=people[indexPath.row]
        cell.textLabel?.text=person.value(forKey: "name") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension ViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print(indexPath)
        tableView.beginUpdates()
        
        let moc=getContext()
        moc.delete(people[indexPath.row])
        do{
            try moc.save()
            people.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }catch let error as NSError {
            print("error \(error)")
        }
        
        tableView.endUpdates()
        tableView.reloadData()

    }
}

