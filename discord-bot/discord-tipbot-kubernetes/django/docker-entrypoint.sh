#!/usr/bin/env bash

sleep 10
python manage.py makemigrations polls
python manage.py migrate
python manage.py runserver 0.0.0.0:8080
