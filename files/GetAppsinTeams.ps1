##Reads the Excluded App File and then stores it 
$excludeAppsFile = import-csv ".\ExcludeApps.csv"
##pulls the appid column from the csv file above
$excludeAppid = $excludeAppsFile.teamsAppId 
##pulls the displayname column from the csv file above
$excludeAppDisplayName = $excludeAppsFile.displayName

#pulls every team from tentant
$teams = Get-MgGroup -Filter "resourceProvisioningOptions/Any(x:x eq 'Team')" -All

#creates the hashtable that we will be printing to a csv file later
$results = [System.Collections.ArrayList]::new()
foreach($team in $teams){
    # Variable Set ups
    $ownerUsers =@()
    $filteredTeamsAppIds = @()
    $filteredTeamsAppDisplayNames = @()
    $teamInstalledApps = Get-MgTeamInstalledApp  -TeamId $team.Id -Property TeamsApp,TeamsAppDefinition -ExpandProperty TeamsApp,TeamsAppDefinition
    $owners = Get-MgGroupOwner -GroupId $team.Id
    $ownerUPN = @()
    foreach ($owner in $owners) {
        $ownerUser = Get-Mguser -UserId $owner.Id
        $ownerUsers += $ownerUser.DisplayName
        $ownerUPN += $ownerUser.UserPrincipalName
    }
    foreach($teamInstalledApp in $teamInstalledApps){
        if ($teamInstalledApp.TeamsApp.id -notin $excludeAppid -or $teamInstalledApp.TeamsApp.displayName -notin $excludeAppDisplayName){
            $filteredTeamsAppIds += $teamInstalledApp.TeamsApp.Id
            $filteredTeamsAppDisplayNames += $teamInstalledApp.TeamsApp.DisplayName
        }
    }
#    [hashtable]
    $result = [ordered]@{
        TeamName =  $team.displayName
        TeamInstalledAppName = $filteredTeamsAppDisplayNames -join ','
        TeamOwnerName =  $ownerUsers -join ','
        TeamOwnerUPN =  $ownerUpn -join ','
        ##TeamInstalledAppId =  $filteredTeamsAppIds -join ','
        ##TeamId =  $team.Id
    }
    $null = $results.Add($result)
}
$results  | ForEach-Object{ [pscustomobject]$_ } | Export-CSV -Path ".\results.csv" -NoTypeInformation
Invoke-Item .\
