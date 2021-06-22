#!/bin/ash

cd /home/specify/taxa_tree_gbif/back_end/ && /home/specify/venv/bin/python3 refresh_data.py
cd /home/specify/taxa_tree_itis/back_end/ && /home/specify/venv/bin/python3 refresh_data.py
cd /home/specify/taxa_tree_col/back_end/ && /home/specify/venv/bin/python3 refresh_data.py
tail -f /dev/null
