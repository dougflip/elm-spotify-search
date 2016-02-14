module SpotifySearch (init, update, view) where

import AlbumSearchService
import AlbumSearchResults exposing (loading, toSearchResult)
import String
import Task
import Html exposing (..)
import Html.Attributes exposing (id, type', for, value, class, classList, placeholder, autofocus)
import Html.Events exposing (on, onWithOptions, targetValue)
import Effects exposing (Effects, Never)
import Json.Decode as Json


init : ( Model, Effects Action )
init =
  ( { query = "", isSubmitted = False, results = toSearchResult "" [] }
  , Effects.none
  )



-- MODEL


type alias Model =
  { query : String
  , isSubmitted : Bool
  , results : AlbumSearchResults.Model
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
      ( { model
          | query = ""
          , isSubmitted = True
          , results = loading model.query
        }
      , fetchAlbums model.query
      )

    UpdateQuery text ->
      ( { model
          | query = text
        }
      , Effects.none
      )

    Results maybeAlbums ->
      ( { model
          | results = toSearchResult model.query <| Maybe.withDefault [ "There was an error - I can handle this better" ] maybeAlbums
        }
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
            [ classList
                [ ( "spotify-search-form-input", True )
                , ( "is-submitted", model.isSubmitted )
                ]
            , type' "text"
            , placeholder "Search for an album..."
            , autofocus True
            , value model.query
            , on "input" targetValue (Signal.message address << UpdateQuery)
            ]
            []
        ]
    , if model.isSubmitted then
        AlbumSearchResults.view model.results
      else
        text ""
    ]


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
