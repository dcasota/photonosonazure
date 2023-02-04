﻿# .SYNOPSIS
#  This VMware Photon OS github branches packages (specs) report script creates an excel prn.
#
# .NOTES
#   Author:  Daniel Casota
#   Version:
#   0.1   06.03.2021   dcasota  First release
#   0.2   17.04.2021   dcasota  dev added
#   0.3   04.02.2023   dcasota  5.0 added
#
#  .PREREQUISITES
#    - Script actually tested only on MS Windows OS with Powershell PSVersion 5.1 or higher
#    - downloaded and unzipped branch directories of github.com/vmware/photon 

function ParseDirectory
{
	param (
		[parameter(Mandatory = $true)]
		[string]$SourcePath,
		[parameter(Mandatory = $true)]
		[string]$PhotonDir
	)
    $Packages=@()
    $Objects=Get-ChildItem -Path "$SourcePath\$PhotonDir\SPECS" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object Name,FullName
    foreach ($object in $objects)
    {
        try
        {
            get-childitem -path $object.FullName -Filter "*.spec" | %{
                $Release=$null
                $Release= (($_ | get-content | Select-String -Pattern "^Release:")[0].ToString() -replace "Release:", "").Trim()
                $Release = $Release.Replace("%{?dist}","")
                $Release = $Release.Replace("%{?kat_build:.kat}","")
                $Release = $Release.Replace("%{?kat_build:.%kat_build}","")
                $Release = $Release.Replace("%{?kat_build:.%kat}","")
                $Release = $Release.Replace("%{?kernelsubrelease}","")
                $Release = $Release.Replace(".%{dialogsubversion}","")
                $Version=$null
                $version= (($_ | get-content | Select-String -Pattern "^Version:")[0].ToString() -replace "Version:", "").Trim()
                if ($Release -ne $null) {$Version = $Version+"-"+$Release}
                $Packages +=[PSCustomObject]@{
                    Spec = $_.Name
                    Version = $Version
                    Name = $object.Name
                }
            }
        }
        catch{}
    }
    return $Packages
}

# EDIT
# path with all downloaded and unzipped branch directories of github.com/vmware/photon
$sourcepath="$env:public"


#download from repo
if (!(test-path -path $sourcepath\photon-1.0))
{
    cd $sourcepath
    git clone -b 1.0 https://github.com/vmware/photon $sourcepath\photon-1.0
}
else
{
    cd $sourcepath\photon-1.0
    git fetch
    git merge origin/1.0
}
if (!(test-path -path $sourcepath\photon-2.0))
{
    cd $sourcepath
    git clone -b 2.0 https://github.com/vmware/photon $sourcepath\photon-2.0
}
else
{
    cd $sourcepath\photon-2.0
    git fetch
    git merge origin/2.0
}
if (!(test-path -path $sourcepath\photon-3.0))
{
    cd $sourcepath
    git clone -b 3.0 https://github.com/vmware/photon $sourcepath\photon-3.0
}
else
{
    cd $sourcepath\photon-3.0
    git fetch
    git merge origin/3.0
}
if (!(test-path -path $sourcepath\photon-4.0))
{
    cd $sourcepath
    git clone -b 4.0 https://github.com/vmware/photon $sourcepath\photon-4.0
}
else
{
    cd $sourcepath\photon-4.0
    git fetch
    git merge origin/4.0
}
if (!(test-path -path $sourcepath\photon-5.0))
{
    cd $sourcepath
    git clone -b 5.0 https://github.com/vmware/photon $sourcepath\photon-5.0
}
else
{
    cd $sourcepath\photon-5.0
    git fetch
    git merge origin/5.0
}
if (!(test-path -path $sourcepath\photon-master))
{
    cd $sourcepath
    git clone -b master https://github.com/vmware/photon $sourcepath\photon-master
}
else
{
    cd $sourcepath\photon-master
    git fetch
    git merge master
}
if (!(test-path -path $sourcepath\photon-dev))
{
    cd $sourcepath
    git clone -b origin/origin/dev https://github.com/vmware/photon $sourcepath\photon-dev
}
else
{
    cd $sourcepath\photon-dev
    git fetch
    git merge origin/origin/dev
}

