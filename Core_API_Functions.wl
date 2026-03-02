(* ::Package:: *)

(* ====================================================== *)
(* Core API Functions & Rate Limiting Backend             *)
(* ====================================================== *)

$minDelay = 6.1;
$lastRequestTime = 0;

rateLimitedExecute[service_, args__] := 
  Module[{timeSinceLast, timeToWait, result}, 
   timeSinceLast = AbsoluteTime[] - $lastRequestTime;
   timeToWait = $minDelay - timeSinceLast;
   If[timeToWait > 0, 
    Print["Waiting " <> ToString[Round[timeToWait, 0.1]] <> "s for rate limit..."];
    Pause[timeToWait]
   ];
   $lastRequestTime = AbsoluteTime[];
   result = ServiceExecute[service, args];
   result
  ];
