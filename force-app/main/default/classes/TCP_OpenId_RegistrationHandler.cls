/*
* openid registration handler for Salesforce.com
* 
*/

global class TCP_OpenId_RegistrationHandler implements Auth.RegistrationHandler {

    
    class RegHandlerException extends Exception {}

    //links the account in the case the user exists either by email
    
    global User createUser(Id portalId, Auth.UserData data) {
        system.debug('in createUser '+data);
        if (!canCreateUser(data)){
            throw new RegHandlerException('Can\'t create a new user or link an existing user because last name or email is missing, or email is not verified.');
        }

        User u;

        List<User> userList = getMatchingUsers(data);

        // If the account exists just return the existing user
        // otherwise we create a new user or fail with a nice message
        if (userList.size() > 0){
            String userId = userList.get(0).id;
            u = new User(id = userId);
            prepareUserData(data, u);
            return u;
        } else {
            
            throw new RegHandlerException('Can\'t create a new user or link an existing user to openid ID either because it is not allowed or the user was not found.');
            // need to return something
            
        }
        //return null;
    }

    // Update the user
    // This is called by salesforce if the user exists
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        system.debug('in updateUser '+data);
        if (!canUpdateUser(data)){
            throw new RegHandlerException('Can\'t update the existing user because the email that was used is not verified');
        } else {
            User u = new User(id = userId);
            List<User> users = [select Id from User where id =:userId AND CIPM_Access__c = true LIMIT 1];
            if(!users.isEmpty()){
                prepareUserData(data, u);
                update(u);
            }
            else{
                throw new RegHandlerException('No access to the portal, please contact system administrator or IT team.');
            }
            
        }
    }
    
    private void prepareUserData(Auth.UserData data, User u) {
        String givenName, lastName, email, alias;

        // Get email
        if (data.attributeMap.containsKey('email')){
            email = data.attributeMap.get('email');
            u.email = email;
        }

        // We are already checking for email_verified in canCreateUser(Auth.UserData data).
        // If already a user and calling update is there a need to stop the login?
        // Probably there is as we don't want to link openid id with an unverified email?

        // Get first name
        if (data.attributeMap.containsKey('given_name')) {
            givenName = data.attributeMap.get('given_name');
            u.firstName = givenName;
        }

        // Get last name
        if (data.attributeMap.containsKey('family_name')) {
            lastName = data.attributeMap.get('family_name');
            u.lastName = lastName;
        }

        // Create alias - must be 8 characters or less
        // First names are more common than last names so, use lastname first
        // to avoid multiple aliases starting from the same chars.
        alias = lastName + givenName;
        if (alias.length() > 8) {
            u.alias = alias.toLowerCase().substring(0, 8);
        }

        // If there is no user id yet means we have a new user so,
        // set the email as the new users username;
        // If there is a user id, then we definitely have a username and we must not change it.

        if (u.id == null) {
            if (availableUsername(email)) {
                u.username  = email;
            } else {
                throw new RegHandlerException('Can\'t create a user. There is already an account with this username.');
            }
        }

        // Get phoneNumber
        // If non existing then it will return null.
        String phoneNumber = data.attributeMap.get('phone_number');

        // Set then phone number attribute based on phone type.
        // Because we don't know how null values are handled we first check for
        // the phone_number key existence and then set the correct attribute to the user.
        // If it does not exist, just skip it.
        if (data.attributeMap.containsKey('phone_number')) {
            if (data.attributeMap.get('phone_type') == 'mobile') {
                u.mobilePhone = phoneNumber;
            } else {
                u.phone = phoneNumber;
            }
        }

        // Get address
        if (data.attributeMap.containsKey('address')) {
            Map<String, String> addressFields = parseMalformedNestedJSON(data.attributeMap.get('address'));
            u.street = addressFields.get('street_address');
            u.city = addressFields.get('locality');
            u.state = addressFields.get('state');
            u.country =  addressFields.get('country');
            u.postalCode = addressFields.get('postal_code');
        }
		// Get zoneinfo
        if (data.attributeMap.containsKey('zoneinfo')) {
            u.timeZoneSidKey = data.attributeMap.get('zoneinfo');
        }

        // Set email encoding key to 'UTF-8'
        u.emailEncodingKey = 'UTF-8';
    }

    // Decide if we can create a user from the data provided
    // Specifically we check for nullity, family_name (though we may skip that?)
    // and email_verified truthness;
    private boolean canCreateUser(Auth.UserData data) {
        return (data != null
                && data.attributeMap.containsKey('email_verified')
                && data.attributeMap.get('email_verified') == 'true');
    }

    // Decide if we can update a user from the data provided
    // Specifically we check for nullity
    // and email_verified truthness.
    private boolean canUpdateUser(Auth.UserData data) {
        return (data != null
                && data.attributeMap.containsKey('email_verified')
                && data.attributeMap.get('email_verified') == 'true');
    }

    // Check if the username we asked for is available
    private boolean availableUsername(String availableUsername) {
        List<User> users = [select Id from User where username =:availableUsername];
        return (users.size()==0); // true if no user has already that user name
    }


    // Try to get at least one matching, existing and active user for account the linking case
    // or for the usage in a new computer / new browser. In the second case, this should trigger a verification email or sms to the user.
    private List<User> getMatchingUsers(Auth.UserData data) {

        // This is the Subject ID. In this case we have a public type and not a pairwise one.
        // Find more about public and pairwise Subject ids here.
        // http://openid.net/specs/openid-connect-core-1_0.html#SubjectIDTypes
        // We could also do data.identifier.
        String sub = data.attributeMap.get('sub');

        List<ThirdPartyAccountLink> matchedAccounts = [SELECT userId, remoteIdentifier FROM ThirdPartyAccountLink where RemoteIdentifier =: sub];

        // Normally we should get only one entry in the accountsList.

        List<User> userList;

        // If there is indeed one or more accounts found then we have a linked account already, so check for the first userid and the email,
        // and return the matching user of the first account.

        // Else we have an account linking case, where we need to find a matching user by the data provided by openid.
        // Check for the account by email (which in an organization probably is usually unique) and for being active (could we check for more?)

        if (matchedAccounts.size() > 0) {
            userList = [SELECT id
                        FROM User
                        WHERE id =: matchedAccounts.get(0).userId
                        AND email =: data.email
                        AND isActive = true
                        AND TCP_Role__c != null
                        AND CIPM_Access__c = true];
        } else { 
            userList = [SELECT id
                        FROM User
                        WHERE email =: data.email
                        AND isActive = true 
                        AND TCP_Role__c != null
                        AND CIPM_Access__c = true];
        }
        
        return userList;
    }

    // Salesforce does not play well with nested jsons.
    // Instead of getting a JSON (e.g. for address) we get something like the following
    // {country=country, street_address=address, formatted=address\nlocality..., locality=locality, state=state, postalcode=postalcode}.
    // So, get the string inside the curly brackets and split by comma to get the array of values.
    // Then add these to a Map<String, String> by splitting each value at the first and the last '=' and trimming.
    // This is not perfectly safe as the user may pass commas and equal signs in the values.
    // It does not break things completely but also does not guarantee consistency on values that contain these characters.
    private Map<String, String> parseMalformedNestedJSON(String value) {
        String[] arrayOfValues = value.substring(value.indexOf('{') + 1, value.indexOf('}') - 1).split(',');
        //TODO: Q: wouldnt this fail if there are commas in the values?
        Map<String, String> fields = new Map<String, String>();
        for (String item : arrayOfValues) {
            String k = item.substringBefore('=').trim();
            String v = item.substringAfterLast('=').trim();
            fields.put(k, v);
        }
        return fields;
    }
}