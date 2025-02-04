#!/bin/bash

python manage.py collectstatic --noinput || exit 1

python manage.py migrate || exit 1

gunicorn kittygram_backend.wsgi:application --bind 0.0.0.0:8000