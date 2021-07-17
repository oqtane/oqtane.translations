dotnet build -c Release ..\..\Oqtane.sln
mkdir ..\..\Oqtane.Server\bin\Debug\net5.0\ur-PK
copy ..\..\Oqtane.Server\bin\Release\net5.0\ur-PK\Oqtane.Client.resources.dll ..\..\Oqtane.Server\bin\Debug\net5.0\ur-PK\Oqtane.Client.resources.dll
..\..\Oqtane.Package\nuget.exe pack Oqtane.Client.ur-PK.nuspec
pause 