wmic os get Name

OUTPUT:
Name
Microsoft Windows 7 Enterprise |C:\Windows|\Device\Harddisk0\Partition2


wmic os get BuildNumber, BuildType, Version

OUTPUT:
BuildNumber  BuildType            Version
7601         Multiprocessor Free  6.1.7601


wmic os get ServicePackMajorVersion, ServicePackMinorVersion

OUTPUT:
ServicePackMajorVersion  ServicePackMinorVersion
1                        0


ALL USEFUL:

WMIC OS GET Name,ServicePackMajorVersion,BuildNumber,Version


OUTPUT:
BuildNumber  Name                                                                     ServicePackMajorVersion  Version
7601         Microsoft Windows 7 Enterprise |C:\Windows|\Device\Harddisk0\Partition2  1                        6.1.7601