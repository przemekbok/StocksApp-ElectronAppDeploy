#create deploy folder w tmp
currentdir=$(pwd)
dirname="electron-app-deploy"

args=("$@")

filename='.env'
n=1
while read line; do
    #read version of build from .env file
    IFS==
    set $line
    BUILD=$2
done < $filename

if [ "${args[0]}" == "--win" ]; then
    dirname="${dirname}-win"
fi

dirname="${dirname}-${BUILD}"
dirpath="/tmp/${dirname}"

#remove old deploy
numbr=`echo $BUILD 0.01 | awk '{print $1 - $2}'`
rm -r "./electron_app_build_${numbr}"

#copy latest build to folder
DIR="./electron_app_build_${BUILD}"
cp -RT "${DIR}" "${dirpath}"

cd $dirpath

#parse args, check if deploy is for linux or windows
if [ "${args[0]}" == "--win" ]; then
    #if windows change child process line for exe then generate exe 
    nexe --target win32 -i ./GPWTrader/bin/www && cd $currentdir && electron-packager $dirpath --platform win32 --overwrite
else
    #if linux just make executable and deploy
    nexe -i ./GPWTrader/bin/www && cd $currentdir && electron-packager $dirpath --overwrite
    #create .desktop file with input:
    cd electron_app-linux-x64
    echo "[Desktop Entry]" > .desktop
    echo "Name=My App" >> .desktop
    excline='"$(dirname "$1")"/electron_app'
    echo Exec=bash -c "'${excline}'" dummy %k >> .desktop
    echo "Terminal=false" >> .desktop
    echo "Type=Application" >> .desktop
    chmod +x ./.desktop
fi

cp -r $dirpath $currentdir
rm -r $dirpath

