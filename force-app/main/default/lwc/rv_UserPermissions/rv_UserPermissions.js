import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getPageDetails from '@salesforce/apex/Rv_UserPermissionsApex.getPageDetails';
import getUserDetails from '@salesforce/apex/Rv_UserPermissionsApex.getUserDetails';
import getUserGrpPermDetails from '@salesforce/apex/Rv_UserPermissionsApex.getUserGrpPermDetails';
import getProfileDetails from '@salesforce/apex/Rv_UserPermissionsApex.getProfileDetails';
import getPermissionDetails from '@salesforce/apex/Rv_UserPermissionsApex.getPermissionDetails';
import getObjectDetails from '@salesforce/apex/Rv_UserPermissionsApex.getObjectDetails';
import getFieldDetails from '@salesforce/apex/Rv_UserPermissionsApex.getFieldDetails';
import getTabDetails from '@salesforce/apex/Rv_UserPermissionsApex.getTabDetails';

export default class Rv_UserPermissions extends LightningElement {
    //Property Declaration starts here
    @api appName = '';
    @api profileFilterLabel = '';
    @api permissionSetFilterLabel = '';
    @api userFilterLabel ='';

    @track pageViewAllowed = false;
    @track showMessage = false;
    @track message ='';

    @api filterList = [];
    @api selectedFilter = '';
    @track filterDisabled = false;

    @track showExportButton = false;
    @track exportButtonLabel = 'Download';

    @track showProfiles = false;
    @track profileList = [];
    @track profileListColumn = [	{ label: 'Name', fieldName: 'Name'},
                                    { label: 'Custom', fieldName: 'Custom', type: 'boolean'}
                                ];
    @track selectedProfileRows = [];
    @track maxProfileListRowSelection = 1;
    @track profileSpinnerLoaded = false;
    @track selectedProfileRow = [];

    @track showPermission = false;
    @track permissionList = [];
    @track permissionListColumn = [	{ label: 'Permission Set Label', fieldName: 'Name'},
                                    { label: 'Description', fieldName: 'Description'}
                                    ];
    @track maxPermissionListRowSelection = 1;
    @track selectedPermissionRows = [];
    @track permitSpinnerLoaded = false;
    @track selectedPermissionRow = [];

    @track showUsers = false;
    @track hasUser = false;
    @track userList = [];
    @track userListColumn = [	{ label: 'Name', fieldName: 'Name'},
                                { label: 'Username', fieldName: 'Username' },
                                { label: 'Email', fieldName: 'Email', type: 'email' },
                                { label: 'Profile', fieldName: 'Profile'}
                          ];
    @track maxUserListRowSelection = 1;
    @track selectedUserRows = [];
    @track hideUserSelectable = false;
    @track userSpinnerLoaded = false;
    @track selectedUserRow = [];
    
    @track userDetailView = false;
    
    @track showUserGrpPermit = false;
    @track hasPermSet = false;
	@track userPermList = [];
    @track userPermListColumn = [	    { label: 'Permission Set Label', fieldName: 'Name'},
                                        { label: 'Description', fieldName: 'Description'}
                                ];
    @track hasGrp = false;
    @track userGrpList = [];
    @track userGrpListColumn = [	{ label: 'Group Name', fieldName: 'Name'}];
    @track permGrpSpinnerLoaded = false;
    
    @track showObjects = false;
    @track objectList = [];
    @track objectListColumn =[	{ label: 'Object Name', fieldName: 'Name'},
                                { label: 'Read', fieldName: 'Read', type: 'boolean' },
                                { label: 'Create', fieldName: 'Create', type: 'boolean' },
                                { label: 'Edit', fieldName: 'Edit', type: 'boolean' },
                             	{ label: 'Delete', fieldName: 'Del', type: 'boolean' },
                             	{ label: 'View All', fieldName: 'ViewAll', type: 'boolean' },
                             	{ label: 'Modify All', fieldName: 'ModifyAll', type: 'boolean' }
                           ];
    @track maxObjectListRowSelection = 1;
    @track selectedObjectRows = [];
    @track objectSpinnerLoaded = false;
    @track selectedObjectRow = [];
    
