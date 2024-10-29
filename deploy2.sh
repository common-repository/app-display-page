#! /bin/bash
# A modification of Dean Clatworthy's deploy script as found here: https://github.com/deanc/wordpress-plugin-git-svn
# The difference is that this script lives in the plugin's git repo & doesn't require an existing SVN repo.

# git config
GITPATH="$CURRENTDIR/" # this file should be in the base of your git repository

# svn config
SVNPATH="../app-display-page-svn" # path to a temp SVN repo. No trailing slash required and don't add trunk.
SVNURL="http://plugins.svn.wordpress.org/app-display-page/" # Remote SVN repo on wordpress.org, with no trailing slash
SVNUSER="mjar81" # your svn username

SVNIGNORE = "deploy.sh
README.md
Readme.md
.git
.gitignore
deploy.sh"

echo "Exporting the HEAD of master from git to the trunk of SVN"
git checkout-index -a -f --prefix=$SVNPATH/trunk/

# rsync the directories so that we're sure that files are deleted that should be
rsync --verbose --progress --recursive --delete --exclude "$SVNIGNORE" ./* "$SVNPATH/trunk/"

echo "Ignoring github specific files and deployment script"
svn propset svn:ignore "$SVNIGNORE" "$SVNPATH/trunk/"

echo "Changing directory to SVN and committing to trunk"
cd $SVNPATH/trunk/
# Add all new files that are not set to be ignored
svn status | grep -v "^.[ \t]*\..*" | grep "^?" | awk '{print $2}' | xargs svn add
# Delete files that aren't present any more.
svn status | grep '^\!' | sed 's/! *//' | xargs -I% svn rm %

svn commit --username=$SVNUSER -m "$COMMITMSG"

echo "*** FIN ***"