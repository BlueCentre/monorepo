# Scratch

1. wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
1. echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
1. sudo apt-get update && sudo apt-get upgrade && sudo apt-get install terraform

## Tech Bloggers

- https://wdenniss.com/
- https://piotrminkowski.com/author/piotr-minkowski/
