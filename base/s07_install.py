import os
import shutil
import subprocess


from base.s02_config import pacmanconf


class Mirror():

    """Update & back-up mirrolist"""

    def __init__(self):
        super(Mirror, self).__init__()

    def mirrorlist_bak(self):
        src='/etc/pacman.d/mirrorlist'
        dst='/etc/pacman.d/mirrorlist.bak'
        shutil.copy2(src, dst)

    def mirrorlist_update(self):
        cmd = subprocess.run([
                'reflector',
                '--latest', '20',
                '--protocol', 'https',
                '--connection-timeout', '5',
                '--sort', 'rate',
                '--save', '/etc/pacman.d/mirrorlist'])
        if cmd.returncode == 0:
            print(f'[+] Pacman: Mirrorlist update')
        else:
            print(f'[-] Pacman: Mirrorlist update [{cmd.returncode}]')
            exit()


class Install():

    """Install main system packages"""

    def __init__(self):
        super(Install, self).__init__()

    def install(self):
        cmd = subprocess.run([
                'pacstrap',
                '-C', pacmanconf,
                '/mnt',
                'linux-hardened',
                'linux-hardened-headers',
                'linux-firmware',
                'base',
                'base-devel',
                'btrfs-progs',
                'efibootmgr',
                'git',
                'github-cli',
                'grub',
                'grub-btrfs',
                'networkmanager',
                'ntp',
                'openssh',
                'python',
                'reflector',
                'snapper',
                'vim',
                'virtualbox-guest-utils']) # TODO: remove
        if cmd.returncode == 0:
            print(f'[+] Pacman: System install')
        else:
            print(f'[-] Pacman: System install [{cmd.returncode}]')
            exit()

    def install_dmi(self):
        # TODO
        # Install DMI packages
        # pacstrap -C ${pacmanconf} /mnt virtualbox-guest-utils
        # pacstrap -C ${pacmancfg} /mnt open-vm-tools
        pass


class Chroot():

    """Change root to system"""

    def __init__(self):
        super(Chroot, self).__init__()

    def pacman_cfg(self):
        # TODO
        # pacman.conf
        # src=""
        # dst=""
        # cp -f ${pacmanconf} /mnt/etc/pacman.conf
        # chown ${username} /mnt/etc/pacman.conf
        pass

    def copy_script(self):
        src='/media/sf_arch/chroot/'
        dst='/mnt/temporary'
        shutil.copytree(src, dst)

    def chroot(self):
        os.chmod('/mnt/temporary/chroot.py', 0o755)
        cmd = subprocess.run([
                'arch-chroot',
                '/mnt',
                './temporary/chroot.py'])
        if cmd.returncode == 0:
            print(f'[+] Chroot')
        else:
            print(f'[-] Chroot [{cmd.returncode}]')
            exit(cmd.returncode)

    def clear(self):
        shutil.rmtree('/mnt/temporary')


m = Mirror()
m.mirrorlist_bak()
m.mirrorlist_update()

i = Install()
i.install()
i.install_dmi()

c = Chroot()
c.pacman_cfg()
c.copy_script()
c.chroot()
c.clear()
