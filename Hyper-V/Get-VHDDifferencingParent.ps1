<#
.SYNOPSIS
Finds the parent of a differencing disk in environments where Get-VHD is not available.

.DESCRIPTION
Uses .Net functions to read a .VHD or .VHDX file to determine if it has a parent.
This is useful on computers that don't (or can't) have the Hyper-V role installed.

.PARAMETER Path
The path to the .VHD or .VHDX file to be scanned. Due to a .Net limitation, you cannot supply raw volume identifiers. You must use a drive letter or a share.

.OUTPUTS
A string containing the absolute path to the parent, or null if none exists.

.NOTES
Author: Eric Siron
Copyright: (C) 2014 Altaro Software
Version 1.1
Authored Date: October 25, 2014

Comments in this file are sparse because they more or less follow along directly from the specification documents.
VHD specification: http://www.microsoft.com/en-us/download/details.aspx?id=23850
VHDX 1.0 specification: http://www.microsoft.com/en-us/download/details.aspx?id=34750

1.1 December 13,2015
--------------------
* Changed suggested function name to Get-VHDDifferencingParent to be more consistent with existing VM cmdlet
* Added a check for the presence of Get-VHD; if available, will use that instead of the more complicated method
* Added more granular error-checking; not much can actually be done about errors, but they'll be reported more accurately

.LINK
https://www.altaro.com/hyper-v/free-script-find-orphaned-hyper-v-vm-files

.EXAMPLE
C:\PS> .\Get-VHDDifferencingParent -Path C:\TestVHDs\diff1.vhdx

Description
-----------
Retrieves the parent disk of C:\TestVHDs\diff1.vhdx, if any.
#>

param(
	[Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)][String]$Path
)

$AbsolutePath = ""
$IdentifierSize = 8
$IdentifierBytes = New-Object Byte[] $IdentifierSize

