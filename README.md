# FAIRly Big Catalog Workflow

This repository provides scripts for generating a user-friendly, browser-based
catalog from a hierarchy of (distributed) DataLad datasets. It uses the functionality
of DataLad and several DataLad extensions.



## Workflow options

### Local
*to be completed*

### Distributed
*to be completed*


## Workflow description

*to be completed*

## Install dependencies

First install DataLad by following [these instructions](https://www.datalad.org/#install).

Then install the DataLad extensions:
- [`datalad-metalad`](https://github.com/datalad/datalad-metalad)
- [`datalad-catalog`](https://github.com/datalad/datalad-catalog)

```
git clone https://github.com/datalad/datalad-metalad
cd datalad-metalad
pip install -e .
cd ..

git clone https://github.com/datalad/datalad-catalog.git
cd datalad-catalog
pip install -e .
cd ..
```

If the metadata extractors available in the `datalad-metalad` and `datalad-catalog`
extensions do not cover your use case, please also install the additional extensions
or packages that you may require.

For example, an updated BIDS dataset extractor (WIP) in [`datalad-neuroimaging`](https://github.com/datalad/datalad-neuroimaging):
```
pip install git+https://github.com/datalad/datalad-neuroimaging.git@refs/pull/104/head
```

In addition, you will also have to provide the means
to translate these extracted metadata into the catalog schema, e.g. a script analogous to
[`extractor_translators/_studyminimeta2catalog.sh`](extractor_translators/_studyminimeta2catalog.sh),
as well as add a call to that script in [`extractor_translators/translate2catalog.sh`](extractor_translators/translate2catalog.sh).

## Run the workflow

### Preparation

Before running the script to extract metadata from local or distributed datasets,
these datasets first have to be prepared. Ideally, you will have constructed a superdataset
that contains as subdatasets all the datasets that you want to have rendered in the catalog.
This superdataset and all subdatasets should be accesible from the location where the script will be running. The main requirement is the access URL or path to the superdataset.

### Local:

#### Step 1
First clone the super dataset, and its subdatasets recursively, to your local environment.

```
datalad install -r "url-of-super-dataset"
```
#### Step 2
Then specify locations of these arguments:

```bash
SUPER_PATH="path-to-super-dataset" #
OUTDIR="directory-where-interim-metadata-files-are-saved"
CATALOGDIR="directory-where-catalog-is-created"
```

#### Step 3

Then `cd` to the root directory of this repository, and run the main script:

```bash
chmod -R u+rwx 
local/local_run_main.sh $SUPER_PATH $OUTDIR $CATALOGDIR
```

### Distributed:
*to be completed*