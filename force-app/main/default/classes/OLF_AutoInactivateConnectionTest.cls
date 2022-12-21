/**
 * Created by Dharmendra.Singh2 on 11/12/2020.
 */
@IsTest
public class OLF_AutoInactivateConnectionTest {

    public static testMethod void ScheduleOLFInactivation(){

        Test.startTest();
        OLF_AutoInactivateConnection olfAutoInactivateConnection = new OLF_AutoInactivateConnection();
        String sch = '0 0 2 * * ?';
        system.schedule('IT Dashboard alert', sch, olfAutoInactivateConnection);
        Test.stopTest();
    }

}