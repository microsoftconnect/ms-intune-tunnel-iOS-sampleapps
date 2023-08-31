# Microsoft Tunnel for Mobile Application Management SDK for Xamarin for iOS

## Building the Sample application

* Clone the repository
* Open [Xamarin/Xamarin.sln](Xamarin/Xamarin.sln) in Visual Studio
* Use the Nuget Package Manager to update the `Microsoft.Intune.Tunnel.MAM.Xamarin.iOS` package to the latest version
* Update [Directory.Build.props](Directory.Build.props) and change the values of `<ApplicationId>`, `<ClientId>` and `<TenantId>` to match the values of your Bundle Id, your AAD application Client Id and your AAD Tenant Id respectively
* Optionally update `<ApplicationTitle>` to change the deployed name of the application
    * Alternatively, you can create a file adjacent to the [Directory.Build.props](Directory.Build.props) file named [Developer.props](Developer.props)
    * Include the contents
    ```xml
    <Project>
        <PropertyGroup>
            <ApplicationId>[your Bundle Id]</ApplicationId>
            <ApplicationTitle>xPlat-Tunnel</ApplicationTitle>
            <ClientId>[your AAD Application Client Id]</ClientId>
            <TenantId>[your AAD Tenant Id]</TenantId>
        </PropertyGroup>
    </Project>
    ```
    * This will allow you to update these properties without altering the csproj file
* Select your target device in Visual Studio and run

## Details 

The target `GeneratePartialAppManifests` defined in [Directory.Build.props](Directory.Build.props) will convert the MSBuild properties defined above into the appropriate [Info.plist](Xamarin/XamarinTunnel/XamarinTunnel.iOS/Info.plist) properties.
It also sets the default values for the [IntuneMAMSettings](https://learn.microsoft.com/en-us/mem/intune/developer/app-sdk-ios#configure-msal-settings-for-the-intune-app-sdk)

The target `AddPartialAppManifests` will merge the newly generated plist file and the main [Info.plist](Xamarin/XamarinTunnel/XamarinTunnel.iOS/Info.plist)

## Integration

* Beyond the configuring of `IntuneMAMSettings` as described in the `Details` section of this document. You also need to configure the [Entitlements.plist](Xamarin/XamarinTunnel/XamarinTunnel.iOS/Entitlements.plist) as seen in step 2 of [this document](https://learn.microsoft.com/en-us/mem/intune/developer/app-sdk-xamarin#enabling-intune-app-protection-policies-in-your-ios-mobile-app). It has already been done in this sample application.

* The bulk of the integration can be found in [MicrosoftTunnelDelegate.cs](Xamarin/XamarinTunnel/XamarinTunnel.iOS/MicrosoftTunnelDelegate.cs). It is a class that inherits from `Microsoft.Intune.Tunnel.MAM.iOS.TunnelDelegate` and implements abstract members.

* To facilitate logging and debugging, the [MicrosoftTunnelDelegate.cs](Xamarin/XamarinTunnel/XamarinTunnel.iOS/MicrosoftTunnelDelegate.cs) file declares a `LogDelegate` that inherits from `Microsoft.Intune.Tunnel.MAM.iOS.MicrosoftTunnelLogDelegate`

* The [MicrosoftTunnelDelegate](Xamarin/XamarinTunnel/XamarinTunnel.iOS/MicrosoftTunnelDelegate.cs) also passes itself into the `Microsoft.Intune.Tunnel.MAM.iOS.MicrosoftTunnel.SharedInstance.MicrosoftTunnelInitialize` method to start the SDK initialization.

* The final integration point is found in [AppDelegate.cs](Xamarin/XamarinTunnel/XamarinTunnel.iOS/AppDelegate.cs). It calls the `MicrosoftTunnelDelegate.Launch` method from within the `FinishedLaunching` method.

## Troubleshooting

### Provisioning problems
Follow the steps outlined [here](https://learn.microsoft.com/en-us/xamarin/ios/get-started/installation/device-provisioning/free-provisioning?tabs=macos) if you have problems provisioning the application