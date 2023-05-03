#!/usr/bin/env python3
"""
Author : FName SName <mail@domain.com>
Date   : 2023 April
"""


import argparse
import configparser
import getpass
import os
import sys

from src.lang import Python
from src.lang import Ruby
from src.lang import Rust

from src.post import AurHelper
from src.post import Bitwarden
from src.post import Customization
from src.post import GitSetup
from src.post import Git
from src.post import Dotfiles
from src.post import Initialize
from src.post import Network
from src.post import SecureShell
from src.post import Pacman
from src.post import Services
from src.post import WiFi
from src.post import Zsh
from src.post import Finalize


class Main():

    """Arch post-installation setup"""

    @staticmethod
    def initialize():
        init = Initialize()
        init.sys_timezone(timezone)
        init.sys_clock()

        while True:
            if Network().check(network_ip, network_port):
                break
            else:
                wifi = WiFi()
                wifi.toggle(network_toggle)
                wifi.connect(network_ssid, network_key)

    @staticmethod
    def arch_user_repository():
        aur = AurHelper(user, aurhelper)
        aur.make_dir()
        aur.clone()
        aur.make_pkg()

    @staticmethod
    def password_manager():
        rbw = Bitwarden()
        rbw.install(aurhelper)
        while True:
            if rbw.register(bw_mail, bw_lock):
                break
            user_in = input(f'Failed to authenticate. Retry? Y/N ')
            if user_in.upper() == 'N':
                sys.exit(1)

    @staticmethod
    def ssh():
        agent = SecureShell(user, current_dir)
        agent.config()
        agent.service_set()
        agent.service_start()
        agent.key_gen(ssh_key, git_mail)
        agent.key_add()

    @staticmethod
    def git():
        gh = GitSetup()
        gh_user = gh.get_user(git_user)
        gh.auth_login(git_token)
        gh.auth_status()
        gh.add_pubkey(user, git_pubkey)
        gh.known_hosts()
        gh.ssh_test()
        gh.config(gh_user, git_mail)

        for repo in repositories:
            r = Git(user, gh_user, repo)
            r.repo_clone()
            r.repo_chdir()
            r.repo_cfg()

        dots = Dotfiles(user, gh_user)
        dots.temp_dir()
        dots.move()
        dots.repo_clone()
        dots.repo_chdir()
        dots.repo_cfg()
        dots.move_back()

    @staticmethod
    def installation():
        pacman = Pacman()
        pacman.install(current_dir)
        #AurHelper.install(package)

    @staticmethod
    def set_zsh():
        zsh = Zsh(user)
        zsh.set()
        zsh.config()
        zsh.tools()

    @staticmethod
    def systemd():
        sysctl = Services()
        sysctl.enable()

    @staticmethod
    def customize():
        c = Customization()
        c.background(user)
        #c.pacman()
        c.pipewire()
        c.wayland()
        c.spotify()
        c.xdg_dirs(user)

    @staticmethod
    def development():
        python = Python()
        python.venv()
        #python.modules(python_modules)
        ruby = Ruby()
        ruby.install()
        ruby.gems()
        rust = Rust()

    @staticmethod
    def finalize():
        final = Finalize(user)
        final.clean_home()


if __name__ == '__main__':
    """ Initialize argparse """

    uid = os.getuid()
    if uid == 0:
        print(f'[-] Executed as root (UID={uid})')
        sys.exit(1)

    parser = argparse.ArgumentParser(
                prog='python3 setup.py',
                description='Arch post install',
                epilog='TODO'  # TODO
                )
    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read('config.ini')

    aurhelper =        config.get('aur', 'helper')
    bw_mail =           config.get('bitwarden', 'mail')
    bw_url =            config.get('bitwarden', 'url')
    bw_lock =           config.get('bitwarden', 'lock')
    git_mail =           config.get('bitwarden_data', 'github_mail')
    git_user =           config.get('bitwarden_data', 'github_user')
    git_token =          config.get('bitwarden_data', 'github_token')
    spotify_client_id = config.get('bitwarden_data', 'spotify_client_id')
    spotify_secret =    config.get('bitwarden_data', 'spotify_client_secret')
    spotify_device_id = config.get('bitwarden_data', 'spotify_device_id')
    spotify_mail =      config.get('bitwarden_data', 'spotify_mail')
    spotify_user =      config.get('bitwarden_data', 'spotify_user')
    dependencies =      config.get('dependencies', 'dependencies')
    git_pubkey =         config.get('github', 'pubkey')
    network_ip =        config.get('network','ip')
    network_port =      config.get('network','port')
    network_toggle =    config.get('network','wifi')
    network_key =       config.get('network','wifi_key')
    network_ssid =      config.get('network','wifi_ssid')
    repositories =      config.get('repositories','repositories').split(', ')
    ssh_key =           config.get('ssh','key')
    timezone =          config.get('timezone', 'timezone')

    user = getpass.getuser()
    current_dir = os.getcwd()

    Main.initialize()
    Main.arch_user_repository()
    Main.password_manager()
    Main.ssh()
    Main.git()
    Main.installation()
    Main.set_zsh()
    #Main.systemd()
    Main.customize()
    #Main.development()
    Main.finalize()
