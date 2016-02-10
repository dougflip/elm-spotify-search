module SpotifySearch (..) where

import Html exposing (..)
import Html.Attributes exposing (id, type', for, value, class, placeholder, autofocus, src)
import Html.Events exposing (on, onWithOptions, targetValue)
import Effects exposing (Effects, Never)
import String exposing (join)
import Json.Decode as Json
import AlbumSearchService
import Task


init : ( Model, Effects Action )
init =
  ( { query = "", submittedQuery = "", albumUrls = [ ] }
  , Effects.none
  )



-- MODEL


type alias Model =
  { query : String
  , submittedQuery : String
  , albumUrls : List String
  }



-- UPDATE


type Action
  = Submit
  | UpdateQuery String
  | Results (Maybe (List String))


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Submit ->
      ( { model | query = "", submittedQuery = model.query }, fetchAlbums model.query )

    UpdateQuery text ->
      ( { model | query = text }, Effects.none )

    Results maybeAlbums ->
      ( { model | albumUrls = Maybe.withDefault [ "I guess there was an error" ] maybeAlbums }
      , Effects.none
      )



-- VIEW


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class "spotify-search-container" ]
    [ form
        [ submitForm address, class "spotify-search-form" ]
        [ input
            [ class "spotify-search-form-input"
            , type' "text"
            , placeholder "Search for an album..."
            , autofocus True
            , value model.query
            , on "input" targetValue (Signal.message address << UpdateQuery)
            ]
            []
        ]
    , div
        [ class "spotify-search-submitted-query" ]
        [ text model.submittedQuery ]
    , div
        [ class "spotify-search-album-list" ]
        (renderAlbumImages model.albumUrls)
    ]


renderAlbumImages : List String -> List Html
renderAlbumImages =
  List.map (\x -> img [ src x ] [])


submitForm : Signal.Address Action -> Html.Attribute
submitForm address =
  preventDefaultOf "submit" address Submit


preventDefaultOf : String -> Signal.Address Action -> Action -> Html.Attribute
preventDefaultOf evt address action =
  onWithOptions
    evt
    { preventDefault = True, stopPropagation = True }
    (Json.succeed Nothing)
    (\_ -> Signal.message address action)



-- EFFECTS


fetchAlbums : String -> Effects Action
fetchAlbums query =
  AlbumSearchService.fetchAlbums query
    |> Task.toMaybe
    |> Task.map Results
    |> Effects.task
