dotnet build -c Release ..\..\Oqtane.slnx
mkdir ..\..\Oqtane.Server\bin\Debug\net10.0\de-DE
copy ..\..\Oqtane.Server\bin\Release\net10.0\de-DE\Oqtane.Client.resources.dll ..\..\Oqtane.Server\bin\Debug\net10.0\de-DE\Oqtane.Client.resources.dll
..\..\Oqtane.Package\nuget.exe pack Oqtane.Client.de-DE.nuspec
pause 

