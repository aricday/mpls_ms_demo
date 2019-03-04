FROM mongo:3.3.15

COPY beer_comments.json /beer_comments.json
CMD mongoimport --host mongo_beer_comments --db beer_comments --collection beer_comments --type json --file /beer_comments.json --jsonArray
