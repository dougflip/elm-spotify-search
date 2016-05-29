module AlbumSearchService exposing (fetchAlbums)

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


pluckSecondImage : List String -> String
pluckSecondImage =
  Maybe.withDefault "" << List.head << List.drop 1


decodeAlbumImage : Json.Decoder String
decodeAlbumImage =
  Json.at [ "images" ] <| Json.map pluckSecondImage <| Json.list decodeImageUrl


decodeAllImages : Json.Decoder (List String)
decodeAllImages =
  Json.at [ "albums", "items" ] <| Json.list decodeAlbumImage
