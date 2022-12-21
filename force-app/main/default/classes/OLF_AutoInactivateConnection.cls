global class OLF_AutoInactivateConnection implements Schedulable {
    /*
	Version : 0.0
	Author	: Soumyajit
	Date	: 09-Sep-2019
	Details	: Scheduler Job to deactivate OLF Connection
	*/
    public static boolean global_overrideChecks = false;
    global static void execute(SchedulableContext s)
    {
        Rv_RevolutionSettingTriggerHelper.global_reason = 'Scheduled Auto-Inactivation.';
        OLF_DashboardApexController.userActivateInactivate('STOP');
    }
}