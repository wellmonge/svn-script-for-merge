param(
    [string] $BranchOrigin = "",
    [string] $BranchDestionation = "",
    [string] $ListOfRevision = ""
)

Write-Host "Reverting..."
svn revert -R .\

Write-Host "Cleaning up..."
$toRemove = svn status --no-ignore | Where-Object { $_.StartsWith("?") -or $_.StartsWith("I") } | % { $_.SubString(8) }
if ($toRemove)
{
    $toRemove | Remove-item -Force -Recurse
}
svn update

# Merging
$trunk = (svn info | Where-Object { $_.StartsWith("URL") }).SubString(4).Trim()
$teste = (svn info | Where-Object { $_.StartsWith("URL") }).SubString(4).Trim()

Write-Host "$teste"

return;

if (!$branchName)
{
    Write-Host "Getting list of branches available for merging..."
    $branches = (svn list $trunk.Replace("trunk","branches"))
    $branches | %{$index=0} { Write-Host "[$index] $_" -foregroundcolor green; $index++ }
    Write-Host "Enter number for branch to merge: " -foregroundcolor yellow -NoNewline
    $branchIndex = Read-Host
    
    if ($branchIndex -ge $branches.Count)
    {
        Write-Host "Branch number does not exist. Quitting."
        return;
    }
    
    $branchName = @($branches)[$branchIndex]
}

if ($branchname -ne '')
{    
    Write-Host "Merging..."    
    $branch = $trunk.Replace("/trunk", "/branches/$branchName");
    Write-Host "   from branch: $branch"    
    Write-Host "   to trunk: $trunk"
    svn merge $branch
}