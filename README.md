# nearby-places-ios-application

<a href="https://imgflip.com/gif/1z3lsu"><img src="https://i.imgflip.com/1z3lsu.gif" title="made at imgflip.com"/></a>

# Search for places using MKLocalSearchRequest and display results with UISearchController

Apple provides a powerful native map API called MapKit. You can display a map, show the user’s current location, and drop annotation pins. And you don’t need to rely on any third-party SDKs.

For example, if you’re building an app that shows branch locations, displays geotagged content, or does anything involving a map, MapKit is the tool for you.

Maps contain a lot of information, so it’s natural for users to search for places. 

# MKLocalSearch

Have you ever wondered which restaurants were nearby? Apple's MapKit framework provides an easy way to lookup places via natural language search.


# MKLocalSearchRequest

First we start with a simple search request. You will need to specify the text for the natural language search and an optional region in which the search will take place. As an example we will specify a region from a MKMapView.

```
let request = MKLocalSearchRequest()
request.naturalLanguageQuery = "Restaurants"
request.region = mapView.region

```

# MKLocalSearchResponse

Next we make a MKLocalSearch from our request. We will get our search response from the completion block when calling the startWithCompletionHandler: method. In the block we get back an array of MKMapItem and an NSError. Each MKMapItem contains information about the location such as name, phone number, url, and address information via the CLPlacemark property.

```
let search = MKLocalSearch(request: request)
search.startWithCompletionHandler { response, error in
    guard let response = response else {
        print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
        return
    }

    for item in response.mapItems {
        // Display the received items
    }
}

```
