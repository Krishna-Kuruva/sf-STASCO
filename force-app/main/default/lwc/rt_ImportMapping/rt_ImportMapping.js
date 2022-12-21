/**
 * Created by Soumyajit.Jagadev on 15-Jun-20.
 */

import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getObjectListApex from '@salesforce/apex/RT_CreateImportMap.getObjectList';
import getRecordTypeListApex from '@salesforce/apex/RT_CreateImportMap.getRecordTypeList';
import getApexListApex from '@salesforce/apex/RT_CreateImportMap.getApexList';
import getFieldListApex from '@salesforce/apex/RT_CreateImportMap.getFieldList';
import viewImportMappingApex from '@salesforce/apex/RT_CreateImportMap.viewImportMapping';
import delImportMappingApex from '@salesforce/apex/RT_CreateImportMap.delImportMapping';
import saveImportMappingApex from '@salesforce/apex/RT_CreateImportMap.saveImportMapping';

export default class RtImportMapping extends LightningElement {

    //Property Declaration starts here
    @api appName = '';
    @api mode = 'CREATE';
    @api mappingTypeId = '';
    @api isAdmin = false;
    @api cloneList = [];
    @api cloneImportList = [];

    @track showCreateType = false;
    @track selectedCloneType = '--None--';
    @track showCreateClone = false;
    @track showMapFileUploader = false;
    mapFileUploaded = [];
    @track mapFileSelected = false;
    @track mapFileName = '';

    @track showEditBtn = false;
    @track showDelBtn = false;
    @track showSaveBtn = false;
    @track showCancelBtn = false;
    @track showExample = false;

    @track showObjectBtns = false;
    @track showObject = false;
    @track mappingInputDisabled = false;
    @track mappingName = '';
    @track mappingDescription = '';
    @track objectAPIname = '';
    @track objectList = [];
    objectMap = new Map();
    @track selectedObject = '';

    @track hasRecordType = false;
    @track selectedRecordType = '';
    @track recTypeList = [];

    @track considerToday = false;

    @track hasCustomLogic = false;
    @track apexList = [];
    @track selectedApexName = '';
    @track apexMethodName = '';

    @track showFields = false;
    @track fieldInputDisabled = false;
    @track tabRowIndex = 0;
    @track typeMapList = [];
    @track fieldList = [];
    fieldMap = new Map();
    refObjectMap = new Map();
    refObjFieldMap = new Map();
    refFieldMap = new Map();
    isDateFieldLst = [];
    isDateTimeFieldLst = [];
    isBooleanFieldLst = [];

    @track spinnerLoad = false;
    @track spinnerMessage = '';

    @track classExample = 'public class [ClassName] implements Callable {'+'\n'
                          +'     public Object call(String action, Map<String, Object> args) {'+'\n'
                          +'         switch on action {'+'\n'
                          +'            when \'[MethodName]\' {return this.[MethodName]((RT_ImportFiles.fileWrapper)args.get(\'[MethodName]\'));}'+'\n'
                          +'            when else {throw new ExtensionMalformedCallException(\'Method not implemented\');}'+'\n'
                          +'      }}'+'\n'
                          +'      public class ExtensionMalformedCallException extends Exception {}'+'\n'
                          +'      public RT_ImportFiles.resultFileWrapper [MethodName] (RT_ImportFiles.fileWrapper inputFileWrapper) {'+'\n'
                          +'         ***************Custom Logic To Be Added Here***************' +'\n'
                          +'         return new RT_ImportFiles.resultFileWrapper();' +'\n'
                          +'      }' +'\n' + '}';
    //Property Declaration ends here

    //Init Method Declaration starts here
    connectedCallback() {
        this.setMode();
    }
    //Init Method Declaration ends here

