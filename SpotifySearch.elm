module SpotifySearch where

import Html exposing (..)
import Html.Attributes exposing (id, type', for, value, class, placeholder)
import Html.Events exposing (onClick)
import Json.Decode as Json
import StartApp.Simple exposing (start)

main =
    start { model = { query = "" }, update = update, view = view }

-- MODEL
type alias Model =
    { query: String }

-- UPDATE
type Action = Submit

update : Action -> Model -> Model
update action model =
  case action of
    Submit -> { model | query = "SUBMITTED!!!"  }

-- VIEW
view : Signal.Address Action -> Model -> Html
view address model =
    form
        []
        [ input
            [ type' "text"
            , placeholder "Search for an album..."
            , value model.query
            ]
            []
        , button
            [ type' "button"
            , onClick address Submit
            ]
            [text "Click to Search"]
        ]
