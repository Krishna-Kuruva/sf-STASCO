/*****************************************************************************
@Name:  OLF_SendContractInformation_Test     
@=========================================================================
@Purpose: Test class for OLF_SendContractInformation class.
@=========================================================================
@History                                                            
@---------                                                            
@VERSION AUTHOR                            DATE                DETAIL                                 
@1.0 - Rahul Sharma     ```````````````    18-Mar-2021         INITIAL DEVELOPMENT

******************************************************************************/
@isTest
public class OLF_SendContractInformation_Test {

    /*Method Name	:	test_sendContractInfoToOLF
    * Date			:	18-Mar-2021
    * Developer		:	Rahul Sharma
    * Description	:	test method for sendContractInfoToOLF(Map<String, List<OLFWrapper.olfDealWrap>>)
    */
    @isTest
    static void test_sendContractInfoToOLF(){
        OLFWrapper.olfDealWrap olfDealWrp = new OLFWrapper.olfDealWrap();
        Map<String, List<OLFWrapper.olfDealWrap>> orderGrpVsDealWrapMap = new Map<String, List<OLFWrapper.olfDealWrap>>();
        olfDealWrp.orderId = '19MGI2G-1';
        olfDealWrp.vendorContractNo = '322123320';
        olfDealWrp.vendorLiftingId = '8352229';
        orderGrpVsDealWrapMap.put('19MGI2G', new List<OLFWrapper.olfDealWrap>{olfDealWrp});
        Test.setMock(HttpCalloutMock.class, new RV_MockHttpResponseGenerator());
        Test.startTest();
        OLF_SendContractInformation.sendContractInfoToOLF(orderGrpVsDealWrapMap);
        Test.stopTest();
    }
}