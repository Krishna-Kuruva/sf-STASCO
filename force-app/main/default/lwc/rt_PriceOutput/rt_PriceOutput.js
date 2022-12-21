/**
 * Created by Soumyajit.Jagadev on 09-Jul-20.
 */

import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getPageDataApex from '@salesforce/apex/RT_PriceOutputController.getPageData';
import savePriceChangeApex from '@salesforce/apex/RT_PriceOutputController.savePriceChange';
import saveDailyAdjustmentApex from '@salesforce/apex/RT_PriceOutputController.saveDailyAdjustment';
import submitForReviewApex from '@salesforce/apex/RT_PriceOutputController.submitForReview';
import approveRejectAllApex from '@salesforce/apex/RT_PriceOutputController.approveRejectAll';
import matchAllApex from '@salesforce/apex/RT_PriceOutputController.matchAll';
import runPriceLogicApex from '@salesforce/apex/RT_PriceOutputController.runPriceLogic';
import hasApproverPermission from '@salesforce/customPermission/RT_Approver';
import runRevConApex from  '@salesforce/apex/RT_REVContractTriggerHelper.deactivateOldAureus';

export default class RtPriceOutput extends NavigationMixin(LightningElement) {

    //Property Declaration starts here
    @track showPageHeader = false;
    @track isApprover = false;
    sectionOpenMap = new Map();

    @track selectedFilter = '--None--';
    @track filterList =   [	 { label: '--None--', value: '--None--'}
                            ,{ label: 'Sold-To', value: 'SoldTo'}
                            ,{ label: 'Plant', value: 'Plant'}
                            ,{ label: 'Material', value: 'Material'}
                            ,{ label: 'Discount Type', value: 'DiscountType'}
                          ];
    @track soldToList = [];
    @track plantList = [];
    @track materialList = [];
    @track selectedSoldTo = 'ALL';
    @track selectedPlant = 'ALL';
    @track selectedMaterial = 'ALL';
    @track showLimitFilter = false;
    @track limitFailedOnes = false;
    @track limitImports = false;
    @track globalDailyAdjustment;
    @track globalDailyAdjustmentDisabled = false;

    @track marginPercentage = 44;
    @track showPriceData = false;
    priceList = [];
    @track priceData = [];
    @track showPriceDetails = false;
    @track priceDetailData = [];

    focusAmount = false;
    focusAdjustment = false;
    tempAmountSet = false;
    tempAmount = 0;
    tempAdjustmentSet = false;
    tempAdjustment = 0;

    @track showExpandAll = false;
    @track showCollapseAll = false;
    @track showSendApproval = false;
    @track showDownloadOutput = false;
    @track showApprovalAll = false;
    @track showRejectAll = false;
    @track showDownloadMsg = false;
    @track showCopySuggAmountBtn = false;

    @track outputReportID = '';
    @track exportReportID = '';

    @track spinnerLoad = false;
    @track spinnerMessage = '';

    @track scrollableHeight = 'height:370px;width:100%';
    @track isBatchRunning = false;
    //Property Declaration ends here

    //Init Method Declaration starts here
    connectedCallback() {
            this.showPageHeader = true;
            this.isApprover = hasApproverPermission;
            this.globalDailyAdjustmentDisabled = true;
            this.getPageData();
        }
    //Init Method Declaration ends here

    //Render Method Declaration starts here
    renderedCallback()
    {
        if(this.focusAmount)
            this.template.querySelector("lightning-input[data-name='amount']").focus();
        if(this.focusAdjustment)
            this.template.querySelector("lightning-input[data-name='adjustment']").focus();
    }
    //Render Method Declaration ends here

    //Method Declaration starts here
    get filterIsNone(){return (this.selectedFilter == '--None--') ? true : false;}
    get filterIsSoldTo(){return (this.selectedFilter == 'SoldTo') ? true : false;}
    get filterIsPlant(){return (this.selectedFilter == 'Plant') ? true : false;}
    get filterIsMaterial(){return (this.selectedFilter == 'Material') ? true : false;}
    get filterIsDiscount(){return (this.selectedFilter == 'DiscountType') ? true : false;}

