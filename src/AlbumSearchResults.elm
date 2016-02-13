module AlbumSearchResults (Model, view, loading, toSearchResult) where

import Html exposing (..)
import Html.Attributes exposing (..)


type SearchResult
  = Loading
  | Empty
  | Results (List String)


type alias Model =
  { query : String, results : SearchResult }


loading : String -> Model
loading query =
  Model query Loading


toSearchResult : String -> List String -> Model
toSearchResult query imageUrls =
  case imageUrls of
    [] ->
      Model query Empty

    _ ->
      Model query (Results imageUrls)


view : Model -> Html
view { query, results } =
  div
    []
    [ div
        [ class "spotify-search-submitted-query" ]
        [ text query ]
    , case results of
        Loading ->
          div [] [ text "Loading..." ]

        Empty ->
          emptyResults

        Results imageUrls ->
          albums imageUrls
    ]


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
