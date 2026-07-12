#!/usr/bin/env python3
from __future__ import annotations

import datetime
import shutil
import subprocess


def main():
    shutil.copyfile(
        "/var/www/dolibarr/htdocs/conf/conf.php", "/home/gilles/Documents/COMPTA/BACKUP/conf.php"
    )
    date = datetime.date.today().__str__()
    args = [
        "mysqldump",
        "-udolibarr",
        "-pOt55Ot5:)",
        "--result-file=/home/gilles/Documents/COMPTA/BACKUP/sqldump_%s.sql" % date,
        "dolibarr",
    ]
    subprocess.run(args, check=True, text=True)


if __name__ == "__main__":
    main()
