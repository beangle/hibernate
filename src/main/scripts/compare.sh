#!/bin/sh

if [ "$2" = "" ]; then
    echo "Usage:compare.sh old_version new_version"
    exit
fi
export M2_REMOTE_REPO="https://maven.aliyun.com/nexus/content/groups/public"
export M2_REPO="$HOME/.m2/repository"

download(){
  zip_dir="$M2_REPO/org/hibernate/hibernate-core/$1/"
  zip_file="$M2_REPO/org/hibernate/hibernate-core/$1/hibernate-core-$1-sources.jar"
  zip_url="$M2_REMOTE_REPO/org/hibernate/hibernate-core/$1/hibernate-core-$1-sources.jar"

  if [ ! -f $zip_file ]; then
    mkdir -p $zip_dir
    cd $zip_dir||exit
    if wget $zip_url 2>/dev/null; then
        echo "fetching $zip_file"
      else
        echo "hibernate-core-$1-sources.jar download error,compare aborted."
        exit 1
      fi
  fi
}

cd /tmp/
download "$1"
download "$2"

extract(){
  zip_file="$M2_REPO/org/hibernate/hibernate-core/$1/hibernate-core-$1-sources.jar"
  rm -rf /tmp/hibernate
  mkdir -p /tmp/hibernate
  unzip -q $zip_file -d /tmp/hibernate
  export target="/tmp/hibernate-core-$1/"
  rm -rf "$target"
  mkdir -p "$target"
  cd /tmp/hibernate/
  files=("org/hibernate/action/internal/CollectionUpdateAction.java"
  "org/hibernate/collection/internal/AbstractPersistentCollection.java"
  "org/hibernate/collection/internal/PersistentArrayHolder.java"
  "org/hibernate/collection/internal/PersistentBag.java"
  "org/hibernate/collection/internal/PersistentIdentifierBag.java"
  "org/hibernate/collection/internal/PersistentList.java"
  "org/hibernate/collection/internal/PersistentMap.java"
  "org/hibernate/collection/internal/PersistentSet.java"
  "org/hibernate/collection/internal/PersistentSortedMap.java"
  "org/hibernate/collection/internal/PersistentSortedSet.java"
  "org/hibernate/collection/spi/PersistentCollection.java"
  "org/hibernate/hql/internal/ast/tree/AbstractMapComponentNode.java"
  "org/hibernate/hql/internal/ast/HqlSqlWalker.java"
  )
  for f in ${files[@]}
  do
    mkdir -p $target${f%/*}
    cp $f $target$f
  done
}

extract "$1"
extract "$2"
cd /tmp

meld "hibernate-core-$1" "hibernate-core-$2"