    @track showFieldPermission = false;
    @track fieldList = [];
    @track fieldListColumn = [	{ label: 'Field Name', fieldName: 'Name'},
                                { label: 'Read', fieldName: 'Read', type: 'boolean' },
                                { label: 'Edit', fieldName: 'Edit', type: 'boolean' },
                                { label: 'System Defined', fieldName: 'SystemControlled', type: 'boolean'}
                           ];
    
    @track fieldSpinnerLoaded = false;

    @track showTabs = false;
    @track tabList = [];
    @track tabListColumn = [	{ label: 'Name', fieldName: 'Name'},
                                { label: 'Description', fieldName: 'Description'},
                                { label: 'Related Object(s)', fieldName: 'RelatedObject'},
                                { label: 'Visible', fieldName: 'Visible', type: 'boolean' }
                           ];
    @track tabSpinnerLoaded = false;
    @track hasTab = false;

    selectedObjectParam1 ="";
    selectedObjectParam2 ="";

    @track xlsHeader = []; // store all the headers of the the tables
    @track workSheetNameList = []; // store all the sheets name of the the tables
    @track xlsData = []; // store all tables data
    @track filename = "User_Permissions.xlsx"; // Name of the Export file
    @track xlsFiltTab = [];
    @track xlsTabHeaders = [];
    @track xlsTabData = [];
    @track xlsTabNames = [];
    //Property Declaration ends here

    //Init Method Declaration starts here
    @wire(getPageDetails)
    wiredGetPageDetails({ error, data }) {
        if (data) {
            this.appName = data.AppName;
            this.pageViewAllowed = data.HasAccess;
            this.profileFilterLabel = data.ProfileFilterLabel;
            this.permissionSetFilterLabel = data.PermissionSetFilterLabel;
            this.userFilterLabel = data.UserFilterLabel;

            this.filterList = [ { value: this.profileFilterLabel, label: this.profileFilterLabel },
                { value: this.permissionSetFilterLabel, label: this.permissionSetFilterLabel },
                { value: this.userFilterLabel, label: this.userFilterLabel }
              ];

            if(!this.pageViewAllowed)
            {
                this.showMessage = true;
                this.message = 'You do not have sufficient permissions to view this page. Please contact System Administrator.';
                this.showToast('error','User Authentication Failure','You do not have sufficient permissions to view this page.');
                this.filterDisabled = true;
            }

        } else if (error) {
            this.showToast('error','User Authentication Failure','You are not allowed to view this page');
            this.filterDisabled = true;
        }
    }

    connectedCallback() {
        //this.fetchDetails();
    }
    //Init Method Declaration ends here

    //Method Declaration starts here
    fetchDetails()
    {
        this.showProfiles = false;
        this.showPermission= false;
        this.showUsers = false;
        this.hideUserSelectable = true;
        this.userDetailView = false;
        this.showMessage = true;
        this.showExportButton = false;
        this.exportButtonLabel = 'Download';

        this.selectedProfileRow = [];
        this.selectedPermissionRow = [];
        this.selectedUserRow = [];
        this.selectedObjectRows = [];
        this.selectedObjectRow = [];
        this.profileList = [];
        this.permissionList = [];
        this.userList = [];
        this.userPermList = [];
        this.userGrpList = [];
        this.objectList = [];
        this.fieldList = [];
        this.hasUser = true;
        this.hasTab = true;
        this.tabList = [];

        if(this.selectedFilter === this.profileFilterLabel)
        {
            this.showProfiles = true;
            this.getProfileList();
            this.message = "Select one Profile to view details";
        }
        
        else if(this.selectedFilter === this.permissionSetFilterLabel)
        {
            this.showPermission= true;
            this.getPermissionList();
            this.message = "Select one Permission to view details";
        }
        
        else if(this.selectedFilter === this.userFilterLabel)
        {
            this.showUsers = true;
            this.hideUserSelectable = false;
            this.getUserList('ALL','','');
            this.message = "Select one User to view details";
        }
        else
        {}
    }