cd $sourcepath
#arrays
$Packages1=ParseDirectory -SourcePath $sourcepath -PhotonDir photon-1.0
$Packages2=ParseDirectory -SourcePath $sourcepath -PhotonDir photon-2.0
$Packages3=ParseDirectory -SourcePath $sourcepath -PhotonDir photon-3.0
$Packages4=ParseDirectory -SourcePath $sourcepath -PhotonDir photon-4.0
$Packages5=ParseDirectory -SourcePath $sourcepath -PhotonDir photon-5.0
$PackagesMaster=ParseDirectory -SourcePath $sourcepath -PhotonDir photon-master
$Packages0=ParseDirectory -SourcePath $sourcepath -PhotonDir photon-dev

# merge
$result = $Packages1,$Packages2,$Packages3,$Packages4,$Packages5,$PackagesMaster| %{$_}|Select Spec,`
@{l='photon-1.0';e={if($_.Spec -in $Packages1.Spec) {$Packages1[$Packages1.Spec.IndexOf($_.Spec)].version}}},`
@{l='photon-2.0';e={if($_.Spec -in $Packages2.Spec) {$Packages2[$Packages2.Spec.IndexOf($_.Spec)].version}}},`
@{l='photon-3.0';e={if($_.Spec -in $Packages3.Spec) {$Packages3[$Packages3.Spec.IndexOf($_.Spec)].version}}},`
@{l='photon-4.0';e={if($_.Spec -in $Packages4.Spec) {$Packages4[$Packages4.Spec.IndexOf($_.Spec)].version}}},`
@{l='photon-5.0';e={if($_.Spec -in $Packages5.Spec) {$Packages5[$Packages5.Spec.IndexOf($_.Spec)].version}}},`
@{l='photon-dev';e={if($_.Spec -in $Packages0.Spec) {$Packages0[$Packages0.Spec.IndexOf($_.Spec)].version}}},`
@{l='photon-master';e={if($_.Spec -in $PackagesMaster.Spec) {$PackagesMaster[$PackagesMaster.Spec.IndexOf($_.Spec)].version}}} -Unique | Sort-object Spec

# write output
# output file
$outputfile="$env:public\photonos-package-report.prn"
"Spec"+","+"photon-1.0"+","+"photon-2.0"+","+"photon-3.0"+","+"photon-4.0"+","+"photon-5.0"+","+"photon-dev"+","+"photon-master"| out-file $outputfile
$result | % { $_.Spec+","+$_."photon-1.0"+","+$_."photon-2.0"+","+$_."photon-3.0"+","+$_."photon-4.0"+","+$_."photon-5.0"+","+$_."photon-dev"+","+$_."photon-master"} |  out-file $outputfile -append

# write diff output 4.0 package with a higher version than same 5.0 package
# output file
$outputfile="$env:public\photonos-diff-report-4.0-5.0.prn"
"Spec"+","+"photon-4.0"+","+"photon-5.0"| out-file $outputfile
$result.foreach({if (($_."photon-4.0" -gt $_."photon-5.0") -and (!([string]::IsNullOrEmpty($_."photon-5.0")))) {$diffspec=[System.String]::Concat($_.spec, ',',$_.'photon-4.0',',',$_.'photon-5.0'); $diffspec | out-file $outputfile -append}})

# write diff output 3.0 package with a higher version than same 4.0 package
# output file
$outputfile="$env:public\photonos-diff-report-3.0-4.0.prn"
"Spec"+","+"photon-3.0"+","+"photon-4.0"| out-file $outputfile
$result.foreach({if (($_."photon-3.0" -gt $_."photon-4.0") -and (!([string]::IsNullOrEmpty($_."photon-4.0")))) {$diffspec=[System.String]::Concat($_.spec, ',',$_.'photon-3.0',',',$_.'photon-4.0');$diffspec | out-file $outputfile -append}})