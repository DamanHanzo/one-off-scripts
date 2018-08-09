## Bash/Shell Scripts

All one-off shell scripts are maintained in this directory.

### deployjob.sh

Deploys local job directory changes to various TED job environments.

#### Prerequisite:

1. Get the job environment host names and path to the job server's app(where jobs are stored) directory from fellow tpl devs.
2. Install dos2unix
   - `sudo apt-get install dos2unix`
   - Windows users
   	 - Enable `Developer Mode`
   	   - Read this article: [Windows 10 Enable Developer Mode](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
