#!/bin/bash

dep_list=(git help2man perl python3 make autoconf g++ flex bison ccache \
                libgoogle-perftools-dev numactl perl-doc)
dep_list_optional=(libfl2 libfl-dev zlibc zlib1g zlib1g-dev)
errors=()
for dep in "${dep_list[@]}"
do
package=$(find / -name "$dep")
if [[ "" ==  "$package" ]];  
then echo "$dep not installed. You have to instal this dependency before install of verilator."
	errors=( "${errors[@]}" "$dep" ) 
else echo "$dep ok"
fi
done

for dep in "${dep_list_optional[@]}"
do
package=$(find / -name "$dep")
if [[ "" ==  "$package" ]];  
then echo "$dep not installed. You have to instal this dependency before install of verilator."
        echo "If you use Ubuntu and you have errors related to libfl2 or libfl-dev or zlibc or zlib1g or zlib1g-dev you can ignore them, and continue installation of verilator"
else echo "$dep ok"
fi
done


if [ ${#errors[*]} -ne 0 ];
then
       echo ${#errors[*]}	
	exit 1
fi
