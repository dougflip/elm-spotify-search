module SpotifySearch where

import Html exposing (..)
import Html.Attributes exposing (id, type', for, value, class, placeholder, autofocus)
import Html.Events exposing (on, onWithOptions, targetValue)
import Effects exposing (Effects, Never)
import Task
import Json.Decode
import StartApp

app =
    StartApp.start
        { init = init
        , update = update
        , view = view
        , inputs = []
        }

main =
    app.html

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

init : (Model, Effects Action)
init =
    ({ query = "", submittedQuery = ""}
    , Effects.none
    )

-- MODEL
type alias Model =
    { query: String
    , submittedQuery: String
    }

-- UPDATE
type Action =
    Submit | UpdateQuery String

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Submit -> ({ model | query = "", submittedQuery = model.query  }, Effects.none)
    UpdateQuery text -> ({ model | query = text }, Effects.none)

-- VIEW
view : Signal.Address Action -> Model -> Html
view address model =
    div []
    [ form [ submitForm address ]
        [ input
            [ type' "text"
            , placeholder "Search for an album..."
            , autofocus True
            , value model.query
            , on "input" targetValue (Signal.message address << UpdateQuery)
            ]
            []
        , button
            [ type' "button" ]
            [text "Click to Search"]
        ]
    , div []
        [ text model.submittedQuery ]
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
