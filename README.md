# Chucker

A local network traffic debugging utility for iOS.

![Chucker Empty List](/docs/images/chucker_empty_list.png) ![Chucker Non-Empty List](/docs/images/chucker_nonempty_list.png)

![Chucker Request View](/docs/images/chucker_request.png) ![Chucker Response View](/docs/images/chucker_response.png)
## Installation
This package may be installed using the swift package manager.

## Network Traffic Recording
To create an instance of Chucker simply call the `make()` method on `ChuckerViewController` for example: 

```
#if DEBUG
import Chucker
#endif

final class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func showChucker() {
        #if canImport(Chucker)
            navigationController?.pushViewController(
                ChuckerViewController.make(), 
                animated: true
            )
        #endif
    }
}
```

For convenience purposes there is a launch argument:
```
--chucker-auto-record
```
that may be passed when running that will cause chucker to start recording automatically. This may be especially convenient for debug schemes and may be added in the scheme editor.
![Auto Record Launch Argument](/docs/images/auto_record_launch_arg.png)

When using this launch argument, ensure that you bootstrap Chucker so that everything is initialized. The best place to do this is in 
```
application(_:didFinishLaunchingWithOptions:)
```
on your `AppDelegate` for example: 
```

#if DEBUG
import Chucker
#endif

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if canImport(Chucker)
        Chucker.bootstrap()
        #endif
    }
}
```

## Response Mocking
Chucker also includes a response mocking feature that uses the same foundation as the network recording functionality. This feature requires the caller to supply: 
- Configuration
- Manifest
- Associated Mock Data.

Both the configuration and manifest files should be JSON files and have the following formats: 

### Configuration 

```JSON
{
    "included": [
        {
            "name": "<# plain text name/description of endpoint>",
            "endpoint": "https://<# endpoint>",
            "method": "GET",
            "useMock": false,
            "responseKey": "success"
        },
        {
            "name": "<# plain text name/description of endpoint>",
            "endpoint": "https://graphql.<# endpoint>",
            "method": "POST",
            "operationType": "query",
            "operationName": "<# query name>",
            "useMock": false,
            "responseKey": "success"
        }
    ],
    "excluded": [
        "https://<# endpoint to exclude>/*"
    ]
}
```
> Note:
>
> The manifest contains a `responseMap` where you can list multiple responses. The item to be used will be the item corresponding to the `responseKey` field.

This file is loaded and, when data mocking is turned on, the framework consults this configuration file for the requested endpoint. If the endpoint is not excluded and the value of `"useMock"` is `true` the framework will then consult the `Manifest` for this endpoint to find and read the mock response. If the endpoint is excluded or the value of `"useMock"` is `false`, the framework sends the request to the network as usual. 

### Manifest

```JSON
{
    "items": [
        {
            "endpoint": "https://<# endpoint>",
            "method": "GET",
            "responseMap": {
                "success": "<# path/to/success/response>",
                "failure": "<# path/to/failure/response>"
            }
        },
        {
            "endpoint": "https://graphql.<# endpoint>",
            "method": "POST",
            "operationType": "query",
            "operationName": "<# query name>",
            "responseMap": {
                "success": "<# path/to/success/response>",
                "failure": "<# path/to/failure/response>"
            }
        }
    ]
}
```

This file is loaded and, when data mocking is turned on and the configuration for the requested endpoint has `true` for `"useMock"`, the framework consults this file to find the file containing the mock response to be loaded and returned.

### Mock Responses
Each mock response is also a JSON file with the following format: 
```JSON
{
    "url": "https://<# endpoint>",
    "statusCode": 200,
    "httpVersion": null,
    "headerFields": {},
    "body": {
        "question": "Test Question",
        "published_at": "2015-08-05T08:40:51.620Z",
        "choices": [
            {
                "choice": "Test 1",
                "votes": 2048
            }, {
                "choice": "Test 2",
                "votes": 1024
            }, {
                "choice": "Test 3",
                "votes": 512
            }, {
                "choice": "Test 4",
                "votes": 256
            }
        ]
    }
}
```

> Note: 
> 
> The `"body"` field does not need to be a top level JSON object, an array is also a valid JSON object and would be acceptable. 

The `ChuckerViewController` contains an option for enabling and disabling mock data while the application is running.

### Mock Data Management
It is likely undesirable to add the mock data and configuration files to the Application bundle for release builds. Because of this, it is recommended that users include this data as part of a Run Script Phase on debug configurations only this can be accomplished as follows:

![Run Script Phase for Mock Data](/docs/images/mock_data_run_script_phase.png)

### Using the Mock Data Feature
To use the mock data feature there are three launch arguments: 
- `--mockDataManifest <# name of your manifest file>`
- `--mockDataConfig <# name of your configuration file>`
- `--useMockData`

`These items may be added to the launch arguments on your scheme as follows: 
![Mock Data Launch Args](/docs/images/chucker_mockdata_launch_args.png)

The first two arguments are used in the Chucker bootstrap process. If you would like to use the mock data feature include the `configuration` and `manifest` arguments in the call to bootstrap chucker:
```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if canImport(Chucker)
        if let mockConfigArgIndex = CommandLine.arguments.firstIndex(of: "--mockDataConfig"),
           let manifestArgIndex = CommandLine.arguments.firstIndex(of: "--mockDataManifest") {
            let configFilename = CommandLine.arguments[mockConfigArgIndex + 1]
            let manifestFilename = CommandLine.arguments[manifestArgIndex + 1]
            Chucker.bootstrap(configFilename: configFilename, mockDataManifest: manifestFilename, mockDataBundle: .main)
        } else {
            Chucker.bootstrap(configFilename: <# config filename>, mockDataManifest: <# manifest filename>, mockDataBundle: .main)
        }
        #endif
```