#!/usr/bin/env python

import os
import shutil
import sys

# TODO: don't hard code the user
HOME = "/home/programmer"

def install(relative_path: str, dst: str):
  os.makedirs(dst, exist_ok=True)

  configuration_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), relative_path)
  src_path = os.path.abspath(configuration_path)
  dst_path = f"{dst}/{os.path.basename(configuration_path)}"
  real_dst_path = os.path.realpath(dst_path)

  should_symlink = True

  if os.path.exists(real_dst_path):
    if src_path != real_dst_path:
      print(src_path)
      print(real_dst_path)
      print("path already exists", real_dst_path)
      answer = input("Continue? [y/n]: ").lower()
      if answer == "y":
        should_symlink = True
        print(f"moving {dst_path} -> {REMOVED_PATH} to replace it")
        shutil.move(dst_path, REMOVED_PATH)
      else:
        should_symlink = False
    else:
      print(f"{src_path} -> {dst_path} already linked")
      should_symlink = False

  if should_symlink:
    os.symlink(src_path, dst_path, target_is_directory=os.path.isdir(src_path))
    print(f"{src_path} -> {dst_path}")

def install_directory(directory_path: str, dst_path: str):
  for entry in os.scandir(directory_path):
    install(entry.path, dst_path)

if __name__ == '__main__':
  subcommand = sys.argv[1] if len(sys.argv) > 1 else ""
  match subcommand:
    case "link":
      REMOVED_PATH = f"{HOME}/Configurations/Removed"
      if os.getuid() == 0:
        if not os.path.exists(REMOVED_PATH):
          print("first run this without sudo")
          exit(1)

        install_directory("Scripts", "/usr/local/bin")
        install_directory("Xorg", "/usr/share/X11/xorg.conf.d")
      else:
        os.makedirs(REMOVED_PATH, exist_ok=True)

        install_directory("Config", f"{HOME}/.config")
        install_directory("Home", f"{HOME}")
        install("Wallpapers", f"{HOME}")
        install("Scripts", f"{HOME}")

        print("you can now run this as sudo to install the rest")
    case "update":
      pass
    case "":
      print(f"Usage: {sys.argv[0]} [link|update]")
