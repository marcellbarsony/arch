import shutil


class SecureShell():

    """SSH setup"""

    @staticmethod
    def bashrc(user: str):
        src = f"/temporary/ssh/.bashrc"
        dst = f"/home/{user}/.bashrc"
        shutil.copy2(src, dst)
