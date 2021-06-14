dotnet build -c Release ..\..\Oqtane.sln
mkdir ..\..\Oqtane.Server\bin\Debug\net5.0\de-DE
copy ..\..\Oqtane.Server\bin\Release\net5.0\de-DE\Oqtane.Client.resources.dll ..\..\Oqtane.Server\bin\Debug\net5.0\de-DE\Oqtane.Client.resources.dll
..\..\Oqtane.Package\nuget.exe pack Oqtane.Client.de-DE.nuspec
pause 

