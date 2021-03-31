# Chucker

A local network traffic debugging utility for iOS.


## Installation
This package may be installed using the swift package manager.

## Usage
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
that may be passed when running that will cause chucker to start recording automatically. This may be especially convenient for debug schemes.

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