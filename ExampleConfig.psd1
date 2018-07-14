@{
    timeStampers = @(   "http://timestamp.globalsign.com/scripts/timstamp.dll",
                        "http://tsa.startssl.com/rfc3161",
                        "http://timestamp.comodoca.com/?td=sha256",
                        "http://sha256timestamp.ws.symantec.com/sha256/timestamp"
    )

    # Set this to a thumbprint of you code signing certificate.
    thumbprint  = "b6b248ff8ab1bf545d3f8db6c2695a6863f4bb3c"
}