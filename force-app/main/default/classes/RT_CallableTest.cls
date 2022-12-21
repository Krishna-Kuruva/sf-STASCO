public class RT_CallableTest implements Callable {
     public Object call(String action, Map<String, Object> args) {
         switch on action {
            when 'execute' {
              return this.execute((RT_ImportFiles.fileWrapper)args.get('execute'));
            }
            when else {
             throw new ExtensionMalformedCallException('Method not implemented');
            }
          }
        }
      public class ExtensionMalformedCallException extends Exception {}
      public RT_ImportFiles.resultFileWrapper execute (RT_ImportFiles.fileWrapper inputFileWrapper) {
         return new RT_ImportFiles.resultFileWrapper();
      }
}