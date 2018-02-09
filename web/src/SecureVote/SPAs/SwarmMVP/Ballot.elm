module SecureVote.SPAs.SwarmMVP.Ballot exposing (..)

import List exposing (map)
import List.Extra exposing (zip)
import Round as R
import SecureVote.SPAs.SwarmMVP.DialogTypes exposing (DialogHtml(..))


type alias BallotParams msg =
    { voteOptions : List (BallotOption msg)
    , openingDesc : String
    , contractAddr : String
    }


rschedBallot : BallotParams msg
rschedBallot =
    { voteOptions = voteOptionsRSched, openingDesc = rSchedOpeningDesc, contractAddr = "0x2Bb10945E9f0C9483022dc473aB4951BC2a77d0f" }


rSchedOpeningDesc : String
rSchedOpeningDesc =
    "This option for the release of SWM tokens corresponds to the following specification:"


type alias BallotOption msg =
    { id : Int
    , title : String
    , description : DialogHtml msg
    }


type alias ReleaseSchedule =
    { nReleases : Int
    , releaseLength : Int
    }


renderReleaseScheduleTitle : ReleaseSchedule -> String
renderReleaseScheduleTitle { nReleases, releaseLength } =
    let
        sOptional =
            if nReleases > 1 then
                "s"
            else
                ""
    in
    toString nReleases ++ " release" ++ sOptional ++ " of " ++ toString releaseLength ++ " days"


rSchedToListElems : ReleaseSchedule -> List (DialogHtml msg)
rSchedToListElems rSched =
    let
        txtToLi =
            DlogLi << DlogTxt

        nRel =
            rSched.nReleases

        relLen =
            rSched.releaseLength

        nRelS =
            if nRel > 1 then
                "s"
            else
                ""

        relLenS =
            if relLen > 1 then
                "s"
            else
                ""

        relLenStr =
            toString relLen

        nRelStr =
            toString nRel
    in
    [ txtToLi <|
        "This release involves "
            ++ nRelStr
            ++ " release"
            ++ nRelS
            ++ " over "
            ++ relLenStr
            ++ " day"
            ++ relLenS
            ++ "."
    , txtToLi <|
        "At the conclusion of each "
            ++ relLenStr
            ++ " day period, approximately "
            ++ (R.round 2 <| 100.0 / toFloat nRel)
            ++ "% of tokens will be released, proportionally across all token holders."
    , txtToLi <|
        "This means the full liquidity release schedule will take "
            ++ (toString <| (nRel * relLen))
            ++ " days to complete."
    ]


addBallotDescRSched : List (DialogHtml msg) -> DialogHtml msg -> DialogHtml msg
addBallotDescRSched dialogElems desc =
    DlogDiv
        [ DlogP [ DlogTxt rSchedOpeningDesc ]
        , DlogUl dialogElems
        , desc
        ]


voteOptionsRSched : List (BallotOption msg)
voteOptionsRSched =
    let
        wrapP inner =
            DlogP [ DlogTxt inner ]

        modRSched ( r, f ) =
            f r
    in
    map modRSched <|
        zip rScheds
            [ \a -> BallotOption 1337000001 (renderReleaseScheduleTitle a) <| addBallotDescRSched (rSchedToListElems a) (wrapP "This is the proposal in the whitepaper. The release will take approximately 1 year.")
            , \a -> BallotOption 1337000002 (renderReleaseScheduleTitle a) <| addBallotDescRSched (rSchedToListElems a) (wrapP "This is like the release schedule in the whitepaper, but smaller chunks will be released more frequently.")
            , \a -> BallotOption 1337000003 (renderReleaseScheduleTitle a) <| addBallotDescRSched (rSchedToListElems a) (wrapP "This release will occur over 2 years.")
            , \a -> BallotOption 1337000004 (renderReleaseScheduleTitle a) <| addBallotDescRSched (rSchedToListElems a) (wrapP "This is similar to option 1 (8 releases of 42 days), but less frequent.")
            ]


rScheds : List ReleaseSchedule
rScheds =
    [ ReleaseSchedule 8 42, ReleaseSchedule 42 8, ReleaseSchedule 16 42, ReleaseSchedule 4 84 ]


doBallotOptsMatchRSched : List (List Int) -> Bool
doBallotOptsMatchRSched optsFromEth =
    let
        extractRelSched rSchedule =
            let
                { nReleases, releaseLength } =
                    rSchedule
            in
            [ nReleases, releaseLength ]

        releaseSchedules =
            List.map extractRelSched rScheds

        matches =
            List.map2 (\ethOpt ourOpt -> ethOpt == ourOpt) optsFromEth releaseSchedules
    in
    List.all (\b -> b) matches


doBallotOptsMatch : List (BallotOption msg) -> List String -> Bool
doBallotOptsMatch voteOpts titlesFromEth =
    True
