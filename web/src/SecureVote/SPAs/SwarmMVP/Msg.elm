module SecureVote.SPAs.SwarmMVP.Msg exposing (..)

import Decimal exposing (Decimal)
import Material
import Material.Snackbar as Snackbar
import RemoteData exposing (RemoteData)
import SecureVote.Ballots.SpecSource exposing (FailSpecFromIpfs, SpecFromIpfs)
import SecureVote.Ballots.Types exposing (..)
import SecureVote.Crypto.Curve25519 exposing (Curve25519KeyPair)
import SecureVote.Eth.Msg exposing (EthMsg)
import SecureVote.Eth.Types exposing (..)
import SecureVote.LocalStorage exposing (LsMsg)
import SecureVote.SPAs.SwarmMVP.Ballots.Types exposing (BallotParams)
import SecureVote.SPAs.SwarmMVP.Routes exposing (DialogRoute, Route)
import SecureVote.SPAs.SwarmMVP.Types exposing (GotTxidResp)
import Time exposing (Time)


type Msg
    = NoOp
    | SetTime Int
      -- ** UI Maintenance msgs
    | SetElevation Int Bool
    | SetField String String
    | RemoveFieldVal String
    | SetBoolField String Bool
    | PageGoForward Route
    | PageGoBack
    | PageGoHome
    | SetDialog String (DialogRoute Msg)
      -- ** Voting msgs
    | SetBallotRange Int Float
    | ModBallotRange Int (Int -> Int)
    | ConstructBallotPlaintext
    | SetBallot String
    | VoteWMetaMask
    | MarkBallotVoted Bool { voterM : Maybe String, bHash : String } --^ If voterM == Nothing it means it's the current address
    | MarkBallotTxInProg
    | SetBallotProgTime { addr : String, bHash : String } Time
    | CheckForPrevVotes
      -- ** Eth related msgs
    | SetCandidateTx (CandidateEthTx -> CandidateEthTx)
    | SetEthNode String
      -- ** Utility msgs
    | MultiMsg (List Msg)
      -- ** Port msgs
    | ToWeb3 ToWeb3Msg
    | FromWeb3 FromWeb3Msg
    | FromCurve25519 FromCurve25519Msg
    | GotFullSpecFromIpfs (Result String SpecFromIpfs)
    | GotFailSpecFromIpfs (Result String FailSpecFromIpfs)
    | LS LsMsg
    | Web3 EthMsg
      -- ** Auditor msgs
    | FromAuditor AuditDoc
    | DoAudit
      -- ** Errors
    | LogErr String
    | Snackbar (Snackbar.Msg String)
      -- ** Elm Mdl
    | Mdl (Material.Msg Msg)


type ToWeb3Msg
    = GetErc20Balance String --^ string is bHash
    | CheckTxid String


type FromWeb3Msg
    = GotBalance Decimal
    | GotDataParam String
    | GotEncPubkey String
    | GotTxidStatus (Result String GotTxidResp)
    | GotMetaMask
    | GotMetaMaskTxid String
    | GotBallotCount (RemoteData String { democHash : String, n : Int })
    | GotBallotInfo (RemoteData String BallotInfo)
    | GotErc20Abrv Erc20Abrv
    | GotBallotSCDeets BallotSCDetails


type FromCurve25519Msg
    = GotKey Curve25519KeyPair
    | GotEncBytes String


type ToCurve25519Msg
    = GenerateSignedBallot
