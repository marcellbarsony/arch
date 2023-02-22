import os


class Fstab():

    """Docstring for Fstab"""

    def fstab_dir(self):
        os.mkdir('/mnt/etc')

    def fstab_gen(self):
        os.system('genfstab -U /mnt >> /mnt/etc/fstab')


f = Fstab()
f.fstab_dir()
f.fstab_gen()
