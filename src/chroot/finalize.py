import logging
import os
# import grp
# import pwd
import shutil


def change_ownership(user: str):
    target = f"/home/{user}/"
    # uid = pwd.getpwnam(user).pw_uid  # Owner
    # gid = grp.getgrnam(user).gr_gid  # Group
    shutil.chown(target, user=user, group=user)
    for dirpath, dirnames, filenames in os.walk(target, followlinks=False):
        # for dirname in dirnames:
        #     dir_path = os.path.join(dirpath, dirname)
        #     os.chown(dir_path, uid, gid)
        # for filename in filenames:
        #     file_path = os.path.join(dirpath, filename)
        #     os.chown(file_path, uid, gid)
        for name in dirnames + filenames:
            path = os.path.join(dirpath, name)

            # Skip symlinks
            if os.path.islink(path):
                logging.info("skipping symlink :: %s", path)
                continue

            try:
                shutil.chown(path, user=user, group=user)
            except Exception as err:
                logging.error(err)

def remove_xdg_dirs(user: str):
    home_dir = f"/home/{user}"
    dirs = [
        ".config",
        "Desktop",
        "Documents",
        "Downloads",
        "Music",
        "Pictures",
        "Public",
        "Templates",
        "Videos"
    ]
    for dir in dirs:
        path = os.path.join(home_dir, dir)
        if os.path.exists(path):
            shutil.rmtree(path)
            logging.info(path)
