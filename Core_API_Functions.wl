(* ::Package:: *)

(* ====================================================== *)
(* Core API Functions & Rate Limiting Backend             *)
(* ====================================================== *)

(* Auto-infer paths from this file's own location.
   $baseDir and $vaultDir are available in every notebook
   that loads this file. Nothing needs to be hardcoded.   *)
$baseDir  = DirectoryName[$InputFileName];
$vaultDir = $baseDir <> "Vault/";

$minDelay        = 10.0;
$lastRequestTime = 0;

(* 1. Initialize Gemini Service Connection *)
If[Not[ValueQ[$geminiService]],
  Print["[API] Connecting to Gemini Service..."];
  $geminiService = ServiceConnect["GoogleGemini"]
];

(* 2. Rate Limiter *)
rateLimitedExecute[service_, args__] := Module[
  {timeSinceLast, timeToWait, result},
  timeSinceLast = AbsoluteTime[] - $lastRequestTime;
  timeToWait    = $minDelay - timeSinceLast;
  If[timeToWait > 0,
    Print["[API] Waiting " <> ToString[Round[timeToWait, 0.1]] <> "s for rate limit..."];
    Pause[timeToWait]
  ];
  $lastRequestTime = AbsoluteTime[];
  result = ServiceExecute[service, args];
  result
];

(* 3. Core API Call Wrapper *)
callGemini[prompt_String, temp_Real : 0.3] := Module[
  {rawResponse, content},
  rawResponse = rateLimitedExecute[$geminiService, "Chat", <|
    "Messages"    -> {<|"Role" -> "user", "Content" -> prompt|>},
    "Model"       -> "gemini-2.5-flash",
    "Temperature" -> temp
  |>];
  If[AssociationQ[rawResponse] && KeyExistsQ[rawResponse, "Content"],
    content = rawResponse["Content"],
    content = "$Failed";
    Print["[API ERROR] Invalid response format: ", rawResponse]
  ];
  content
];
