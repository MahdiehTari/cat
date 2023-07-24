# function MakeColorPrompt {
#     param (
#         [string]$Text,
#         [string]$ConfigText
#     )
#     #
#     if (($null -ne $Text ) -and ($null -ne $ConfigText)) {
#         $TextArray = $Text.Split(" ")
#         $ConfigTextArray = $ConfigText.Split("|")
#         for ($Tindex = 0 ; $Tindex -lt $TextArray.Length ; $Tindex += 1) {
#             $Color = "Gray"
#             for ($Cindex = 0 ; $Cindex -lt $ConfigTextArray.Length ; $Cindex += 1) {
#                 $ConfigWord = $ConfigTextArray[$Cindex].Split(",")
#                 if (($Tindex + 1) -eq $ConfigWord[0]) {
#                     $Color = $ConfigWord[1]
#                     break
#                 }
#             }   
#             if ($Tindex -eq ($TextArray.Length - 1)) {
#                 Write-Host "$($TextArray[$Tindex])" -ForegroundColor $Color
#             }
#             else {
#                 Write-Host "$($TextArray[$Tindex]) " -ForegroundColor $Color -NoNewline
#             }
#         }
#     }    
# }

# MakeColorPrompt -Text "This Is A Color Text" -ConfigText "1,Yellow|2,Red|4,Blue"