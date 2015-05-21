
# philosophie-password-app

This is a simple Twitter bot that evaluates password strength. Run the bot attached to an account, then tweet @ it. It will reply with information about the strength of the password contained in the tweet's body. If a password is weak but still viable, it may suggest stronger, alternative passwords instead.

## Running the bot

The bot itself runs on Node.js. To run it, download the repository, then install the dependencies and build the project.

```bash
cd philosophie-password-app
npm install
npm run build
```
The bot pulls in information from environment variables in order to configure itself properly. It references the following variables:

- `TWITTER_SCREEN_NAME` — The username of the Twitter account
- `TWITTER_CONSUMER_KEY` and `TWITTER_CONSUMER_SECRET` — The consumer app key and secret for the Twitter API
- `TWITTER_ACCESS_TOKEN_KEY` and `TWITTER_ACCESS_TOKEN_SECRET` — The access token key and secret for the Twitter API

With the environment properly configured, just run `npm start`, and the bot will start listening for tweets.
