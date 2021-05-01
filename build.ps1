param (
	[Parameter(Mandatory=$True)][string]$RAKUDO_VER,
	[switch]$checksum,
	[switch]$sign
)

# Download Rakudo and build
$progresspreference = 'silentlyContinue'
iwr https://github.com/rakudo/rakudo/releases/download/$RAKUDO_VER/rakudo-$RAKUDO_VER.tar.gz -outfile rakudo-$RAKUDO_VER.tar.gz
$progressPreference = 'Continue'
tar -xzf rakudo-$RAKUDO_VER.tar.gz
cd rakudo-$RAKUDO_VER
perl Configure.pl --backends=moar --gen-moar --moar-option="--cc=gcc" --moar-option="--make=gmake" --relocatable --prefix=C:\rakudo
gmake
gmake test
gmake install

# Download Zef and install
git clone https://github.com/ugexe/zef.git
cd zef
C:\rakudo\bin\raku.exe -I. bin\zef install .

# Add the required rakudo folders to PATH in order for some modules to test correctly (File::Which)
$Env:Path += ";C:\rakudo\bin;C:\rakudo\share\perl6\site\bin"

# Install modules
cd ..\..
C:\rakudo\bin\raku.exe C:\rakudo\share\perl6\site\bin\zef install .

# Copy required dll from Strawberry Perl
copy C:\strawberry\perl\bin\libwinpthread-1.dll -Destination C:\rakudo\bin
copy C:\strawberry\perl\bin\libgcc_s_seh-1.dll -Destination C:\rakudo\bin

# Package .msi
mkdir output
heat dir C:\rakudo\bin -dr DIR_BIN -cg FilesBin -gg -g1 -sfrag -srd -suid -ke -sw5150 -var "var.BinDir" -out files-bin.wxs
heat dir C:\rakudo\include -dr DIR_INCLUDE -cg FilesInclude -gg -g1 -sfrag -srd -ke -var "var.IncludeDir" -out files-include.wxs
heat dir C:\rakudo\share -dr DIR_SHARE -cg FilesShare -gg -g1 -sfrag -srd -ke -sw5150 -var "var.ShareDir" -out files-share.wxs
candle files-bin.wxs files-include.wxs files-share.wxs -dBinDir="C:\rakudo\bin" -dIncludeDir="C:\rakudo\include" -dShareDir="C:\rakudo\share"
candle -dSTARVERSION="$RAKUDO_VER" star.wxs
light -b C:\rakudo -ext WixUIExtension files-bin.wixobj files-include.wixobj files-share.wixobj star.wixobj -sw1076 -o "output\rakudo-star-$RAKUDO_VER-01-win-x86_64-(JIT).msi"

# SHA256
if ($checksum) {
	CertUtil -hashfile "output\rakudo-star-$RAKUDO_VER-01-win-x86_64-(JIT).msi" SHA256 | findstr /V ":" > "output\rakudo-star-$RAKUDO_VER-01-win-x86_64-(JIT).msi.sha256.txt"
}

# GPG signature
if ($sign) { 
	gpg --armor --detach-sig "output\rakudo-star-$RAKUDO_VER-01-win-x86_64-(JIT).msi"
}

# Clean up
del rakudo-$RAKUDO_VER.tar.gz
del files-bin.wxs
del files-include.wxs
del files-share.wxs
del files-bin.wixobj
del files-include.wixobj
del files-share.wixobj
del star.wixobj
del "output\rakudo-star-$RAKUDO_VER-01-win-x86_64-(JIT).wixpdb"
rmdir rakudo-$RAKUDO_VER -Recurse -Force