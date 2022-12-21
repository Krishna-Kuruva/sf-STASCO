/*****************************************************************************
@Name:  RV_MRCInsertWebserviceClass
@Purpose: To insert data from mulesoft into MRC staging objects
@History                                                            
@---------                                                            
@VERSION AUTHOR        DATE                DETAIL                                 
@1.0 - Dharmendra      12/9/2020         INITIAL DEVELOPMENT

******************************************************************************/
@RestResource(urlMapping='/createMRC/*')
global class RV_MRCInsertWebserviceClass {
    
	@HttpPost
    global static String createMRCStagings() {
        
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        System.debug('-----body----'+body);
        //String requestString = '['+body.toString()+']';
        String requestString = body.toString();
        //String finalRequestString = '['+requestString+']';
        System.debug('-----requestString----'+requestString);
        //List<RV_MRCWrapperClass> rw = (List<RV_MRCWrapperClass>)System.JSON.deserialize(requestString,List<RV_MRCWrapperClass>.class);
        RV_MRCWrapperClass rw = (RV_MRCWrapperClass)JSON.deserialize(requestString, RV_MRCWrapperClass.class);
        System.debug('-----rw----'+rw);
        List<RV_MRC_Header_Staging__c> mrcHeaderList = new List<RV_MRC_Header_Staging__c>();
        List<RV_MRC_Item_Staging__c> mrcItemStgLst = new List<RV_MRC_Item_Staging__c>();
        
        mrcHeaderList.add(createMRCHeader(rw));
         if(rw.MRCItemList != null){
                for(RV_MRCWrapperClass.mrcItemClass mrcItem : rw.MRCItemList){
                     mrcItemStgLst.add(createMRCItem(mrcItem));
                }
         }
        /*
        for(RV_MRCWrapperClass mrcContract : rw){
            System.debug('-----mrcContract----'+mrcContract);
                mrcHeaderList.add(createMRCHeader(mrcContract));
            	System.debug('-----mrcContract----'+mrcContract);
            if(mrcContract.MRCItemList != null){
                for(RV_MRCWrapperClass.mrcItemClass mrcItem : mrcContract.MRCItemList){
                     mrcItemStgLst.add(createMRCItem(mrcItem));
                }
            }
			
        }
		*/
        String responseMsg = 'Record has been inserted.';
        if(!mrcHeaderList.isEmpty()){
            try{
                insert mrcHeaderList;
                responseMsg = 'MRC Header '+mrcHeaderList[0].name+ ' along with line items created successfully!';
                
            }catch(Exception de){
                System.debug('--------------'+de.getMessage());
                responseMsg = 'MRC Header could not be created. Error msg: '+de.getMessage();
            }
        }
        
        List<RV_MRC_Item_Staging__c> mrcItemFinalLst = new List<RV_MRC_Item_Staging__c>();
        
        //String mrcLineItemNames = '';
        System.debug('------mrcItemStgLst--------'+mrcItemStgLst);
        for(RV_MRC_Item_Staging__c mrcItem : mrcItemStgLst){
            mrcItem.Master_Reference_Contract_number__c = mrcHeaderList.get(0).Id;
            mrcItemFinalLst.add(mrcItem);
            //mrcLineItemNames = mrcLineItemNames+', ' + mrcItem.name;
        }
        
        if(!mrcItemFinalLst.isEmpty()){
            System.debug('------mrcItemFinalLst--------'+mrcItemFinalLst);
            try{
                insert mrcItemFinalLst;
                //responseMsg = responseMsg+ '\n' + ' Line Items: '+mrcLineItemNames;
            }catch(Exception de){
                System.debug('-----error---------'+de.getMessage());
                //responseMsg = responseMsg +'\n'+ ' Line Items Rejected dure to: '+de.getMessage();
            }
        }
        return responseMsg;
    }
    
    public static RV_MRC_Header_Staging__c createMRCHeader(RV_MRCWrapperClass mrcContract){
        		RV_MRC_Header_Staging__c mrcHeader 	= new RV_MRC_Header_Staging__c();
            	mrcHeader.Action_Indicator__c 		= mrcContract.actionInd;
            	mrcHeader.Name 						= mrcContract.MRCNo;
            	mrcHeader.Sales_Document_Type__c 	= mrcContract.SalesDoctype;
            	mrcHeader.Ship_To_PO_type__c 		= mrcContract.ShipToPOtype;
            	mrcHeader.Sales_Organization__c 	= mrcContract.SalesOrg;
            	mrcHeader.Distribution_Channel__c 	= mrcContract.DistributionChannel;
            	mrcHeader.Division__c 				= mrcContract.Division;
            	mrcHeader.Valid_From__c 			= mrcContract.ValidFrom;
            	mrcHeader.Valid_To__c  				= mrcContract.ValidTo;
            	mrcHeader.Sold_To__c 				= mrcContract.SoldTo;
            	mrcHeader.Sold_To_Name__c 			= mrcContract.SoldToName;
            	mrcHeader.Ship_To__c 				= mrcContract.ShipTo;
            	mrcHeader.Ship_To_Name__c 			= mrcContract.ShipToName;
            	mrcHeader.Shipping_Condition__c 	= mrcContract.ShippingCondition;
        		mrcHeader.Description__c 			= mrcContract.Description;
        		mrcHeader.Shipping_Condition_Description__c = mrcContract.ShipCondDescription;
        		mrcHeader.Sold_To_Deletion_Flag_at_All_Areas__c = mrcContract.SoldToDelFlgAllArea;
        		mrcHeader.Sold_To_Deletion_Flag_at_Sales_Area__c = mrcContract.SoldToDelFlgSaleArea;
        		mrcHeader.Sold_To_National_Account_Partner__c = mrcContract.SoldToNatiAccPart;
        		mrcHeader.Sold_To_National_Account_Partner_Name__c = mrcContract.SoldToNatiAccPartName;
        		mrcHeader.Sold_To_Primary_Sales_Repr__c = mrcContract.SoldToPrimSalesRep;
        		mrcHeader.Sold_To_Primary_Sales_Repr_Name__c = mrcContract.SoldToPrimSalesRepName;
        		mrcHeader.Sold_To_Sales_Group__c = mrcContract.SoldToSalesGrp;
        		mrcHeader.Sold_To_Sales_Group_Description__c = mrcContract.SoldToSalesGrpDescrp;
        		mrcHeader.Ship_To_Primary_Sales_Repr__c = mrcContract.ShipToPrimrySalesRepr;
        		mrcHeader.Ship_To_Primary_Sales_Repr_Name__c = mrcContract.ShipToPrimrySalesReprName;
        		mrcHeader.Ship_To_Sales_Group__c = mrcContract.ShipToSalesGrp;
        		mrcHeader.Ship_To_Sales_Group_Description__c = mrcContract.ShipToSalesGrpDesc;
        		mrcHeader.Customer_Credit_Limit__c = mrcContract.customerCreditLimit;
        return mrcHeader;
    }
    
    public static RV_MRC_Item_Staging__c createMRCItem(RV_MRCWrapperClass.mrcItemClass mrcItem){
        RV_MRC_Item_Staging__c mrcInsertItem = new RV_MRC_Item_Staging__c();
        mrcInsertItem.Name = mrcItem.MRCItemNo;
        mrcInsertItem.Plant__c = mrcItem.PlantCode;
        mrcInsertItem.Plant_Name__c = mrcItem.PlantName;
        mrcInsertItem.Material_Number__c = mrcItem.MaterialNumber;
        mrcInsertItem.Material_Description__c = mrcItem.MaterialDescription;
        mrcInsertItem.Handling_Type__c = mrcItem.HandlingType;
        mrcInsertItem.Reason_for_Rejection_Code__c = mrcItem.ReasonforRejectionCode;
        mrcInsertItem.Reason_for_Rejection_Message__c = mrcItem.ReasonforRejectionMessage;
        mrcInsertItem.Mode_of_Transport__c = mrcItem.ModeofTransport;
        mrcInsertItem.Mode_of_Transport_Description__c = mrcItem.ExterMOTDesc;
        mrcInsertItem.Incoterms_Part1__c = mrcItem.incoTermsPart1;
        mrcInsertItem.Incoterms_Part2__c = mrcItem.incoTermsPart2;
        mrcInsertItem.Payment_Terms__c = mrcItem.PaymentTerms;
        mrcInsertItem.Payment_Terms_Description__c = mrcItem.PaymentTermsDescrp;
        mrcInsertItem.Valuation_Type__c = mrcItem.ValuationType;
        mrcInsertItem.Condition_group_2__c = mrcItem.CondGroup2;
        mrcInsertItem.Condition_group_2_Description__c = mrcItem.CondGroup2Desc;
        mrcInsertItem.Invoicing_date__c = mrcItem.InvoiceDate;
        mrcInsertItem.Invoicing_dates_Description__c = mrcItem.InvoiceDateDesc;
        mrcInsertItem.Payment_Method__c = mrcItem.Paymentmethod;
        mrcInsertItem.Payment_Method_Description__c = mrcItem.PaymentmethodDesc;
        return mrcInsertItem;
    }
}