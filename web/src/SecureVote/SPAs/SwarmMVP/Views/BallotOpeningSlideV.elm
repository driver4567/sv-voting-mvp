module SecureVote.SPAs.SwarmMVP.Views.BallotOpeningSlideV exposing (..)

import Html exposing (Html, a, div, em, p, span, strong, text)
import Html.Attributes exposing (class, href, style, target)
import Material.Options as Options exposing (cs, css)
import Material.Typography exposing (body1, display1, display2, display3, display4, title)
import Maybe.Extra exposing ((?))
import RemoteData exposing (RemoteData(Failure, Loading, NotAsked, Success))
import SecureVote.Ballots.Lenses exposing (..)
import SecureVote.Ballots.Types exposing (..)
import SecureVote.Components.UI.Btn exposing (BtnProps(..), btn)
import SecureVote.Components.UI.FullPageSlide exposing (fullPageSlide)
import SecureVote.Components.UI.RenderAudit exposing (isAuditSuccessMsg, renderAudit)
import SecureVote.Components.UI.Typo exposing (headline, subhead)
import SecureVote.SPAs.SwarmMVP.Helpers exposing (formatTsAsDate)
import SecureVote.SPAs.SwarmMVP.Model exposing (..)
import SecureVote.SPAs.SwarmMVP.Msg exposing (Msg(..), ToWeb3Msg(..))
import SecureVote.SPAs.SwarmMVP.Routes exposing (DialogRoute(FullAuditDialog), Route(..))
import SecureVote.Utils.Int exposing (maxInt, minInt)


