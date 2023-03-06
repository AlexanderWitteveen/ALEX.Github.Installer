#!/bin/bash -l

path=$(pwd)

#echo "$INPUT_SCRIPT"
#echo "$INPUT_NAME"
#echo "$path"

if [ "$INPUT_SCRIPT" != "pwsh" ] && [ "$INPUT_SCRIPT" != "bash" ] ; then
    echo "Script does not match [pwsh, bash]"
    exit 1
fi

cd $INPUT_SOURCEFOLDER
zip -r $path/folder.zip *
cd $path
folder=$( base64 -w 0 folder.zip )

if [ "$INPUT_SCRIPT" == "pwsh" ] ; then
    filename="$INPUT_NAME.ps1"
    scriptpath="./$filename"
    echo '# Powershell' > $scriptpath
    echo "# Install script for $INPUT_NAME" >> $scriptpath
    echo -n "\$folder='"  >> $scriptpath
    echo -n "$folder" >> $scriptpath
    echo "'" >> $scriptpath
    echo "\$name=\"$INPUT_NAME\"" >> $scriptpath
    echo "\$rootfolder=\"$INPUT_ROOTFOLDER\"" >> $scriptpath
    echo "\$targetfolder=\"$INPUT_TARGETFOLDER\"" >> $scriptpath
    echo "\$install=\"$INPUT_INSTALL\"" >> $scriptpath
    cat /basescript.ps1 >> $scriptpath
elif [ "$INPUT_SCRIPT" == "bash" ] ; then
    filename="$INPUT_NAME.sh"
    scriptpath="./$filename"
    echo '#!/bin/bash -l' > $scriptpath
    echo "# Install script for $INPUT_NAME" >> $scriptpath
    echo -n "folder='" >> $scriptpath
    echo -n "$folder" >> $scriptpath
    echo "'" >> $scriptpath
    echo "name=\"$INPUT_NAME\"" >> $scriptpath
    echo "rootfolder=\"$INPUT_ROOTFOLDER\"" >> $scriptpath
    echo "targetfolder=\"$INPUT_TARGETFOLDER\"" >> $scriptpath
    echo "install=\"$INPUT_INSTALL\"" >> $scriptpath
    cat /basescript.sh >> $scriptpath
fi

echo "filename=$filename" >> $GITHUB_OUTPUT

exit 0
