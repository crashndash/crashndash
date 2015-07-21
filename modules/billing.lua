module ( "bill", package.seeall )
if MOAIBillingAndroid and not MOAIBilling then
  MOAIBilling = MOAIBillingAndroid
end

BILLING_KEY = appConfig.billingKey

local androidSetup = function (  )

  local onBillingSupported = function ( supported )

    if ( supported ) then
      -- First make sure we consume "old" purchases.
      local prods = MOAIBilling.getPurchasedProducts()
      if prods then
        local jprods = MOAIJsonParser.decode(prods)
        if jprods and jprods.purchaseData then
          for i, item in next, jprods.purchaseData, nil do
            -- Must consume.
            MOAIBilling.consumePurchaseSync(item.purchaseToken)
          end
        end
      end

      payForProduct = function ( product, callback )
        successCallback = callback or successCallback
        MOAIBilling.purchaseProduct ( product, BILLINGV3_PRODUCT_INAPP )
      end

    else
      print ( "billing is not supported" )
    end
  end

  local onPurchaseResponseReceived = function ( code, id )

    if ( code == MOAIBilling.BILLING_RESULT_SUCCESS ) then

      print ( "purchase request received" )
      successCallback ()
      postSuccess ()
    elseif ( code == MOAIBilling.BILLING_RESULT_USER_CANCELED ) then
      print ( "user canceled purchase" )
    else
      print ( "purchase failed" )
    end
  end

  MOAIBilling.setListener ( MOAIBilling.CHECK_BILLING_SUPPORTED, onBillingSupported )
  MOAIBilling.setListener ( MOAIBilling.PURCHASE_RESPONSE_RECEIVED, onPurchaseResponseReceived )
  local supported = MOAIBilling.checkInAppSupported()
  onBillingSupported(supported)

  if not MOAIBilling.setBillingProvider ( MOAIBilling.BILLING_PROVIDER_GOOGLE ) then

    print ( "unable to set billing provider" )
  else

    if not MOAIBilling.checkInAppSupported() then

      print ( "check billing supported failed" )
    end
  end

end

successCallback = function (  )
  print("success")
end

postSuccess = function (  )
  local ls = statemgr.getCurState ()
  -- Make sure the achievement variable is set.
  globalData.usedShop = true
  achmng.sendAchievements ( ls.layer )
  config:saveGame ()
end

restoreTransactions = function ( callback )
  -- Empty placeholder.
end

local iosSetup = function (  )
  if MOAIBilling.canMakePayments () then
    local onPaymentQueueTransaction = function (transaction)
      if transaction.transactionState == MOAIBillingIOS.TRANSACTION_STATE_PURCHASED then
        -- Success state.
        successCallback ()
        postSuccess ()
      else
        -- @todo. Some error handling, maybe? Problem is, even a "wait" is an
        -- error. Must do later
      end
      if transaction.transactionState == MOAIBillingIOS.TRANSACTION_STATE_RESTORED then
        successCallback(transaction.payment.productIdentifier)
      end
    end

    MOAIBilling.setListener ( MOAIBilling.PAYMENT_QUEUE_TRANSACTION, onPaymentQueueTransaction )
    payForProduct = function ( product, callback )
      successCallback = callback or successCallback
      MOAIBilling.requestPaymentForProduct  ( product )
    end
    restoreTransactions = function ( callback )
      successCallback = callback or successCallback
      MOAIBilling.restoreCompletedTransactions()
    end
  end
end

if MOAIBilling then
  if MOAIBillingIOS then
    iosSetup ()
  end
  if MOAIBillingAndroid then
    androidSetup ()
  end
else
  payForProduct = function ( product, callback )
    successCallback = callback or successCallback
    print("mock purchase: " .. product)
    successCallback ()
    postSuccess ()
  end
end
