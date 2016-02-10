module AlbumSearchService (fetchAlbums) where

import Json.Decode as Json
import Task
import Http


fetchAlbums : String -> Task.Task Http.Error (List String)
fetchAlbums query =
  Http.get decodeAllImages <| albumUrl query


albumUrl : String -> String
albumUrl query =
  Http.url
    "https://api.spotify.com/v1/search"
    [ ( "q", query )
    , ( "type", "album" )
    ]


decodeImageUrl : Json.Decoder String
decodeImageUrl =
  Json.at [ "url" ] Json.string


pluckFirstImage : List String -> String
pluckFirstImage =
  Maybe.withDefault "" << List.head


decodeAlbumImage : Json.Decoder String
decodeAlbumImage =
  Json.at [ "images" ] <| Json.map pluckFirstImage <| Json.list decodeImageUrl


decodeAllImages : Json.Decoder (List String)
decodeAllImages =
  Json.at [ "albums", "items" ] <| Json.list decodeAlbumImage
