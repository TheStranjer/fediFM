# fediFM

This is a Last.fm to fediverse (Pleroma) scrobble bridge. You need to get a Last.fm API key and a Pleroma account to use this.

# Installing

1. Clone the repository wherever you need it to be
2. Enter the directory it's in
3. Edit JSON file to reflect your credentials (see below)
4. Install `jq` and `curl` (on Ubuntu it's `sudo apt install jq curl -y`)
5. Create a cron job that looks like this: `* * * * * cd /wherever/you/cloned/this/fedifm.sh /your/config/file.json`
6. Enjoy!

# Config file

The config file should come in the following shape:

```json
{
  "lastfm_api": "your lastfm api key here",
  "lastfm_user": "your lastfm username here",
  "pleroma_instance": "your instance, eg., whatever.com",
  "pleroma_bearer": "your bearer token"
}
```
