# wsb - Website Backup

Backup your website via SSH, including all files and databases, stored with full history into Git.

## Requirements

* Git (on client side)
* Python2 or Python3 (on client side)
* Rsync (on client and server side)
* SSH (on client and server side)

## Notes

Assuming an existing `.my.cnf` in the remote user's home directory:

    [client]
    user = jane
    password = ...

## Tests

Run tests with Python2 as well as Python3:

    ./wsb test

Run tests only with default Python version:

    ./wsb test_single