    //Method Declaration starts here
    setMode()
    {
        if(this.mode != '' && this.mode != undefined)
        {
            if(this.mode == 'VIEW')
            {
                if(this.mappingTypeId != '' && this.mappingTypeId != undefined)
                {
                    this.showEditBtn = false;
                    this.showDelBtn = false;
                    this.showSaveBtn = false;
                    this.showObjectBtns = false;

                    this.mappingInputDisabled = true;
                    this.fieldInputDisabled = true;

                    if(this.mappingTypeId != '' && this.mappingTypeId != undefined)
                        this.viewImportMapping('VIEW',this.mappingTypeId);
                }
                else
                    this.showToast('error','Page Init Error','Mapping Type ID is missing');
            }
            else if(this.mode == 'VIEWEDIT')
            {
                if(this.mappingTypeId != '' && this.mappingTypeId != undefined)
                {
                    this.showEditBtn = true;
                    this.showDelBtn = true;
                    this.showSaveBtn = false;
                    this.showObjectBtns = false;

                    this.mappingInputDisabled = true;
                    this.fieldInputDisabled = true;

                    if(this.mappingTypeId != '' && this.mappingTypeId != undefined)
                        this.viewImportMapping('VIEW',this.mappingTypeId);
                }
                else
                    this.showToast('error','Page Init Error','Mapping Type ID is missing');
            }
            else if (this.mode == 'CREATE')
            {
                this.showSaveBtn = true;
                this.showCancelBtn = true;

                this.showObjectBtns = true;
                this.resetObjDisabled = true;

                this.showCreateType = true;
            }
        }
    }

    createFromFile()
    {
        this.showMapFileUploader = true;
    }

    handleMapFileChange(event)
    {
        if(event.target.files.length > 0)
        {
            this.mapFileUploaded = event.target.files;
            this.mapFileName = event.target.files[0].name;
            this.mapFileSelected = true;
        }
    }

    handleMapFileSave()
    {
        if(this.mapFileName.endsWith('.json'))
        {
            if(this.mapFileUploaded.length > 0)
            {
                this.loadSpinner(true,'Mapping File Upload In Progress');

                let file = this.mapFileUploaded[0];
                let fileReader = new FileReader();

                console.log(this.mapFileUploaded);
                fileReader.onload = ((e) => {
                    let mapFileContents = e.target.result;
                    var jsonContent = JSON.parse(mapFileContents);
                    if(jsonContent != '' && jsonContent != undefined)
                    {
                        this.setMappingContent(jsonContent,'FILE');
                        this.showCreateType = false;
                    }
                    else
                        this.loadSpinner(false,'');
                  });
                 fileReader.readAsText(file);
            }
            else
                this.showToast('error','Mapping File Upload Failure','Please Select A File to Upload');
        }
        else
            this.showToast('error','Mapping File Upload Failure','Not A Valid Mapping File');
    }

    createNew()
    {
        this.viewObject();
        this.showCreateType = false;
    }

    createClone()
    {
        if(this.selectedCloneType != '--None--' && this.selectedCloneType != '' && this.selectedCloneType!= undefined)
        {
            let mapTypeID = '';
            for(let i = 0; i < this.cloneImportList.length; i++)
            {
                if(this.cloneImportList[i].Name == this.selectedCloneType)
                {
                    mapTypeID = this.cloneImportList[i].TypeID;
                }
            }
            if(mapTypeID !='' && mapTypeID!= undefined)
            {
                this.viewImportMapping('CLONE',mapTypeID);
                this.showCreateType = false;
            }
        }
    }

