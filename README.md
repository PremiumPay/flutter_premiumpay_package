# flutter_premiumpay_package

Flutter package to help you add premium features in your app using the [PremiumPay platform](https://premiumpay.site)

## Getting Started

1. See [PremiumPay site instructions](https://premiumpay.site) for connecting to / creating your Stripe Account

1. Add dependency to `flutter_premiumpay_package`

1. Add `import 'package:flutter_premiumpay_package/flutter_premiumpay_package.dart';` to your dart code

1. Use the exported variable `premiumPayAPI` and see below API usage summary & Flow and dart documentation in [api/doc/](api/doc/)


## API usage summary & Flow

Typically, the first thing to do is to generate a random installId and to store this value for all the life of your App (like storing its value in secure storage):

`premiumPayAPI.createInstallId()`  is provided for that (but it is your responsability to provide a unique value and you can use your own generator).

Somewhere in your App you propose the user to link this installation to his account. This is done by capturing the user email (which you must store somewhere).

Then you issue a `premiumPayAPI.connectRequest()` which require several parameters you need to provide(notably the installId and the user email) which result in sending him an email to obtain confirmation for his email and for creating the account if necessary.

The user access his account, and can activate or buy features from there which is generating tokens related to this installation. 

You must then offer him to click on a 'Sync' button which will issue a `premiumPayAPI.syncRequest()` to retrieve the related tokens.

Then you must verify the tokens using `premiumPayAPI.verifyToken()` to verify if it is related to one of your restricted features and you need to store them and to  verify them on your App start or when needed.

Enjoy!

For any question, you can ask the [support team](mailto:support@premiumpay.site).


## Generate api/doc yourself on a cloned repository

1. Install dartdoc using command `pub global activate dartdoc`.
2. Run command `flutter pub global run dartdoc:dartdoc` from the root of your cloned repository.




