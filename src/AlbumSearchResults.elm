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
    , resultsOrEmpty images
    ]


resultsOrEmpty : List String -> Html
resultsOrEmpty images =
  if List.isEmpty images then
    emptyResults
  else
    albums images


emptyResults : Html
emptyResults =
  div
    [ class "spotify-search-empty-results" ]
    [ text "Sorry! No results matched your search. Try another?" ]


albums : List String -> Html
albums images =
  div
    [ class "spotify-search-album-list" ]
    (List.map albumImage images)


albumImage : String -> Html
albumImage x =
  img [ src x ] []
