module SpotifySearch exposing (initModel, view, update, subscriptions)

import AlbumSearchService exposing (..)

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
    = SearchInput String
    | Submit String
    | SearchSucceed (List AlbumResult)
    | SearchFail Http.Error

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    SearchInput query -> ({ model | query = query }, Cmd.none)
    Submit query -> ({ model | query = "", submittedQuery = query }, searchAlbum query)
    SearchSucceed albumResults -> ({ model | albums = albumResults }, Cmd.none)
    SearchFail errMsg -> (model, Cmd.none)

-- SUBSCRIPTION

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ Html.form [onSubmit <| Submit model.query]
            [ input [ placeholder "Search an album...", value model.query, onInput SearchInput ] []
            , button [type' "submit"] [text "go"]
            ]
        , div [] [text <| "Search: " ++ model.submittedQuery]
        , div [] (List.map (\x -> img [src x.imageUrl] []) model.albums)
        ]



searchAlbum : String -> Cmd Msg
searchAlbum query =
    Task.perform SearchFail SearchSucceed <| Task.map (List.map AlbumResult) <| fetchAlbums query
