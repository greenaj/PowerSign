# PowerSign

A PowerShell signtool.exe wrapper for codesigning using Microsoft's signtool and rfc3161 timestamp servers.

## Configuration Files

An example configuration file is shown below. They are PowerShell Data files. In order to run PowerSign, you will need to have at least 1 configuration setup.

```powershell
@{
    timeStampers = @(   "http://timestamp.globalsign.com/scripts/timstamp.dll",
                        "http://tsa.startssl.com/rfc3161",
                        "http://timestamp.comodoca.com/?td=sha256",
                        "http://sha256timestamp.ws.symantec.com/sha256/timestamp"
    )

    # Set this to a thumbprint of you code signing certificate.
    thumbprint  = "b6b248ff8ab1bf545d3f8db6c2695a6863f4bb3c"
}
```

For PowerSign to use your configuration file, it must be located in the `%LOCALAPPDATA%\PowerSign\` directory. The file name of the config is the name of the file minus the .psd1 extensions. For example, for the `prod_sign` configuration you would have

> `%LOCALAPPATA%\PowerSign\prod_sign.psd1`

Running

> `Add-Config -File prod_sign.psd1 -Name prod_sign`

Will create the *prod_sign* configuration given a prod_sign.psd1 file in the current directory.

## Notes

Example SignTool Command Line
> signtool sign /sha1 b6b248ff8ab1bf545d3f8db6c2695a6863f4bb3c /fd SHA256 /tr http://sha256timestamp.ws.symantec.com/sha256/timestamp  hellosign.exe

## References

[How to Be Your Own Certificate Authority (with Pictures) - wikiHow](https://www.wikihow.com/Be-Your-Own-Certificate-Authority)

[digital signature - Does anyone know a free(trial) timestamp server service? - Stack Overflow](https://stackoverflow.com/questions/25052925/does-anyone-know-a-freetrial-timestamp-server-service)

[List of free rfc3161 servers.](https://gist.github.com/Manouchehri/fd754e402d98430243455713efada710)

[Code Signing Certificates - SHA-1 and SHA-256 Information - Powered by Kayako Help Desk Software](https://support.comodo.com/index.php?/Knowledgebase/Article/View/1102/38/code-signing-certificates---sha-1-and-sha-256-information)
