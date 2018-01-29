param(    
    [string] $BranchUrlFrom = "",
    [string[]] $ListOfRevisions = @("")
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
Write-Host "Updating..."

# Merging
$originUrl = (svn info | Where-Object { $_.StartsWith("URL") });
$nameOfWorkingCopy = $originUrl.substring(4).split("/")[-1];

Write-Host "Working Copy $nameOfWorkingCopy";


Foreach ($item in $ListOfRevisions){

    $MessageLog = (svn log $BranchUrlFrom -r $item) | Select-String -Pattern "#(\d+)" | % {$_.Matches}

    svn merge -c $item $BranchUrlFrom
    svn commit -m "Automatic merge [$item] $MessageLog from Url:$BranchUrlFrom" 

}
