    //
    //  ViewController.swift
    //  Juicer
    //
    //  Created by Jared Sorge on 6/18/16.
    //  Copyright © 2016 Taphouse Software. All rights reserved.
    //

    import UIKit


    struct Battery {
        let BatteryID: String
        let name:String
        var count: Int
        
    }

    let cellID = "BatteryCell"


    class ViewController: UIViewController, myIAPManagerDelegate{
        
        private var batteries = [Battery]()
        var IAPManagerInstance:IAPManager!
        
        //IBOutlets
        
        @IBOutlet weak var tableView: UITableView!
        var selectedProductIndex: NSIndexPath!
        
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.dataSource = self
            tableView.delegate = self
            
            IAPManagerInstance = IAPManager()
            IAPManagerInstance.delegate = self
            IAPManagerInstance.requestProductInfo()
            
        }
        
        
        //MARK:
        //MARK: - myIAPManagerDelegate functions>
        //MARK:
        func didReceiveBatteryList(batteryList: [batteryTuple]?) {
            var tempBatteryList = [Battery]()
            for batteryItem in batteryList!{
                tempBatteryList.append(Battery(BatteryID: batteryItem.batteryID, name: batteryItem.batteryName, count: 0))
            }
            batteries = tempBatteryList
            tableView.reloadData()
        }
        
        
        func didCompleteTransactionWithError(error: NSError?) {
            if(error == nil){
                guard let cell = tableView.cellForRowAtIndexPath(selectedProductIndex) as? BatteryTableViewCell else { fatalError() }
                
                
                var battery = batteries[selectedProductIndex.row]
                battery.count += 1
                batteries[selectedProductIndex.row] = battery
                cell.configure(withBattery: battery)
                tableView.reloadRowsAtIndexPaths([selectedProductIndex], withRowAnimation: .Top)
                
            }
            else{
                print("Failed to buy!")
            }
        }
        
        
        //MARK:
        //MARK: - Action Sheet
        //MARK:
        func showActions() {
            
            let actionSheetController = UIAlertController(title: "IAPDemo", message: "What do you want to do?", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let buyAction = UIAlertAction(title: "Buy", style: UIAlertActionStyle.Default) { (action) -> Void in
                
                self.IAPManagerInstance.buyProductWithIndex(self.selectedProductIndex.row)
                
            }
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
                
            }
            
            actionSheetController.addAction(buyAction)
            actionSheetController.addAction(cancelAction)
            
            presentViewController(actionSheetController, animated: true, completion: nil)
        }
        
    }





    //MARK:
    //MARK: - UITableViewDataSource functions>
    //MARK:

    extension ViewController: UITableViewDataSource {
        func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //return batteries.count
            return batteries.count
        }
        
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 80.0
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as? BatteryTableViewCell else { fatalError() }
            
            let battery = batteries[indexPath.row]
            cell.configure(withBattery: battery)
            
            return cell
            
            
        }
        
        
    }


        //MARK:
        //MARK: - UITableViewDelegate functions>
        //MARK:

    extension ViewController: UITableViewDelegate {
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            selectedProductIndex = indexPath
            showActions()
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
            
        }
    }



