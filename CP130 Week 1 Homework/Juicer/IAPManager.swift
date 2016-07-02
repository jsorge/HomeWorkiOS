//
//  IAPManager.swift
//  Juicr
//
//  Created by Aasveen Kaur on 7/2/16.
//  Copyright © 2016 Taphouse Software. All rights reserved.
//

import UIKit
import StoreKit

typealias batteryTuple = (batteryID: String, batteryName: String)

protocol myIAPManagerDelegate:class {
    
    func didReceiveBatteryList(batteryList:[batteryTuple]?)
    func didCompleteTransactionWithError(error:NSError?)
    
}




class IAPManager: NSObject, SKProductsRequestDelegate ,SKPaymentTransactionObserver {
   
    
    weak var delegate: myIAPManagerDelegate!
        
    var productIDs: Array<String!> = []
    
    var productsArray: Array<SKProduct!> = []
    
   
    //MARK:
    //MARK: - PURCHASE HANDLING
    //MARK:
    func buyProductWithIndex(productIndex:Int!)  {
        
         SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        let payment = SKPayment(product: self.productsArray[productIndex] as SKProduct)
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
       
        if SKPaymentQueue.canMakePayments() {
            productIDs.append("juice.AAABattery")
            let productIdentifiers = NSSet(array: productIDs)
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
            
            var batteries:[(batteryID: String, batteryName: String)] = []
            for product in response.products {
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