    fetchFilter(event)
    {
        this.selectedFilter = event.detail.value;
        this.fetchDetails();
    }

    viewDetails(event)
    {
        const selectedRow = event.detail.selectedRows;

        this.showUsers = true;
        this.showUserGrpPermit= false;
        this.showMessage = false;
        this.userDetailView = true;
        this.showFieldPermission = false;
        this.showTabs = true;
        this.showObjects = true;
        this.showExportButton = false;
        this.exportButtonLabel = 'Download Selection';

        this.selectedProfileRow = [];
        this.selectedPermissionRow = [];
        this.selectedUserRow = [];
        this.selectedObjectRows = [];
        this.selectedObjectRow = [];
        this.userPermList = [];
        this.userGrpList = [];
        this.objectList = [];
        this.fieldList = [];
        this.hasUser = true;
        this.hasTab = true;
        this.tabList = [];
            
        if(this.selectedFilter === this.profileFilterLabel)
        {    
            if(selectedRow != undefined)
                this.selectedProfileRow = selectedRow[0];
            
            this.userList = [];
            this.selectedUserRows = [];
            this.getUserList('ALL',this.selectedProfileRow.keyID,'');
        }
        
        else if(this.selectedFilter === this.permissionSetFilterLabel)
        {
            if(selectedRow != undefined)
                this.selectedPermissionRow = selectedRow[0];
            
            this.userList = [];
            this.selectedUserRows = [];
            this.getUserList('ALL',this.selectedPermissionRow.keyID,'');
        }
        
        else if(this.selectedFilter === this.userFilterLabel)
        {
            if(selectedRow != undefined)
                this.selectedUserRow = selectedRow[0];

            this.showUserGrpPermit= true;
            this.getUserList('THIS',this.selectedUserRow.keyID,this.selectedUserRow.Profile);
        }
        else
        {}
    }

    viewFieldPermission(event)
    {
         if(this.objectList != undefined && this.objectList != '')
            {        
                this.showFieldPermission = true;
                this.showExportButton = false;
                const selectedObj = event.detail.selectedRows;

                if(selectedObj != undefined && selectedObj != '')
                {
                    if(selectedObj[0] != undefined && selectedObj[0] != '')
                    {
                        this.selectedObjectRow = selectedObj[0];
                        this.getFieldList(selectedObj[0].APIName);
                    }
                }
            }
    }

    getUserList(userSearchType,searchParam1,searchParam2)
    {
        if(userSearchType === 'THIS')
        {
            this.getUserPermGrpList(searchParam1);
            this.getObjectList(searchParam1,searchParam2);
            this.getTabList(searchParam1,searchParam2);
        }
        else
        {
            this.userSpinnerLoaded = !this.userSpinnerLoaded;
            getUserDetails( {SearchType: this.selectedFilter, SearchParam: searchParam1})
            .then(result => {
                this.userList= result.UserWrapperLst;
                this.selectedObjectParam1 = searchParam1;
                this.objectList= result.ObjectWrapperLst;
                this.tabList= result.TabWrapperLst;
                this.userSpinnerLoaded = !this.userSpinnerLoaded;
                if(this.userList == undefined || this.userList == '')
                    this.hasUser = false;
                if(this.tabList == undefined || this.tabList == '')
                    this.hasTab = false;
                this.setExportGrid('User');
            })
            .catch(error => { 
                this.showToast('error','Page Error','Something went wrong while fetching Users. Please try again later!');
                this.userSpinnerLoaded = !this.userSpinnerLoaded;
            });
        }
    }

