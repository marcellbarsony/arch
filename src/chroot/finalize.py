import os
import grp
import pwd

class Finalize():

    """Finalize setup"""

    @staticmethod
    def ownership(user: str):
        target = f'/home/{user}/'
        uid = pwd.getpwnam(user).pw_uid # Owner
        gid = grp.getgrnam(user).gr_gid # Group
        for dirpath, dirnames, filenames in os.walk(target):
            for dirname in dirnames:
                dir_path = os.path.join(dirpath, dirname)
                os.chown(dir_path, uid, gid)
            for filename in filenames:
                file_path = os.path.join(dirpath, filename)
                os.chown(file_path, uid, gid)
