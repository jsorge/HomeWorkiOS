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
        
        //This doesn't see safe to me. What if it gets nilled out somehow?
        var IAPManagerInstance:IAPManager!
        
        //IBOutlets
        
        @IBOutlet weak var tableView: UITableView!
        
        //What if there isn't a selected index path? I would stay away from leaning heavily on implicitly unwrapped optionals. Use them with caution.
        //The only place that I personally use them is in IBOutlets. There are cases to be made either way in using them, but if you load up a view and it crashes because it found nil in an outlet, that's an easy fix. But if a user crashes because of some edge case where this variable is nil, that's a whole new app release before it gets fixed to the user.
        var selectedProductIndex: NSIndexPath!
        
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tableView.dataSource = self
            tableView.delegate = self
            
            IAPManagerInstance = IAPManager()
            IAPManagerInstance.delegate = self
            
            //If this is the method that you want to use to fetch the available batteries for purchase, that is fine. However, I would advise adding some loading state to the view. If the network needs to get hit, then you could have some latency and waiting for the the UI to update. That isn't a good experience for the user without them knowing that something is happening.
            IAPManagerInstance.requestProductInfo()
            
        }
        
        
        //MARK:
        //MARK: - myIAPManagerDelegate functions>
        //MARK:
        func didReceiveBatteryList(batteryList: [batteryTuple]?) {
            var tempBatteryList = [Battery]()
            
            //If the batteryList is nil, this will crash
            //You could simplify this whole call by first guarding that your battery list is not nil, otherwise remove all the batteries from your batteris array
            //Then map all of the tuples in the batteryList to your batteries array. Like so:
            //batteries = batteryList.map { (batterySource) -> Battery in return Battery(BatteryID: batterySource.batteryID, name: batterySource.batteryName, count: 0) }
            for batteryItem in batteryList!{
                tempBatteryList.append(Battery(BatteryID: batteryItem.batteryID, name: batteryItem.batteryName, count: 0))
            }
            batteries = tempBatteryList
            
            //Since this is a delegate callback, is it guaranteed to be on the main thread? You could get a crash if it isn't
            tableView.reloadData()
        }
        
        
        func didCompleteTransactionWithError(error: NSError?) {
            //This is a great candidate for a guard on the error
            if(error == nil){
                //You don't need to get the cell out if you are reloading the row later in this method. All you should need to do here is
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
            //I like that you are asking for confirmation to buy the battery, but it might be nice to give the specific battery being purchased
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
            
            //This call isn't needed since your first call was to deselectRowAtIndexPath. That will handle the selection state of the cell
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
            
        }
    }



