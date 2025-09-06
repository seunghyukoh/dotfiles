#!/bin/bash

set -e

brew install miniconda

~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh
