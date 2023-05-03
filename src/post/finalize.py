import os

class Finalize():

    """Docstring for Finalize"""

    def __init__(self, user):
        self.user = user

    def clean_home(self):
        files = ['.bash_history', '.bash_logout', '.bash_profile', '.bashrc']
        for file in files:
            os.remove(os.path.join(f'/home/{self.user}', file))
