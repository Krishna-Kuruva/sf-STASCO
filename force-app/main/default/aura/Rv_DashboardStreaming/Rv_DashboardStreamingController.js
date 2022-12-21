({
	doInit : function(component, event, helper) {
	  console.log('inside dashboard streaming component');
      var action = component.get("c.getSessionId");
      action.setCallback(this, function(response){
		  let state = response.getState();  
          console.log(state);
          // Configure CometD for this component
          var sessionId = response.getReturnValue();
          console.log('sessionId==>'+sessionId); 
          var cometd = new window.org.cometd.CometD();
          cometd.configure({
                url: window.location.protocol + '//' + window.location.hostname + '/cometd/41.0/',
                requestHeaders: { Authorization: 'OAuth ' + sessionId},
                appendMessageTypeToURL : false
          });
          cometd.websocketEnabled = false;
          cometd.handshake($A.getCallback(function(status){
              if (status.successful) {
				  var eventName = component.get("v.channel"); 
                  var diffEventName=component.get("v.channelDiff");
                  var subscription = cometd.subscribe(eventName, $A.getCallback(function(message) {
                            var messageEvent = component.getEvent("onUpdate");
                            console.log('messageEvent==>',message);
	                        if(messageEvent!=null) {
                                messageEvent.setParam("priceChanged", message.data.payload.Price_Changed__c);
                                messageEvent.fire();    

	                        }
                        }
                    ));
                    component.set('v.subscription', subscription);
              }
              else{
                    // TODO: Throw an event / set error property here?
                    console.log('dashboard streaming component error status not successful');
              }
          }));
      });
      $A.enqueueAction(action);
	},
     handleDestroy : function (component, event, helper) {
        console.log('inside handle destroy');
        // Ensure this component unsubscribes and disconnects from the server
		var cometd = component.get("v.cometd");
		var subscription = component.get("v.subscription");
		cometd.unsubscribe(subscription, {}, function(unsubscribeReply) {
		    if(unsubscribeReply.successful) {
                cometd.disconnect(function(disconnectReply) 
                    { 
                        console.log('streaming component: Success unsubscribe')
                        if(disconnectReply.successful) {
                            console.log('streaming component: Success disconnect')
                        } else {
                            console.error('streaming component: Failed disconnect')                    
                        }
                    });
		    } else {
		        console.error('streaming component: Failed unsubscribe')                    		    
		    }
		});
    }
})