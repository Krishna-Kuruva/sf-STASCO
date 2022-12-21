/**
 * Created by Dharmendra.Singh2 on 8/1/2020.
 */


public class RT_AureusJobSchedule implements schedulable
{
    public void execute(SchedulableContext sc)
    {
        RT_REVContractDataBatch b = new RT_REVContractDataBatch(); //run aureus batch
      	database.executebatch(b);
    }
}