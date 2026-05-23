dotnet build -c Release ..\..\Oqtane.slnx
mkdir ..\..\Oqtane.Server\bin\Debug\net10.0\pt-BR
copy ..\..\Oqtane.Server\bin\Release\net10.0\pt-BR\Oqtane.Client.resources.dll ..\..\Oqtane.Server\bin\Debug\net10.0\pt-BR\Oqtane.Client.resources.dll
..\..\Oqtane.Package\nuget.exe pack Oqtane.Client.pt-BR.nuspec
pause

