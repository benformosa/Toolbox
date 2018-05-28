<#
.SYNOPSIS
Search an LDAP directory

.DESCRIPTION
Search an LDAP directory such as Active Directory without additional dependencies.

.PARAMETER LDAPFilter
An LDAP filter

.PARAMETER SearchRoot
Use SearchRoot as the starting point for the search

.PARAMETER SearchScope
Specify the scope of the search.

.PARAMETER Attributes
List of attributes to return
#>

[CmdletBinding()]
param(
    [string]
    $LDAPFilter = "(objectClass=*)",

    [string]
    $SearchRoot = $Null,

    [ValidateSet("Base","Onelevel","Subtree")]
    [string]
    $SearchScope = "Subtree",

    [string[]]
    $Attributes = @("samAccountname", "objectClass", "distinguishedName")
) 

# Set up the DirectorySearcher
$Search = New-Object DirectoryServices.DirectorySearcher
$Search.Filter = $LDAPFilter
$Search.SearchScope = $SearchScope
if($SearchRoot) {
    $Search.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($SearchRoot)")
}

$All = $Search.FindAll()
if($All -and $Attributes) {
    # If $Attributes is set, convert into an array of PSObjects with all the returned attributes
    # This will throw away the Path and just use Properties returned by FindAll()
    $Objects = [System.Collections.ArrayList] @()
    $All | ForEach-Object {
        $Objects += New-Object PSObject -Property ($_ | Select-Object -ExpandProperty Properties)
    }
    $Objects = $Objects | Select-Object $Attributes
    return $Objects
} elseif($All -and -not $Attributes) {
    # If $Attributes is $Null, return the output of FindAll()
    return $All
} else {
    # Don't return an empty list if nothing was found
    return $Null
}