#!/bin/bash

echo -ne "Checking for pox: "
pushd ~ 1> /dev/null
if [ ! -e "pox" ]; then
    echo "Not found: Downloading:"
    git clone https://github.com/noxrepo/pox.git
else 
    echo "Found."
fi
popd 1> /dev/null

echo -ne "Checking for ~/pox/ext: "
pushd ~/pox/ 1> /dev/null
if [ ! -e "ext" ]; then
    echo "Not found: Creating."
    mkdir ext
else 
    echo "Found."
fi
popd 1> /dev/null

cd ~
if [ -e "eec273_hedera" ]; then
    echo "Renaming 'eec273_hedera' to 'hedera'"
    mv eec273_hedera hedera
fi
cd hedera

echo -n "checking for matplotlib: "
python -c "import matplotlib" 2> /dev/null
if [ "$?" -ne "0" ]; then
    echo "Not found. Installing."
    sudo apt-get install -y python-matplotlib
else
    echo "Found."
fi

echo "Checking for required softlinks in ~/pox/ext"
ls ~/hedera | grep ".py$" > deps
ls ~/pox/ext | grep ".py$" > links
reqs=`diff deps links | grep "<" | awk '{print $2}'`

echo "Adding missing links"
pushd ~/pox/ext 1> /dev/null
for file in $reqs; do
    echo "Adding link ~/pox/ext/$file"
    ln -s ~/hedera/$file
done
echo "Done adding links"
popd 1> /dev/null

echo -ne "Cleaning Up.. "
rm deps links
echo "done"
