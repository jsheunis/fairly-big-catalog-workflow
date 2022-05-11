## --- UNDER DEVELOPMENT ---
*This repository is undergoing continuous development and all branches should
be considered unstable*

---

# FAIRly Big Catalog Workflow

This repository provides scripts for generating a user-friendly, browser-based
catalog from a set of (distributed) DataLad datasets. It uses the functionality
of [Datalad](https://www.datalad.org/) and several DataLad extensions, mainly
[datalad-metalad](https://github.com/datalad/datalad-metalad) and [datalad-catalog](https://github.com/datalad/datalad-catalog).

It was inspired by the [FAIRly big processing workflow](https://github.com/psychoinformatics-de/fairly-big-processing-workflow), which was also built using DataLad.

See an original description of the idea [in this issue](https://github.com/datalad/datalad-catalog/issues/36).


## Workflow description

This workflow is designed to run
1. metadata extraction,
2. translation of extracted metadata into compatible structures,
3. and adding translated metadata to a data catalog,

all as part of a distributed and automated workflow on linked datasets.

The workflow has two variants: distributed and local.

### Distributed

*\*not functional yet - to be completed\**

The distributed worklfow is designed to run on computing infrastructure and
under the direction of a workflow manager such as HTCondor or SLURM. It supports
distributed catalog generation in the sense that: 
- A single job can orchestrate the creation of a catalog, and can kick off the procedure
to add an arbitrary number of datasets to the catalog
- Procedures run on individual datasets are run by individual, parallelized jobs
- After completion of distributed jobs, these additions can be made part of the whole
via an octopus-merge.

The technical design is as follows:
```
Main job:
- clone superdataset
- create catalog
- catalog set super
- extract dataset+file metadata of superdataset
- translate and add superdataset metadata to catalog
- save catalog as a datalad dataset (which config? text2git?)
- start per-subdataset jobs in parallel (by accessing subdatasets)

Per-dataset job (args: subdataset, catalog):
- clone subdataset
- extract dataset/file metadata
- translate metadata to catalog schema
- clone catalog, check out subdataset-specific branch
- add metadata to catalog
- commit to subdataset-specific branch
- push to origin/upstream

Main job (continue once subdataset jobs completed):
- merge all branches into master (no conflicts since subdataset jobs only added new content to seperate locations)
- push catalog to server
```

### Local

This is currently the only functional variant of the workflow. The design
mirrors the functioning of the distributed variant except:
- the superdataset and subdatasets are cloned locally beforehand
- the job is run by the user (i.e. without a job scheduler)
- parallalized jobs are executed in a loop

This variant is intended for local testing or generation of catalogs from small
and locally available datasets that won't require large computing resources.

The local variant also allows for generating a catalog from already extracted
metadata, by skipping the first of the three steps listed in the workflow
description above.


### Extractor translators

An integral part of this workflow includes translating extracted metadata to
the format expected by `datalad-catalog`'s schema. For this purpose, the subdirectory
`extractor_translators/` contains several shell scripts to translate metadata between
known structures: always from the format that is output by the particular extractor and
`datalad-metalad` into the format expected by the catalog. Mostly, these scripts make
extensive use of `jq`, but this is not a hard requirement.

Developers aiming to make use of this workflow will have to ensure that a translator
script exists that is compatible with their extracted metadata and `datalad-catalog`.


## Installation

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

If you want to generate a new catalog from already extracted metadata, you can
use the script that only translates (instead of extracts and translates):

```bash
CATALOGDIR="directory-where-new-catalog-is-created"
local/local_run_main_translate_only.sh $SUPER_PATH $OUTDIR $CATALOGDIR
```


### Distributed:
*to be completed*

## Practical example
Using the StudyForrest dataset... *to be completed*