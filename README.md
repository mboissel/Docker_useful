# Docker_useful

+ snippets about docker cmd
+ dev containers
+ vscode and ssh key

## Deploy a project under dev-container (VScode!)

Aim : Build the docker container in live, when opening the project folder

step 1 : install vscode, in trust mode (not restricted).  
https://code.visualstudio.com/download

step 2 : in extension, install in local "remote ssh" and "dev container"  

step 3 : make sure you are a user from biostat infra  
(see http://gitlab.egid.local/Calcul/biostats-infrastructure/-/wikis/Server/Create-Sudo-Users)

step 4 : Go in "Remote Explorer" (left icons),  
Select in scrolling menu the "Remote" list,  
Clic on the "+" for a "new remote" connexion,  
Select the host (for instance the server called "Server17"),  
Save the footprint (yes) and specify it is a "Linux" environment (all will be saved in your local profil folder D:\Profils\username\.ssh)  
Type the commande for run the ssh remote connexion ssh username@host for instance ssh username@Server17  
Type your password  
In the greed little left corner you would read "ssh Server17" if you are connected.

step 5 : Open a terminal  
Either with the shortcut (ctrl + ù)  
I suggest to setup one very important shortcut : to close the remote connexion properly.  
Nor with "View" > "Command Palette" > where you can start typing what you are looking for "open terminal" ...  
To quit the the Command Palette, type "Echap".

step 6 : (not mendatory) in extension, install in server "Docker" pluggin, so you will be able to start/stop/restart your container easily.

step 7 : Open a new folder = Open a project.  
Either with the with welcome page  
Either with the shortcut "ctrl + k   ctrl + o"  
Not with "View" > "Command Palette" > typing "open folder" ...  

step 8 : Dev container  
Once you have entered your password once (to reconnect the host),  
Vscode will detect if a folder ".devcontainer" is existing.  
If yes, a pop up window in the right corner will ask if you want to "Reopen in a container" this project,  
Yes you do !  
So you must re-enter your password to let know the system your are allowed to build a docker container,  
and re-re-enter your password to check if you are someone allowed to be connected in this project.  

step 9 : Enjoy  
You can start work on the project build form the environemnt parametrized in the .devcontainer.json and its dockerfile.  
You can open a new terminal (ctrl + ù) in bash or R or what ever (see the "\/" button)  

Bonus : fed up of typing your password, see how to set up the ssh key...

## VScode Tips : In case of problem

Check via an other tool (like mobaXterm) if the ssh connection is ok (just connect to any server), so you know it is VScode which has a problem...  
or if it is a ssh problem (see your ssh key, or anything related in .ssh folder)

Stop and Restart the project's container, (via the docker pluggin in VScode or via docker cli in server)  
then try to reconnect to the project.  
You can also "Rebuild and re open the container" if just restart didn't worked.

Check if the "Dev Containers" plugin was automatically updated very recently, if so, the problem might come from here.  
You can try to install an older version (e.g., a version from a couple of weeks ago), then close and reopen the VScode to reload the installed old version of "Dev Containers", now you can try to open your dev container as usual.

Finally, when you close not properly the vscode session, you will fail to reconnect next time (sometime).  
So you should close all VScode opened, and go in your home (in the server cd /home/username/) and just clean the folder rm -rf ~/.vscode-server/bin/*  
More generaly, if problems still occured when tring to open your project in VScode, we just close VScode, clear all ".vscode-" folder from the user home (in server), and re-do the connexion steps...  
(hardcore but it usually works). It is possible that you have to re-install some vscode-pluggins related to the server (like the Docker one).  
Also sometime the ssh connection can not restart because of the "vscode-server" folder mentionned in errors. you may need to clean .nfsfile openned.  
(see explanation here https://stackoverflow.com/questions/63340440/rm-cannot-remove-vscode-server-bin-xxxxxx-nfs000000000xxxxxxxxxxxx-device)  
Go on your .vscode-server/, try to rm -rf bin/ you will see which .nfs makes trouble (in errors message), go in the named folder, use lsof .nfs** and kill it kill -9 [PID] (when [PID] is to replace with the processus ID of the openned file).

Look in the error if it is related to a specific line from the dockerfile used in this project  
(for instance previously we used to have ` RUN Rscript -e 'pak::pkg_install(c("httpgd"))' ` but this R pkg was archive in 01/2024 so the build trying to pull it via CRAN failed).

## SSH key

In VScode, the .ssh config folder is  D:\Profils\username\.ssh

Open a windows terminal (power shell) and make a key in windows with ssh-keygen -t rsa -C "youradress@company.fr"

It will produce this message bellow, to skip the set up of the pass word just press enter 2 times.

```
Generating public/private rsa key pair.
Enter file in which to save the key (D:\Profils\username/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in D:\Profils\username/.ssh/id_rsa.     
Your public key has been saved in D:\Profils\username/.ssh/id_rsa.pub.     
The key fingerprint is: ....
```

Put the pub key (from windows) in authorized key file in server : "/home/username/.ssh/authorized_keys"

The id_rsa file should be well detected (after a reboot), but the precision may be needed, in VScode, you can oped the config file and add the wanted id_rsa to use like :

```
Host name-server
  HostName Server17.egid.local
  User username 
  Port 22
  IdentityFile D:\Profils\username\.ssh\id_rsa
```
