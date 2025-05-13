#!/bin/sh

echo "Setting up mkdocs environment in /run/shm/mkdocs-pisound-micro"
rm -rf /run/shm/mkdocs-pisound-micro
python3 -m venv /run/shm/mkdocs-pisound-micro
. /run/shm/mkdocs-pisound-micro/bin/activate

pip install -r requirements.txt
pip install libpisoundmicro/pypisoundmicro --use-pep517
pip install libpisoundmicro/pypisoundmicro --use-pep517

mkdocs build

deactivate

echo "Done! Thank you!"
