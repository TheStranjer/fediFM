if [ `echo $1 | wc -m` -eq 1 ]
then
	echo "No config file submitted, aborting"
	exit
fi

configfn=$1
config=`cat $configfn`

lastfm_api=`echo $config | jq -r '.lastfm_api'`
lastfm_user=`echo $config | jq -r '.lastfm_user'`
pleroma_instance=`echo $config | jq -r '.pleroma_instance'`
pleroma_bearer=`echo $config | jq -r '.pleroma_bearer'`
stored_total=`echo $config | jq -r '.total'`

lastfm_api_result=`curl "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$lastfm_user&api_key=$lastfm_api&format=json&limit=1"`
echo $lastfm_api_result

total=`echo $lastfm_api_result | jq -r '."recenttracks"."@attr".total'`

saveresults () {
	saveres=`jq -n --arg api "$lastfm_api" --arg user "$lastfm_user" --arg instance "$pleroma_instance" --arg bearer "$pleroma_bearer" --arg tot "$total" '{lastfm_api: $api, lastfm_user: $user, pleroma_instance: $instance, pleroma_bearer: $bearer, total: $tot|tonumber}'`
  if [ -z "$saveres" ]
  then
    echo "Results blank, aborting"
    exit
  else
    echo "$saveres" > $configfn
  fi
}

if [ "$stored_total" = "null" ]
then
	echo "No value yet. Storing total of $total for future use."
	saveresults
	exit
fi

if [ $total -eq $stored_total ]
then
	echo "No change since last time; exiting"
	exit
fi

artist=`echo $lastfm_api_result | jq -r '.recenttracks.track' | jq -r '.[0].artist."#text"' | perl -MHTML::Entities -pe 'decode_entities($_);'`
title=`echo $lastfm_api_result | jq -r '.recenttracks.track' | jq -r '.[0].name' | perl -MHTML::Entities -pe 'decode_entities($_);'`
album=`echo $lastfm_api_result | jq -r '.recenttracks.track' | jq -r '.[0].album."#text"' | perl -MHTML::Entities -pe 'decode_entities($_);'`
url=`echo $lastfm_api_result | jq -r '.recenttracks.track' | jq -r '.[0].url'`

echo "ARTIST: $artist TITLE: $title ALBUM: $album"

if [ "$artist" = "null" ] || [ "$title" = "null" ] || [ "$album" = "null" ] || [ -z "$lastfm_api_result" ] || [ "$artist" = "" ] || [ "$title" = "" ]
then
	echo "null output, skipping"
	exit
fi


json=`jq -n --arg art "$artist" --arg tit "$title" --arg alb "$album" --arg url "$url" '{artist: $art, title: $tit, album: $alb, url: $url}'`

echo $json

curl -X POST "https://$pleroma_instance/api/v1/pleroma/scrobble" \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $pleroma_bearer" \
	-d "$json"

echo "Submitted scrobble"

saveresults