    getProfileList()
    {
        this.profileSpinnerLoaded = !this.profileSpinnerLoaded;
        getProfileDetails()
        .then(result => {
            this.profileList = result;
            this.profileSpinnerLoaded = !this.profileSpinnerLoaded;
            this.setExportGrid('Profile');
        })
        .catch(error => { 
            this.showToast('error','Page Error','Something went wrong while fetching Profiles. Please try again later!');
            this.profileSpinnerLoaded = !this.profileSpinnerLoaded;
        });
    }

    getPermissionList()
    {
        this.permitSpinnerLoaded = !this.permitSpinnerLoaded;
        getPermissionDetails()
        .then(result => {
            this.permissionList = result;
            this.permitSpinnerLoaded = !this.permitSpinnerLoaded;
            this.setExportGrid('Permission Set');
        })
        .catch(error => { 
            this.showToast('error','Page Error','Something went wrong while fetching Permission Sets. Please try again later!');
            this.permitSpinnerLoaded = !this.permitSpinnerLoaded;
        });
    }

    getUserPermGrpList(searchParam)
    {
        this.permGrpSpinnerLoaded = !this.permGrpSpinnerLoaded;
        getUserGrpPermDetails( {SearchType: this.selectedFilter, SearchParam: searchParam})
            .then(result => {
                this.userPermList= result.UserPermitWrapperLst;
                this.hasPermSet = result.HasPermSet;
                this.userGrpList= result.UserGrpWrapperLst;
                this.hasGrp= result.HasGrp;
                this.permGrpSpinnerLoaded = !this.permGrpSpinnerLoaded;
                this.setExportGrid('User Permission Group');
            })
            .catch(error => { 
                this.showToast('error','Page Error','Something went wrong while fetching Groups. Please try again later!');
                this.permGrpSpinnerLoaded = !this.permGrpSpinnerLoaded;
            });
    }

    getObjectList(searchParam1, searchParam2)
    {
        this.objectSpinnerLoaded = !this.objectSpinnerLoaded;
        this.selectedObjectParam1 = searchParam1;
        this.selectedObjectParam2 = searchParam2;
        getObjectDetails( {SearchType: this.selectedFilter
                        , SearchParam1: searchParam1
                        , SearchParam2: searchParam2})
            .then(result => {
                this.objectList= result;
                this.objectSpinnerLoaded = !this.objectSpinnerLoaded;
                this.setExportGrid('Object');
            })
            .catch(error => { 
                this.showToast('error','Page Error','Something went wrong while fetching Objects. Please try again later!');
                this.objectSpinnerLoaded = !this.objectSpinnerLoaded;
            });
    }

    getFieldList(objAPIName)
    {
        this.fieldSpinnerLoaded = !this.fieldSpinnerLoaded;
        if( objAPIName != undefined ||  objAPIName != '')
        {
            getFieldDetails( {ObjName: objAPIName
                            , SearchType: this.selectedFilter
                            , SearchParam1: this.selectedObjectParam1
                            , SearchParam2: this.selectedObjectParam2})
                .then(result => {
                    this.fieldList= result;
                    this.fieldSpinnerLoaded = !this.fieldSpinnerLoaded;
                    this.setExportGrid('Field');
                })
                .catch(error => { 
                    this.showToast('error','Page Error','Something went wrong while fetching Fields. Please try again later!');
                    this.fieldSpinnerLoaded = !this.fieldSpinnerLoaded;
                });
        }
    }

    getTabList(searchParam1, searchParam2)
    {
        this.tabSpinnerLoaded = !this.tabSpinnerLoaded;
        getTabDetails( {SearchType: this.selectedFilter
                        , SearchParam1: searchParam1
                        , SearchParam2: searchParam2})
            .then(result => {
                this.tabList= result;
                this.tabSpinnerLoaded = !this.tabSpinnerLoaded;
                this.setExportGrid('Tab');
            })
            .catch(error => {
                this.showToast('error','Page Error','Something went wrong, while fetching Tabs. Please try again later!');
                this.tabSpinnerLoaded = !this.tabSpinnerLoaded;
            });
    }

