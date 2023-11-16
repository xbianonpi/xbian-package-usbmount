#!/bin/sh

rm_size() {
	cat ./content/DEBIAN/control | grep -v "Installed-Size:" > ./content/DEBIAN/control.new
	mv ./content/DEBIAN/control.new ./content/DEBIAN/control
}

package=$(cat ./content/DEBIAN/control | grep Package | awk '{print $2}')
version=$(cat ./content/DEBIAN/control | grep Version | awk '{print $2}')
arch="_$(grep -m1 'Architecture\:' ./content/DEBIAN/control | awk -F':' '{print $2}' | tr -d ' ')"

# calculate size dynamically. remove first any entry, then add the actual 
rm_size
printf "Installed-Size: %d\n" $(du -s ./content | awk '{print $1}') >> ./content/DEBIAN/control

cd content
find ./ -type f -print0 |xargs --null strip 2>/dev/null
find ./ -type f ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -printf '%P\0' | sort -z| xargs --null md5sum > DEBIAN/md5sums
cd ..
fakeroot dpkg-deb -b ./content "${package}-${version}${arch}".deb

# remove the size again, because on different filesystems du will return different size
rm_size
