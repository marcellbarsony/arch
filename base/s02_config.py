class Config():

    """Docstring for Menu"""

    def __init__(self):
        pass

    def main(self):
        pass

    # TODO
    # def disk_select(self):
    #     disk = subprocess.run(['lsblk', '-p', '-n', '-l', '-o', 'NAME,SIZE', '-e', '7,11'],
    #                                   stdout=subprocess.PIPE)
    #     print(disk.stdout.decode('utf-8'))

c = Config()
c.main()

disk='/dev/sda'
efidevice='/dev/sda1'
rootdevice='/dev/sda2'
cryptpassword='admin'
pacmanconf='/media/sf_arch/base/cfg/pacman.conf'
