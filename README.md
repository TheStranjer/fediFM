# fediFM

This is a Last.fm to fediverse (Pleroma) scrobble bridge. You need to get a Last.fm API key and a Pleroma account to use this.

# Installing

1. Clone the repository wherever you need it to be
2. Enter the directory it's in
3. Edit `.lastfm_api.dat` with the API key from Last.fm
4. Edit `.lastfm_user.dat` with your Last.fm username
5. Edit `.pleroma_instance.dat` with your Pleroma instance, like `shitposter.club`
6. Edit `.pleroma_bearer.dat` with your account's bearer token (DO NOT SHARE THIS WITH ANYBODY)
7. Install `jq` (on Ubuntu it's `sudo apt install jq -y`)
8. Create a cron job that looks like this: `* * * * * cd /wherever/you/cloned/this && ./fedifm.sh`
9. Enjoy!

