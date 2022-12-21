/**
 * Created by Soumyajit.Jagadev on 17-Apr-20.
 */

import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getPageData from '@salesforce/apex/Rv_BSPD2DApexController.getPageData';

export default class rv_Bspd2dDashboard extends LightningElement {

    //Property Declaration starts here
    @track spinnerDisplay = false;
    @api priceTable = [];
    @api deltaPriceData = [];
    @api today = new Date().toISOString().slice(0, 10);
    @api yesterday = ( (new Date()).getDay() == 1 )
                        ? new Date(new Date().setDate(new Date().getDate()-3)).toISOString().slice(0, 10)
                        : new Date(new Date().setDate(new Date().getDate()-1)).toISOString().slice(0, 10);
    @track viewDeltaBtnDisabled = false;
    @track downloadBtnDisabled = false;
    @track headerTopRow = [   {title: ' ', value: ' ', tabColSpan: 3, tabRowSpan: 2, divClass : "slds-truncate plantColor", thClass : "plantColor firstHeader"}
                            ,{title: 'IGO 50ppm', value: 'IGO 50ppm', tabColSpan: 7, tabRowSpan: 1, divClass : "slds-truncate slds-align_absolute-center igoColor", thClass : "igoColor firstHeader"}
                            ,{title: 'AGO B7', value: 'AGO B7', tabColSpan: 7, tabRowSpan: 1, divClass : "slds-truncate slds-align_absolute-center agoColor", thClass : "agoColor firstHeader"}
                            ,{title: 'ULG95 E10', value: 'ULG95 E10', tabColSpan: 7, tabRowSpan: 1, divClass : "slds-truncate slds-align_absolute-center mogasColor", thClass : "mogasColor firstHeader"}
                          ];
    @track headerMidRow = [   {title: '∆ BSP', value: '∆ BSP', tabColSpan: 6, tabRowSpan: 1, divClass : "slds-truncate slds-align_absolute-center igoColor", thClass : "igoColor secondHeader"}
                            ,{title: '∆ PSP', value: '∆ PSP', tabColSpan: 1, tabRowSpan: 1, divClass : "slds-truncate slds-align_absolute-center igoColor", thClass : "igoColor secondHeader"}
                            ,{title: '∆ BSP', value: '∆ BSP', tabColSpan: 6, tabRowSpan: 1, divClass : "slds-truncate slds-align_absolute-center agoColor", thClass : "agoColor secondHeader"}
                            ,{title: '∆ PSP', value: '∆ PSP', tabColSpan: 1, tabRowSpan: 1, divClass : "slds-truncate slds-align_absolute-center agoColor", thClass : "agoColor secondHeader"}
                            ,{title: '∆ BSP', value: '∆ BSP', tabColSpan: 6, tabRowSpan: 1, divClass : "slds-truncate slds-align_absolute-center mogasColor", thClass : "mogasColor secondHeader"}
                            ,{title: '∆ PSP', value: '∆ PSP', tabColSpan: 1, tabRowSpan: 1, divClass : "slds-truncate slds-align_absolute-center mogasColor", thClass : "mogasColor secondHeader"}
                          ];
    @track headerLastRow = [ {title: 'PLANT', value: 'PLANT', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter plantColor", thClass : "plantColor thirdHeader"}
                            ,{title: 'PLANT CODE', value: 'PLANT CODE', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter plantColor", thClass : "plantColor thirdHeader"}
                            ,{title: 'SALES CHANNEL', value: 'SALES CHANNEL', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter plantColor", thClass : "plantColor thirdHeader"}

                            ,{title: 'Total', value: 'Total', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter igoColor", thClass : "igoColor thirdHeader"}
                            ,{title: 'Hydro Carbon Value (HCV)', value: 'HCV', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter igoColor", thClass : "igoColor thirdHeader"}
                            ,{title: 'Adjusted by Hydro Carbon Value', value: 'Adjusted by HCV', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter igoColor", thClass : "igoColor thirdHeader"}
                            ,{title: 'Thereof CO Steer (Depot + Source Steer)', value: 'Thereof CO Steer (Depot + Source Steer)', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter igoColor", thClass : "igoColor thirdHeader"}
                            ,{title: 'Thereof Bio Steer', value: 'Thereof Bio Steer', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter igoColor", thClass : "igoColor thirdHeader"}
                            ,{title: 'Thereof Freight', value: 'Thereof Freight', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter igoColor", thClass : "igoColor thirdHeader"}
                            ,{title: 'Thereof Target Margin', value: 'Thereof Target Margin', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter igoColor", thClass : "igoColor thirdHeader"}

                            ,{title: 'Total', value: 'Total', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter agoColor", thClass : "agoColor thirdHeader"}
                            ,{title: 'Hydro Carbon Value (HCV)', value: 'HCV', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter agoColor", thClass : "agoColor thirdHeader"}
                            ,{title: 'Adjusted by Hydro Carbon Value', value: 'Adjusted by HCV', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter agoColor", thClass : "agoColor thirdHeader"}
                            ,{title: 'Thereof CO Steer (Depot + Source Steer)', value: 'Thereof CO Steer (Depot + Source Steer)', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter agoColor", thClass : "agoColor thirdHeader"}
                            ,{title: 'Thereof Bio Steer', value: 'Thereof Bio Steer', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter agoColor", thClass : "agoColor thirdHeader"}
                            ,{title: 'Thereof Freight', value: 'Thereof Freight', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter agoColor", thClass : "agoColor thirdHeader"}
                            ,{title: 'Thereof Target Margin', value: 'Thereof Target Margin', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter agoColor", thClass : "agoColor thirdHeader"}

                            ,{title: 'Total', value: 'Total', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter mogasColor", thClass : "mogasColor thirdHeader"}
                            ,{title: 'Hydro Carbon Value (HCV)', value: 'HCV', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter mogasColor", thClass : "mogasColor thirdHeader"}
                            ,{title: 'Adjusted by Hydro Carbon Value', value: 'Adjusted by HCV', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter mogasColor", thClass : "mogasColor thirdHeader"}
                            ,{title: 'Thereof CO Steer (Depot + Source Steer)', value: 'Thereof CO Steer (Depot + Source Steer)', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter mogasColor", thClass : "mogasColor thirdHeader"}
                            ,{title: 'Thereof Bio Steer', value: 'Thereof Bio Steer', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter mogasColor", thClass : "mogasColor thirdHeader"}
                            ,{title: 'Thereof Freight', value: 'Thereof Freight', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter mogasColor", thClass : "mogasColor thirdHeader"}
                            ,{title: 'Thereof Target Margin', value: 'Thereof Target Margin', tabColSpan: 1, tabRowSpan: 1, divClass : "textCenter mogasColor", thClass : "mogasColor thirdHeader"}
                          ];

    @track xlsHeader = []; // store all the headers of the the tables
    @track workSheetNameList = []; // store all the sheets name of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "BSP. D2D Changes.xlsx"; // Name of the Export file
    tranche = 'ATP1';
    salesOrg = 'DE';  //Rahul Sharma | Date - 07-Jan-2021 : Added variable to for Sales Channnel radio button.
    //Property Declaration ends here

    //Init Method Declaration starts here
    connectedCallback() {
                this.getAllPageData();
                this.downloadBtnDisabled = true;
            }
    //Init Method Declaration ends here

    //START - Rahul Sharma | Date - 10-Nov-2020 : Added renderedCallback to identify height of headers and update CSS classes to make them sticky.
    renderedCallback() {
        var head = this.template.querySelector('.head1');
        if(head){
            var head2Height = head.getBoundingClientRect().height;
            var head3Height = (2 * head2Height);
            this.template.host.style.setProperty('--second-head-top',  head2Height + 'px');
            this.template.host.style.setProperty('--third-head-top', head3Height + 'px');
        }
    }
    //END - Rahul Sharma | Date - 10-Nov-2020 : Added renderedCallback to identify height of headers and update CSS classes to make them sticky.

    //START - Rahul Sharma | Date - 19-Nov-2020 : Added getter to show tranche values in lightning combo box.
    get trancheList(){
        return [
            { label: 'Tranche 1', value: 'ATP1' },
            { label: 'Tranche 2', value: 'ATP2' },
            { label: 'Tranche 3', value: 'ATP3' },
        ];
    }
    //END - Rahul Sharma | Date - 19-Nov-2020 : Added getter to show tranche values in lightning combo box.
    //START - Rahul Sharma | Date - 07-Jan-2021 : Added getter to show sales channels.
    get salesOrgs(){
        return [
            { label: 'DE', value: 'DE' },
            { label: 'AT', value: 'AT' },
        ];
    }
    //END - Rahul Sharma | Date - 07-Jan-2021 : Added getter to show sales channels.

    //Method Declaration starts here
    getAllPageData(){
        this.spinnerDisplay = !this.spinnerDisplay;
        this.downloadBtnDisabled = true;
        if(this.salesOrg == 'DE'){
            this.headerTopRow[3].title = 'ULG95 E10';
            this.headerTopRow[3].value = 'ULG95 E10';
        }
        else if(this.salesOrg == 'AT'){
            this.headerTopRow[3].title = 'ULG95 E5';
            this.headerTopRow[3].value = 'ULG95 E5';
        }
        getPageData( {yDayInput: this.yesterday,
                      tDayInput: this.today,
                      tranche: this.tranche,    //Rahul Sharma | Date - 25-Nov-2020 : Added addtional parameter to filter D2D changes based on tranche.
                      salesChannel: this.salesOrg}  //Rahul Sharma | Date - 07-Jan-2021 : Added addtional parameter to filter D2D changes based on sales channel.   
                      )
                .then(result => {
                    this.priceTable = result.priceTable;
                    if(this.priceTable != undefined)
                        this.setPriceData(this.priceTable);
                    this.setExportGrid();
                    this.spinnerDisplay = !this.spinnerDisplay;
                    if(!result.responseStatus)
                        this.showToast('error','Data Error',result.error);
                })
                .catch(error => {
                    this.showToast('error','Page Error','Something went wrong. Please try again later!');
                    this.spinnerDisplay = !this.spinnerDisplay;
                });
    }

    setPriceCol(title,value,divClass,tdClass)
    {
        let dataRow = [];
        dataRow.title = title;
        dataRow.value = value;
        dataRow.divClass = divClass;
        dataRow.tdClass = tdClass;
        return dataRow;
    }

    setPriceData(priceData)
    {
        const titleTday = 'Day 2 = ';
        const titleYday = 'Day 1 = ';
        const titleSeprator = '\n';

        try{
            let priceRow = [];

            if(priceData != undefined && priceData!='')
            {
                 for(let i = 0; i < priceData.length; i++)
                 {
                     let record = priceData[i];
                     let row = [];

                            let rowCol = [];
                            let rowleft = [];//Lakshmi-changes
                            rowleft.push(this.setPriceCol(record.plantName, record.plantName,'slds-truncate','plantColor'));
                            rowleft.push(this.setPriceCol(record.plantCode, record.plantCode,'slds-truncate','plantColor'));
                            rowleft.push(this.setPriceCol(record.salesOrg, record.salesOrg,'slds-truncate','plantColor'));
                            //lakshmi-changes-ends
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.totalIGO.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.totalIGO.toFixed(2)
                                                          , record.deltaPrice.totalIGO.toFixed(2),'slds-truncate','igoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspIGO.hcv.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspIGO.hcv.toFixed(2)
                                                           , record.deltaPrice.bspIGO.hcv.toFixed(2),'slds-truncate','igoColor'));
                            rowCol.push(this.setPriceCol('+[' + record.deltaPrice.totalIGO.toFixed(2) + '] - [' + record.deltaPrice.bspIGO.hcv.toFixed(2) + ']'
                                                           , (record.deltaPrice.totalIGO - record.deltaPrice.bspIGO.hcv).toFixed(2),'slds-truncate','igoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspIGO.coSteer.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspIGO.coSteer.toFixed(2)
                                                           , record.deltaPrice.bspIGO.coSteer.toFixed(2),'slds-truncate','igoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspIGO.bioSteer.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspIGO.bioSteer.toFixed(2)
                                                            , record.deltaPrice.bspIGO.bioSteer.toFixed(2),'slds-truncate','igoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspIGO.freight.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspIGO.freight.toFixed(2)
                                                            , record.deltaPrice.bspIGO.freight.toFixed(2),'slds-truncate','igoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.pspIGO.margin.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.pspIGO.margin.toFixed(2)
                                                            , record.deltaPrice.pspIGO.margin.toFixed(2),'slds-truncate','igoColor'));

                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.totalAGO.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.totalAGO.toFixed(2)
                                                          , record.deltaPrice.totalAGO.toFixed(2),'slds-truncate','agoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspAGO.hcv.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspAGO.hcv.toFixed(2)
                                                           , record.deltaPrice.bspAGO.hcv.toFixed(2),'slds-truncate','agoColor'));
                            rowCol.push(this.setPriceCol('+[' + record.deltaPrice.totalAGO.toFixed(2) + '] - [' + record.deltaPrice.bspAGO.hcv.toFixed(2) + ']'
                                                           , (record.deltaPrice.totalAGO - record.deltaPrice.bspAGO.hcv).toFixed(2),'slds-truncate','agoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspAGO.coSteer.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspAGO.coSteer.toFixed(2)
                                                           , record.deltaPrice.bspAGO.coSteer.toFixed(2),'slds-truncate','agoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspAGO.bioSteer.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspAGO.bioSteer.toFixed(2)
                                                            , record.deltaPrice.bspAGO.bioSteer.toFixed(2),'slds-truncate','agoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspAGO.freight.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspAGO.freight.toFixed(2)
                                                            , record.deltaPrice.bspAGO.freight.toFixed(2),'slds-truncate','agoColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.pspAGO.margin.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.pspAGO.margin.toFixed(2)
                                                            , record.deltaPrice.pspAGO.margin.toFixed(2),'slds-truncate','agoColor'));

                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.totalMOGAS.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.totalMOGAS.toFixed(2)
                                                          , record.deltaPrice.totalMOGAS.toFixed(2),'slds-truncate','mogasColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspMOGAS.hcv.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspMOGAS.hcv.toFixed(2)
                                                           , record.deltaPrice.bspMOGAS.hcv.toFixed(2),'slds-truncate','mogasColor'));
                            rowCol.push(this.setPriceCol('+[' + record.deltaPrice.totalMOGAS.toFixed(2) + '] - [' + record.deltaPrice.bspMOGAS.hcv.toFixed(2) + ']'
                                                           , (record.deltaPrice.totalMOGAS.toFixed(2) - record.deltaPrice.bspMOGAS.hcv).toFixed(2),'slds-truncate','mogasColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspMOGAS.coSteer.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspMOGAS.coSteer.toFixed(2)
                                                           , record.deltaPrice.bspMOGAS.coSteer.toFixed(2),'slds-truncate','mogasColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspMOGAS.bioSteer.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspMOGAS.bioSteer.toFixed(2)
                                                            , record.deltaPrice.bspMOGAS.bioSteer.toFixed(2),'slds-truncate','mogasColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.bspMOGAS.freight.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.bspMOGAS.freight.toFixed(2)
                                                            , record.deltaPrice.bspMOGAS.freight.toFixed(2),'slds-truncate','mogasColor'));
                            rowCol.push(this.setPriceCol(titleTday + record.tDayPrice.pspMOGAS.margin.toFixed(2) + titleSeprator + titleYday + record.yDayPrice.pspMOGAS.margin.toFixed(2)
                                                            , record.deltaPrice.pspMOGAS.margin.toFixed(2),'slds-truncate','mogasColor'));

                    row.rowKey = record.rowKey;
                    row.rowCol = rowCol;
                    row.rowleft = rowleft;//lakshmi-changes
                    priceRow.push(row);
                 }
            }

            if(priceRow != undefined && priceRow!='')
                this.deltaPriceData = priceRow;
        }
        catch(err)
        {console.log(err.message);}
    }

    dateChangeSearch()
    {
        this.priceTable = [];
        this.deltaPriceData = [];
        this.getAllPageData();
    }

    dateChange(event)
    {
        if( event.target.name == 'Yesterday' )
        {
            let yDay = event.target.value;
            this.viewDeltaBtnDisabled = true;
            //START - Rahul Sharma | Date - 07-Jan-21 : Fixed incorrect error message.
            if(yDay == this.today)
                this.showToast('error','Input Validation Error','Day 1 must be earlier than today');
            if(yDay > this.today)
                this.showToast('error','Input Validation Error','Day 1 cannot be a future date');
            //END - Rahul Sharma | Date - 07-Jan-21 : Fixed incorrect error message.
            else
            {
                this.yesterday = yDay;
                this.viewDeltaBtnDisabled = false;
            }
        }
        if( event.target.name == 'Today' )
        {
            let tDay = event.target.value;
            this.viewDeltaBtnDisabled = true;

            let tDayActual = new Date().toISOString().slice(0, 10);
            if(tDay <= this.yesterday)
                this.showToast('error','Input Validation Error','Day 2 must be greater than Day 1');
            else if(tDay > tDayActual)
                this.showToast('error','Input Validation Error','Day 2 cannot be a future date');
            else
            {
                this.today = tDay;
                this.viewDeltaBtnDisabled = false;
            }
        }
    }

    setExportGrid()
    {
        try{
            this.xlsHeader = [];
            this.workSheetNameList = [];
            this.xlsData = [];

            //headerTopRow
            let header = [];
            for(let i = 0; i < this.headerTopRow.length; i++)
            {
                for(let j = 0; j < this.headerTopRow[i].tabColSpan; j++)
                {
                    if(i >= 1 && j>0)
                        header.push('---');
                    else
                        header.push(this.headerTopRow[i].title);
                }
            }
            this.xlsHeader.push(header);

            this.workSheetNameList.push('Delta of '+this.today+'~'+this.yesterday);

            let data = [];

            //headerMidRow
            let headerMid = []
            for(let i = 0; i < 3; i++)
                headerMid.push(' ');
            for(let i = 0; i < this.headerMidRow.length; i++)
            {
                for(let j = 0; j < this.headerMidRow[i].tabColSpan; j++)
                {
                    if(i%2==0 && j>0)
                        headerMid.push('---');
                    else
                        headerMid.push(this.headerMidRow[i].title);
                }
            }
            data.push(headerMid);

            //headerLastRow
            let headerLast = []
            for(let i = 0; i < this.headerLastRow.length; i++)
                headerLast.push(this.headerLastRow[i].title);
            data.push(headerLast);

            //dataRows
            if(this.deltaPriceData != undefined && this.deltaPriceData!='')
            {
                for(let i = 0; i < this.deltaPriceData.length; i++)
                {
                    //lakshmi-changes
                    if(this.deltaPriceData[i].rowCol != undefined && this.deltaPriceData[i].rowCol != ''
                       && this.deltaPriceData[i].rowleft != undefined && this.deltaPriceData[i].rowleft != '')
                    {
                           let tempRow = [];
                          //lakshmi-changes
                        for(let j = 0; j < this.deltaPriceData[i].rowleft.length; j++)
                            tempRow.push(this.deltaPriceData[i].rowleft[j].value);
                        for(let j = 0; j < this.deltaPriceData[i].rowCol.length; j++)
                            tempRow.push(this.deltaPriceData[i].rowCol[j].value);

                        if(tempRow != '')
                            data.push(tempRow);
                    }
                }
                this.downloadBtnDisabled = false;
            }
            else
                this.downloadBtnDisabled = true;

            this.xlsData.push(data);

        }
        catch(err)
        {
            console.log(err.message);
            //this.showToast('error','Export Setting Error',err.message);
        }
    }

    exportPage()
    {
        if(this.xlsData.length>0)
        {
            this.template.querySelector("c-rv_-excel-export").download();
            this.showToast('success','Download Initiated',this.filename + ' file will be exported');
        }
        else
            this.showToast('error','Download Error','Excel Download Failed. Please try again later!');
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
    
    /*Method Name : updateTranche
     *Date        : 25-Nov-2020
     *Developer   : Rahul Sharma
     *Description : Updated tranche variable on change of drop-down. 
     */
    updateTranche(event){
        this.tranche = event.detail.value;
    }

    /*Method Name : updateSalesChannel
     *Date        : 07-Jan-2021
     *Developer   : Rahul Sharma
     *Description : Update sales channel seleccted on change of radio button. 
     */
    updateSalesOrg(event){
        this.salesOrg = event.detail.value;
    }
    //Method Declaration ends here
}