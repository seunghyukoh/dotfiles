#!/bin/bash

set -e

brew install miniconda

/opt/homebrew/bin/conda init bash
/opt/homebrew/bin/conda init zsh
