module AlbumSearchResults (view) where

import Html exposing (..)
import Html.Attributes exposing (..)


view : String -> List String -> Html
view query images =
  div
    []
    [ div
        [ class "spotify-search-submitted-query" ]
        [ text query ]
    , div
        [ class "spotify-search-album-list" ]
        (renderAlbumImages images)
    ]


renderAlbumImages : List String -> List Html
renderAlbumImages =
  List.map (\x -> img [ src x ] [])
