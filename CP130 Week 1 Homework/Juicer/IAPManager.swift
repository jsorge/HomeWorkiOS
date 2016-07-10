//
//  IAPManager.swift
//  Juicr
//
//  Created by Aasveen Kaur on 7/2/16.
//  Copyright © 2016 Taphouse Software. All rights reserved.
//

import UIKit
import StoreKit

//This seems to be replicating the Battery struct that is in the view controller, is it necessary?
typealias batteryTuple = (batteryID: String, batteryName: String)

protocol myIAPManagerDelegate:class {
    //Nicely done declaring a method in the protocol that can return available batteries for purchase
    func didReceiveBatteryList(batteryList:[batteryTuple]?)
    func didCompleteTransactionWithError(error:NSError?) //I like this method name. It's very Cocoa!
    
}




class IAPManager: NSObject, SKProductsRequestDelegate ,SKPaymentTransactionObserver {
   
    //If something calls this class and forgets to set the delegate, you'll get a crash. I would prefer to see the delegate as an optional. It adds a few more ? to check for its presence, but will enhance safety
    weak var delegate: myIAPManagerDelegate!
    
    //You seem to be holding on to a state here that may not be needed.
    //Declaring the array in this manner is also saying that it will be implicitly unwrapped optionals (which means you can check a value for nil). If you want to say that it's an array of strings, it could be declared as simply var productIDs = [String]()
    var productIDs: Array<String!> = []
    
    //Similar to the productIDs array. A more concise way to put it would be var productsArray = [SKProduct]()
    var productsArray: Array<SKProduct!> = []
    
   
    //MARK:
    //MARK: - PURCHASE HANDLING
    //MARK:
    func buyProductWithIndex(productIndex:Int!)  {
        //Every time this method is called, the IAPManager is being added as a transaction observer. That only needs to be done once, and depending on the implementation of the addTransactionObserver(_:) method could be an incorrect way to interact with that class
         SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        let payment = SKPayment(product: self.productsArray[productIndex] as SKProduct) //If you refactor the productsArray to contain SKProduct instances and not SKProduct! instances, you can avoid that cast
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
               delegate.didCompleteTransactionWithError(nil)
                
                
                
            case SKPaymentTransactionState.Failed:
                print("Transaction Failed");
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                delegate.didCompleteTransactionWithError(NSError(domain: "Transaction Failed", code: 0, userInfo:nil))
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    //MARK:
    //MARK: - GET PRODUCT
    //MARK:
    
    func requestProductInfo() {
       
        //Nicely done, asking if the payment queue can make payments. One other way this could be done here is to guard it. That would get rid of the single line else statement below and remove the indentation here.
        //That would read guard SKPaymentQueue.canMakePayments else { print("Cannot perform In App Purchases."); return }
        if SKPaymentQueue.canMakePayments() {
            
            //Every time this method is called, you are appending a new battery to the array. That doesn't seem like your intended effect
            productIDs.append("juice.AAABattery")
            
            //Swift has its own Set type, so you don't need to fall back to NSSet.
            //The swift version is typed, so it will also make your next call safer
            let productIdentifiers = NSSet(array: productIDs)
            
            //Force casting could be dangerous here.
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String> )
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if response.products.count != 0 {
            
            //This could read as var batteries = [batteryTuple]()
            var batteries:[(batteryID: String, batteryName: String)] = []
            for product in response.products {
                //What happens if the product is already in the products array?
                productsArray.append(product)
                batteries.append((batteryID: product.productIdentifier, batteryName: product.localizedTitle))
                
            }
            delegate.didReceiveBatteryList(batteries)
           
        }
        else {
            print("There are no products.")
             delegate.didReceiveBatteryList(nil)
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
        
    }
}