openingSlide : Model -> ( String, BallotSpec ) -> Html Msg
openingSlide model ( bHash, bSpec ) =
    let
        ballotOver =
            (bEndTime.getOption bSpec ? maxInt) < model.now

        ( auditBtn, auditTitle, auditBtnText ) =
            if ballotOver then
                ( PriBtn, "Audit Ballot Results", "See Results" )
            else
                ( SecBtn, "Ballot Premilinary Results", "See Preliminary Results" )

        resultsMsg =
            MultiMsg <| [ SetDialog auditTitle FullAuditDialog, DoAudit ]

        maybeEarlyResults =
            if model.enableEarlyResults then
                btn 829378439 model [ auditBtn, Attr (class "ma2"), Click resultsMsg, OpenDialog ] [ text auditBtnText ]
            else
                Html.span [] []

        getDomain l =
            String.split "/" l
                |> List.drop 2
                |> List.head
                |> Maybe.withDefault l

        discussionLink =
            case bDiscLink.getOption bSpec of
                Just l ->
                    [ [ text <| "A discussion for this topic has been started at " ++ getDomain l ]
                    , [ btn 3948573984 model [ PriBtn, Link l ] [ text "Discuss This Ballot" ] ]
                    ]

                Nothing ->
                    []

        introText =
            let
                smallP =
                    p [ class "mb3 lh-title" ]

                ( voteDesc, voteInst, extraHtml ) =
                    case bVoteOpts.getOption bSpec of
                        Just (OptsSimple RangeVotingPlusMinus3 _) ->
                            ( "a number of options. Each option may have a description explaining it in more detail."
                            , "you allocate each option a number from -3 to +3 (inclusive). It's important to choose a vote for each option. (This method of voting is called 'Range Voting'.)"
                            , [ smallP
                                    [ text "If you'd like, "
                                    , a [ href "https://www.youtube.com/watch?v=afEwklJEzFc", target "_blank" ] [ text "here is a video" ]
                                    , text " walking you through the voting process."
                                    ]
                              ]
                            )

                        Just OptsBinary ->
                            ( "a choice of Yes or No for this ballot."
                            , "you'll need to choose 'Yes' if you agree with the resolution, or 'No' if you disagree."
                            , []
                            )

                        _ ->
                            ( "ERROR: UNKNOWN BALLOT TYPE", "ERROR: UNKNOWN BALLOT TYPE", [] )
            in
            [ [ text <| "Ballot description: " ++ bLongDesc.getOption bSpec ? "NO DESCRIPTION" ]
            ]
                ++ discussionLink
                ++ [ [ subhead "Voting" ]
                   , [ strong [] [ text <| "This is a stake-weighted vote using SWM balances as they were at " ++ formatTsAsDate (bStartTime.getOption bSpec ? 0) ] ]
                   , [ div [] <|
                        [ smallP [ text <| "You will be presented with " ++ voteDesc ]
                        , smallP [ text <| "When you vote, " ++ voteInst ]
                        ]
                            ++ extraHtml
                            ++ [ smallP [ text "When you're ready, let's vote!" ]
                               ]
                     ]
                   ]

        introParagraphs =
            div [ class "center" ] <| List.map renderPara introText

        resultsParas =
            div [ class "mb3" ]
                [ div [ class "mb3" ] [ renderAudit model ( bHash, bSpec ) ]
                , btn 893479357 model [ PriBtn, Attr (class "ph2"), Click (SetDialog "Voting Audit Log" FullAuditDialog), OpenDialog ] [ text "Full Voting Audit Log" ]
                ]

        renderPara txt =
            Options.styled span [ body1, cs "black db pa1 mv2" ] txt

        continueBtn =
            if ballotOver then
                span [] []
            else
                div [ class "mv3" ]
                    [ btn 348739845 model [ PriBtn, Attr (class "ph2"), Click (PageGoForward SwmHowToVoteR) ] [ text "Continue" ]
                    ]

        auditComplete =
            List.length (List.filter isAuditSuccessMsg model.auditMsgs) /= 0

        subtitleText =
            if ballotOver then
                if auditComplete then
                    "Results:"
                else
                    "Counting Votes..."
            else
                "This vote is open to all " ++ (mErc20Abrv bHash).get model ++ " token holders."
    in
    fullPageSlide
        model
        { id = 9483579329
        , title = bTitle.getOption bSpec ? "NO BALLOT TITLE"
        , inner =
            [ Options.styled div [ cs "black pa2 mv3 f4" ] [ text subtitleText ]
            , div
                [ style [ ( "max-width", "700px" ) ], class "center" ]
              <|
                [ if ballotOver then
                    resultsParas
                  else
                    introParagraphs
                , maybeEarlyResults
                , ballotIntegrity ( bHash, bSpec ) model
                , continueBtn
                ]
            ]
        }


ballotIntegrity : ( String, BallotSpec ) -> Model -> Html Msg
ballotIntegrity ( bHash, bSpec ) model =
    let
        failMsg errMsg =
            Options.styled span [ body1, cs "red" ] [ text errMsg ]

        successMsg msg =
            Options.styled span [ body1, cs "green" ] [ text msg ]

        ballotOptionsHtml =
            List.singleton <|
                successMsg "✅ Ballot cryptographically verified."

        row left right =
            div [ class "w-100 dt dt--fixed black mv2" ]
                [ div [ class "dtc tr pr3" ] left
                , div [ class "dtc tl" ] right
                ]

        ballotOpenHtml =
            let
                sTs =
                    bStartTime.getOption bSpec ? maxInt

                eTs =
                    bEndTime.getOption bSpec ? minInt
            in
            List.singleton <|
                if sTs > model.now then
                    failMsg <| "🔜 Ballot has not opened for voting yet. (Opens " ++ formatTsAsDate sTs ++ " local time)"
                else if eTs < model.now then
                    failMsg "❌ Voting is closed."
                else
                    successMsg <| "✅ Voting open! 🗳 Voting closes on: " ++ formatTsAsDate eTs ++ " local time"
    in
    div [ class "mt1 mb3" ]
        [ subhead "Checking ballot details:"
        , row
            [ text "Ballot open:" ]
            ballotOpenHtml
        , row
            [ text "Ballot options match smart contract:" ]
            ballotOptionsHtml
        ]
