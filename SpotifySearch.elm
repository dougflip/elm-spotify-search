module SpotifySearch where

import Html exposing (..)
import Html.Attributes exposing (id, type', for, value, class, placeholder)
import Html.Events exposing (onWithOptions)
import Json.Decode
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
        [ submitForm address ]
        [ input
            [ type' "text"
            , placeholder "Search for an album..."
            , value model.query
            ]
            []
        , button
            [ type' "button" ]
            [text "Click to Search"]
        ]

submitForm : Signal.Address Action -> Html.Attribute
submitForm address =
    preventDefaultOf "submit" address Submit

preventDefaultOf : String -> Signal.Address Action -> Action -> Html.Attribute
preventDefaultOf evt address action =
    onWithOptions
        evt
        { preventDefault = True, stopPropagation = True }
        (Json.Decode.succeed Nothing)
        (\_ -> Signal.message address action)
