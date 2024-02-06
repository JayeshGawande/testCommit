public class populateSiteAddress {
    
    @future(Callout=True)
    public static void findSiteAddressFromLatLong(Id IdSet){
        system.debug('InCallout==>'+IdSet);
        Site_ID__c siteIds=[SELECT ID,Geoapify__c,Street_Address__c,Latitude__c,Longitude__c from Site_ID__c 
                            where Id=:IdSet];
        
        if(siteIds!=Null && siteIds.Latitude__c!=Null && siteIds.Longitude__c!=Null){
            string ApiKey = '7a5b0868c47e414e8409063777571df0';
            String lattitude=String.Valueof(siteIds.Latitude__c);
            String longitude=String.Valueof(siteIds.Longitude__c);
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            string endPoint = 'https://api.geoapify.com/v1/geocode/reverse?lat='+lattitude+'&lon='+longitude+'&apiKey='+ApiKey;
            req.setEndpoint(endpoint);
            HttpResponse res = h.send(req);
            if(res.getStatusCode() == 200){
                JSON2Apex obj=JSON2Apex.parse(res.getBody());
                List<JSON2Apex.features> jsonFeatures=obj.features;
                String StreetAddress='';
                String Country='';
                String state_code='';
                String post_code='';
                String city='';
                For(JSON2Apex.features jf:jsonFeatures){
                    if(jf.properties.formatted != Null){
                        StreetAddress=jf.properties.formatted;
                    }
                    if(jf.properties.country != Null){
                        Country=jf.properties.country;
                    }
                    if(jf.properties.state_code != Null){
                        state_code=jf.properties.state_code.toUpperCase();
                    }
                    if(jf.properties.postcode!=Null){
                        post_code=jf.properties.postcode;
                    }
                    if(jf.properties.city!=Null){
                        city=jf.properties.city;
                    }
                }
                system.debug('StreetAddress=>'+StreetAddress+'<==Country=>'+Country+'<==state_code=>'+state_code+'<==postcode=>'+post_code+'<==city=>'+city);
                siteIds.Street_Address__c=StreetAddress;
                siteIds.State__c=state_code;
                siteIds.Country__c=Country;
                siteIds.Zip_Code__c=post_code;
                siteIds.City__c=city;
                if(siteIds.City__c==Null || string.isBlank(siteIds.City__c))
                {
                    siteIds.City__c=StreetAddress;
                }
                siteIds.Geoapify__c=endPoint;
                checkRecursion.checkRecursive=true;
                update siteIds;
            }
        }
    }
}