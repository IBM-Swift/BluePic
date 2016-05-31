# BluePic

**This repo is not ready for consumption yet and please note that this README is still under construction This is a new development effort that has not completed yet. If you are looking for the Kitura-BluePic repo, please visit this URL: https://github.com/IBM-Swift/Kitura-BluePic.**

BluePic is a photo and image sharing sample application that allows you to take photos and share them with other BluePic users. This sample application demonstrates how to leverage a Kitura-based server application [written in Swift] in a mobile iOS 9 application.

## Getting started

There are two ways you can compile and provision BluePic on Bluemix. The first approach uses the IBM Cloud Bridge tool. Using the IBM Cloud Bridge tool is the easiest and quickest path to get BluePic up and running. The second approach is manual, does not leverage this  tool, and, therefore, takes longer but you get to understand exactly the steps that are happening behind the scenes.

### IBM Cloud Bridge
TODO: ADD Contents

### Step by step instructions for configuration and deployment
Instead of using the IBM Cloud Bridge, which gives you a seamless compilation and provisioning experience, you can follow the steps outlined in this section if you'd like to take a peek under the hood!

#### 1. Install system dependencies

The following system level dependencies should be installed on OS X using [Homebrew](http://brew.sh/):

```bash
brew install curl
```

If you are using Linux as your development platform, you can find full details on how to set up your environment for building Kitura-based applications at [Getting started with Kitura](https://github.com/IBM-Swift/Kitura).

#### 2. Clone the BluePic Git repository

Execute the following command to clone the Git repository:

```bash
git clone https://github.com/IBM-Swift/BluePic.git
```

If you'd like to, you can spend a few minutes to get familiar with the folder structure of the repo as described in the [About](Docs/About.md) page.

#### 3. Create BluePic application on Bluemix

Clicking on the button below deploys the BluePic application to Bluemix. The `manifest.yml` file [included in the repo] is parsed to obtain the name of the application and to determine the Cloud Foundry services that should be instantiated. For further details on the structure of the `manifest.yml` file, see the [Cloud Foundry documentation](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html#minimal-manifest).

[![Deploy to Bluemix](https://bluemix.net/deploy/button.png)](https://bluemix.net/deploy)

Once deployment to Bluemix is completed, you should access the route assigned to your application using the web browser of your choice. You should see the Kitura welcome page!

Note that the [Bluemix buildpack for Swift](https://github.com/IBM-Swift/swift-buildpack) is used for the deployment of BluePic to Bluemix.

#### 4. Populate Cloudant database

To populate your Cloudant database instance with sample data, execute the `populator.sh` script in the `./Bridge-Scripts/cloudantNoSQLDB/` directory. Please note that this script requires three parameters:

- `username` - The username for your Cloudant instance.
- `password` - The password for your Cloudant instance.
- `projectid` - The project ID for your Object Storage instance.

You can obtain the above credentials by accessing your application's page on Bluemix and clicking on the `Show Credentials` twisty found on your Cloudant service and Object Storage service instances. Once you have these credentials, execute the `populator.sh` script:

```bash
./Bridge-Scripts/cloudantNoSQLDB/populator.sh --username=<cloudant username> --password=<cloudant password> --projectid=<object storage projectid>

```

#### 5. Populate Object Storage

To populate your Object Storage instance with sample data, execute the `populator.sh` script in the `./Bridge-Scripts/Object-Storage/` directory. Please note that this script requires three parameters:

- `userid` - The username for your Object Storage instance.
- `password` - The password for your Object Storage instance.
- `projectid` - The project ID for your Object Storage instance.

You can obtain the above credentials by accessing your application's page on Bluemix and clicking on the `Show Credentials` twisty found on your Object Storage instance. Once you have these credentials, execute the `populator.sh` script:

```bash
./Bridge-Scripts/Object-Storage/populator.sh --userid=<object storage username> --password=<object storage password> --projectid=<object storage projectid>
```

#### 6. Update `BluePic-Server/config.json` file

You should now update the credentials for each one of the services listed in the `BluePic-Server/config.json` file. Doing so will allow you to run the Kitura-based server locally for development and testing purposes. You will find placeholders in the `config.json` file (e.g. `<username>`, `<projectId>`) for each of the credential values that should be provided.

Remember that you can obtain the credentials for each service listed in the `config.json` file by accessing your application's page on Bluemix and clicking on the `Show Credentials` twisty found on each of the service instances bound to the BluePic app.

You can take a look at the contents of the `config.json` file by clicking [here](BluePic-Server/config.json).

#### 7. Create an application instance on Facebook

In order to have the app authenticate with Facebook, you must create an application instance on Facebook's website and connect it to your Bluemix app's Mobile Client Access.

1. Go to the BluePic-iOS directory and open the BluePic workspace with Xcode using `open BluePic.xcworkspace`.

1. We will need to update the bundle identifier in the Xcode project. To do this, make sure the project navigator folder icon is selected in the top left of Xcode; then select the BluePic project at the top of the file structure and then select the BluePic target. Under the identity section, you should see a text field for the bundle identifier. Update this field with a bundle identifier of your choosing. (ie. com.bluepic)

1. To create an application instance on Facebook's Developer website, first go to [Facebook's Quick Start for iOS](https://developers.facebook.com/quickstarts/?platform=ios) page. Type 	`BluePic` as the name of your new Facebook app and click the `Create New Facebook App ID` button. Choose any Category for the application, and click the `Create App ID` button.

1. On the screen that follows, note that you **do not** need to download the Facebook SDK. The Mobile Client Access framework (already included in the iOS project) has all the code needed to support Facebook authentication. In the `Configure your info.plist` section, under `step 2`, copy the fields shown in the xml snippet into your `info.plist` file. You can find the `info.plist` file in `Configuration` folder of the Xcode project. If you have trouble finding the `CFBundleURLType` key, note that Xcode changes the `CFBundleURLType` key to `URL types` when the key is entered. Your `info.plist` file should now look like this:
<p align="center"><img src="Imgs/infoplist.png"  alt="Drawing" height=150 border=0 /></p>

1. Next, scroll to the bottom of the quick start page where it says `Supply us with your Bundle Identifier` and enter the app's Bundle Identifier you chose in `step 2` of this section. 

1. Once you have entered the Bundle Identifier on the Facebook quick start page, that's it for setting up the BluePic application instance on the Facebook Developer website. In the next section we will link this Facebook application instance to your Bluemix Mobile Client Access service.

#### 8. Configure Bluemix Mobile Client Access

1. Go to your Bluemix dashboard, under services section click the `Mobile Client Access` service:
<p align="center"><img src="Imgs/mobile-client-access-service.png"  alt="Drawing" height=125 border=0 /></p>

1. On the page that follows click the `configure` button under the Facebook section. 
<p align="center"><img src="Imgs/configure-facebook-button.png"  alt="Drawing" height=125 border=0 /></p>

1. On the next page, enter your Facebook appication ID you gathered from [step 4 of section 7 (Create an application instance on Facebook)](#7-create-an-application-instance-on-facebook) of this README. Press the save button.

<p align="center"><img src="Imgs/facebook-mca-setup.png"  alt="Drawing" height=250 border=0 /></p>

Facebook Authentication with Bluemix Mobile Client Acess is now completely set up. No further steps are required.

#### 9. Configure Bluemix Push service

To utilize push notification capabilities on Bluemix, you need to configure a notification provider. For BluePic, you should configure credentials for the Apple Push Notification Service (APNS). As part of this configuration step, you will need to use the **bundle identifier** you chose in [step 2 of section 7 (Create an application instance on Facebook)](#7-create-an-application-instance-on-facebook). Take note of this **bundle identifier**, you will need it for the steps below.

Luckily, Bluemix has [instructions](https://console.ng.bluemix.net/docs/services/mobilepush/t_push_provider_ios.html) to walk you through that process. Please note that you'd need to upload a `.p12` certificate to Bluemix and enter the password for it, as described in the Bluemix instructions.

Lastly, remember that push notifications will only show up on a physical iOS device.


#### 10. Configure OpenWhisk

TODO: ADD CONTENTS

#### 11. Build the BluePic-Server

You can now build the BluePic-Server by going to the `BluePic-Server` directory of the cloned repository and running `make`.

#### 12. Run the BluePic-Server

To start the Kitura-based server for the BluePic app, go to the `BluePic-Server` directory of the cloned repository and run `.build/debug/Server`.

#### 13. Update configuration for iOS app

Go to the BluePic-iOS directory and open the BluePic workspace with Xcode using `open BluePic.xcworkspace`.

 Let's finally update the `bluemix.plist` in the Xcode project.  You can find this file in `Configuration` folder of the Xcode project.
 
1. You can set the `isLocal` value to `YES` if you want to use a locally running server or set the value to `NO` if you want to use your server instance running on Bluemix.

2. You shouldn't have to change the `appRouteLocal` value, it is using the default port for Kitura.

3. To get the `appRouteRemote` and `bluemixAppGUID` value, you need to go to your Bluemix dashboard and open the application you created in [step 3](#3-create-bluepic-application-on-bluemix). Once on your application's page, there should be a "Mobile Options" button near the top right, that you can tap on. It should then open up a view that displays your Route which maps to the `appRouteRemote` key in the plist. You will also see a App GUID value which maps to the `bluemixAppGUID` key in the plist.

4. Lastly, we need to get the value for `bluemixAppRegion`, which can be one of three options currently: 

		REGION US SOUTH | REGION UK | REGION SYDNEY
		--- | --- | ---
		`.ng.bluemix.net` | `.eu-gb.bluemix.net` | `.au-syd.bluemix.net`
		
You can find the one you need in multiple ways, the first, by just looking at the URL you use to access your Bluemix dashboard. Another way is to look at the `config.json` file you modifed earlier. If you look at the credentials under your `AdvancedMobileAccess` service, there is a value called `serverUrl` which should contain one of the regions mentioned above. Once you insert your `bluemixAppRegion` value into the `bluemix.plist`, your app should be configured.

#### 14. Run the iOS app

If you don't have the iOS project already open, go to the BluePic-iOS directory and open the BluePic workspace using `open BluePic.xcworkspace`.

You can now build and run the iOS app using the Xcode capabilities you are used to!

## About BluePic

To learn more about BluePic's folder structure, its architecture, the Swift packages it depends on, and details on how to use the iOS app, see the [About](Docs/About.md) page.

## License

This application is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE).
