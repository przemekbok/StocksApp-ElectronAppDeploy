#!/bin/bash

if [ $# -eq 0 ]; then
    echo "You need to provide credentials for GPWTraderAPI database."
else
    #get argv
    args=("$@")

    filename='.env'
    n=1
    while read line; do
    #read version of build from .env file
    IFS==
    set $line
    BUILD=$2
    done < $filename

    #if current build directory exist - remove it
    DIR="./electron_app_build_${BUILD}"
    if [ -d "$DIR" ]; then
        rm -rf $DIR
    fi

    #increment version for next release and save it in .env file
    numbr=`echo $BUILD 0.01 | awk '{print $1 + $2}'`
    echo BUILD=$numbr > $filename

    #save directory name as variable and create new build directory
    catalogname="electron_app_build_${numbr}"
    mkdir $catalogname

    #copy electron core app to build directory
    cp -RT electron_app $catalogname
    #copy frontend build to build directory
    cp -R build $catalogname

    #copy GPWTrader to build directory
    gpwtdir="${catalogname}/GPWTrader"
    mkdir $gpwtdir
    git clone /home/przemo/Documents/Prace/Magisterka/APImisc/GPWTrader $gpwtdir
    cd $gpwtdir
    rm -fr .git
    npm install && cd .. #&& nexe -i ./GPWTrader/bin/www

    #modify Main.js
    sed -i -e "s/'..\/build'/'.\/build'/g" Main.js

    #add gpwtrader API server to an app
    sed -i -e "s/\/\/init-process/const process = require('child_process').execFile(\`\${__dirname}\/www\`);/g" Main.js 
    sed -i -e "s/\/\/kill-process/process.kill('SIGKILL');/g" Main.js 

    #add .env to gpw server
    printf "LOGIN=${args[0]}\nPASSWORD=${args[1]}\nADDRESS=gpwtrader.ok87b.mongodb.net/gpwtrader?retryWrites=true&w=majority" > ./GPWTrader/.env
fi

