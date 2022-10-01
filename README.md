# PostThis
A simple toy social media app. Users can create accounts, upload posts with images, add comments to posts, like comments and posts, and follow other users to get a personalised feed.
Demonstrates MVVM architecture, Protocol Oriented Programming, interacting with a REST API, and concurrency with async/await.

This repo only contains the app. To use the app, you also need to run the PostThisAPI repo on localhost:8081/api with a PostgreSQL database. If you want to change the URL of the API, you can do so in the APIEnvironment file, with the APIEnvironment.production constant.

To start using it, you will first need to create an account with the landing view. Currently the email header is a dummy field. You can put whatever you want in it.

As of September 2022, running this project will generate a warning of "Publishing changes from within view updates is not allowed, this will cause undefined behavior." This warning is being reported a great deal after the Xcode update, and may be an issue with Apple. Because it doesn't seem to impact functionality, I have chosen to leave it for the moment.