try # the easy way first
{
	Get-Command -Name Get-VHD -ErrorAction Stop
	try
	{
		(Get-VHD -Path $Path -ErrorAction Stop).ParentPath
		return
	}
	catch
	{
		# probably means we have to try something harder, but let the next section worry about that
	}
}
catch
{
	# just means we have to try something harder
}
try
{
	try
	{
		$VHDStream = New-Object System.IO.FileStream($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite) -ErrorAction Stop
	}
	catch
	{
		throw ("Unable to open differencing disk {0} to determine its parent: {1}" -f $Path, $_)
	}

	try
	{
		$BytesRead = $VHDStream.Read($IdentifierBytes, 0, $IdentifierSize)
	}
	catch
	{
		throw ("Unable to read the VHD type identifier for {0}: {1}" -f $Path, $_)
	}

			if([System.Text.Encoding]::ASCII.GetString($IdentifierBytes) -eq "vhdxfile")
	{
		$1stRegionOffset = 196608; $1stRegionEntryCount = 0; $2ndRegionOffset = 262144; $2ndRegionEntryCount = 0
		$SignatureSize = 4; $EntryCountSize = 8; $GUIDSize = 16; $EntryOffsetSize = 8; $EntryLengthSize = 4
		$ShortEntrySize = 2; $MetadataOffsetSize = 4; $KeyValueCountSize = 2; $LocatorEntrySize = 12
		$SignatureBytes = New-Object Byte[] $SignatureSize; $EntryCountBytes = New-Object Byte[] $EntryCountSize
		$GUIDBytes = New-Object Byte[] $GUIDSize; $EntryOffset = New-Object Byte[] $EntryOffsetSize
		$ShortEntryBytes = New-Object Byte[] $ShortEntrySize; $MetadataOffsetBytes = New-Object Byte[] $MetadataOffsetSize
		$KeyValueCountBytes = New-Object Byte[] $KeyValueCountSize; $LocatorEntryBytes = New-Object Byte[] $LocatorEntrySize
		$LocatorEntries = @()

		($1stRegionOffset, $2ndRegionOffset) | foreach {
			$VHDStream.Position = $_
			try
			{
				$BytesRead = $VHDStream.Read($SignatureBytes, 0, $SignatureSize)
			}
			catch
			{
				throw ("Unable to read signature from header region of {0}: {1}" -f $Path, $_)
			}
			if([System.Text.Encoding]::ASCII.GetString($SignatureBytes) -eq "regi")
			{
				$VHDStream.Position += 4	# jump over the checksum
				try
				{
					$BytesRead = $VHDStream.Read($EntryCountBytes, 0, $EntryCountSize)
				}
				catch
				{
					throw ("Unable to determine number of header entries in {0}: {1}" -f $Path, $_)
				}
				$RegionEntryCount = [System.BitConverter]::ToInt32($EntryCountBytes, 0)
				if($_ = $1stRegionOffset)
				{
					$1stRegionEntryCount = $RegionEntryCount
				}
				else
				{
					$2ndRegionEntryCount = $RegionEntryCount
				}
			}
		}
		if($1stRegionEntryCount -ge $2ndRegionEntryCount)
		{
			$EntryCount = $1stRegionEntryCount
			$StartingEntryOffset = $1stRegionOffset + 16
		}
		else
		{
			$EntryCount = $2ndRegionEntryCount
			$StartingEntryOffset = $2ndRegionOffset + 16
		}

		1..$EntryCount | foreach {
			$VHDStream.Position = $StartingEntryOffset + (32 * ($_ - 1))	# an entry is 32 bytes long
			try
			{
				$BytesRead = $VHDStream.Read($GUIDBytes, 0, $GUIDSize)
			}
			catch
			{
				throw ("Unable to retrieve the GUID of a header entry in {0}, {1}" -f $Path, $_)
			}
			if([System.BitConverter]::ToString($GUIDBytes) -eq "06-A2-7C-8B-90-47-9A-4B-B8-FE-57-5F-05-0F-88-6E")	# this is the GUID of a metadata region
			{
				try
				{
					$BytesRead = $VHDStream.Read($EntryOffset, 0, $EntryOffsetSize)
				}
				catch
				{
					throw("Unable to determine the location of a metadata region in {0}: {1}" -f $Path, $_)
				}
				$MetadataStart = $VHDStream.Position = [System.BitConverter]::ToInt64($EntryOffset, 0)

				try
				{
					$BytesRead = $VHDStream.Read($IdentifierBytes, 0, $IdentifierSize)
				}
				catch
				{
					throw("Unable to parse the identifier of an expected metadata region in {0}: {1}"-f $Path, $_)
				}
				if([System.Text.Encoding]::ASCII.GetString($IdentifierBytes) -eq "metadata")
				{
					$VHDStream.Position += 2	# jump over reserved field
					try
					{
						$BytesRead = $VHDStream.Read($ShortEntryBytes, 0, $ShortEntrySize)
					}
					catch
					{
						throw("Unable to retrieve the number of header short entries in {0}: {1}" -f $Path, $_)
					}
					$VHDStream.Position += 20	# jump over the rest of the header
					1..([System.BitConverter]::ToUInt16($ShortEntryBytes, 0)) | foreach {
						try
						{
							$BytesRead = $VHDStream.Read($GUIDBytes, 0, $GUIDSize)
						}
						catch
						{
							throw ("Unable to retrieve the GUID of a short entry in {0}: {1}" -f $Path, $_)
						}
						$SavedStreamPosition = $VHDStream.Position
						switch([System.BitConverter]::ToString($GUIDBytes))
						{	## We're only watching for a single item so an "if" could do this, but switch is future-proofing.
							## Should be able to query 37-67-A1-CA-36-FA-43-4D-B3-B6-33-F0-AA-44-E7-6B for a "HasParent" value, but either the documentation is wrong or the implementation is broken as this field holds the same value for all disk types
							"2D-5F-D3-A8-0B-B3-4D-45-AB-F7-D3-D8-48-34-AB-0C" {	# Parent Locator
								try
								{
									$BytesRead = $VHDStream.Read($MetadataOffsetBytes, 0, $MetadataOffsetSize)
								}
								catch
								{
									throw ("Unable to read the location of a metadata entry in {0}: {1}" -f $Path, $_)
								}

								if($BytesRead)
								{
									$ParentLocatorOffset = $MetadataStart + [System.BitConverter]::ToInt32($MetadataOffsetBytes, 0)
									$VHDStream.Position = $ParentLocatorOffset + 18 # jump over the GUID and reserved fields

									try
									{
										$BytesRead = $VHDStream.Read($KeyValueCountBytes, 0, $KeyValueCountSize)
									}
									catch
									{
										throw("Unable to read the number of key/value metadata sets in {0}: {1}" -f $Path, $_)
									}
									if($BytesRead)
									{
										1..[System.BitConverter]::ToUInt16($KeyValueCountBytes, 0) | foreach {
											try
											{
												$BytesRead = $VHDStream.Read($LocatorEntryBytes, 0, $LocatorEntrySize)
											}
											catch
											{
												throw ("Unable to retrieve a key/value metadata set from {0}: {1}" -f $Path, $_)
											}
											if($BytesRead)
											{
												$KeyOffset = [System.BitConverter]::ToUInt32($LocatorEntryBytes, 0)
												$ValueOffset = [System.BitConverter]::ToUInt32($LocatorEntryBytes, 4)
												$KeyLength = [System.BitConverter]::ToUInt16($LocatorEntryBytes, 8)
												$ValueLength = [System.BitConverter]::ToUInt16($LocatorEntryBytes, 10)
												$LocatorEntries += [String]::Join(",", ($KeyOffset, $ValueOffset, $KeyLength, $ValueLength))
											}
										}
										foreach($Locator in $LocatorEntries)
										{
											$KeyValueSet = $Locator.Split(",")
											$KeyPosition = $ParentLocatorOffset + $KeyValueSet[0]
											$ValuePosition = $ParentLocatorOffset + $KeyValueSet[1]
											$KeyBytes = New-Object Byte[] $KeyValueSet[2]
											$ValueBytes = New-Object Byte[] $KeyValueSet[3]
											$VHDStream.Position = $KeyPosition

											try
											{
												# NOTE: we don't actually do anything with the key, technically could move the pointer past it to the value
												$BytesRead = $VHDStream.Read($KeyBytes, 0, $KeyBytes.Length)
											}
											catch
											{
												throw ("Unable to retrieve the parent path key in the key/value set of {0}: {1}")
											}
											if($BytesRead)
											{
												if([System.Text.Encoding]::Unicode.GetString($KeyBytes) -eq "absolute_win32_path")
												{
													try
													{
														$BytesRead = $VHDStream.Read($ValueBytes, 0, $ValueBytes.Length)
													}
													catch
													{
														throw ("Unable to retrieve the parent path value in the key/value set of {0}: {1}")
													}
													if($BytesRead)
													{
														$AbsolutePath = [System.Text.Encoding]::Unicode.GetString($ValueBytes)
														break
													}
												}
											}
										}
									}
								}
							}
						}
						# move to the start of the next entry
						$VHDStream.Position = $SavedStreamPosition + 16
					}
				}
			}
		}
	}
	elseif([System.Text.Encoding]::ASCII.GetString($IdentifierBytes) -eq "conectix") # this is a VHD file
	{
		$TypeSize = 4; $ChunkSize = 2
		$TypeBytes = New-Object Byte[] $TypeSize -ErrorAction Stop; $ChunkBytes = New-Object Byte[] $ChunkSize -ErrorAction Stop
		$ReverseParentBytes = [Byte[]]@()
		$VHDStream.Position = 60	# this is where the disk type is stored
		try
		{
			$BytesRead = $VHDStream.Read($TypeBytes, 0, $TypeSize)
		}
		catch
		{
			throw ("Unable to determine the disk type of {0}: {1}" -f $Path, $_)
		}
		if($BytesRead)
		{
			[Array]::Reverse($TypeBytes)	# surprise byte reversal!
			if([System.BitConverter]::ToUInt32($TypeBytes, 0) -eq 4)	# is the differencing type
			{
				$VHDStream.Position = 576	# this is where the name of the parent is stored, if any
				1..256 | foreach {	# there are 512 bytes in the name, but they're also reversed. this is much more miserable to fix
					try
					{
						$BytesRead = $VHDStream.Read($ChunkBytes, 0, $ChunkSize)
					}
					catch
					{
						throw ("Unable to read the parent of {0}: {1}" -f $Path, $_)
					}
					if($BytesRead)
					{
						[Array]::Reverse($ChunkBytes)
						$ReverseParentBytes += $ChunkBytes
					}
				}
				$AbsolutePath = [System.Text.Encoding]::Unicode.GetString($ReverseParentBytes) -replace "(?<=\.vhd).*"	# remove leftover noise
			}
		}
	}
	else
	{
		throw ("{0} is not a valid VHD(X) file or has a damaged header" -f $Path)
	}
}
catch
{	<#
		PowerShell does not implement any form of "goto" or "using", so the purpose of this outer try block is to simulate goto functionality with an ending point
		that ensures that the file is always closed, if one was opened. otherwise, PS's normal erroring is sufficient
	#>
	throw($_)
}
finally
{
	if($VHDStream)
	{
		$VHDStream.Close()
	}
}
$AbsolutePath