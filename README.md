# Build Rakudo Star for Windows

Based on [hankache rakudo-star-win](https://github.com/hankache/rakudo-star-win/)

## The original hankache `build.ps1` script
The script `build.ps1` is still here as a reference.
As the script doesn't check any dependencies, it did fail in my environment and may also fail on your Windows system!
Some reasons may be:
* The RAKUDO developers seem to rely on the Microsoft Visual C toolchain, like `cl.exe`, `nmake.exe` and friends nowadays, but in this script the GNU tool chain is still used to compile RAKUDO.
* To build NQP (and the MoarVM?) it is a hard requirement, [checked and enforced by the RAKUDO devs](https://github.com/Raku/nqp-configure/blob/e068508a94d643c1174bcd29e333dd659df502c5/lib/NQP/Config.pm#L252), to have `cl.exe` _version 19 or newer_ available, but this is also not checked in this script.

## New and recommended `build-with-choco.ps1` script
* Builds a release as well localy on your Windows system as also on Github.com via a workflow Action!
* The script takes also care for all the required dependencies and assures everything is installed. It uses [the choco tool](https://chocolatey.org/) for this, mainly because choco is already included in the [windows-latest](https://github.com/actions/virtual-environments/blob/main/images/win/Windows2019-Readme.md) GitHub container.

## Prerequisites:
* A similar tag / branch to the version we want to build has to exist on https://github.com/rakudo/rakudo.git
  * In example `2021.04`

* `Microsoft Visual C++ 2019`
  * _YOU_ need to install it on your Windows system before you can run `build-with-choco.ps1` locally!

### The following requirements are managed by the script.
They are all available in [windows-latest](https://github.com/actions/virtual-environments/blob/main/images/win/Windows2019-Readme.md)
* [Git](https://git-scm.com/)
* [WiX Toolset](https://wixtoolset.org/)
* [Strawberry Perl](http://strawberryperl.com/)

### Optional
* [Gpg4win](https://www.gpg4win.org/)


# On your local Windows system
## Usage
* Build the MSI package and calculate the sha256 checksum:  
  * `.\build-with-choco.ps1 [YYYY.MM]` (`YYYY.MM` is optional. If not given, the [RAKUDO latest](https://github.com/rakudo/rakudo/releases/latest) form GitHub will be used)
* Build the MSI package, calculate the sha256 checksum and sign the MSI with your key:  
  * `.\build-with-choco.ps1 [YYYY.MM] -sign`

## Output
* rakudo-star-YYYY.MM-[XY-]win-x86_64-(JIT).msi
* rakudo-star-YYYY.MM-[XY-]win-x86_64-(JIT).msi.sha256.txt
* rakudo-star-YYYY.MM-[XY-]win-x86_64-(JIT).msi.asc (optional with the `-sign` option)

# As a GitHub Action workflow
* Create a tag, which needs to be the same as on [RAKUDO](https://github.com/rakudo/rakudo/) and push it to this repo
  * `git tag -a 2021.04 -m 'Following the https://github.com/rakudo/rakudo/ release cycle'`
  * `git push --tags`
  * You can now watch the build in the `Actions` tab in your GitHub repo
  * After some time there should be a new release published

