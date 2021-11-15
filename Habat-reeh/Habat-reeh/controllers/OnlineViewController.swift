//
//  OnlineViewController.swift
//  Habat-reeh
//
//  Created by Hamad Wasmi on 10/04/1443 AH.
//

import UIKit

class OnlineViewController: UIViewController {
    
    var onlineEmail : [Any] = []
    @IBOutlet weak var onlineLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //GroceriesTableviewController().updateStatus()
        getOnline()
    }
    
    
    func getOnline(){
        var email : [Any] = []
        //        guard let user = Auth.auth().currentUser else{return}
        DBmanager.onlineRef.observeSingleEvent(of: .value, with: {snapshot in
            guard let values=snapshot.value as? [String: Any] else{return}
            for (key, value) in values{
                email.append(value)
            }
            
            for emb in email{
                self.onlineEmail.append(emb)
            }
        })
    }
}


extension OnlineViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        onlineEmail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ( onlineEmail[indexPath.row]) as? String
        return cell
    }
    
    
}
