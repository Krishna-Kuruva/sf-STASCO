public class RE_updateCBUcustomerOpps implements Queueable {   
public void execute(QueueableContext context) {
       System.debug('Start updateCBUcustomerOpps Queue Class DML Rows ::: '+Limits.getDMLRows()+'  CPU Limit ::: '+Limits.getCpuTime());
       RE_MY_CustOpsCalculationController.todayCBUcustomOppsgenerate( );
       System.debug('End todayCBUcustomOppsgenerate Method Class DML Rows ::: '+Limits.getDMLRows()+'  CPU Limit ::: '+Limits.getCpuTime());
       RE_MY_AMVCalculationController.getDirectListPrice();
       System.debug('End updateCBUcustomerOpps Queue Class DML Rows ::: '+Limits.getDMLRows()+'  CPU Limit ::: '+Limits.getCpuTime()); 
    }
}