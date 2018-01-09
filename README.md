# CryptoAlert

1. You will need to add your own values from a Twilio account(you can get free a trial) into app/models/currency_status.rb

2. And you will want to personalize the volume values in the docker-compose.yml file.

3. Other than that just run `docker-compose build` then `docker compose up`.

4. And to access the container while it's running: `docker-compose exec web /bin/bash`
