//
//  AMHomekitManager.swift
//  HomeKitSample
//
//  Created by anoop mohanan on 27/03/18.
//  Copyright © 2018 com.anoopm. All rights reserved.
//

import Foundation
import HomeKit

enum Result<T, Error> {
    case success(T)
    case error(Error)
}

protocol PresenterProtocol : class{
    func updateUIWithPrimaryHome(status:Bool)
    func refrehDeviceList()
}

protocol DataStoreProtocol {
    
    associatedtype T
    func sectionCount() -> Int
    func rowsCountIn(section: Int) -> Int
    func itemAt(row: Int) -> T?
}

class AMHomekitManager: NSObject{
    
    private var homeManager: HMHomeManager!
    private var accessoryBrowser: HMAccessoryBrowser!
    private var activeHome:HMHome!
    private var activeRoom:HMRoom!
    private weak var presenter:PresenterProtocol!
    private var accessories = [HMAccessory]()
    
    typealias Completion = (Result<HMHome, Error>) -> ()
    typealias CompletionRoom = (Result<HMRoom, Error>) -> ()
    
    init (with presenter:PresenterProtocol){
        
        super.init()
        self.homeManager = HMHomeManager()
        self.homeManager.delegate = self
        
        self.accessoryBrowser = HMAccessoryBrowser()
        self.accessoryBrowser.delegate = self
        self.presenter = presenter
    }
    // MARK: Public Methods
    
    // Method to add a home
    func setUpHomeWith(name: String, completion: @escaping Completion){
        
        homeManager.addHome(withName: name) { (home, error) in
            if (error != nil){
                completion(.error(error!))
            }else{
                guard let homeVal = home else{
                    // No error but no home object, we mark it as unknown error
                    let errorTemp = NSError(domain:"Custom", code:999, userInfo:[NSLocalizedDescriptionKey : "Home could not be created"])
                    completion(.error(errorTemp))
                    return
                }
                completion(.success(homeVal))
            }
        }
    }
    
    // Method to add a room in a home
    func setUpOneRoomFor(home: HMHome, roomName:String, completion: @escaping CompletionRoom){
        
        home.addRoom(withName: roomName) { (room, error) in
            if (error != nil){
                    completion(.error(error!))
            }else{
                guard let roomVal = room else{
                    // No error but no home object, we mark it as unknown error
                    let errorTemp = NSError(domain:"Custom", code:999, userInfo:[NSLocalizedDescriptionKey : "Room could not be created"])
                    completion(.error(errorTemp))
                    return
                }
                completion(.success(roomVal))
                
            }
        }
    }
    
    // MARK: Accessory detection
    // Method to start searching for accessories
    func detectAccessories(){
        
        print("Starting detection")
        accessoryBrowser.startSearchingForNewAccessories()
        
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector:#selector(stopAccessoryDetection), userInfo: nil, repeats: false)
    }
    
    // Method to stop searching for accessories
    @objc func stopAccessoryDetection(){
        
        print("Stopping detection")
        //accessoryBrowser.stopSearchingForNewAccessories()
        presenter?.refrehDeviceList()
    }
    
    // Method to add an accessory to Home
    func add(accessory:HMAccessory,to theHome:HMHome?, in room:HMRoom?){
        var home:HMHome?
        if theHome == nil{
            home = activeHome
        }
        home?.addAccessory(accessory, completionHandler: {(_ error: Error?) -> Void in
            if error != nil {
                // Failed to add accessory to home
                print(error?.localizedDescription)
            } else {
//                if accessory.room != room {
//                    // 3. If successfully, add the accessory to the room
//                    home?.assignAccessory(accessory, to: room!, completionHandler: {(_ error: Error?) -> Void in
//                        if error != nil {
//                            // Failed to add accessory to room
//                        }
//                    })
//                }
            }
        })
    }

    // Clean up
    deinit {
        accessoryBrowser.stopSearchingForNewAccessories()
    }
}
extension AMHomekitManager:HMHomeManagerDelegate{
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        
        if let home = homeManager.primaryHome {
            activeHome = home
            // Find already added accessory
            //accessories.insert(contentsOf: home.accessories, at: 0)
            presenter?.updateUIWithPrimaryHome(status: true)
        }
        
    }
    
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        
    }
}

extension AMHomekitManager: HMAccessoryBrowserDelegate{
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory){
        
        accessories.append(accessory)
        print("Accessory Found \(accessory.name)")
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory){
        
    }
}

extension AMHomekitManager: DataStoreProtocol{
    
    func sectionCount() -> Int {
        
        return 1
    }
    
    func rowsCountIn(section: Int) -> Int {
        
        return accessories.count
    }
    
    func itemAt(row: Int) -> HMAccessory?{
        
        return accessories[row]
    }

}
