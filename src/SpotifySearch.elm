module SpotifySearch exposing (initModel, view, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL

initModel : Model
initModel = Model "Rush" "" [AlbumResult ""]

type alias AlbumResult =
    { imageUrl: String }

type alias Model =
    { query: String, submittedQuery: String, albums: List AlbumResult }


-- UPDATE

type Msg =
    Submit String | Input String

update : Msg -> Model -> Model
update msg model = case msg of
    Input query -> { model | query = query }
    Submit query -> { model | query = "", submittedQuery = query }

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ Html.form [onSubmit <| Submit model.query]
            [ input [ placeholder "Search an album...", value model.query, onInput Input ] []
            , div [] [text <| "Search: " ++ model.submittedQuery]
            ]
        ]
