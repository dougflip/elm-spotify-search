module SpotifySearch where

import Html exposing (..)
import Html.Attributes exposing (id, type', for, value, class, placeholder, autofocus, src)
import Html.Events exposing (on, onWithOptions, targetValue)
import Effects exposing (Effects, Never)
import String exposing (join)
import Json.Decode as Json
import Http
import Task

init : (Model, Effects Action)
init =
    ({ query = "", submittedQuery = "", albumUrls = [""] }
    , Effects.none
    )

-- MODEL
type alias Model =
    { query: String
    , submittedQuery: String
    , albumUrls: List String
    }

-- UPDATE
type Action =
    Submit | UpdateQuery String | Results (Maybe (List String))

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Submit -> ({ model | query = "", submittedQuery = model.query  }, fetchAlbum model.query)
    UpdateQuery text -> ({ model | query = text }, Effects.none)
    Results maybeAlbums ->
        ({ model | albumUrls = Maybe.withDefault ["I guess there was an error"] maybeAlbums }
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
        ]
    , div []
        [ text model.submittedQuery ]
    , div []
        (renderAlbumImages model.albumUrls)
    ]

renderAlbumImages : List String -> List Html
renderAlbumImages =
    List.map (\x -> img [src x] [])

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
  Http.get decodeAllImages (albumUrl query)
    |> Task.toMaybe
    |> Task.map Results
    |> Effects.task

albumUrl : String -> String
albumUrl query =
  Http.url "https://api.spotify.com/v1/search"
    [ ("q", query)
    , ("type", "album")
    ]

-- JSON Decoding
decodeImageUrl : Json.Decoder String
decodeImageUrl =
    Json.at ["url"] Json.string

pluckFirstImage : List String -> String
pluckFirstImage =
    Maybe.withDefault "" << List.head

decodeAlbumImage : Json.Decoder String
decodeAlbumImage =
    Json.at ["images"] <| Json.map pluckFirstImage <| Json.list decodeImageUrl

decodeAllImages : Json.Decoder (List String)
decodeAllImages =
    Json.at ["albums", "items"] <| Json.list decodeAlbumImage
