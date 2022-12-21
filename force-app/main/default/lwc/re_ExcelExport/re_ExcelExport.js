import { LightningElement, api } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/xlsx";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Re_ExcelExport extends LightningElement {
    @api headerList;    //Header Row list for excel
    @api filename;      //Final file name for excel
    @api worksheetNameList; //Names of sheets in an excel
    @api sheetData;     //Data to be shown in excel
    @api headerListObj; //In the format {apiName:fieldLabel}
    librariesLoaded = false;

    renderedCallback() {
        if (this.librariesLoaded) return;
        this.librariesLoaded = true;
        Promise.all([loadScript(this, workbook + "/xlsx/xlsx.full.min.js")])
            .then(() => {
                console.log("success in reExcelExport");
            })
            .catch(error => {
                console.log("failure in reExcelExport");
            });
    }

    @api download() {
        try {
            const XLSX = window.XLSX;
            let xlsData = this.sheetData;
            let xlsHeader = this.headerList;
            let ws_name = this.worksheetNameList;
            let createXLSLFormatObj = Array(xlsData.length).fill([]);

            /* form header list */
            xlsHeader.forEach((item, index) => createXLSLFormatObj[index] = [item])

            /* form data key list */
            xlsData.forEach((item,selectedRowIndex)=>{
                let headerApiNames = Object.keys(this.headerListObj);
                let headerLabelNames = Object.values(this.headerListObj);
                item.forEach((value)=>{
                    var innerRowData = [];
                    headerApiNames.forEach(item => {
                        innerRowData.push(value[item]);
                    });
                    createXLSLFormatObj[selectedRowIndex].push(innerRowData);
                });
            });
            
            /* creating new Excel */
            var wb = XLSX.utils.book_new();

            /* creating new worksheet */
            var ws = Array(createXLSLFormatObj.length).fill([]);
            for (let i = 0; i < ws.length; i++) {
                /* converting data to excel format and puhing to worksheet */
                let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
                ws[i] = [...ws[i], data];

                /* Add worksheet to Excel */
                XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
            }

            /* Write Excel and Download */
            XLSX.writeFile(wb, this.filename);
            this.showToastMessage('Download Success', 'Data has been downloaded in excel successfully!', 'success');
        }
        catch (error) {
            console.log(error.message);
            this.showToastMessage('Failed to create Excel', error.message, 'error');
        }
    }

    showToastMessage(title, message, variant) {
        const toast = new ShowToastEvent({
            title   : title,
            message : message,
            variant : variant,
            mode    : 'dismissable'
        });
        this.dispatchEvent(toast);
    }
}