lastfm_api=`cat .lastfm_api.dat`
lastfm_user=`cat .lastfm_user.dat`
pleroma_instance=`cat .pleroma_instance.dat`
pleroma_bearer=`cat .pleroma_bearer.dat`

lastfm_api_result=`curl "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$lastfm_user&api_key=$lastfm_api&format=json&limit=1"`

echo $lastfm_api_result > ~/example.json

total=`echo $lastfm_api_result | jq -r '."recenttracks"."@attr".total'`

stored_total=`cat .total.dat`

if [ -z $stored_total ]
then
	echo "No value yet. Storing total of $total for future use."
	echo $total > .total.dat
	exit
fi

if [ $total -eq $stored_total ]
then
	echo "No change since last time; exiting"
	exit
fi

artist=`echo $lastfm_api_result | jq -r '.recenttracks.track' | jq -r '.[0].artist."#text"'`
title=`echo $lastfm_api_result | jq -r '.recenttracks.track' | jq -r '.[0].name'`
album=`echo $lastfm_api_result | jq -r '.recenttracks.track' | jq -r '.[0].album."#text"'`

echo "ARTIST: $artist TITLE: $title ALBUM: $album"

json=`jq -n --arg art "$artist" --arg tit "$title" --arg alb "$album" '{artist: $art, title: $tit, album: $alb}'`

echo $json

curl -X POST "https://$pleroma_instance/api/v1/pleroma/scrobble" \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer $pleroma_bearer" \
	-d "$json"

echo "Submitted scrobble"

echo $total > .total.dat

