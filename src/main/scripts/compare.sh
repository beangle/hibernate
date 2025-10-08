#!/bin/sh

if [ "$2" = "" ]; then
    echo "Usage:compare.sh old_version new_version"
    exit
fi
export M2_REMOTE_REPO="https://repo1.maven.org/maven2"
export M2_REPO="$HOME/.m2/repository"

download(){
  zip_dir="$M2_REPO/org/hibernate/orm/hibernate-core/$1/"
  zip_file="$M2_REPO/org/hibernate/orm/hibernate-core/$1/hibernate-core-$1-sources.jar"
  zip_url="$M2_REMOTE_REPO/org/hibernate/orm/hibernate-core/$1/hibernate-core-$1-sources.jar"

  if [ ! -f $zip_file ]; then
    mkdir -p $zip_dir
    cd $zip_dir||exit
    echo "downloading $zip_url"
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
  zip_file="$M2_REPO/org/hibernate/orm/hibernate-core/$1/hibernate-core-$1-sources.jar"
  rm -rf /tmp/hibernate
  mkdir -p /tmp/hibernate
  unzip -q $zip_file -d /tmp/hibernate
  export target="/tmp/hibernate-core-$1/"
  rm -rf "$target"
  mkdir -p "$target"
  cd /tmp/hibernate/
  files=("org/hibernate/action/internal/CollectionUpdateAction.java"
  "org/hibernate/collection/spi/AbstractPersistentCollection.java"
  "org/hibernate/collection/spi/PersistentArrayHolder.java"
  "org/hibernate/collection/spi/PersistentBag.java"
  "org/hibernate/collection/spi/PersistentCollection.java"
  "org/hibernate/collection/spi/PersistentIdentifierBag.java"
  "org/hibernate/collection/spi/PersistentList.java"
  "org/hibernate/collection/spi/PersistentMap.java"
  "org/hibernate/collection/spi/PersistentSet.java"
  "org/hibernate/metamodel/internal/BaseAttributeMetadata.java"
  "org/hibernate/metamodel/internal/PluralAttributeMetadataImpl.java"
  "org/hibernate/metamodel/model/domain/internal/PluralAttributeBuilder.java"
  "org/hibernate/sql/results/graph/collection/internal/BagInitializer.java"
  "org/hibernate/sql/results/graph/collection/internal/ListInitializer.java"
  "org/hibernate/sql/results/graph/collection/internal/MapInitializer.java"
  "org/hibernate/sql/results/graph/collection/internal/SetInitializer.java"
  )
  for f in ${files[@]}
  do
    mkdir -p $target${f%/*}
    cp $f $target$f
  done
}

echo "extract $1.."
extract "$1"
echo "extract $2..."
extract "$2"
cd /tmp

echo meld "hibernate-core-$1" "hibernate-core-$2"
meld "hibernate-core-$1" "hibernate-core-$2"
