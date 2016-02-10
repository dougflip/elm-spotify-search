module SpotifySearch where

import Html exposing (..)
import Html.Attributes exposing (id, type', for, value, class, placeholder, autofocus)
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
        , button
            [ type' "button" ]
            [text "Click to Search"]
        ]
    , div []
        [ text model.submittedQuery ]
    , div []
        [ text ("Albums: " ++ (join ", " model.albumUrls)) ]
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
  Http.get decodeAlbumTypeList (albumUrl query)
    |> Task.toMaybe
    |> Task.map Results
    |> Effects.task

albumUrl : String -> String
albumUrl query =
  Http.url "https://api.spotify.com/v1/search"
    [ ("q", query)
    , ("type", "album")
    ]

-- type alias Image =
--     { url: String }
--
-- decodeUrl : Json.Decode String
-- decodeUrl =
--     Json.at ["url"] Json.string
--
-- decodeImage : Json.Decoder String
-- decodeImage =
--     Json.at ["url"] Json.string
--
-- decodeImages : Json.Decoder (List String)
-- decodeImages =
--     Json.at ["images"] (Json.list decodeImage)
--
-- decodeAlbumImages : Json.Decoder (List String)
-- decodeAlbumImages =
--     Json.at ["albums", "items"] (Json.list decodeImages)
--
-- decodeAlbumName : Json.Decoder String
-- decodeAlbumName =
--     Json.at ["name"] Json.string

-- decodeAlbumType : Json.Decoder String
-- decodeAlbumType =
--     Json.at ["album_type"] Json.string
--
decodeAlbumTypeList : Json.Decoder (List String)
decodeAlbumTypeList =
    Json.at ["albums", "items"] (Json.list (Json.at ["album_type"] Json.string))

decodeHref : Json.Decoder (List String)
decodeHref =
    Json.at ["albums", "href"] (Json.map (\x -> [x]) Json.string)
