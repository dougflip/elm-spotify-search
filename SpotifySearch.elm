module SpotifySearch where

import Html exposing (..)
import Html.Attributes exposing (id, type', for, value, class, placeholder, autofocus)
import Html.Events exposing (on, onWithOptions, targetValue)
import Effects exposing (Effects, Never)
import Json.Decode as Json
import Http
import Task

init : (Model, Effects Action)
init =
    ({ query = "", submittedQuery = "", albumUrls = "" }
    , Effects.none
    )

-- MODEL
type alias Model =
    { query: String
    , submittedQuery: String
    , albumUrls: String
    }

-- UPDATE
type Action =
    Submit | UpdateQuery String | Results (Maybe String)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Submit -> ({ model | query = "", submittedQuery = model.query  }, fetchAlbum model.query)
    UpdateQuery text -> ({ model | query = text }, Effects.none)
    Results maybeAlbums ->
        ({ model | albumUrls = Maybe.withDefault "I guess there was an error" maybeAlbums }
        , Effects.none
        )

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
    , div []
        [ text ("Albums: " ++ model.albumUrls) ]
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
fetchAlbum : String -> Effects Action
fetchAlbum query =
  Http.get decodeUrl (albumUrl query)
    |> Task.toMaybe
    |> Task.map Results
    |> Effects.task

albumUrl : String -> String
albumUrl query =
  Http.url "https://api.spotify.com/v1/search"
    [ ("q", query)
    , ("type", "album")
    ]

decodeUrl : Json.Decoder String
decodeUrl =
  Json.at ["albums", "href"] Json.string