    viewImportMapping(viewType, typeID)
    {
        this.loadSpinner(true,'Fetching Mapping Details');

        viewImportMappingApex( { TypeID : typeID} )
        .then(result => {
            this.setMappingContent(result,viewType);
        })
        .catch(error => {
            this.showToast('error','Mapping Details Fetch Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    setMappingContent(wrapper,setType)
    {
            this.mappingName = wrapper.Name;
            this.mappingDescription = wrapper.Description;
            this.selectedObject = wrapper.ObjectAPIName;
            this.objectAPIname = wrapper.ObjectAPIName;
            this.selectedRecordType = wrapper.RecordTypeFilter;
            if(this.selectedRecordType != '' && this.selectedRecordType != undefined)
                this.hasRecordType = true;
            else
                this.hasRecordType = false;
            this.hasCustomLogic = wrapper.HasCustomLogic;
            this.considerToday = wrapper.ConsiderToday;
            this.selectedApexName = wrapper.ApexClassName;
            this.typeMapList = wrapper.FieldMap;

            this.viewObject();

            if(setType == 'CLONE')
            {
                this.mappingTypeId = '';
                this.mappingName += ' Copy';
            }

            if(setType == 'FILE')
            {
                this.mappingTypeId = '';
            }

            this.loadSpinner(false,'');
    }

    getObjectList()
    {
        this.loadSpinner(true,'Fetching Object(s)');
        this.objectList = [];

        let searchType = '';
        if(this.showSaveBtn)
            searchType = 'ALL';
        else
            searchType = 'THIS';

        getObjectListApex({ SearchType : searchType, ObjName : this.selectedObject})
        .then(result => {
            this.objectList = result;
            for(let i=0;i<this.objectList.length;i++)
                this.objectMap.set(this.objectList[i].value,this.objectList[i].label);
            this.loadSpinner(false,'');

            if(this.hasCustomLogic)
                this.getApexList();

            if(this.hasRecordType)
                this.getRecordTypeList();
        })
        .catch(error => {
            this.showToast('error','Object Fetch Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    getRecordTypeList()
    {
        this.loadSpinner(true,'Fetching RecordType(s)');
        this.recTypeList = [];
        this.hasRecordType = false;

        getRecordTypeListApex({ ObjName : this.selectedObject})
        .then(result => {
            this.recTypeList = result;

            if(this.recTypeList != '' && this.recTypeList != undefined)
            {
                if(this.recTypeList.length >0 )
                    this.hasRecordType = true;
            }

            this.loadSpinner(false,'');
        })
        .catch(error => {
            this.showToast('error','Record Type Fetch Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    getApexList()
    {
        this.loadSpinner(true,'Fetching Apex Class(s)');
        this.apexList = [];

        let searchType = '';
        if(this.showSaveBtn)
            searchType = 'ALL';
        else
            searchType = 'THIS';

        getApexListApex({ SearchType : searchType, ApexName : this.selectedApexName})
        .then(result => {
            this.apexList = result;
            this.loadSpinner(false,'');
        })
        .catch(error => {
            this.showToast('error','Apex Class Fetch Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    getFieldList(searchObj)
    {
        this.loadSpinner(true,'Fetching Fields');
        this.fieldList = [];
        this.isDateFieldLst = [];
        this.isDateTimeFieldLst = [];
        this.isBooleanFieldLst = [];

        getFieldListApex( { ObjName : searchObj} )
        .then(result => {
            if(result != undefined && result != '')
            {
                for(let i=0;i<result.length;i++)
                {
                    const fldOption = {label: result[i].label,value: result[i].value};
                    this.fieldList = [ ...this.fieldList, fldOption ];
                    this.fieldMap.set(result[i].value,result[i].label);

                    if(result[i].refObjValue != '' && result[i].refObjValue != undefined)
                    {
                        const refObjOption = {label: result[i].refObjlabel,value: result[i].refObjValue};
                        this.refObjectMap.set(result[i].value,refObjOption);
                        this.refObjFieldMap.set(result[i].refObjValue,result[i].refFldLst);
                    }

                    if(result[i].isDate)
                        this.isDateFieldLst.push(result[i].value);
                    if(result[i].isDateTime)
                        this.isDateTimeFieldLst.push(result[i].value);
                    if(result[i].isBoolean)
                        this.isBooleanFieldLst.push(result[i].value);
                }

                if(this.typeMapList !='' && this.typeMapList != undefined)
                {
                    for(let key=0; key<this.typeMapList.length; key++)
                    {
                        let fieldValue = this.typeMapList[key].FieldAPIName;
                        if(this.refObjectMap.has(fieldValue))
                        {
                            if(this.refObjFieldMap.has(this.refObjectMap.get(fieldValue).value))
                                this.typeMapList[key].ReferenceToFieldList = this.refObjFieldMap.get(this.refObjectMap.get(fieldValue).value);
                        }
                    }
                }
            }

            this.loadSpinner(false,'');
        })
        .catch(error => {
            this.showToast('error','Field Fetch Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    setDropSelection(event)
    {
        let dropType = event.target.name;

        if(dropType == 'setCloneType')
        {
            this.selectedCloneType = event.detail.value;
            if(this.selectedCloneType != '--None--' && this.selectedCloneType != '' && this.selectedCloneType!= undefined)
                this.showCreateClone = true;
            else
                this.showCreateClone = false;
        }

        if(dropType == 'objSelect')
        {
            this.selectedObject = event.detail.value;
            this.objectAPIname = this.selectedObject;
            this.selectedRecordType = '';
            this.getRecordTypeList();
        }

        if(dropType == 'recTypeSelect')
        {
            this.selectedRecordType = event.detail.value;
        }

        if(dropType == 'apexSelect')
        {
            this.selectedApexName = event.detail.value;
        }

        if(dropType == 'fieldSelect')
        {
            this.loadSpinner(true,'');
            var selectedRow = event.currentTarget;
            var key = selectedRow.dataset.id;
            var fieldValue = event.detail.value;
            this.typeMapList[key].FieldName = this.fieldMap.get(fieldValue);
            this.typeMapList[key].FieldAPIName = fieldValue;

            this.typeMapList[key].isDate = false;
            this.typeMapList[key].isDateTime = false;
            this.typeMapList[key].isBoolean = false;

            if(this.isDateFieldLst.includes(fieldValue))
                this.typeMapList[key].isDate = true;
            if(this.isDateTimeFieldLst.includes(fieldValue))
                this.typeMapList[key].isDateTime = true;
            if(this.isBooleanFieldLst.includes(fieldValue))
                this.typeMapList[key].isBoolean = true;

            if(this.refObjectMap.has(fieldValue))
            {
                this.typeMapList[key].HasReference = true;
                this.typeMapList[key].ReferenceTo = this.refObjectMap.get(fieldValue).label;
                this.typeMapList[key].ReferenceToAPIName = this.refObjectMap.get(fieldValue).value;

                this.typeMapList[key].ReferenceToFieldList = [];
                if(this.refObjFieldMap.has(this.refObjectMap.get(fieldValue).value))
                {
                    this.typeMapList[key].ReferenceToFieldList = this.refObjFieldMap.get(this.refObjectMap.get(fieldValue).value);

                    let tempFldMap = new Map();
                    for(let i = 0; i<  this.refObjFieldMap.get(this.refObjectMap.get(fieldValue).value).length;i++)
                        tempFldMap.set( this.refObjFieldMap.get(this.refObjectMap.get(fieldValue).value)[i].value
                                       ,this.refObjFieldMap.get(this.refObjectMap.get(fieldValue).value)[i].label );

                    this.refFieldMap.set(this.refObjectMap.get(fieldValue).value,tempFldMap);
                }
            }
            else
            {
                this.typeMapList[key].HasReference = false;
                this.typeMapList[key].ReferenceTo = '';
                this.typeMapList[key].ReferenceToAPIName = '';
                this.typeMapList[key].ReferenceToFieldList = [];
                this.typeMapList[key].ReferenceToFieldName = '';
                this.typeMapList[key].ReferenceToFieldAPIName = '';
            }

            this.loadSpinner(false,'');
        }

        if(dropType == 'refFieldSelect')
        {
            this.loadSpinner(true,'');
            var selectedRow = event.currentTarget;
            var key = selectedRow.dataset.id;
            var fieldValue = event.detail.value;
            this.typeMapList[key].ReferenceToFieldName = this.refFieldMap.get(this.typeMapList[key].ReferenceToAPIName).get(fieldValue);
            this.typeMapList[key].ReferenceToFieldAPIName = fieldValue;

            this.loadSpinner(false,'');
        }
    }

    checkboxChange(event)
    {

        const chkName = event.target.name;
        const chkVal = event.target.checked;

        if(chkName == 'Identifier')
        {
            this.loadSpinner(true,'');
            var selectedRow = event.currentTarget;
            var key = selectedRow.dataset.id;
            this.typeMapList[key].Identifier = chkVal;
            this.loadSpinner(false,'');
        }

        if(chkName == 'IsFixedValue')
        {
            this.loadSpinner(true,'');
            var selectedRow = event.currentTarget;
            var key = selectedRow.dataset.id;
            this.typeMapList[key].IsFixedValue = chkVal;
            if(chkVal)
                this.typeMapList[key].OrderNum = 9999;
            this.loadSpinner(false,'');
        }

        if(chkName == 'hasCustomLogic')
        {
            this.hasCustomLogic = chkVal;
            this.selectedApexName = '';
            if(this.hasCustomLogic)
                this.getApexList();
        }

        if(chkName == 'considerToday')
        {
            this.considerToday = chkVal;
        }
    }

    textFldChange(event)
    {
        const name = event.target.name;
        const val = event.target.value;

        if(val != undefined && val != '')
        {
            if(name == 'mappingName')
            {
                this.mappingName = val;
            }

            if(name == 'mappingDescription')
            {
                this.mappingDescription = val;
            }

            if(name == 'OrderNum')
            {
                this.loadSpinner(true,'');
                var selectedRow = event.currentTarget;
                var key = selectedRow.dataset.id;
                this.typeMapList[key].OrderNum = val;
                this.loadSpinner(false,'');
            }

            if(name == 'SourceCol')
            {
                this.loadSpinner(true,'');
                var selectedRow = event.currentTarget;
                var key = selectedRow.dataset.id;
                this.typeMapList[key].SourceCol = val;
                this.loadSpinner(false,'');
            }

            if(name == 'apexMethodName')
            {
                this.apexMethodName = val;
            }
        }
    }

    viewExample()
    {
        this.showExample = true;
    }

    hideExample()
    {
        this.showExample = false;
    }

    viewObject()
    {
        this.showObject = true;
        this.getObjectList();
    }

    hideObject()
    {
        this.showObject = false;
    }

    viewFields()
    {
        if(this.validateObjDefinition())
        {
            this.hideObject();
            this.showFields = true;
            this.getFieldList(this.selectedObject);
        }
    }

    hideFields()
    {
        this.showFields = false;
        this.viewObject();
    }

    confirmObject()
    {
        if(this.validateObjDefinition())
        {
            this.mappingInputDisabled = true;
            this.viewFields();
        }
    }

    resetObject()
    {
        this.mappingInputDisabled = false;
        this.tabRowIndex = 0;

        if(!(this.mappingTypeId != '' && this.mappingTypeId != undefined))
           this.typeMapList = [];

        this.viewObject();
        this.showFields = false;
    }

    setBlankTypeMapRow()
    {
        let row = [];
        row.mapNum = this.tabRowIndex;
        row.OrderNum = 1;
        row.IsFixedValue = false;
        row.SourceCol = '';
        row.Identifier = false;
        row.FieldName = '';
        row.FieldAPIName = '';
        return row;
    }

    addRow(event)
    {
        var buttonName = event.target.dataset.name;
        this.loadSpinner(true,'');

        if(buttonName == 'fieldAdd')
        {
            this.tabRowIndex ++;
            this.typeMapList.push(this.setBlankTypeMapRow());
        }

        this.loadSpinner(false,'');
    }

    removeRow(event)
    {
        var buttonName = event.target.dataset.name;
        this.loadSpinner(true,'');

        if(buttonName == 'fieldRemove')
        {
            var selectedRow = event.currentTarget;
            var key = selectedRow.dataset.id;
            if(this.typeMapList.length>1)
            {
                this.typeMapList.splice(key, 1);
                this.tabRowIndex --;
            }
            else if(this.typeMapList.length == 1)
            {
                this.showToast('error','Field Map Error','One Field Mapping is Required');
            }
        }

        this.loadSpinner(false,'');
    }

    editMap()
    {
        this.showEditBtn = false;
        this.showDelBtn = false;
        this.showSaveBtn = true;
        this.showObjectBtns = true;

        this.mappingInputDisabled = false;
        this.fieldInputDisabled = false;

        if(this.showFields)
        {
            this.viewFields();
        }
        else
            this.viewObject();
    }

    saveMap()
    {

        if(!this.validateObjDefinition() || !this.validateFldDefinition())
            return;

        let importTypeWrap = {};
        importTypeWrap.TypeID = (this.mappingTypeId != '' && this.mappingTypeId != undefined)? this.mappingTypeId : '';
        importTypeWrap.Name = (this.mappingName != '' && this.mappingName != undefined)? this.mappingName : '';
        importTypeWrap.Description = (this.mappingDescription != '' && this.mappingDescription != undefined)? this.mappingDescription : '';
        importTypeWrap.ObjectName = (this.selectedObject != '' && this.selectedObject != undefined)? this.objectMap.get(this.selectedObject) : '';
        importTypeWrap.ObjectAPIName = (this.objectAPIname != '' && this.objectAPIname != undefined)? this.objectAPIname : '';
        importTypeWrap.RecordTypeFilter = (this.selectedRecordType != '' && this.selectedRecordType != undefined)? this.selectedRecordType : '';
        importTypeWrap.HasCustomLogic = this.hasCustomLogic;
        importTypeWrap.ConsiderToday = this.considerToday;
        importTypeWrap.ApexClassName = (this.selectedApexName != '' && this.selectedApexName != undefined)? this.selectedApexName : '';
        importTypeWrap.ApexClassMethodName = (this.apexMethodName != '' && this.apexMethodName != undefined)? this.apexMethodName : '';
        importTypeWrap.FieldMap = [];

        for(let i=0; i< this.typeMapList.length;i++)
        {
            let fldWrap = {};
            let typeMap = this.typeMapList[i];

            fldWrap.mapNum = (typeMap.mapNum != '' && typeMap.mapNum != undefined)? typeMap.mapNum : 0;
            fldWrap.OrderNum = (typeMap.OrderNum != '' && typeMap.OrderNum != undefined)? typeMap.OrderNum : 1;
            fldWrap.SourceCol = (typeMap.SourceCol != '' && typeMap.SourceCol != undefined)? typeMap.SourceCol : '';
            fldWrap.Identifier = (typeMap.Identifier != '' && typeMap.Identifier != undefined)? typeMap.Identifier : false;
            fldWrap.IsFixedValue = (typeMap.IsFixedValue != '' && typeMap.IsFixedValue != undefined)? typeMap.IsFixedValue : false;
            fldWrap.FieldName = (typeMap.FieldName != '' && typeMap.FieldName != undefined)? typeMap.FieldName : '';
            fldWrap.FieldAPIName = (typeMap.FieldAPIName != '' && typeMap.FieldAPIName != undefined)? typeMap.FieldAPIName : '';
            fldWrap.HasReference = (typeMap.HasReference != '' && typeMap.HasReference != undefined)? typeMap.HasReference : false;
            fldWrap.ReferenceTo = (typeMap.ReferenceTo != '' && typeMap.ReferenceTo != undefined)? typeMap.ReferenceTo : '';
            fldWrap.ReferenceToAPIName = (typeMap.ReferenceToAPIName != '' && typeMap.ReferenceToAPIName != undefined)? typeMap.ReferenceToAPIName : '';
            fldWrap.ReferenceToFieldName = (typeMap.ReferenceToFieldName != '' && typeMap.ReferenceToFieldName != undefined)? typeMap.ReferenceToFieldName : '';
            fldWrap.ReferenceToFieldAPIName = (typeMap.ReferenceToFieldAPIName != '' && typeMap.ReferenceToFieldAPIName != undefined)? typeMap.ReferenceToFieldAPIName : '';
            importTypeWrap.FieldMap.push(fldWrap);
        }

        this.loadSpinner(true,'Saving Mapping');

        saveImportMappingApex( { inputWrap : JSON.stringify(importTypeWrap)
                                , AppName : this.appName
                               } )
        .then(result => {
            if(result)
             {
                 this.showToast('success','Success','Mapping has been Saved');
                 this.loadSpinner(false,'');
                 this.closePopUp();
             }
             else
             {
                 this.showToast('error','Mapping Save Error','Something went wrong. Please try again later!');
                 this.loadSpinner(false,'');
             }
        })
        .catch(error => {
            this.showToast('error','Mapping Save Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    deleteMap()
    {
        this.loadSpinner(true,'Inactivating Mapping');

        delImportMappingApex( { TypeID : this.mappingTypeId} )
        .then(result => {
            this.showToast('success','Success','Mapping has been Inactivated');
            this.loadSpinner(false,'');
            this.closePopUp();
        })
        .catch(error => {
            this.showToast('error','Mapping Delete Error','Something went wrong. Please try again later!');
            this.loadSpinner(false,'');
        });
    }

    validateObjDefinition()
    {
        let status = true;

        if(this.mappingName == '' || this.mappingName == undefined)
        {
            this.showToast('error','Import Type Name Is Required','');
            status = false;
        }
        else if(this.selectedObject == '' || this.selectedObject == undefined)
        {
            this.showToast('error','Mapping Object Is Required','');
            status = false;
        }
        else if(this.hasCustomLogic)
        {
            if(this.selectedApexName == '' || this.selectedApexName == undefined)
            {
                this.showToast('error','Class Name Is Required For Custom Logic','');
                status = false;
            }
            else if(this.apexMethodName == '' || this.apexMethodName == undefined)
            {
                this.showToast('error','Class Method Name Is Required For Custom Logic','');
                status = false;
            }
            else
                status = true;
        }
        else
            status = true;

        return status;
    }

    validateFldDefinition()
    {
        let status = true;

        if(this.typeMapList == '' || this.typeMapList == undefined)
        {
            this.showToast('error','Atleast One Field Mapping Is Required','');
            status = false;
        }

        return status;
    }

    closePopUp()
    {
        this.dispatchEvent(new CustomEvent('close'));
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