    getPageData()
    {
        this.loadSpinner(true,'Fetching Price Details');

        getPageDataApex({})
        .then(result => {

            this.isBatchRunning = result.isLogicRunning;

            if(this.isBatchRunning)
            {
                this.showToast('success','Price Logic Is Running, Please Refresh After Some Time','');
                this.showPageHeader = false;
                this.showPriceData = false;
                this.loadSpinner(false,'');
            }
            else
            {
                this.soldToList = result.soldToList;
                this.plantList = result.plantList;
                this.materialList = result.materialList;
                this.priceList = result.priceData;
                this.globalDailyAdjustment = result.dailyAdjustment;
                this.outputReportID = result.outputReportID;
                this.exportReportID = result.exportReportID;
                this.marginPercentage = result.marginPercentage;

                if(this.priceList != undefined && this.priceList != '' && this.priceList != [])
                {
                    if(this.priceList.length>0)
                    {
                        /*this.selectedFilter = '--None--';
                        this.selectedSoldTo = 'ALL';
                        this.selectedPlant = 'ALL';
                        this.selectedMaterial = 'ALL';
                        this.showLimitFilter = true;
                        this.sectionOpenMap = new Map();*/
                        this.showLimitFilter = true;
                        this.loadSpinner(false,'');
                        this.doPriceGrouping();
                    }
                    else
                    {
                        this.showToast('error','No Data Found For Today','');
                        this.showPageHeader = false;
                        this.showPriceData = false;
                        this.loadSpinner(false,'');
                    }
                }
                else
                {
                    this.showToast('error','No Data Found For Today','');
                    this.showPageHeader = false;
                    this.showPriceData = false;
                    this.loadSpinner(false,'');
                }
            }
        })
        .catch(error => {
            this.showToast('error','Page Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    savePriceChange(saveType, priceRowID, priceRowVal)
    {
        this.loadSpinner(true,'Saving Price Change');

        if(this.showPriceDetails)
            this.showPriceDetails = false;

        savePriceChangeApex({changeType: saveType, priceId: priceRowID, value: priceRowVal})
        .then(result => {
            if(result != '' && result != undefined)
            {
                this.priceList = result;
                this.doPriceGrouping();
            }
            else
                this.showToast('error','Price Update Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        })
        .catch(error => {
            this.showToast('error','Price Update Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    saveDailyAdjustment()
    {
        this.loadSpinner(true,'Saving Daily Adjustment');

        saveDailyAdjustmentApex({dailyAdjust : this.globalDailyAdjustment})
        .then(result => {
            if(result != '' && result != undefined)
            {
                this.priceList = result;
                this.doPriceGrouping();
                this.showToast('success','Update Successful','');
            }
            else
                this.showToast('error','Daily Adjustment Update Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        })
        .catch(error => {
            this.showToast('error','Daily Adjustment Update Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    approveRejectAll(saveType)
    {
        this.loadSpinner(true,'Updating Price Approval');

        approveRejectAllApex({changeType : saveType})
        .then(result => {
            if(result != '' && result != undefined)
            {
                this.priceList = result;
                this.doPriceGrouping();
                this.showToast('success','Update Successful','');
            }
            else
                this.showToast('error','Price Approval Update Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        })
        .catch(error => {
            this.showToast('error','Price Approval Update Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    matchAll()
    {
        this.loadSpinner(true,'Updating Price Amount to Suggested Amount');

        matchAllApex({})
        .then(result => {
            if(result != '' && result != undefined)
            {
                this.priceList = result;
                this.doPriceGrouping();
                this.showToast('success','Update Successful','');
            }
            else
                this.showToast('error','Price Update Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        })
        .catch(error => {
            this.showToast('error','Price Update Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    submitForReview()
    {
        this.loadSpinner(true,'Sending For Review');

        submitForReviewApex({})
        .then(result => {
            if(result != '' && result != undefined)
            {
                this.priceList = result;
                this.doPriceGrouping();
                this.showToast('success','Price Change has been sent for Review','');
            }
            else
                this.showToast('error','Submission of Review Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        })
        .catch(error => {
            this.showToast('error','Submission of Review Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    doPriceGrouping()
    {
        this.loadSpinner(true,'Formatting Price Data');

        let priceMap = new Map();
        let priceList = this.priceList;
        this.priceData = [];
        let parentCounter = -1;
        this.showDownloadOutput = false;
        this.showSendApproval = false;
        this.showApprovalAll = false;
        this.showRejectAll = false;
        this.showCopySuggAmountBtn = false;

        try{
            for(let key=0; key<priceList.length; key++)
            {
                let childCounter = 0;
                let childIndex = -1;
                let includePrice = true;
                let grp1Key = '';
                let grp1Name = '';
                let grp2Name = '';
                let grp3Name = '';
                let grp4Name = '';
                let grp1ID = '';
                let grp2ID = '';
                let grp3ID = '';
                let grp4ID = '';
                let soldToFilter = priceList[key].soldToID;
                let plantFilter = priceList[key].plantID;
                let materialFilter = priceList[key].materialGradeID;

                //priceList[key].shellMargin/=100;
                //priceList[key].cfMargin/=100;

                priceList[key].soldToLink = '/' + priceList[key].soldToID;
                priceList[key].plantLink = '/' + priceList[key].plantID;
                priceList[key].materialLink = '/' + priceList[key].materialID;
                priceList[key].refineryLink = '/' + priceList[key].refineryID;
                priceList[key].siteLink = '/' + priceList[key].siteID;
                priceList[key].keyValLink = '/' + priceList[key].aureusID;

                if(this.selectedFilter =='--None--')
                {
                    grp1Key = 'All Price';
                    grp1Name = priceList[key].soldToName;
                    grp1ID = priceList[key].soldToLink;
                    grp2Name = priceList[key].plantAbbreviatedName + ' [' + priceList[key].plantCode + ']';
                    grp2ID = priceList[key].plantLink;
                    grp3Name = priceList[key].materialGrade + ' [' + priceList[key].materialCode + ']';
                    grp3ID = priceList[key].materialLink;
                    grp4Name = priceList[key].discountType;
                    grp4ID = '';
                }

                if(this.selectedFilter =='SoldTo')
                {
                    grp1Key = priceList[key].soldToID;
                    grp1Name = priceList[key].soldToName;
                    grp1ID = priceList[key].soldToLink;
                    grp2Name = priceList[key].plantAbbreviatedName + ' [' + priceList[key].plantCode + ']';
                    grp2ID = priceList[key].plantLink;
                    grp3Name = priceList[key].materialGrade + ' [' + priceList[key].materialCode + ']';
                    grp3ID = priceList[key].materialLink;
                    grp4Name = priceList[key].discountType;
                    grp4ID = '';
                }

                if(this.selectedFilter == 'Plant')
                {
                    grp1Key = priceList[key].plantID;
                    grp1Name = priceList[key].plantAbbreviatedName + ' [' + priceList[key].plantCode + ']';
                    grp1ID = priceList[key].plantLink;
                    grp2Name = priceList[key].soldToName;
                    grp2ID = priceList[key].soldToLink;
                    grp3Name = priceList[key].materialGrade + ' [' + priceList[key].materialCode + ']';
                    grp3ID = priceList[key].materialLink;
                    grp4Name = priceList[key].discountType;
                    grp4ID = '';
                }

                if(this.selectedFilter == 'Material')
                {
                    grp1Key = priceList[key].materialID;
                    grp1Name = priceList[key].materialGrade + ' [' + priceList[key].materialCode + ']';
                    grp1ID = priceList[key].materialLink;
                    grp2Name = priceList[key].soldToName;
                    grp2ID = priceList[key].soldToLink;
                    grp3Name = priceList[key].plantAbbreviatedName + ' [' + priceList[key].plantCode + ']';
                    grp3ID = priceList[key].plantLink;
                    grp4Name = priceList[key].discountType;
                    grp4ID = '';
                }

                if(this.selectedFilter =='DiscountType')
                {
                    grp1Key = priceList[key].discountType;
                    grp1Name = priceList[key].discountType;
                    grp1ID = '';
                    grp2Name = priceList[key].soldToName;
                    grp2ID = priceList[key].soldToLink;
                    grp3Name = priceList[key].plantAbbreviatedName + ' [' + priceList[key].plantCode + ']';
                    grp3ID = priceList[key].plantLink;
                    grp4Name = priceList[key].materialGrade + ' [' + priceList[key].materialCode + ']';
                    grp4ID = priceList[key].materialLink;
                }

                if(includePrice)
                {
                    if(this.selectedSoldTo == 'ALL' && this.selectedPlant == 'ALL' && this.selectedMaterial == 'ALL')
                        includePrice = true;
                    else if(this.selectedSoldTo != 'ALL' && this.selectedSoldTo == soldToFilter
                        && ( (this.selectedPlant == 'ALL'&& (this.selectedMaterial == 'ALL' || (this.selectedMaterial != 'ALL' && this.selectedMaterial == materialFilter)))
                            || (this.selectedPlant != 'ALL' && this.selectedPlant == plantFilter
                                && (this.selectedMaterial == 'ALL' || (this.selectedMaterial != 'ALL' && this.selectedMaterial == materialFilter))
                               )
                            )
                        )
                        includePrice = true;
                    else if(this.selectedPlant != 'ALL' && this.selectedPlant == plantFilter
                        && ( (this.selectedSoldTo == 'ALL'&& (this.selectedMaterial == 'ALL' || (this.selectedMaterial != 'ALL' && this.selectedMaterial == materialFilter)))
                            || (this.selectedSoldTo != 'ALL' && this.selectedSoldTo == soldToFilter
                                && (this.selectedMaterial == 'ALL' || (this.selectedMaterial != 'ALL' && this.selectedMaterial == materialFilter))
                               )
                            )
                        )
                        includePrice = true;
                    else if(this.selectedMaterial != 'ALL' && this.selectedMaterial == materialFilter
                        && ( (this.selectedSoldTo == 'ALL'&& (this.selectedPlant == 'ALL' || (this.selectedPlant != 'ALL' && this.selectedPlant == plantFilter)))
                            || (this.selectedSoldTo != 'ALL' && this.selectedSoldTo == soldToFilter
                                && (this.selectedPlant == 'ALL' || (this.selectedPlant != 'ALL' && this.selectedPlant == plantFilter))
                               )
                            )
                        )
                        includePrice = true;
                    else
                        includePrice = false;
                }

                if(this.limitFailedOnes && includePrice)
                {
                    if(!priceList[key].isMatch)
                        includePrice = true;
                    else
                        includePrice = false;
                }

                if(this.limitImports && includePrice)
                {
                    if(priceList[key].isImportTerminal)
                        includePrice = true;
                    else
                        includePrice = false;
                }

                if(includePrice)
                {
                    let parentList = {};
                    parentList.index = 0;
                    parentList.hasSuccess = true;
                    parentList.successCount = 0;
                    parentList.hasError = false;
                    parentList.errorCount = 0;
                    parentList.hasReview = false;
                    parentList.reviewCount = 0;
                    parentList.hasApproval = false;
                    parentList.approvalCount = 0;
                    parentList.hasReject = false;
                    parentList.rejectCount = 0;
                    parentList.gridData = [];

                    if(priceMap.has(grp1Key))
                    {
                        parentList = priceMap.get(grp1Key);
                        childIndex = parentList.gridData.length;
                        childCounter = parentList.gridData.length;
                    }
                    else
                    {
                        parentList.grp1Name = grp1Name;
                        parentList.grp1ID = grp1ID;
                        parentCounter++;
                        childIndex++;
                        parentList.index = parentCounter;
                    }
                    childCounter++;

                    if(this.selectedFilter =='--None--')
                    {
                        parentList.showSectionData = true;
                    }
                    else
                    {
                        if(this.sectionOpenMap.has(parentList.index))
                            parentList.showSectionData = this.sectionOpenMap.get(parentList.index);
                        else
                        {
                            parentList.showSectionData = false;
                            this.sectionOpenMap.set(parentList.index,parentList.showSectionData);
                        }
                    }

                    let childList = priceList[key];
                    childList.gridIndex = parentList.index + '-' + childIndex;
                    childList.grp1Name = grp1Name;
                    childList.grp1ID = grp1ID;
                    childList.grp2Name = grp2Name;
                    childList.grp2ID = grp2ID;
                    childList.grp3Name = grp3Name;
                    childList.grp3ID = grp3ID;
                    childList.grp4Name = grp4Name;
                    childList.grp4ID = grp4ID;

                    if(!childList.isMatch)
                    {
                        parentList.errorCount++;
                        if(!this.showCopySuggAmountBtn)
                            this.showCopySuggAmountBtn = true;
                    }
                    else
                    {
                        parentList.successCount++;
                    }

                    childList.adjustmentInputDisabled = true;
                    childList.amountInputDisabled = true;

                    childList.isNew = false;
                    childList.isEdited = false;
                    childList.inReview = false;
                    childList.isApproved = false;
                    childList.isRejected = false;
                    childList.showSubmitter = false;
                    childList.showApprover = false;
                    childList.isLocked = false;

                    switch(childList.status) {
                        case 'New': childList.isNew = true; break;
                        case 'Edited': childList.isEdited = true; break;
                        case 'In Review': childList.inReview = true; parentList.reviewCount++; break;
                        case 'Approved': childList.isApproved = true; parentList.approvalCount++; break;
                        case 'Rejected': childList.isRejected = true; parentList.rejectCount++; break;
                    }

                    if(!childList.isNew)
                        childList.showSubmitter = true;

                    if(childList.isRejected || childList.isApproved)
                        childList.showApprover = true;

                    if((childList.inReview || childList.isApproved) && !this.isApprover)
                        childList.isLocked = true;

                    parentList.gridData = [ ...parentList.gridData, childList ];
                    parentList.childCounter = childCounter;

                    (parentList.successCount>0) ? parentList.hasSuccess = true : parentList.hasSuccess = false;
                    (parentList.errorCount>0) ? parentList.hasError = true : parentList.hasError = false;
                    (parentList.reviewCount>0) ? parentList.hasReview = true : parentList.hasReview = false;
                    (parentList.approvalCount>0) ? parentList.hasApproval = true : parentList.hasApproval = false;
                    (parentList.rejectCount>0) ? parentList.hasReject = true : parentList.hasReject = false;

                    if(childList.isApproved && !this.showDownloadOutput)
                        this.showDownloadOutput = true;

                    if((childList.isNew || childList.isEdited || childList.isRejected) && !this.showSendApproval && !this.isApprover)
                        this.showSendApproval = true;

                    if(!childList.isApproved && !this.showApprovalAll && this.isApprover)
                        this.showApprovalAll = true;

                    if(!childList.isRejected && !this.showRejectAll && this.isApprover)
                        this.showRejectAll = true;

                    priceMap.set(grp1Key,parentList);
                }
            }

            for (let value of priceMap.values())
                this.priceData = [ ...this.priceData, value ];

            if(this.priceData.length>0)
            {
                this.showPriceData = true;
                this.showExpandAll = true;
            }
            else
            {
                this.showPriceData = false;
                this.showToast('error','No Data Found For Selected Condition(s)','');
            }
        }
        catch(err)
        {console.log(err);}

        this.loadSpinner(false,'');
    }

    fetchFilter(event)
    {
        this.selectedFilter = event.detail.value;
        this.showLimitFilter = false;
        this.showExpandAll = false;
        this.showCollapseAll = false;

        if(this.selectedFilter != undefined && this.priceList != undefined && this.priceList != '')
        {
            this.selectedSoldTo = 'ALL';
            this.selectedPlant = 'ALL';
            this.selectedMaterial = 'ALL';
            this.showLimitFilter = true;
            this.sectionOpenMap = new Map();
            this.doPriceGrouping();
        }
        else
            this.showPriceData = false;
    }

    fetchLimitFilter(event)
    {
        let name = event.target.name;

        if(name == 'limitSoldTo')
            this.selectedSoldTo = event.detail.value;
        if(name == 'limitPlant')
            this.selectedPlant = event.detail.value;
        if(name == 'limitMaterial')
            this.selectedMaterial = event.detail.value;

        this.doPriceGrouping();
    }

    doButtonAction(event)
    {
        const btnType = event.target.name;
        const actionType = event.target.dataset.name;

        if(btnType == "amount")
        {
            const key = event.target.dataset.id;
            let parentKey = parseInt(key.split('-')[0]);
            let childKey = parseInt(key.split('-')[1]);

            if(actionType == 'save')
            {
                this.tempAmountSet = false;
                this.priceData[parentKey].gridData[childKey].amountInputDisabled = true;
                this.savePriceChange(btnType,
                                    this.priceData[parentKey].gridData[childKey].priceId,
                                    this.priceData[parentKey].gridData[childKey].amount);
                this.focusAmount = false;
            }

            if(actionType == 'cancel')
            {
                this.tempAmountSet = false;
                this.priceData[parentKey].gridData[childKey].amount = this.tempAmount;
                this.priceData[parentKey].gridData[childKey].amountInputDisabled = true;
            }
        }

        if(btnType == "adjustment")
        {
            const key = event.target.dataset.id;
            let parentKey = parseInt(key.split('-')[0]);
            let childKey = parseInt(key.split('-')[1]);

            if(actionType == 'save')
            {
                this.tempAdjustmentSet = false;
                this.priceData[parentKey].gridData[childKey].adjustmentInputDisabled = true;
                this.savePriceChange(btnType,
                                     this.priceData[parentKey].gridData[childKey].priceId,
                                     this.priceData[parentKey].gridData[childKey].adjustment);
                this.focusAdjustment = false;
            }

            if(actionType == 'cancel')
            {
                this.tempAdjustmentSet = false;
                this.priceData[parentKey].gridData[childKey].adjustment = this.tempAdjustment;
                this.priceData[parentKey].gridData[childKey].adjustmentInputDisabled = true;
            }
        }

        if(btnType == "approve")
        {
            if(actionType == 'this')
            {
                const key = event.target.dataset.id;
                let parentKey = parseInt(key.split('-')[0]);
                let childKey = parseInt(key.split('-')[1]);
                this.savePriceChange(btnType,
                                     this.priceData[parentKey].gridData[childKey].priceId,
                                     this.priceData[parentKey].gridData[childKey].adjustment);
            }

            if(actionType == 'all')
            {
                this.approveRejectAll(btnType);
            }
        }

        if(btnType == "reject")
        {
            if(actionType == 'this')
            {
                const key = event.target.dataset.id;
                let parentKey = parseInt(key.split('-')[0]);
                let childKey = parseInt(key.split('-')[1]);
                this.savePriceChange(btnType,
                                     this.priceData[parentKey].gridData[childKey].priceId,
                                     this.priceData[parentKey].gridData[childKey].adjustment);
            }

            if(actionType == 'all')
            {
                this.approveRejectAll(btnType);
            }
        }

        if(btnType == "globalDailyAdjustment")
        {
            if(actionType == 'edit')
            {
                this.globalDailyAdjustmentDisabled = false;
            }

            if(actionType == 'save')
            {
                this.globalDailyAdjustmentDisabled = true;
                this.saveDailyAdjustment();
            }

            if(actionType == 'cancel')
            {
                this.globalDailyAdjustmentDisabled = true;
            }
        }

        if(btnType == "match")
        {
            if(actionType == 'all')
            {
                this.matchAll();
            }
        }
    }

    textFldChange(event)
    {
        const name = event.target.name;
        const val = event.target.value;

        if(val != undefined && val != '')
        {
            if(name == 'amount')
            {
                const key = event.target.dataset.id;
                let parentKey = parseInt(key.split('-')[0]);
                let childKey = parseInt(key.split('-')[1]);
                if(!this.tempAmountSet){
                    this.tempAmount = this.priceData[parentKey].gridData[childKey].amount;
                    this.tempAmountSet = true;
                }
                this.priceData[parentKey].gridData[childKey].amount = val;
            }

            if(name == 'adjustment')
            {
                const key = event.target.dataset.id;
                let parentKey = parseInt(key.split('-')[0]);
                let childKey = parseInt(key.split('-')[1]);
                if(!this.tempAdjustmentSet){
                    this.tempAdjustment = this.priceData[parentKey].gridData[childKey].adjustment;
                    this.tempAdjustmentSet = true;
                }
                this.priceData[parentKey].gridData[childKey].adjustment = val;
            }

            if(name == 'globalDailyAdjustment')
            {
                this.globalDailyAdjustment = val;
            }
        }
    }

    checkboxChange(event)
    {
        const chkName = event.target.name;
        const chkVal = event.target.checked;

        if(chkName == 'limitFailedOnes')
        {
            this.limitFailedOnes = chkVal;
            this.doPriceGrouping();
        }

        if(chkName == 'limitImports')
        {
            this.limitImports = chkVal;
            this.doPriceGrouping();
        }
    }

    showPriceDetail(event)
    {
        const key = event.target.dataset.id;
        const name = event.target.dataset.name;
        let parentKey = parseInt(key.split('-')[0]);
        let childKey = parseInt(key.split('-')[1]);
        this.priceDetailData = this.priceData[parentKey].gridData[childKey];
        this.priceData[parentKey].gridData[childKey].amountInputDisabled = true;
        this.priceData[parentKey].gridData[childKey].adjustmentInputDisabled = true;

        this.showPriceDetails = true;
        this.focusAmount = false;
        this.focusAdjustment = false;

        if(name == 'editAmount')
        {
            this.priceData[parentKey].gridData[childKey].amountInputDisabled = false;
            this.focusAmount = true;
        }

        if(name == 'editAdjustment')
        {
            this.priceData[parentKey].gridData[childKey].adjustmentInputDisabled = false;
            this.focusAdjustment = true;
        }
    }

    hidePriceDetail()
    {
        this.showPriceDetails = false;
        this.focusAmount = false;
        this.focusAdjustment = false;
    }

    openDownloadMsg()
    {
        this.showDownloadMsg = true;
    }

    hideDownloadMsg()
    {
        this.showDownloadMsg = false;
    }

    openHidePageHeader(event)
    {
        const actionType = event.target.dataset.name;
        this.loadSpinner(true,'');
        if(actionType == 'open')
        {
            this.showPageHeader = true;
            this.scrollableHeight = 'height:370px;width:100%';
        }
        else
        {
            this.showPageHeader = false;
            this.scrollableHeight = 'height:470px;width:100%'
        }
        this.loadSpinner(false,'');
    }

    download(event)
    {
        if(this.showDownloadMsg)
            this.showDownloadMsg = false;

        const reportID = event.target.dataset.name;
        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: reportID,
                                objectApiName: 'Report',
                                actionName: 'view'
                            }
                        });
    }

    doRefresh()
    {
        this.connectedCallback();
    }

    runLogic()
    {
        this.loadSpinner(true,'Running Price Logic');

        runPriceLogicApex({})
        .then(result => {
            this.showToast('success','Price Logic Execution Has Been Initiated','');
            this.doRefresh();
            this.loadSpinner(false,'');
        })
        .catch(error => {
            this.showToast('error','Price Logic Run Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }
    // added by Dharmendra on 5th Oct 2020 to deactivateOldAureus records.
    runRevContractDeactivation()
        {
            this.loadSpinner(true,'Deactivation in progress');

            runRevConApex({})
            .then(result => {
                this.showToast('success','Rev Contract Deactivation job has run successfully!','');
                this.doRefresh();
                this.loadSpinner(false,'');
            })
            .catch(error => {
                this.showToast('error','Rev Contract Deactivation Run Error','Something went wrong. Please try again later!');
                this.loadSpinner(false,'');
            });
        }
    //

    toggleSection(event)
    {
        let name = event.target.dataset.name;
        this.loadSpinner(true,'');

        if(name == 'section')
        {
            let key = event.target.dataset.id;
            if(this.priceData[key].showSectionData)
                this.priceData[key].showSectionData = false;
            else
                this.priceData[key].showSectionData = true;

            this.sectionOpenMap.set(parseInt(key),this.priceData[key].showSectionData);

            let totalOpenCnt = 0
            let totalCnt = 0
            for(let parentKey=0; parentKey<this.priceData.length;parentKey++)
            {
                totalCnt++;
                if(this.priceData[parentKey].showSectionData)
                    totalOpenCnt++;
            }

            if(totalOpenCnt>0)
            {
                if(totalOpenCnt == totalCnt)
                {
                    this.showExpandAll = false;
                    this.showCollapseAll = true;
                }
                else
                {
                    this.showExpandAll = true;
                    this.showCollapseAll = true;
                }
            }
            else
            {
                this.showExpandAll = true;
                this.showCollapseAll = false;
            }
        }

        if(name == 'expand')
        {
            for(let key=0; key<this.priceData.length;key++)
            {
                this.priceData[key].showSectionData = true;
                this.sectionOpenMap.set(parseInt(key),this.priceData[key].showSectionData);
            }
            this.showExpandAll = false;
            this.showCollapseAll = true;
        }

        if(name == 'collapse')
        {
            for(let key=0; key<this.priceData.length;key++)
            {
                this.priceData[key].showSectionData = false;
                this.sectionOpenMap.set(parseInt(key),this.priceData[key].showSectionData);
            }
            this.showExpandAll = true;
            this.showCollapseAll = false;
        }

        this.loadSpinner(false,'');
     }

    loadSpinner(load, msg)
     {
         if(load)
         {
             this.spinnerLoad = true;
             this.spinnerMessage = msg;
         }
         else
             this.spinnerLoad = false;
     }

    showToast(type,msgtitle,msg)
    {
        const evt = new ShowToastEvent({
            title: msgtitle,
            message: msg,
            variant: type,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    //Method Declaration ends here
}