    setXlsTab(tabName, headerList, dataList, dataRow)
    {
        try{
            
        let headerData = [];
        let data = [];
        let gridDataHeaders = headerList;
        let gridDataRows = [];

        if(dataList != undefined || dataList != '')
        {
            if(dataList.length > 0)
            {
                if(dataRow == '')
                {
                    gridDataRows = dataList;

                    for(let i = 0; i < gridDataRows.length; i++)
                    {
                        let tempRow = [];

                        if(gridDataRows[i].exportRow != undefined && gridDataRows[i].exportRow != '')
                        {
                            for(let j = 0; j < gridDataRows[i].exportRow.length; j++)
                                tempRow.push(gridDataRows[i].exportRow[j]);
                        }

                        if(tempRow != '')
                            data.push(tempRow);
                    }
                }
                else
                {
                    if(dataRow != undefined)
                    {
                        gridDataRows = dataRow;

                        let filtDataRow = [];
                        let tempRow = [];
                        filtDataRow.push(tabName + ':');

                        filtDataRow.push(gridDataRows.Name);
                        if(gridDataRows.exportRow != undefined && gridDataRows.exportRow!= '')
                        {
                            for(let j = 0; j < gridDataRows.exportRow.length; j++)
                                tempRow.push(gridDataRows.exportRow[j]);
                        }
                        
                        this.xlsFiltTab.push(filtDataRow);
                        if(tempRow != '')
                            data.push(tempRow);
                    }
                }

                if(data != undefined || data != '')
                {
                    for(let i = 0; i < gridDataHeaders.length; i++){
                        headerData.push(gridDataHeaders[i]["label"]); 
                    }

                    this.xlsTabNames.push(tabName);
                    this.xlsTabHeaders.push(headerData);
                    this.xlsTabData.push(data);
                }
            }
        }

        }catch(err)
        {
            console.log(err.message);
            //this.showToast('error','Excel Tab Setting Error',err.message);
        }
    }

    xlsFormatter(header, data, sheetName) {
        this.xlsHeader.push(header);
        this.workSheetNameList.push(sheetName);
        if(data.length>0)
            this.xlsData.push(data);
    }

