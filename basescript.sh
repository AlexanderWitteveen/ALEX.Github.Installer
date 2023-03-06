if [ $( whoami ) != "root" ]; then
    sudo $0
    exit 0
fi

echo "Installing: $name"

targetpath="$rootfolder/$targetfolder"
zippath="$targetpath/install"
installpath="$zippath/$install"

mkdir -p "$zippath"

echo $folder | base64 -d > "$zippath.zip"

unzip -o -q "$zippath.zip" -d "$zippath"

rm "$zippath.zip"

if [ ! -z $install ]; then
    chmod 777 $installpath
    $installpath
fi

echo "press key..."
read -n 1
