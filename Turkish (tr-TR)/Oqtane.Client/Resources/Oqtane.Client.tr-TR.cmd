dotnet build -c Release ..\..\Oqtane.slnx
mkdir ..\..\Oqtane.Server\bin\Debug\net10.0\tr-TR
copy ..\..\Oqtane.Server\bin\Release\net10.0\tr-TR\Oqtane.Client.resources.dll ..\..\Oqtane.Server\bin\Debug\net10.0\tr-TR\Oqtane.Client.resources.dll
..\..\Oqtane.Package\nuget.exe pack Oqtane.Client.tr-TR.nuspec
pause