    setExportGrid(setType)
    {
        try{
        this.xlsFiltTab = [];
        this.xlsTabHeaders = [];
        this.xlsTabData = [];
        this.xlsTabNames = [];
        this.xlsHeader = [];
        this.workSheetNameList = [];
        this.xlsData = [];

        let filtDataRow = [];
        filtDataRow.push('Application Name :');
        filtDataRow.push(this.appName);
        this.xlsFiltTab.push(filtDataRow);

        filtDataRow = [];
        filtDataRow.push('Fetch details based on:');
        filtDataRow.push(this.selectedFilter);
        this.xlsFiltTab.push(filtDataRow);

        if(setType === 'Profile')
            {
                this.setXlsTab('Profile', this.profileListColumn, this.profileList, this.selectedProfileRow);
            }
        
        else if(setType === 'Permission Set')
            {
                this.setXlsTab('Permission Set', this.permissionListColumn, this.permissionList, this.selectedPermissionRow);
            }
        
        else if(setType === 'User')
            {
                if(this.selectedFilter == this.profileFilterLabel)
                {
                    this.setXlsTab('Profile', this.profileListColumn, this.profileList, this.selectedProfileRow);
                    this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                    this.setXlsTab('Tab', this.tabListColumn, this.tabList, []);
                    this.setXlsTab('Object', this.objectListColumn, this.objectList, this.selectedObjectRow);
                }
                if(this.selectedFilter == this.permissionSetFilterLabel)
                {
                    this.setXlsTab('Permission Set', this.permissionListColumn, this.permissionList, this.selectedPermissionRow);
                    this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                    this.setXlsTab('Tab', this.tabListColumn, this.tabList, []);
                    this.setXlsTab('Object', this.objectListColumn, this.objectList, this.selectedObjectRow);
                }
                if(this.selectedFilter == this.userFilterLabel)
                    this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
            }
        else if(setType === 'User Permission Group')
            {
                this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                this.setXlsTab('User Permission Set', this.userPermListColumn, this.userPermList, []);
                this.setXlsTab('User Group', this.userGrpListColumn, this.userGrpList, []);
            }
        else if(setType === 'Object')
            {
                if(this.selectedFilter == this.profileFilterLabel)
                {
                    this.setXlsTab('Profile', this.profileListColumn, this.profileList, this.selectedProfileRow);
                    this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                }
                if(this.selectedFilter == this.permissionSetFilterLabel)
                {
                    this.setXlsTab('Permission Set', this.permissionListColumn, this.permissionList, this.selectedPermissionRow);
                    this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                }
                if(this.selectedFilter == this.userFilterLabel)
                {
                    this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                    this.setXlsTab('User Permission Set', this.userPermListColumn, this.userPermList, []);
                    this.setXlsTab('User Group', this.userGrpListColumn, this.userGrpList, []);
                }
                this.setXlsTab('Tab', this.tabListColumn, this.tabList, []);
                this.setXlsTab('Object', this.objectListColumn, this.objectList, this.selectedObjectRow);
            }
        else if(setType === 'Field')
            {
                if(this.selectedFilter == this.profileFilterLabel)
                {
                    this.setXlsTab('Profile', this.profileListColumn, this.profileList, this.selectedProfileRow);
                    this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                }
                if(this.selectedFilter == this.permissionSetFilterLabel)
                {
                    this.setXlsTab('Permission Set', this.permissionListColumn, this.permissionList, this.selectedPermissionRow);
                    this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                }
                if(this.selectedFilter == this.userFilterLabel)
                    {
                        this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                        this.setXlsTab('User Permission Set', this.userPermListColumn, this.userPermList, []);
                        this.setXlsTab('User Group', this.userGrpListColumn, this.userGrpList, []);
                    }
                this.setXlsTab('Tab', this.tabListColumn, this.tabList, []);
                this.setXlsTab('Object', this.objectListColumn, this.objectList, this.selectedObjectRow);
                this.setXlsTab('Field', this.fieldListColumn, this.fieldList, []);
            }
        else if(setType === 'Tab')
                {
                    if(this.selectedFilter == this.profileFilterLabel)
                    {
                        this.setXlsTab('Profile', this.profileListColumn, this.profileList, this.selectedProfileRow);
                        this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                    }
                    if(this.selectedFilter == this.permissionSetFilterLabel)
                    {
                        this.setXlsTab('Permission Set', this.permissionListColumn, this.permissionList, this.selectedPermissionRow);
                        this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                    }
                    if(this.selectedFilter == this.userFilterLabel)
                        {
                            this.setXlsTab('User', this.userListColumn, this.userList, this.selectedUserRow);
                            this.setXlsTab('User Permission Set', this.userPermListColumn, this.userPermList, []);
                            this.setXlsTab('User Group', this.userGrpListColumn, this.userGrpList, []);
                        }
                    this.setXlsTab('Tab', this.tabListColumn, this.tabList, []);
                    this.setXlsTab('Object', this.objectListColumn, this.objectList, this.selectedObjectRow);
                    this.setXlsTab('Field', this.fieldListColumn, this.fieldList, []);
                }
        else{}
        

        if(this.xlsTabData != undefined && this.xlsTabData != '')
        {
            this.xlsFormatter('', this.xlsFiltTab,'Filtered By');
            for(var i = 0; i < this.xlsTabNames.length; i++){
                this.xlsFormatter(this.xlsTabHeaders[i], this.xlsTabData[i],this.xlsTabNames[i]);
            }
            this.showExportButton = true;
        }
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
    //Method Declaration ends here

}