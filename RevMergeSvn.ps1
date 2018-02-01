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

# Merging
$originUrl = (svn info | Where-Object { $_.StartsWith("URL") });
$nameOfWorkingCopy = $originUrl.substring(4).split("/")[-1];
$BranchNameFrom = $BranchUrlFrom.substring(4).split("/")[-1];

Write-Host "Working Copy $nameOfWorkingCopy";
Write-Host "Branch From $BranchNameFrom";

Foreach ($item in $ListOfRevisions){

    $MessageLog = (svn log $BranchUrlFrom -r $item) | Select-String -Pattern "#(\d+)" | % {$_.Matches}
    svn cleanup
    Write-Host "Cleaning up..."

    svn update

    Write-Host "Updating..."
    
    svn merge -c $item $BranchUrlFrom --accept postpone

    $statusConflict = (svn st) | Select-String -Pattern "Conflicts" | % {$_.Matches} 
        
    if ($statusConflict -eq "") {
        svn commit -m "Automatic merge [$item] $MessageLog from $BranchNameFrom"             
    }else{
        Write-Host "Merge with conflicts!!!!"

        svn cleanup
        Write-Host "Cleaning up..."

        svn revert . --recursive
        Write-Host "Reverting merge..."

    }

}
