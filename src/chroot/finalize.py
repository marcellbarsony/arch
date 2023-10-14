import os
import grp
import pwd
import shutil


class Finalize():

    """Finalize setup"""

    def __init__(self, user: str):
        self.user = user

    def ownership(self):
        target = f"/home/{self.user}/"
        uid = pwd.getpwnam(self.user).pw_uid # Owner
        gid = grp.getgrnam(self.user).gr_gid # Group
        for dirpath, dirnames, filenames in os.walk(target):
            for dirname in dirnames:
                dir_path = os.path.join(dirpath, dirname)
                os.chown(dir_path, uid, gid)
            for filename in filenames:
                file_path = os.path.join(dirpath, filename)
                os.chown(file_path, uid, gid)

    def remove_dirs(self):
        home_dir = f"/home/{self.user}"
        dirs = [
            ".config",
            "Desktop",
            "Documents",
            "Music",
            "Public",
            "Templates",
            "Videos"
        ]
        for dir in dirs:
            path = os.path.join(home_dir, dir)
            if os.path.exists(path):
                shutil.rmtree(path)
