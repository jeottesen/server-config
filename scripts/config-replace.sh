help='changes [fromText] to [toText] in all sub files usage: change-user.sh [fromText] [toText]'

if [[ -z $1 || -z $2 ]]; then
    echo $help
elif [[ $1 == "-h" ]]; then
        echo $help
else
    find ~/docker/ -type f | grep -f ~/docker/scripts/include.txt | xargs -L1 sed -i "s/$1/$2/g"
fi