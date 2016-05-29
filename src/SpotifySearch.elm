module SpotifySearch exposing (initModel, view, update, subscriptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Task exposing (..)


-- MODEL

initModel : Model
initModel = Model "Rush" "" [AlbumResult ""]

type alias AlbumResult =
    { imageUrl: String }

type alias Model =
    { query: String, submittedQuery: String, albums: List AlbumResult }


-- UPDATE

type Msg
    = Input String
    | Submit String
    | SearchSucceed String
    | SearchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    Input query -> ({ model | query = query }, Cmd.none)
    Submit query -> ({ model | query = "", submittedQuery = query }, searchAlbum query)
    SearchSucceed data -> (model, Cmd.none)
    SearchFail errMsg -> (model, Cmd.none)

-- SUBSCRIPTION

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ Html.form [onSubmit <| Submit model.query]
            [ input [ placeholder "Search an album...", value model.query, onInput Input ] []
            , div [] [text <| "Search: " ++ model.submittedQuery]
            ]
        ]


searchAlbum : String -> Cmd Msg
searchAlbum query =
  let
    url =
      Http.url "https://api.spotify.com/v1/search"
          [ ("q", query)
          , ("type", "album")]
  in
    Task.perform SearchFail SearchSucceed (Http.getString url)
