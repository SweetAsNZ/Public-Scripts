wmic csproduct get name
:: 
:: OUTPUT:
:: Name
:: ProLiant BL680c G5
:: 
:: =============================================================================
:: 
wmic csproduct get vendor,name,identifyingNumber
:: 
:: OUTPUT:
:: IdentifyingNumber  Name                Vendor
:: TWT833003W         ProLiant BL680c G5  HP
:: 
:: =============================================================================
:: 
wmic csproduct
:: 
:: OUTPUT:
:: Caption                  Description              IdentifyingNumber  Name
::          SKUNumber  UUID                                  Vendor  Version
:: Computer System Product  Computer System Product  TWT833003W         ProLiant BL
:: 680c G5             35333434-3832-5754-5438-333330303357  HP
:: 
:: =============================================================================
:: 
wmic bios get serialnumber
:: 
:: OUTPUT:
:: SerialNumber
:: CN71480G3Q

PAUSE
