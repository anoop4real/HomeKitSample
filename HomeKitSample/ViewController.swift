//
//  ViewController.swift
//  HomeKitSample
//
//  Created by anoop mohanan on 27/03/18.
//  Copyright © 2018 com.anoopm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var deviceListTable:UITableView!
    private var homeManager: AMHomekitManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        homeManager = AMHomekitManager(with: self)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func initialHomeSetup() {
        
        homeManager.setUpHomeWith(name: "My New Home") {[weak self] (result) in
            
            switch result {
                
            case .success(let home):
                self?.homeManager.setUpOneRoomFor(home: home, roomName: "Bedroom", completion: { (response) in
                    switch response{
                    case .success(let room):
                        print("Room added")
                    
                    case .error(let error):
                        print(error.localizedDescription)
                    }
                })
            case .error(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

extension ViewController: PresenterProtocol{
    func refrehDeviceList() {
        
        deviceListTable.reloadData()
    }
    
    func updateUIWithPrimaryHome(status: Bool) {
        
        if(status){
           homeManager.detectAccessories()
        }else{
            initialHomeSetup()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return homeManager.rowsCountIn(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        let device = homeManager.itemAt(row: indexPath.row)
        cell.textLabel?.text = device?.name
        cell.detailTextLabel?.text = device?.manufacturer
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let device = homeManager.itemAt(row: indexPath.row)
        
        homeManager.add(accessory: device!, to: nil, in: nil)
    }
    
}

