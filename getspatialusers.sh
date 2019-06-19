#!/bin/bash

# Start an AWS instance with one of the AMIs provided by:
#  http://www.louisaslett.com/RStudio_AMI/
#
# Get this script and make executable.
#  wget THE_RAW_URL
#  chmod +x build_logins.sh
#
# Then use this script to create many logins on the system.
#
#  sudo ./build_logins.sh 50
#
# * This creates 50 users named getspatial1, getspatial2, ...
# * The passwords are the same as the user names.
# * The home directories are initialized with a copy of the "rstudio" user's
#   home directory, so you can login as rstudio (pw: rstudio) first, get it
#   set up how you want, and then run this script to create clones.
#
# Running the script again trashes all of those users and regenerates new ones.

# stop rstudio because it runs instances as the users we are trying to delete
rstudio-server stop
sleep 4 # might take time to release

# clear out any previously generated logins
existing_users=$(grep ^getspatial /etc/passwd | sed 's/:.*//')
if [ ! -z "$existing_users" ]; then
    for user in $existing_users; do
        deluser --remove-home $user > /dev/null
    done
fi

# Make new ones. (Specify the count on the comand line!)
for id in $(seq 1 $1); do
    userhome=/home/getspatial$id
    adduser \
        --gid 1001 \
        --home $userhome \
        --no-create-home \
        --quiet --gecos "" \
        --shell /bin/false \
        --disabled-password \
        getspatial$id < /dev/null
    cp -a /home/rstudio/ $userhome
    chown -R getspatial$id $userhome
    echo "getspatial$id:AOS19AK" | chpasswd
done

# start again
rstudio-server start
